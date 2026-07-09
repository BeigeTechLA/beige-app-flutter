# Login Full-Screen Loader Plan

Add a full-screen Lottie loader shown during the login API call on `LoginScreen`. Hide on success (proceed with redirect) or error (show existing `TopMessage`). Loader wraps the screen as a translucent scrim so the form remains dimly visible.

## Decisions (confirmed)

| Topic | Choice |
|-------|--------|
| Backdrop | Translucent scrim (dim over-form) |
| Widget scope | New reusable widget in `lib/shared/widgets/` |
| Mount point | `Stack` inside `Scaffold.body` on `LoginScreen` |
| Asset | Add new `AppAssets.lottieCircleLoader`; keep existing `lottieLoader` untouched |

## Files touched

1. `lib/app/assets.dart` — add `lottieCircleLoader` constant.
2. `lib/shared/widgets/app_full_screen_loader.dart` — **new** reusable overlay widget.
3. `lib/features/auth/presentation/screens/login_screen.dart` — wrap body in `Stack`, mount loader when `LoginStatus.loading`.

No changes to `LoginNotifier` / `LoginState` — existing `LoginStatus.loading | success | error` is sufficient.

## Widget contract

```dart
// lib/shared/widgets/app_full_screen_loader.dart
class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({
    super.key,
    this.size = 140,
    this.scrimOpacity = 0.6,
  });

  final double size;
  final double scrimOpacity;
}
```

Composition:
- `Positioned.fill` with `ColoredBox(AppColors.black.withValues(alpha: scrimOpacity))`.
- `AbsorbPointer` wrapping the scrim so taps behind the loader do nothing.
- Centered `Lottie.asset(AppAssets.lottieCircleLoader, width: size, height: size, repeat: true)`.
- No dismiss handler — visibility owned by caller (state-driven).

## Login screen wiring

Current: `Scaffold.body = SingleChildScrollView(...)` + `bottomNavigationBar`.

Change:
```dart
final isLoggingIn = loginState.status == LoginStatus.loading;

return Scaffold(
  body: Stack(
    children: [
      SingleChildScrollView(...existing tree...),
      if (isLoggingIn) const AppFullScreenLoader(),
    ],
  ),
  bottomNavigationBar: ...,
);
```

- Existing `ref.listen` already handles `success → context.goNamed(RouteNames.home)` and `error → TopMessage.show(...)`. No change needed.
- Login button's existing `isLoggingIn` disable stays — belt + suspenders once the loader also blocks touch.
- Keyboard: not explicitly dismissed; `AbsorbPointer` on the scrim prevents field re-focus.

## Asset entry

```dart
// lib/app/assets.dart
static const String lottieCircleLoader = '$_lottie/circleLoader.json';
```

`pubspec.yaml` already includes `assets/lottie/` — no manifest edit needed.

## Edge cases

- **Very fast API response**: loader may flash briefly. Acceptable; no min-display debounce added unless requested.
- **Error → user retries**: `LoginNotifier` re-enters `loading`, loader shows again. No manual reset required.
- **Back button during loading**: system back still pops the route. Not blocked — user can escape a stuck request. Flag if you want it blocked.
- **Screen dispose mid-request**: `AppFullScreenLoader` is a `StatelessWidget`; Lottie controller torn down with the widget. No leak.

## Out of scope

- Reusing the loader on signup / OTP / forgot-password / reset screens — widget is designed for reuse but this plan only wires login. Follow-up ticket to expand.
- Global router-level loader mount — rejected in favor of screen-local Stack for now.
- Replacing existing `AppLoader` (small 70x70) — kept as-is.

## Test plan (manual)

1. Enter valid credentials → tap Login → verify Lottie loader appears, scrim dims form, taps blocked.
2. Success → loader disappears as navigation to home fires.
3. Invalid credentials → loader disappears, `TopMessage` shows error.
4. Airplane mode → network exception path shows loader then error message.
5. Rotate device / large text scale → loader stays centered.