# GoRouter + Riverpod ProviderScope — Batch-Wise Migration Plan

> **Phase:** 3 (Foundations)
> **Created:** 2026-04-19
> **Aligned to:** MIGRATION_PLAN.md, MIGRATION_RULES.md, FLUTTER_BASE_GUIDELINES.md
> **Constraint:** Max 5–8 files per commit. `flutter analyze` zero errors after each batch. App must remain shippable.

---

## Prerequisites (Already Complete)

| Item | Status |
|------|--------|
| `flutter_riverpod: ^2.6.1` in pubspec | ✅ |
| `go_router: ^14.8.1` in pubspec | ✅ |
| `dartz: ^0.10.1` in pubspec | ✅ |
| Design tokens (`lib/app/colors.dart`, etc.) | ✅ |
| Network layer (`lib/core/network/`) | ✅ |
| Core providers (`lib/core/providers/core_providers.dart`) | ✅ |
| Phase 2 bug fixes committed | ✅ |

---

## Current State

- `main.dart` uses `MaterialApp` with `home:` property (no router)
- Auth guard: boot-time `SharedPreferences.getBool('isLoggedIn')` only — no runtime redirect
- `MainScreen` uses destructive `switch(_selectedIndex)` — tab state lost on every switch
- 135 Navigator calls across 38 files (62 push, 54 pop, 11 pushReplacement, 7 pushAndRemoveUntil)
- 27 unique screens
- Global `navigatorKey` and `scaffoldMessengerKey` declared at module level

---

## Batch Overview

| Batch | Description | Files Changed | New Files | Commit Type | Status | Commit |
|-------|-------------|--------------|-----------|-------------|--------|--------|
| **1** | Route names + GoRouter config | 0 modified | 2 created | `refactor(navigation)` | ✅ Done | `1e2a8b8` |
| **2** | App widget + ProviderScope + wire router | 2 modified | 1 created | `refactor(navigation)` | ✅ Done | (pre-existing) |
| **3** | StatefulShellRoute for bottom nav | 1 modified | 0 | `refactor(navigation)` | ✅ Done | (pre-existing) |
| **4** | Auth redirect guard in GoRouter | 2 modified | 1 created | `refactor(auth)` | ✅ Done | — |
| **5** | Migrate auth screen Navigator calls (6 files) | 6 modified | 0 | `refactor(auth)` | ✅ Done | `e189160` |
| **6** | Migrate splash + onboarding Navigator calls | 2 modified | 0 | `refactor(navigation)` | ✅ Done | `c51ade5` |
| **7** | Migrate home screen Navigator calls (part 1) | 3 modified | 0 | `refactor(navigation)` | ✅ Done | — |
| **8** | Migrate home screen Navigator calls (part 2) | 3 modified | 0 | `refactor(navigation)` | ✅ Done | — |
| **9** | Migrate booking flow Navigator calls (part 1) | 5 modified | 0 | `refactor(navigation)` | ✅ Done | — |
| **10** | Migrate booking flow Navigator calls (part 2) | 4 modified | 0 | `refactor(navigation)` | ✅ Done | — |
| **11** | Migrate profile Navigator calls | 5 modified | 0 | `refactor(navigation)` | ⬜ Pending | — |
| **12** | Migrate remaining profile + cleanup | 5 modified | 0 | `refactor(navigation)` | ⬜ Pending | — |
| **13** | Remove global navigator keys + dead code | 2 modified | 0 | `refactor(navigation)` | ⬜ Pending | — |

---

## Batch 1 — Route Names + GoRouter Configuration ✅

> **Completed:** 2026-04-19 | **Commit:** `1e2a8b8`
> **Notes:** 39 screens mapped (not 27 — audit undercounted). All constructor param types verified (most IDs are `int`). `_MainShell` widget defined in router.dart for Batch 3 use. `extra` used for multi-param screens, `pathParameters` for single IDs.

**Goal:** Create route definitions and GoRouter config. No wiring yet — just the files.

### Create: `lib/app/route_names.dart`

```dart
abstract class RouteNames {
  // Auth
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const signup = 'signup';
  static const forgotPassword = 'forgot_password';
  static const forgotOtp = 'forgot_otp';
  static const resetPassword = 'reset_password';
  static const passwordSuccess = 'password_success';

  // Main shell tabs
  static const home = 'home';
  static const bookShoot = 'book_shoot';
  static const myShoots = 'my_shoots';
  static const messages = 'messages';

  // Home sub-screens
  static const viewProfile = 'view_profile';
  static const recommendedDetails = 'recommended_details';
  static const changeLocation = 'change_location';
  static const findingPerfect = 'finding_perfect';
  static const paymentMethod = 'payment_method';

  // New Booking Flow
  static const contentType = 'content_type';
  static const videoShootType = 'video_shoot_type';
  static const shootDateTime = 'shoot_date_time';
  static const moreDetails = 'more_details';
  static const crewSizeMatching = 'crew_size_matching';
  static const selectDreamTeam = 'select_dream_team';
  static const reviewConfirm = 'review_confirm';
  static const paymentSuccess = 'payment_success';

  // Booking Management
  static const bookingEventSummary = 'booking_event_summary';
  static const manageBooking = 'manage_booking';
  static const bookingReviewConfirm = 'booking_review_confirm';
  static const cancelBooking = 'cancel_booking';
  static const selectBookingType = 'select_booking_type';
  static const shootUpdated = 'shoot_updated';

  // Profile
  static const profile = 'profile';
  static const editProfile = 'edit_profile';
  static const changePassword = 'change_password';
  static const profileOtp = 'profile_otp';
  static const profileNewPassword = 'profile_new_password';
  static const bookingHistory = 'booking_history';
  static const favourites = 'favourites';
  static const appPreferences = 'app_preferences';
  static const deleteAccount = 'delete_account';
  static const deleteAccountOtp = 'delete_account_otp';
}
```

### Create: `lib/app/router.dart`

GoRouter with all routes defined. Uses `StatefulShellRoute.indexedStack` for bottom nav tabs.

**Route tree:**

```
/splash
/onboarding
/login
/signup
/forgot-password
/forgot-otp
/reset-password
/password-success
/                          ← StatefulShellRoute (bottom nav)
  ├── /home                ← Tab 0: NewHomeScreen
  ├── /book-shoot          ← Tab 1: ContentTypeScreen(fromHome: false)
  ├── /my-shoots           ← Tab 2: BookingAllScreen
  └── /messages            ← Tab 3: Messages placeholder
/view-profile/:id          ← pushed on top (no bottom nav)
/recommended/:id
/change-location
/finding-perfect
/payment-method
/content-type
/video-shoot-type/:shootTypeId
/shoot-date-time/:bookingId
/more-details/:bookingId
/crew-size-matching/:bookingId
/select-dream-team/:bookingId
/review-confirm/:bookingId
/payment-success/:bookingId
/booking-summary/:bookingId
/manage-booking/:bookingId
/booking-review-confirm/:bookingId
/cancel-booking/:bookingId
/select-booking-type/:bookingId
/shoot-updated
/profile
/edit-profile
/change-password
/profile-otp
/profile-new-password
/booking-history
/favourites
/app-preferences
/delete-account
/delete-account-otp
```

### Files:
| Action | File | Lines |
|--------|------|-------|
| Create | `lib/app/route_names.dart` | ~55 |
| Create | `lib/app/router.dart` | ~250 |

### Commit message:
```
refactor(navigation): add RouteNames constants and GoRouter configuration

All 27 screens mapped to named routes. StatefulShellRoute.indexedStack
configured for bottom nav tabs. Auth routes outside shell. No wiring yet.
```

### Verify:
- `flutter analyze` — zero errors
- App still runs unchanged (router not wired yet)

---

## Batch 2 — App Widget + ProviderScope + Wire Router

**Goal:** Create `App` widget wrapping `ProviderScope` + `MaterialApp.router`. Update `main.dart` to use it.

### Create: `lib/app/app.dart`

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BEIGE',
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
```

### Modify: `lib/main.dart`

**Before:**
```dart
runApp(MyApp(isLoggedIn: isLoggedIn));
// ...
class MyApp extends StatefulWidget { ... }
```

**After:**
```dart
Future<void> startApp(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(environment);
  Stripe.publishableKey = Env.stripePublishableKey;
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}
```

- Remove `MyApp` class entirely
- Remove `InternetHelper.init()` call (broken anyway — Phase 2 confirmed)
- Keep `navigatorKey` and `scaffoldMessengerKey` temporarily (removed in Batch 13)

### Files:
| Action | File |
|--------|------|
| Create | `lib/app/app.dart` |
| Modify | `lib/main.dart` |

### Commit message:
```
refactor(navigation): wire ProviderScope and MaterialApp.router in main.dart

Replace MyApp StatefulWidget with App + ProviderScope wrapping.
SharedPreferences injected via provider override at startup.
GoRouter now controls initial route via redirect logic.
```

### Verify:
- `flutter analyze` — zero errors
- `flutter run` — app launches to splash screen via GoRouter
- Bottom nav still works (MainScreen still intact as route target)

---

## Batch 3 — StatefulShellRoute for Bottom Nav

**Goal:** Replace destructive `switch(_selectedIndex)` in MainScreen with GoRouter's `StatefulShellRoute.indexedStack`. Tab state preserved on switch.

### Modify: `lib/MainScreen.dart`

**Before:** `switch` on `_selectedIndex`, rebuild entire page
**After:** Shell widget receives `child` from GoRouter, uses `ScaffoldWithNavBar` pattern

```dart
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,  // IndexedStack managed by GoRouter
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        // ... same items as before
      ),
    );
  }
}
```

### Update router.dart:
Wire `StatefulShellRoute.indexedStack` with `MainShell` as builder.

### Files:
| Action | File |
|--------|------|
| Modify | `lib/MainScreen.dart` |
| Modify | `lib/app/router.dart` (if not already configured in Batch 1) |

### Commit message:
```
refactor(navigation): replace destructive tab switch with StatefulShellRoute.indexedStack

Tab state now preserved on switch. No more rebuild-on-tab-change.
MainScreen renamed to MainShell, receives StatefulNavigationShell from GoRouter.
```

### Verify:
- All 4 tabs switch without losing state
- Back button works correctly from tab sub-screens
- `flutter analyze` — zero errors

---

## Batch 4 — Auth Redirect Guard

**Goal:** Add GoRouter `redirect` logic for auth state. Replace boot-time-only check with runtime redirect.

### Create: `lib/core/providers/auth_state_provider.dart`

```dart
final authStateProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('isLoggedIn') ?? false;
});
```

### Modify: `lib/app/router.dart`

Add `redirect` callback:
```dart
redirect: (context, state) {
  final isLoggedIn = /* read auth state */;
  final isAuthRoute = state.matchedLocation.startsWith('/login') ||
      state.matchedLocation.startsWith('/signup') || ...;
  final isSplash = state.matchedLocation == '/splash';
  final isOnboarding = state.matchedLocation == '/onboarding';

  if (!isLoggedIn && !isAuthRoute && !isSplash && !isOnboarding) {
    return '/login';
  }
  if (isLoggedIn && isAuthRoute) {
    return '/';
  }
  return null;
},
```

### Files:
| Action | File |
|--------|------|
| Create | `lib/core/providers/auth_state_provider.dart` |
| Modify | `lib/app/router.dart` |

### Commit message:
```
refactor(auth): add GoRouter redirect guard with auth state provider

Runtime auth redirect — unauthenticated users sent to login,
authenticated users skip auth screens. Replaces boot-time-only check.
```

### Verify:
- Logged-out user → redirected to login
- Logged-in user → goes to home
- Login → redirect to home
- Logout → redirect to login
- `flutter analyze` — zero errors

---

## Batch 5 — Migrate Auth Screen Navigator Calls

**Goal:** Replace all `Navigator.push/pop/pushReplacement/pushAndRemoveUntil` in auth screens with GoRouter equivalents.

### Files to modify (6):
| File | Navigator Calls | Migration |
|------|----------------|-----------|
| `lib/auth/new_login_screen.dart` | 2 push, 1 pushAndRemoveUntil | `context.goNamed`, `context.pushNamed` |
| `lib/auth/new_sing_up_screen.dart` | 1 push, 1 pushReplacement, 2 pop | `context.pushNamed`, `context.goNamed`, `context.pop` |
| `lib/auth/new_forgot_passwrod_screen.dart` | 1 push, 1 pop | `context.pushNamed`, `context.pop` |
| `lib/auth/new_forgot_otp_screen.dart` | 1 push, 1 pushReplacement, 1 pop | `context.pushNamed`, `context.goNamed`, `context.pop` |
| `lib/auth/new_new_passwrod_screen.dart` | 1 pushReplacement, 1 pop | `context.goNamed`, `context.pop` |
| `lib/auth/Password_successfull.dart` | 1 pushAndRemoveUntil | `context.goNamed` (go replaces entire stack) |

### Migration patterns:
```dart
// BEFORE: Navigator.pushAndRemoveUntil → Mainscreen
Navigator.pushAndRemoveUntil(context,
  MaterialPageRoute(builder: (_) => Mainscreen()), (route) => false);

// AFTER: context.go replaces entire stack
context.goNamed(RouteNames.home);

// BEFORE: Navigator.push
Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotOtpScreen()));

// AFTER: context.pushNamed
context.pushNamed(RouteNames.forgotOtp, extra: {'email': email});

// BEFORE: Navigator.pop
Navigator.pop(context);

// AFTER: context.pop
context.pop();
```

### Commit message:
```
refactor(auth): migrate 6 auth screens from Navigator to GoRouter

Replace all Navigator.push/pop/pushReplacement/pushAndRemoveUntil
with context.goNamed/pushNamed/pop. 10 Navigator calls migrated.
```

### Verify:
- Login → Home flow works
- Signup → OTP → Home flow works
- Forgot password → OTP → Reset → Success → Login flow works
- Back button works on all auth screens
- `flutter analyze` — zero errors

---

## Batch 6 — Migrate Splash + Onboarding

**Goal:** Replace Navigator calls in splash and onboarding screens.

### Files to modify (2):
| File | Navigator Calls |
|------|----------------|
| `lib/SplashScreen/splash_screen.dart` | 1 pushReplacement |
| `lib/OnbodingScreen/onboding_screen.dart` | 2 push, 1 pushReplacement |

### Commit message:
```
refactor(navigation): migrate splash and onboarding to GoRouter
```

---

## Batch 7 — Migrate Home Screen Navigator Calls (Part 1)

**Goal:** Migrate first half of home-related screens. `new_home_screen.dart` has 18 push calls — split across Batch 7 and 8.

### Files to modify (3):
| File | Navigator Calls |
|------|----------------|
| `lib/Home/New_Home/new_home_screen.dart` | 18 push (migrate first 9) |
| `lib/Home/HomeSekect/Home_view_profile.dart` | 1 push, 1 pop |
| `lib/Home/HomeSekect/recommended_detils_screen.dart` | 1 push, 1 pop |

### Commit message:
```
refactor(navigation): migrate home screen Navigator calls (part 1 of 2)
```

---

## Batch 8 — Migrate Home Screen Navigator Calls (Part 2)

### Files to modify (3):
| File | Navigator Calls |
|------|----------------|
| `lib/Home/New_Home/new_home_screen.dart` | remaining 9 push calls |
| `lib/Home/HomeSekect/change_location_screen.dart` | 1 pop |
| `lib/Home/HomeSekect/finding_the_perfect_screen.dart` | 1 pushReplacement |

### Commit message:
```
refactor(navigation): migrate home screen Navigator calls (part 2 of 2)
```

---

## Batch 9 — Migrate New Booking Flow (Part 1)

### Files to modify (5):
| File | Navigator Calls |
|------|----------------|
| `lib/Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart` | 2 push, 1 pop |
| `lib/Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart` | 1 push, 2 pop |
| `lib/Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | 1 push, 3 pop |
| `lib/Home/NewBookingFlow/More_Details/more_details_screen.dart` | 1 push, 2 pop |
| `lib/Home/NewBookingFlow/More_Details/crew_size_matching_screen.dart` | 1 push, 2 pop |

### Commit message:
```
refactor(navigation): migrate new booking flow screens to GoRouter (part 1)
```

---

## Batch 10 — Migrate New Booking Flow (Part 2) + Payment

### Files to modify (5):
| File | Navigator Calls |
|------|----------------|
| `lib/Home/NewBookingFlow/More_Details/select_your_dream_team.dart` | 4 push, 1 pushReplacement, 5 pop |
| `lib/Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart` | 1 push, 1 pushReplacement, 1 pop |
| `lib/Home/NewBookingFlow/Book_Confirm/PaymentSuccessScreen.dart` | 2 pushAndRemoveUntil |
| `lib/Home/HomeSekect/payment_method.dart` | 1 push, 1 pop |

### Commit message:
```
refactor(navigation): migrate booking flow part 2 + payment screens to GoRouter
```

---

## Batch 11 — Migrate Booking Management

### Files to modify (5 — within limit):
| File | Navigator Calls |
|------|----------------|
| `lib/Booking/booking_all_screen.dart` | 3 push, 1 pop |
| `lib/Booking/upcoming_booking_event_summary.dart` | 1 push, 2 pop |
| `lib/Booking/upcoming_event_summary_managebooking.dart` | 2 pushReplacement, 1 pop |
| `lib/Booking/bookin_review_confirm.dart` | 1 push, 1 pop |
| `lib/Booking/cancel_booking.dart` | 1 pushReplacement, 1 pop |

### Remaining booking files (moved to Batch 12 if needed):
| File | Navigator Calls |
|------|----------------|
| `lib/Booking/MY_SelectBookingType.dart` | 2 push, 3 pop |
| `lib/Booking/Shoot_updated_screen.dart` | 1 pushAndRemoveUntil |

### Commit message:
```
refactor(navigation): migrate booking management screens to GoRouter
```

---

## Batch 12 — Migrate Profile Screens + Remaining Booking

### Files to modify (5):
| File | Navigator Calls |
|------|----------------|
| `lib/Booking/MY_SelectBookingType.dart` | 2 push, 3 pop |
| `lib/Booking/Shoot_updated_screen.dart` | 1 pushAndRemoveUntil |
| `lib/MyProfile/my_profile.dart` | 4 push, 1 pushAndRemoveUntil, 2 pop |
| `lib/MyProfile/edit_profile.dart` | 3 push, 5 pop |
| `lib/MyProfile/app_preferences.dart` | 1 push, 1 pop |

### Commit message:
```
refactor(navigation): migrate remaining booking + profile screens (part 1)
```

---

## Batch 13 — Migrate Remaining Profile Screens

### Files to modify (5):
| File | Navigator Calls |
|------|----------------|
| `lib/MyProfile/Change_Password_screen.dart` | 2 push, 1 pop |
| `lib/MyProfile/myprofile_enter_otp_screen.dart` | 1 push, 1 pop |
| `lib/MyProfile/myprofile_new_password_screen.dart` | 2 pop |
| `lib/MyProfile/Booking_History_screen.dart` | 1 pop |
| `lib/MyProfile/Favourite_screen.dart` | 1 pop |

### Commit message:
```
refactor(navigation): migrate remaining profile screens to GoRouter
```

---

## Batch 14 — Migrate Delete Account + Final Cleanup

### Files to modify (4):
| File | Navigator Calls |
|------|----------------|
| `lib/MyProfile/DeleteAccount/delete_account.dart` | 1 push, 1 pop |
| `lib/MyProfile/DeleteAccount/delete_account_otp_screen.dart` | 1 pushAndRemoveUntil, 1 pop |
| `lib/main.dart` | Remove global `navigatorKey`, `scaffoldMessengerKey` |
| `MIGRATION_LOG.md` | Log GoRouter + Riverpod migration completion |

### Commit message:
```
refactor(navigation): complete GoRouter migration — remove global navigator keys
```

### Final Verify:
- All 27 screens reachable via GoRouter
- Zero `Navigator.push/pop` calls remaining (grep verify)
- All tab switches preserve state
- Auth redirect works at runtime
- Back button works on all screens
- `flutter analyze` — zero errors
- `flutter run` — full app functional

---

## Navigation Pattern Reference

### Replacement Cheat Sheet

| Old Pattern | New Pattern | When |
|-------------|-------------|------|
| `Navigator.push(ctx, MaterialPageRoute(builder: (_) => Screen()))` | `context.pushNamed(RouteNames.screen)` | Push on stack (back button returns) |
| `Navigator.pushReplacement(ctx, MaterialPageRoute(...))` | `context.goNamed(RouteNames.screen)` | Replace current screen |
| `Navigator.pushAndRemoveUntil(ctx, route, (r) => false)` | `context.goNamed(RouteNames.home)` | Clear stack (go to root) |
| `Navigator.pop(ctx)` | `context.pop()` | Go back |
| `Navigator.pop(ctx, result)` | `context.pop(result)` | Return value to previous screen |
| `await Navigator.push(...)` | `final result = await context.pushNamed(...)` | Push and wait for return value |

### Passing Data

```dart
// Path parameters (IDs)
context.pushNamed(RouteNames.viewProfile, pathParameters: {'id': creativeId});

// Extra data (complex objects — avoid for deep links)
context.pushNamed(RouteNames.reviewConfirm, extra: bookingData);

// Query parameters (filters, optional params)
context.pushNamed(RouteNames.myShoots, queryParameters: {'filter': 'upcoming'});
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Breaking existing navigation during migration | Old `Navigator` and GoRouter coexist. Migrate one screen at a time. |
| Tab state lost during GoRouter wiring | Test tab switching immediately after Batch 3 |
| Auth redirect loop | Test login/logout cycle after Batch 4. Ensure public routes excluded. |
| `new_home_screen.dart` has 18 Navigator calls | Split into 2 batches (7 & 8). Test after each. |
| `select_your_dream_team.dart` has 10 Navigator calls | Handle in single batch (10). Complex but contained to one file. |
| Screens passing data via constructor | Use `extra` parameter for complex objects. Path params for IDs. |
| `BuildContext` used after `await` | GoRouter's `context.goNamed` is safer but still check `mounted` where needed. |

---

## Estimated Effort

| Batch | Est. Time |
|-------|-----------|
| 1–2 (Foundation) | 0.5 day |
| 3 (Shell route) | 0.5 day |
| 4 (Auth guard) | 0.25 day |
| 5–6 (Auth + Splash) | 0.5 day |
| 7–8 (Home) | 1 day |
| 9–10 (Booking flow) | 1 day |
| 11–14 (Management + Profile + Cleanup) | 1.5 days |
| **Total** | **~4.25 days** |

---

## Success Criteria

- [ ] Zero `Navigator.push` / `Navigator.pushReplacement` / `Navigator.pushAndRemoveUntil` calls in codebase
- [ ] All 27 screens accessible via named routes
- [ ] `ProviderScope` wrapping entire app
- [ ] `StatefulShellRoute.indexedStack` preserving tab state
- [ ] Auth redirect guard functional at runtime
- [ ] `flutter analyze` — zero errors after every batch
- [ ] `flutter run` — app fully functional after every batch
