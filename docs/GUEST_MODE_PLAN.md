# Guest Mode Plan

## Goal
Allow user to skip authentication from onboarding and browse the Home tab as a guest. Any interactive element shows a stylized Login dialog. Guest flag is in-memory only — every cold start re-shows onboarding.

## Scope Summary
| Decision | Choice |
|---|---|
| Guest persistence | In-memory Riverpod state. Not written to `SharedPreferences`. Cold start → splash → onboarding. |
| Entry point | Onboarding "Skip" button (top-right). No new button on login screen. |
| Home API in guest | Skip all API calls. Render static UI only. |
| Bottom nav | All 4 tabs visible. Tapping Book/MyShoots/Messages while guest → `LoginDialog`, no branch switch. |
| Interactive elements (home) | **Only navigation actions guarded** — location chip, profile icon, search field (if it pushes a route), notifications icon, "Book a Shoot" card, creative cards, recommended items. **Scroll / in-page actions stay as-is** — e.g. "Explore Creatives" scrolls to featured section, "Find Your Creative" scrolls to top creatives — no dialog. |
| After login from dialog | Push login screen. On success, clear guest flag. Router redirect lands user on `/` (authed home). Auth back stack cleared. |
| Login dialog design | Match screenshot: frosted glass card, white translucent fill, two stacked pill buttons, "Outfit" font via `AppTextStyles`, fills via `AppColors`. |
| Logout flow | Unchanged. Still goes to login screen. |

---

## Architecture

### 1. New State — `guestModeProvider`
Path: `lib/core/providers/guest_mode_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory guest flag. NOT persisted.
/// True between onboarding "Skip" and successful login.
/// Reset on cold start (always rebuilt as false), on successful login,
/// and on logout (logout already routes to login screen).
class GuestModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;
  void exit() => state = false;
}

final guestModeProvider =
    NotifierProvider<GuestModeNotifier, bool>(GuestModeNotifier.new);
```

### 2. Router Redirect Changes
File: `lib/app/router.dart`

- Add `guestNotifier` ValueNotifier mirroring `guestModeProvider` alongside `authNotifier` and `connNotifier`. Merge into `refreshListenable`.
- Define `_guestAllowedRoutes` — only the home shell branch is allowed while guest:
  ```dart
  const _guestAllowedRoutes = {'/', '/splash', '/onboarding', '/login',
      '/signup', '/forgot-password', '/forgot-otp',
      '/reset-password', '/password-success'};
  ```
- Update redirect logic (line ~123):
  ```dart
  if (!isLoggedIn && !isGuest && !isPublicRoute) return '/login';
  if (!isLoggedIn && isGuest && !_guestAllowedRoutes.contains(location)) {
    return '/';
  }
  ```
- Keep `if (isLoggedIn && isPublicRoute) return '/';` (clears stack after login).

### 3. Onboarding Skip
File: `lib/features/onboarding/presentation/screens/onboarding_screen.dart:186-188`

Change Skip `onTap` from `context.goNamed(RouteNames.login)` to:
```dart
onTap: () {
  ref.read(guestModeProvider.notifier).enter();
  context.goNamed(RouteNames.home);
}
```
(Convert screen to `ConsumerStatefulWidget` if not already.)

### 4. Bottom Nav Guard
File: `lib/app/router.dart` — `_MainShell`

Convert `_MainShell` to `ConsumerWidget`. Wrap `onTap`:
```dart
onTap: (index) {
  final isGuest = ref.read(guestModeProvider);
  if (isGuest && index != 0) {
    showLoginDialog(context);
    return;
  }
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
```

### 5. Home Screen Guards
File: `lib/features/home/presentation/screens/home_screen.dart`

- In notifier wiring (line ~35-41): if `ref.read(guestModeProvider)` is true, skip `repo.getHomeData()` and render static-only state. Simplest path — add a guest branch at the very top of `build()`:
  ```dart
  final isGuest = ref.watch(guestModeProvider);
  if (isGuest) return _buildGuestHome(context);
  ```
- Create `_buildGuestHome(context)` — copy of the static skeleton (header, location chip, search bar, "Book a Shoot" card, section titles, empty placeholders). No `homeNotifierProvider` watch.
- Each `GestureDetector` / `InkWell` / tappable in guest home calls a small helper:
  ```dart
  void _guardOrShowLogin(VoidCallback action) {
    if (ref.read(guestModeProvider)) {
      showLoginDialog(context);
    } else {
      action();
    }
  }
  ```
- Wrap only **navigation** handlers (refs from survey):
  - Line ~581 — location change → `RouteNames.changeLocation` (WRAP)
  - Line ~625 — profile icon → `RouteNames.profile` (WRAP)
  - Line ~2749 — "Book a Shoot" card → `RouteNames.contentType` (WRAP)
  - Creative card → `RouteNames.viewProfile` (WRAP)
  - Recommended creative item → `RouteNames.recommendedDetails` (WRAP)
  - Search field (if it pushes a route) (WRAP)
  - Notifications icon (if it pushes a route) (WRAP)
- **Do NOT wrap scroll / in-page handlers** — they don't leave the home screen, so no auth state is needed:
  - Line ~2751 — "Explore Creatives" (scrolls to featured section) — leave as-is
  - Line ~2753 — "Find Your Creative" (scrolls to top creatives) — leave as-is
  - Any pure-UI toggles, expand/collapse, carousel paging — leave as-is

> Rule of thumb: if `onTap` calls `context.goNamed` / `context.pushNamed` / `Navigator.push`, wrap with `_guardOrShowLogin`. If it only mutates local state or scrolls, leave it alone.

> If guest home diverges significantly from authed home, extract a `GuestHomeView` widget in `lib/features/home/presentation/screens/` to keep `HomeScreen.build` clean.

### 6. Login Dialog Rework
File: `lib/shared/widgets/login_dialog.dart`

Bugs in current file:
- `NewLoginScreen` (line 50) — undefined class. Replace with `context.pushNamed(RouteNames.login)`.
- `ColorCode.*` — not in design tokens. Replace with `AppColors.*`.
- Inline `TextStyle` — replace with `AppTextStyles.*`.
- `withOpacity` deprecated — use `withValues(alpha:)`.

Redesigned widget (matches screenshot — frosted card, two pill buttons, Outfit font via theme):

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/route_names.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

void showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.6),
    builder: (ctx) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                color: AppColors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please Login to Continue',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LoginDialogButton(
                    label: 'Ok',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.pushNamed(RouteNames.login);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _LoginDialogButton(
                    label: 'Cancel',
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _LoginDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LoginDialogButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.popButtonBackground,
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

Verify that `AppColors.popButtonBackground` exists — if not, add token or substitute `AppColors.surface` / nearest equivalent. Same for `AppRadii.full` / `AppRadii.xl`.

### 7. Login Success → Clear Guest
Where successful login sets `isLoggedIn=true` (likely `SharedService` or login notifier success path), also call:
```dart
ref.read(guestModeProvider.notifier).exit();
```
Router redirect handles the rest — `isLoggedIn=true && isPublicRoute('/login') → return '/'`, which clears the stack since `context.pushNamed` returns to root via go.

> Find existing call sites for `SharedService.setLoggedIn(true)` / `authStateProvider.refresh()` and place `guestModeProvider.exit()` next to each.

### 8. Logout
No change. Existing flow clears prefs and navigates to login. Guest flag is already false during authed session.

---

## File-by-File Diff Map

| File | Change |
|---|---|
| `lib/core/providers/guest_mode_provider.dart` | NEW — Notifier + provider |
| `lib/app/router.dart` | Add guest listenable, update redirect, convert `_MainShell` to ConsumerWidget, guard bottom nav onTap |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Skip onTap sets guest=true + navigates to home |
| `lib/features/home/presentation/screens/home_screen.dart` | Guest branch in build, static guest home, guard all tap sites |
| `lib/shared/widgets/login_dialog.dart` | Rewrite — design tokens, Outfit via `AppTextStyles`, fix `NewLoginScreen` typo, use `context.pushNamed(RouteNames.login)` |
| Login success site (TBD — likely in `lib/features/auth/presentation/providers/`) | Call `guestModeProvider.notifier.exit()` after `isLoggedIn=true` |

---

## Edge Cases

1. **Cold start as guest** — Not possible. Guest flag is in-memory; splash → onboarding always. ✓
2. **Deep link while guest** — Router redirect strips protected deep link → returns `/`. ✓
3. **Login dialog opened, user backgrounds app, returns** — Dialog still on top of guest home. No state to restore. ✓
4. **User logs in then logs out** — `authStateProvider` flips to false. Router redirect sends to `/login`. Guest flag is false. Onboarding path remains the only way back into guest. ✓
5. **Network offline as guest** — Static home has no API → no offline gate triggers. Tapping a tab still shows dialog (purely local). Login screen is in `_publicRoutes`. ✓
6. **Tap "Book a Shoot" tab vs. "Book a Shoot" card** — both routed through guards. Dialog appears either way. ✓
7. **In-app navigation from dialog Ok** — `pushNamed` keeps `/` underneath. After login, router redirect clears protected stack (since `isLoggedIn && isPublicRoute → '/'`). Auth back stack reset to home. ✓

---

## Step-by-Step Implementation Order

1. Create `guest_mode_provider.dart`.
2. Rewrite `login_dialog.dart` (resolve token names + lint).
3. Update `router.dart` — add listenable, redirect rule, bottom nav guard.
4. Update onboarding skip handler.
5. Add guest branch + helper in `home_screen.dart`, wrap each tap site.
6. Locate login success site, call `guestModeProvider.notifier.exit()`.
7. `flutter analyze` — fix lints.
8. Manual QA flow:
   - Cold start → onboarding → Skip → home (no API).
   - Tap each of: location, profile icon, search, "Book a Shoot" card, creative card, notifications → dialog appears.
   - Tap Book Shoot / My Shoots / Messages tab → dialog appears, current tab unchanged.
   - Tap Cancel in dialog → returns to home.
   - Tap Ok → login screen → log in → land on authed home, back stack empty.
   - Kill app → relaunch → splash → onboarding (guest flag forgotten). ✓

---

## Open Questions (resolved)

- ~~Persistence?~~ In-memory only.
- ~~Home API?~~ Skip entirely.
- ~~Bottom nav?~~ Show all, guard non-home.
- ~~Dialog Ok?~~ Push login, fresh stack on success.
- ~~Logout?~~ Unchanged.

## Out of Scope
- Backend changes / anonymous API endpoints.
- Persisting "last viewed creative" across login.
- Adding analytics events for guest-mode interactions (can be follow-up).
- Translating dialog text (uses hardcoded EN string — same as current codebase pattern).
