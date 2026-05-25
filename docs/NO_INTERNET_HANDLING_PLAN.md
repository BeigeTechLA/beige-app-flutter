# No-Internet Handling — Execution Plan

**Status:** Proposed
**Owner:** improvments-phase1 branch
**Created:** 2026-05-14

## Goal

Restrict navigation while device is offline and surface a **platform-adaptive** "No Internet" dialog (Cupertino on iOS, Material on Android). Replace the legacy unwired `InternetHelper` with a Riverpod-driven, event-based connectivity layer that integrates with `GoRouter` and the existing `ExceptionHandler` flow.

## Current State (Audit)

| Item | Status |
|------|--------|
| `lib/core/utils/internet_helper.dart` | Exists, **never instantiated/wired**. Uses 3-second DNS polling of `google.com`, deprecated `WillPopScope`, Material-only `AlertDialog`, pushes a full-screen overlay route via `rootNavigatorKey`. |
| `connectivity_plus` package | **Not in pubspec**. |
| `NoInternetException` | Defined in `lib/core/network/exceptions/network_exception.dart`. Mapped from `SocketException` + `DioException.connectionError` inside `ExceptionHandler`. Already surfaces in repo `Either<AppException, T>` returns. |
| GoRouter redirect | Currently checks only `authStateProvider`. No connectivity gate. |
| Platform-specific dialog | Not used anywhere. |

## Decisions (confirmed)

1. **Detection:** event-driven via `connectivity_plus` (no polling). Validate "actual reachability" via DNS lookup only on transition (debounced), not on a timer.
2. **Navigation gate:** GoRouter `redirect` consults connectivity state; offline routes get blocked / pinned to last screen. Public splash + onboarding are exempt (otherwise app stalls on cold start with no network).
3. **Dialog:** `showAdaptiveDialog` with `AlertDialog.adaptive` → Material on Android, Cupertino on iOS. Dismissible with **Retry** action. Auto-dismisses when connectivity returns.
4. **Reactive fallback:** keep `NoInternetException` path — if an API call fails due to transport error while state still says "online" (race), repos still propagate the exception; UI can surface the same dialog via shared helper.
5. **Scope:** app-wide, mounted under `ProviderScope` at `startApp()`. Active from splash onward.

## Architecture

```
ConnectivityService (singleton, event stream)
        │
        ▼
connectivityStreamProvider (StreamProvider<ConnectivityStatus>)
        │
        ├──► connectivityStatusProvider (Provider<ConnectivityStatus>)
        │       │
        │       ├──► routerProvider.redirect()  ── gate navigation
        │       └──► ConnectivityListener widget ── show/hide adaptive dialog
        │
        └──► (reactive) ExceptionHandler still maps NoInternetException
```

### Status enum
```dart
enum ConnectivityStatus { online, offline, unknown }
```

`unknown` covers the first tick before the stream emits (used so splash isn't falsely flagged offline).

## File Plan

### New files
| Path | Purpose |
|------|---------|
| `lib/core/connectivity/connectivity_status.dart` | `ConnectivityStatus` enum. |
| `lib/core/connectivity/connectivity_service.dart` | Wraps `Connectivity().onConnectivityChanged`, debounces, optional DNS reachability check. Exposes `Stream<ConnectivityStatus>` + `Future<ConnectivityStatus> check()`. |
| `lib/core/connectivity/connectivity_providers.dart` | `connectivityServiceProvider`, `connectivityStreamProvider` (StreamProvider), `connectivityStatusProvider` (Provider derived from stream — defaults to `unknown`). |
| `lib/shared/widgets/no_internet_dialog.dart` | `showNoInternetDialog(BuildContext)` using `showAdaptiveDialog` + `AlertDialog.adaptive`. Buttons: **Retry**, **Settings** (optional via `app_settings` — out of scope, defer). |
| `lib/shared/widgets/connectivity_listener.dart` | `ConsumerWidget` that wraps app. Listens to `connectivityStatusProvider`; shows dialog on `online → offline`, pops dialog on `offline → online`. |

### Modified files
| Path | Change |
|------|--------|
| `pubspec.yaml` | Add `connectivity_plus: ^6.1.0` (or latest stable compatible with Flutter SDK in repo). |
| `lib/app/app.dart` | Wrap `MaterialApp.router` child with `ConnectivityListener`. |
| `lib/app/router.dart` | Extend `redirect` to also read `connectivityStatusProvider`. When `offline` and target is not in `_publicRoutes` or the current location, return `null` (stay) — i.e., block forward nav. Splash/onboarding/login allowed so app doesn't deadlock. Bridge via the same `ValueNotifier` pattern as auth, or replace with a combined `Listenable`. |
| `lib/core/utils/internet_helper.dart` | **Delete** after new path is wired (no usages today). |

## Detailed Implementation Steps

### Step 1 — Dependency
Add to `pubspec.yaml`:
```yaml
connectivity_plus: ^6.1.0
```
Run `flutter pub get`.

### Step 2 — Status enum
`lib/core/connectivity/connectivity_status.dart`:
```dart
enum ConnectivityStatus { online, offline, unknown }
```

### Step 3 — Service
`lib/core/connectivity/connectivity_service.dart`:
- Inject `Connectivity` instance (allow override in tests via constructor).
- Map `List<ConnectivityResult>` → `ConnectivityStatus` (any result that is not `none` → `online`).
- Optional: on transition to `online`, run `InternetAddress.lookup('google.com')` to confirm captive-portal isn't masking real outage. Debounced (300ms) to avoid flapping.
- Expose `Stream<ConnectivityStatus> watch()` and `Future<ConnectivityStatus> current()`.

### Step 4 — Providers
`lib/core/connectivity/connectivity_providers.dart`:
```dart
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityServiceProvider).watch();
});

final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityStreamProvider).maybeWhen(
    data: (s) => s,
    orElse: () => ConnectivityStatus.unknown,
  );
});
```

### Step 5 — Adaptive dialog
`lib/shared/widgets/no_internet_dialog.dart`:
```dart
Future<void> showNoInternetDialog(BuildContext context) {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog.adaptive(
      title: const Text('No Internet'),
      content: const Text(
        'You are offline. Please check your connection and try again.',
      ),
      actions: [
        adaptiveAction(
          context: ctx,
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```
- `adaptiveAction` = small helper returning `CupertinoDialogAction` on iOS, `TextButton` on Android.
- Retry simply dismisses; on dismiss, `ConnectivityListener` re-evaluates and re-shows if still offline.

### Step 6 — Connectivity listener widget
`lib/shared/widgets/connectivity_listener.dart`:
- `ConsumerStatefulWidget`. In `build`, `ref.listen(connectivityStatusProvider, ...)`.
- On transition to `offline`: call `showNoInternetDialog(rootNavigatorKey.currentContext!)` guarded by an `_isDialogShowing` flag.
- On transition to `online` while showing: `Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop()`, clear flag.
- Returns `widget.child` unchanged.

### Step 7 — Router gate
In `lib/app/router.dart`:
- Read `connectivityStatusProvider` into a second `ValueNotifier<ConnectivityStatus>`.
- Combine with existing `authNotifier` via a `Listenable.merge([authNotifier, connNotifier])` so `refreshListenable` reacts to both.
- Inside `redirect`:
  ```dart
  if (connNotifier.value == ConnectivityStatus.offline) {
    // Allow splash/onboarding/login so app isn't deadlocked on cold start.
    if (!_publicRoutes.contains(location)) {
      return null; // Stay on current route; dialog blocks UI.
    }
  }
  ```
- Net effect: when offline, programmatic `context.goNamed()` to a protected route is a no-op; user sees the modal dialog over the current screen.

### Step 8 — Wire into app shell
`lib/app/app.dart`:
- Wrap router widget with `ConnectivityListener(child: ...)` so it lives above the navigator and survives route changes.

### Step 9 — Cleanup
- Delete `lib/core/utils/internet_helper.dart` (zero current usages confirmed).
- Search for any stale imports — none expected.

### Step 10 — Tests
- `test/core/connectivity/connectivity_service_test.dart`
  - Happy: stream emits `online` when `Connectivity` reports `wifi`.
  - Edge: rapid flap (`wifi → none → wifi` in <300ms) collapses to single emission.
  - Error: stream surfaces `offline` when `Connectivity` reports `none`.
- `test/shared/widgets/connectivity_listener_test.dart` (widget test)
  - When provider transitions to `offline`, dialog appears.
  - When provider transitions back to `online`, dialog dismisses.
- `test/app/router_connectivity_test.dart`
  - Offline + navigate to protected route → location unchanged.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Cold-start race: app launches offline, splash needs network for auth check → user stuck on splash with dialog. | `ConnectivityStatus.unknown` treated as online for redirect; first real `offline` emission only triggers dialog after splash transition. |
| Captive Wi-Fi (connected but no real internet). | DNS lookup on transition; if lookup fails, override to `offline`. |
| Dialog stacking if listener fires twice. | `_isDialogShowing` flag in `ConnectivityListener`. |
| `rootNavigatorKey.currentContext` null during early frames. | Guard with null check; postpone dialog to next frame via `WidgetsBinding.instance.addPostFrameCallback`. |
| iOS `connectivity_plus` reports `wifi` even with airplane sub-modes. | DNS reachability check covers this. |

## Acceptance Criteria

- [ ] `connectivity_plus` added; `flutter pub get` clean.
- [ ] `flutter analyze` clean (no new warnings).
- [ ] Manual: airplane mode toggled on Android → adaptive Material dialog appears within ~1s; toggled off → dialog dismisses.
- [ ] Manual: airplane mode toggled on iOS → Cupertino-styled dialog appears; toggled off → dialog dismisses.
- [ ] Manual: while offline, tapping any navigation action (bottom tab, push) does not change visible screen.
- [ ] Legacy `internet_helper.dart` removed; no dangling imports.
- [ ] Unit + widget tests added per Step 10 pass.

## Out of Scope

- Persistent offline banner (top-of-screen) — can layer on later if UX wants it.
- Per-request retry queue / offline-first caching.
- "Open Settings" deep link (would need `app_settings` package).
- Onboarding-time connectivity messaging (splash path stays untouched).

## Rollout Order

1. Step 1 (dep) → 2 (enum) → 3 (service) → 4 (providers) — backend layer in isolation.
2. Step 5 (dialog) → 6 (listener) → 8 (mount) — UI surfaces dialog without router changes.
3. Step 7 (router gate) — adds nav restriction once dialog already works.
4. Step 9 (delete legacy) → 10 (tests).

Each step independently committable.
