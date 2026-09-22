# Navigation System Audit — Beige App

> Audited: 2026-04-19
> Target: GoRouter with named routes

---

## 1. CURRENT APPROACH

| Question | Answer |
|---|---|
| Navigation method | Navigator 1.0 — 100% imperative `MaterialPageRoute` |
| Named routes defined? | None — zero `routes:` map in `MaterialApp`, zero `pushNamed()` calls |
| GoRouter present? | No — zero `context.go()` or `context.push()` calls |
| Route configuration location | Nowhere — routes are defined inline at each call site |
| Auth guard | `SharedPreferences.getBool('isLoggedIn')` checked at app start in `startApp()`, result passed as `bool isLoggedIn` to `MyApp` constructor; `home: isLoggedIn ? Mainscreen() : SplashScreen()` |
| Deep linking support | None |
| Redirect logic | None — after login, `pushAndRemoveUntil(Mainscreen(), (route) => false)` clears stack manually |

---

## 2. ROUTE MAP

### Navigation Graph

```
startApp()
  └── SharedPreferences.getBool('isLoggedIn')
        ├── TRUE  → Mainscreen() [bottom nav shell]
        └── FALSE → SplashScreen()
                        └── pushReplacement → OnboardingScreen()
                                ├── push → NewLoginScreen()
                                │           ├── pushAndRemoveUntil → Mainscreen() [after login]
                                │           ├── push → NewForgotPasswrodScreen()
                                │           │           ├── push → NewForgotOtpScreen(email)
                                │           │           │           └── pushReplacement → NewNewPasswrodScreen(email, otp)
                                │           │           │                                   └── pushReplacement → PasswordSuccessfull()
                                │           │           │                                                           └── pushAndRemoveUntil → NewLoginScreen() [after 3s]
                                │           │           └── push → NewLoginScreen()
                                │           └── push → NewSingUpScreen()
                                │                       ├── pushReplacement → NewLoginScreen() [on success]
                                │                       └── push → NewLoginScreen() [already have account]
                                └── pushReplacement → NewLoginScreen()

Mainscreen() [StatefulWidget, BottomNavigationBar]
  ├── Tab 0: NewHomeScreen()
  │     ├── push → HomeViewProfile(id)
  │     │           └── push → ContentTypeScreen(value, specialtyId, fromHome:true)
  │     ├── push → RecommendedDetilsScreen(...)
  │     │           └── push → ContentTypeScreen(...)
  │     ├── push → FindingThePerfectScreen() [pushReplacement → ContentTypeScreen]
  │     ├── push → ContentTypeScreen(fromHome:false) [direct from home cards]
  │     └── await push → ChangeLocationScreen() [returns payload on pop]
  │
  ├── Tab 1: ContentTypeScreen(fromHome:false) [New Booking flow entry]
  │     └── push → VideoShootType(contentTypeId, bookingId)
  │           │     └── [await push] returns bookingId on pop
  │           └── await push → ContentTypeScreen (recursive — sub-type selection)
  │                 └── push → ShootDateTimeScreen(bookingId, contentTypeId, specialtyId)
  │                       └── push → MoreDetailsScreen(bookingId, contentTypeId)
  │                             └── push → CrewSizeMatchingScreen(bookingId, ...)
  │                                   └── push → SelectYourDreamTeam(bookingId, ...)
  │                                         ├── pushReplacement → SelectYourDreamTeam (self — crew refresh)
  │                                         └── push → ReviewConfirmScreen(bookingId)
  │                                               ├── pushReplacement → PaymentSuccessScreen(bookingId, fullName, phone, paymentMethod)
  │                                               │     └── pushAndRemoveUntil → Mainscreen() [clears stack]
  │                                               └── push → PaymentMethodScreen(...)
  │
  ├── Tab 2: BookingAllScreen()
  │     ├── push → UpcomingBookingEventSummary(bookingId, contentType, shootTypeId)
  │     │           └── push → MySelectBookingType(bookingId)
  │     ├── push → UpcomingEventSummaryManagebooking(bookingId, ...)
  │     │           ├── pushReplacement → UpcomingEventSummaryManagebooking (self — refresh)
  │     │           ├── pushReplacement → BookinReviewConfirm(bookingId)
  │     │           └── push → CancelBooking(bookingId, ...)
  │     │                       └── pushReplacement → BookingAllScreen() [after cancel]
  │     └── push → ShootUpdatedScreen()
  │                 └── pushAndRemoveUntil → Mainscreen() [clears stack]
  │
  └── Tab 3: Center(Text("Message")) [placeholder — not implemented]

MyProfile() [accessed from NewHomeScreen via push]
  ├── await push → EditProfile() [returns bool true on save]
  ├── push → BookingHistoryScreen()
  ├── push → FavouriteScreen()
  ├── push → AppPreferences()
  │           └── push → ChangePasswordScreen()
  │                       ├── push → MyProfileEnterOtpScreen()
  │                       │           └── push → MyProfileNewPasswordScreen()
  │                       │                       └── pop(context, true) [signals success]
  │                       └── pop(context, true) [signals success]
  └── pushAndRemoveUntil → SplashScreen() [on logout — clears stack]

DeleteAccount flow (from MyProfile):
  └── push → DeleteAccount()
              └── push → DeleteAccountOtpScreen()
                          └── pushAndRemoveUntil → SplashScreen() [clears stack]
```

### Screen → Constructor Parameters Reference

| Screen | Parameters |
|---|---|
| `SplashScreen` | none |
| `OnboardingScreen` | none |
| `NewLoginScreen` | none |
| `NewSingUpScreen` | none |
| `NewForgotPasswrodScreen` | none |
| `NewForgotOtpScreen` | `required String email` |
| `NewNewPasswrodScreen` | `required String email, required String otp` |
| `PasswordSuccessfull` | none |
| `Mainscreen` | none |
| `NewHomeScreen` | none |
| `HomeViewProfile` | `required int id` |
| `ContentTypeScreen` | `int? value, int? specialtyId, bool fromHome = false` |
| `VideoShootType` | `required int contentTypeId, required int bookingId` |
| `ShootDateTimeScreen` | `required int bookingId, required int contentTypeId, required int specialtyId` |
| `MoreDetailsScreen` | `required int bookingId, required int contentTypeId` |
| `CrewSizeMatchingScreen` | `required int bookingId, ...` |
| `SelectYourDreamTeam` | `required int bookingId, ...` |
| `ReviewConfirmScreen` | `required int bookingId` |
| `PaymentSuccessScreen` | `required int bookingId, required String fullName, required String phone, required String paymentMethod` |
| `BookingAllScreen` | none |
| `UpcomingBookingEventSummary` | `required int bookingId, String? contentType, required int shootTypeId` |
| `UpcomingEventSummaryManagebooking` | `required int bookingId, String? projectName, String? eventDate, String? startTime, String? endTime, String? durationHours, String? location, String? imageUrl, String? contentType, required int shootTypeId, bool? multiDays` |
| `CancelBooking` | `required int bookingId, String? projectName, String? eventDate, String? startTime, String? endTime, String? durationHours, String? location, String? contentType, String? imageUrl` |
| `BookinReviewConfirm` | `required int bookingId` |
| `MySelectBookingType` | `required int bookingId` |
| `ShootUpdatedScreen` | none |
| `MyProfile` | none |
| `EditProfile` | none |
| `BookingHistoryScreen` | none |
| `FavouriteScreen` | none |
| `AppPreferences` | none |
| `ChangePasswordScreen` | none |
| `MyProfileEnterOtpScreen` | none |
| `MyProfileNewPasswordScreen` | none |
| `DeleteAccount` | none |
| `DeleteAccountOtpScreen` | none |
| `FindingThePerfectScreen` | none |
| `RecommendedDetilsScreen` | none |
| `ChangeLocationScreen` | none |
| `PaymentMethodScreen` | none |

---

## 3. NAVIGATION CALLS — FULL INVENTORY

### Total Count

| Type | Count |
|---|---|
| `Navigator.push()` | **62** |
| `Navigator.pushReplacement()` | **11** |
| `Navigator.pushAndRemoveUntil()` | **8** |
| `Navigator.pop()` | **54** |
| `Navigator.pushNamed()` | **0** |
| `context.go() / context.push()` | **0** |
| **TOTAL** | **135** |

All 81 `MaterialPageRoute` usages are inline, anonymous, with no route name.

### `Navigator.push()` — 62 calls

| File | Lines |
|---|---|
| `Home/New_Home/new_home_screen.dart` | 353, 358, 368, 378, 389, 403, 415, 427, 440, 449, 458, 498, 638, 690, 1885, 2754, 2862, 3561 |
| `Home/NewBookingFlow/More_Details/select_your_dream_team.dart` | 877, 1264, 1670, 1723, 2221 |
| `MyProfile/my_profile.dart` | 248, 327, 338, 418 |
| `MyProfile/edit_profile.dart` | 964, 1216, 1259 |
| `Booking/booking_all_screen.dart` | 405, 425, 474 |
| `auth/new_forgot_passwrod_screen.dart` | 72, 416 |
| `Booking/MY_SelectBookingType.dart` | 612, 1775 |
| `OnbodingScreen/onboding_screen.dart` | 136, 167 |
| `auth/new_login_screen.dart` | 374, 532 |
| `Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart` | 154, 246 |
| `Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart` | 1269 |
| `Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | 608 |
| `Home/NewBookingFlow/More_Details/more_details_screen.dart` | 115 |
| `Home/NewBookingFlow/More_Details/crew_size_matching_screen.dart` | 731 |
| `Home/HomeSekect/payment_method.dart` | 312 |
| `Home/HomeSekect/Home_view_profile.dart` | 164 |
| `Home/HomeSekect/recommended_detils_screen.dart` | 166 |
| `MyProfile/myprofile_enter_otp_screen.dart` | 78 |
| `MyProfile/Change_Password_screen.dart` | 44, 111 |
| `MyProfile/DeleteAccount/delete_account.dart` | 56 |
| `auth/new_sing_up_screen.dart` | 1309 |
| `auth/new_forgot_otp_screen.dart` | 541 |
| `Booking/upcoming_booking_event_summary.dart` | 427 |
| `Booking/bookin_review_confirm.dart` | 779 |
| `MyProfile/app_preferences.dart` | 64 |
| `Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart` | 145 |

### `Navigator.pushReplacement()` — 11 calls

| File | Line | Destination |
|---|---|---|
| `SplashScreen/splash_screen.dart` | 62 | `OnboardingScreen` |
| `OnbodingScreen/onboding_screen.dart` | 210 | `NewLoginScreen` |
| `auth/new_sing_up_screen.dart` | 654 | `NewLoginScreen` |
| `auth/new_forgot_otp_screen.dart` | 112 | `NewNewPasswrodScreen` |
| `auth/new_new_passwrod_screen.dart` | 85 | `PasswordSuccessfull` |
| `Home/HomeSekect/finding_the_perfect_screen.dart` | 35 | `ContentTypeScreen` |
| `Home/NewBookingFlow/More_Details/select_your_dream_team.dart` | 1339 | `SelectYourDreamTeam` (self) |
| `Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart` | 318 | `PaymentSuccessScreen` |
| `Booking/upcoming_event_summary_managebooking.dart` | 382 | `UpcomingEventSummaryManagebooking` (self) |
| `Booking/upcoming_event_summary_managebooking.dart` | 426 | `BookinReviewConfirm` |
| `Booking/cancel_booking.dart` | 539 | `BookingAllScreen` |

### `Navigator.pushAndRemoveUntil()` — 8 calls

| File | Line | Destination | Predicate |
|---|---|---|---|
| `auth/new_login_screen.dart` | 110 | `Mainscreen` | `(route) => false` |
| `auth/Password_successfull.dart` | 24 | `NewLoginScreen` | `(route) => false` |
| `Home/NewBookingFlow/Book_Confirm/PaymentSuccessScreen.dart` | 25 | `Mainscreen` | `(route) => false` (WillPopScope) |
| `Home/NewBookingFlow/Book_Confirm/PaymentSuccessScreen.dart` | 80 | `Mainscreen` | `(route) => false` |
| `Booking/Shoot_updated_screen.dart` | 75 | `Mainscreen` | `(route) => false` |
| `Booking/Shoot_updated_screen.dart` | 106 | `Mainscreen` | `(route) => false` |
| `MyProfile/my_profile.dart` | 595 | `SplashScreen` | `(route) => false` (logout) |
| `MyProfile/DeleteAccount/delete_account_otp_screen.dart` | 89 | `SplashScreen` | `(route) => false` |

### `Navigator.pop()` with return value — 10 calls

| File | Line | Returns |
|---|---|---|
| `Home/HomeSekect/change_location_screen.dart` | 130 | `payload` (location object) |
| `Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart` | 233, 501 | `widget.bookingId` (int) |
| `Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | 919 | `tempSelected` |
| `Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | 1121 | `true` |
| `Booking/MY_SelectBookingType.dart` | 841 | `tempSelected` |
| `MyProfile/myprofile_new_password_screen.dart` | 126 | `true` |
| `MyProfile/Change_Password_screen.dart` | 176 | `true` |
| `MyProfile/edit_profile.dart` | 242, 755 | `true` |

All return types are **untyped** (`dynamic`) — no type safety on the receiving end.

---

## 4. PARAMETERS

### How parameters are passed

**Constructor injection only** — all data is passed directly through widget constructors in `MaterialPageRoute(builder: (_) => ScreenName(param: value))`. No `settings.arguments`, no query params, no shared state.

### Screens with > 3 parameters

| Screen | Required Params | Optional Params | Total |
|---|---|---|---|
| `UpcomingEventSummaryManagebooking` | 2 | 9 | **11** |
| `CancelBooking` | 1 | 8 | **9** |
| `PaymentSuccessScreen` | 4 | 0 | **4** |
| `ShootDateTimeScreen` | 3 | 0 | **3** |

`UpcomingEventSummaryManagebooking` and `CancelBooking` are the worst cases — receiving the same 8+ optional strings because there is no shared booking model that is looked up by ID.

### Type safety

- **Required constructor params:** typed (e.g., `required int bookingId`) — safe at compile time
- **Return values from `pop()`:** all `dynamic` — no type safety, receiver must cast manually or trust the value
- **No `RouteSettings.arguments`** used anywhere — all compile-time constructor injection

---

## 5. BOTTOM NAVIGATION / TABS

| Question | Answer |
|---|---|
| Bottom nav implemented? | Yes — `BottomNavigationBar` with 4 items |
| Implementation | `StatefulWidget` with `int _selectedIndex` + `setState()` |
| Tab switch mechanism | `switch(_selectedIndex)` returns a new widget — **NOT IndexedStack** |
| State preserved on tab switch? | **No** — every tab switch destroys and rebuilds the current tab widget |
| ShellRoute equivalent | None — plain `StatefulWidget` (`Mainscreen`) |
| Tab 3 (Messages) | Unimplemented placeholder: `Center(child: Text("Message"))` |

The lack of `IndexedStack` means:
- `NewHomeScreen` re-initialises and re-fetches API data every time the user returns to Tab 0
- `BookingAllScreen` same — re-fetches on every tab switch to Tab 2
- Scroll position and any in-progress state is lost on every tab switch

---

## 6. PROBLEMS

### ❌ No route name system
- 0 named routes. Every `Navigator.push` is inline with an anonymous `MaterialPageRoute`. No central route registry exists. Impossible to deep-link to any screen.

### ❌ 62 push calls scattered across the codebase
- Route destinations are hardcoded at every call site. Renaming a screen class requires hunting every instantiation. No single source of truth.

### ❌ No auth guard — only a boot-time check
- `isLoggedIn` is checked once at startup via `SharedPreferences`. There is no runtime guard. If the token expires mid-session, the user gets API errors, not a redirect to login.

### ❌ No deep linking
- No URL scheme, no universal links, no `go_router` path configuration. The app cannot be opened to a specific screen from outside.

### ❌ Tab state not preserved (no IndexedStack)
- `_currentPage` uses a `switch` — every tab switch fully rebuilds the tab widget, losing scroll position and triggering fresh API calls.

### ❌ Tab 3 (Messages) is an unimplemented placeholder
- `Center(child: Text("Message"))` — a dead tab visible to all users.

### ❌ `pushAndRemoveUntil(..., (route) => false)` used 8 times manually
- Stack management is manual and duplicated. Each flow that needs to "reset to home" repeats the same predicate inline. GoRouter's `go()` handles this automatically.

### ❌ `pushReplacement` self-navigation (screen refreshes itself)
- `SelectYourDreamTeam` (line 1339) and `UpcomingEventSummaryManagebooking` (line 382) push a replacement of themselves to refresh data — a workaround for no reactive state. This creates ghost entries in the history stack that browsers/Android back-gesture can navigate into.

### ❌ Result passing via untyped `pop(context, dynamic)`
- 10 `pop()` calls return values (`true`, `int`, objects). The receiving `await push()` gets back `dynamic`. No type contract — a change on either side compiles but fails silently at runtime.

### ❌ Navigator calls inside business logic
- `new_login_screen.dart:110` — `Navigator.pushAndRemoveUntil` is called inside the API response callback, not in a user gesture handler. Navigation is entangled with API logic, making it impossible to test or extract to a notifier without breaking navigation.
- Same pattern in `auth/new_forgot_otp_screen.dart:112`, `auth/new_new_passwrod_screen.dart:85`, `Booking/cancel_booking.dart:539`.

### ❌ `UpcomingEventSummaryManagebooking` receives 11 constructor params
- Screen receives 11 separate fields instead of a single `Booking` domain object. Passing this through GoRouter `extra` will require a custom codec; refactoring to look up by `bookingId` alone is the right fix before migration.

### ❌ No unreachable screens (all screens are reachable)
- All 39 screens are navigated to from at least one call site. No dead routes, but `FindingThePerfectScreen` and `RecommendedDetilsScreen` are only accessible from `NewHomeScreen`'s 18 inline push calls — no other entry points.

---

## 7. MIGRATION NOTES FOR GOROUTER

| Item | Action Required |
|---|---|
| Route names | Define a `AppRoutes` constants class with all path strings before migration |
| Auth redirect | Replace boot-time `isLoggedIn` flag with GoRouter `redirect` callback reading live token state from a Riverpod provider |
| Bottom nav | Replace `Mainscreen` `StatefulWidget` with a `ShellRoute` — tabs get persistent state via `IndexedStack` automatically |
| Stack resets (`pushAndRemoveUntil`) | Replace with `context.go('/home')` — GoRouter handles stack clearing |
| Self-replacement hacks | Replace with Riverpod provider invalidation — screen reacts to state, not navigation |
| Untyped `pop()` return values | Replace with Riverpod shared state — eliminate result-passing entirely |
| `UpcomingEventSummaryManagebooking` 11 params | Refactor to pass `bookingId` only; look up booking from a Riverpod provider |
| Deep linking | Add `path` to every named route; configure `AndroidManifest` + `Info.plist` URL schemes |
| Tab 3 placeholder | Implement or hide before migration |
