# State Management Audit — Beige App

> Audited: 2026-04-19
> Target: Riverpod (flutter_riverpod) with Notifier pattern

---

## 1. PATTERNS FOUND

### `setState` — Used in ALL screen files (37 files)

| File | Notable Usage |
|---|---|
| `auth/new_login_screen.dart` | Form state, loading flag, API call inside setState |
| `auth/new_sing_up_screen.dart` | Form state, image crop, map, location, OTP flow |
| `auth/new_forgot_passwrod_screen.dart` | Form state, loading, API call |
| `auth/new_forgot_otp_screen.dart` | Timer countdown, OTP state, API call |
| `auth/new_new_passwrod_screen.dart` | Password visibility, loading, API call |
| `auth/Password_successfull.dart` | `Future.delayed` + Navigator pop |
| `Booking/booking_all_screen.dart` | Tab selection, booking list, loading |
| `Booking/bookin_review_confirm.dart` | Booking data, loading, API call |
| `Booking/cancel_booking.dart` | Cancel reason, loading, API call |
| `Booking/MY_SelectBookingType.dart` | Date/time pickers, selection state |
| `Booking/upcoming_booking_event_summary.dart` | Event detail, loading, API call |
| `Home/New_Home/new_home_screen.dart` | PageController, AnimationController, carousel index |
| `Home/HomeSekect/Home_view_profile.dart` | Profile data, PageController, API call |
| `Home/HomeSekect/change_location_screen.dart` | Location picking, map state |
| `Home/HomeSekect/finding_the_perfect_screen.dart` | Loading/search state |
| `Home/HomeSekect/payment_method.dart` | Payment selection, loading |
| `Home/HomeSekect/recommended_detils_screen.dart` | Detail loading, API call |
| `Home/NewBookingFlow/Book_Confirm/review_confirm_screen.dart` | Booking summary, Stripe, loading |
| `Home/NewBookingFlow/CreateProjectStep1/Content_Type_screen.dart` | Selection state |
| `Home/NewBookingFlow/CreateProjectStep1/Video_Shoot_Type.dart` | Selection state |
| `Home/NewBookingFlow/CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | Date/time state |
| `Home/NewBookingFlow/More_Details/more_details_screen.dart` | Form state, file upload |
| `Home/NewBookingFlow/More_Details/crew_size_matching_screen.dart` | Loading, API call |
| `Home/NewBookingFlow/More_Details/select_your_dream_team.dart` | Selection, loading |
| `MyProfile/my_profile.dart` | Profile data, loading, API call |
| `MyProfile/edit_profile.dart` | Form, image upload, map, location, API call |
| `MyProfile/Booking_History_screen.dart` | List loading, API call |
| `MyProfile/Favourite_screen.dart` | Favourites list, loading |
| `MyProfile/Change_Password_screen.dart` | Form, visibility toggles, API call |
| `MyProfile/myprofile_enter_otp_screen.dart` | OTP, timer, API call |
| `MyProfile/myprofile_new_password_screen.dart` | Form, loading, API call |
| `MyProfile/DeleteAccount/delete_account.dart` | Loading, API call |
| `MyProfile/DeleteAccount/delete_account_otp_screen.dart` | OTP, timer, API call |
| `MyProfile/app_preferences.dart` | Preferences UI, SharedPrefs read |
| `SplashScreen/splash_screen.dart` | Timer-driven image rotation |
| `OnbodingScreen/onboding_screen.dart` | PageController, page index |
| `MainScreen.dart` | Tab index |
| `Customtextfiled/CustomInputField.dart` | FocusNode listener (UI only) |

### `ChangeNotifier / Provider` — None

### `BLoC / Cubit` — None

### `Riverpod` — None

### `GetX` — None

### `InheritedWidget / ValueNotifier` — None

### Raw Streams — 2 files

| File | Usage |
|---|---|
| `service/internet_service.dart` | `Connectivity().onConnectivityChanged` stream |
| `No_internet/internet_helper.dart` | Subscribes to stream + `Stream.periodic` polling; uses static `_subscription` and static `_isDialogShowing` flag |

### Global Variables / Singletons

| Variable | Location | Scope |
|---|---|---|
| `navigatorKey` | `main.dart` | App-wide GlobalKey |
| `scaffoldMessengerKey` | `main.dart` | App-wide GlobalKey |
| `ApiService.imageURL` | `service/api_service.dart` | Static field |
| `SharedService.imageURL` | `service/shared_service.dart` | Duplicate static field |
| `InternetHelper._subscription` | `No_internet/internet_helper.dart` | Static stream subscription |
| `InternetHelper._isDialogShowing` | `No_internet/internet_helper.dart` | Static flag |

---

## 2. CONSISTENCY CHECK

**Is one approach used consistently?**
Yes — 100% `setState` across all screens. There is exactly one controller class (`HomeController`, 58 lines) that does an API fetch. Everything else is monolithic `StatefulWidget`.

**Screens using setState for business logic (not just UI toggle):**
23 out of 37 screen files make API calls directly inside `setState` callbacks or `initState`. Only ~5 screens use `setState` purely for UI toggles (tab index, password visibility, page swipe).

### God Widgets (screens > 200 lines handling their own state)

| Screen | Est. LOC | Notes |
|---|---|---|
| `new_sing_up_screen.dart` | ~1,742 | Form + image crop + map + location + OTP + API — worst offender |
| `new_forgot_otp_screen.dart` | ~609 | OTP + timer + API + navigation chain |
| `new_login_screen.dart` | ~557 | Form + auth API + token storage |
| `new_home_screen.dart` | ~500 | PageController + AnimationController + carousel + API |
| `edit_profile.dart` | ~450 | Form + image upload + map + location + API |
| `new_forgot_passwrod_screen.dart` | ~487 | Form + API |
| `review_confirm_screen.dart` | ~400 | Stripe + booking summary + API |
| `more_details_screen.dart` | ~350 | Form + file picker + API |
| `booking_all_screen.dart` | ~350 | Tab nav + multi-state list + API |
| `my_profile.dart` | ~300 | Profile fetch + display + nav |
| `myprofile_enter_otp_screen.dart` | ~300 | Timer + OTP + API |

**11 confirmed god widgets.** `new_sing_up_screen.dart` at ~1,742 lines is the most critical — a single file handling registration, OTP, map-based location, image cropping, and form validation.

---

## 3. DEPENDENCY INJECTION

| Question | Answer |
|---|---|
| `get_it` used? | No |
| Services injected via constructor? | No — `ApiService()` is instantiated inline inside each widget's methods |
| Service locator pattern? | No |
| How are services accessed? | Direct instantiation: `ApiService apiService = ApiService();` per widget |
| Shared state across screens? | Via `SharedPreferences` (token, user id) read directly inside each widget using `SharedService` static methods |

**Current DI pattern: none.** Each screen creates its own `ApiService` instance. There is no injection, no registry, and no shared service instance. Migration to Riverpod providers will also serve as the DI replacement — no `get_it` needed.

---

## 4. MIGRATION RISK PER SCREEN

| Screen | Current Approach | Est. LOC | Business Logic Location | Migration Risk |
|---|---|---|---|---|
| `SplashScreen` | setState + Timer | ~126 | UI only (image rotation) + nav | **LOW** |
| `OnboardingScreen` | setState + PageController | ~150 | UI only (page swipe) | **LOW** |
| `Password_successfull` | setState + Future.delayed | ~79 | UI only (auto-nav) | **LOW** |
| `MainScreen` | setState | ~145 | Tab index only | **LOW** |
| `Shoot_updated_screen` | setState | ~136 | Nav only | **LOW** |
| `MY_SelectBookingType` | setState | ~200 | Date/time UI, no API | **LOW** |
| `Content_Type_screen` | setState | ~180 | Selection UI only | **LOW** |
| `Video_Shoot_Type` | setState | ~180 | Selection UI only | **LOW** |
| `Shoot_Date_Time_screen` | setState | ~200 | Date/time picker UI | **LOW** |
| `app_preferences.dart` | setState | ~150 | Preferences UI, SharedPrefs read | **LOW** |
| `PaymentSuccessScreen` | setState | ~100 | Nav only | **LOW** |
| `cancel_booking.dart` | setState | ~200 | API call + reason selection | **MEDIUM** |
| `booking_all_screen.dart` | setState | ~350 | API call + multi-tab list | **MEDIUM** |
| `bookin_review_confirm.dart` | setState | ~200 | API call + booking data | **MEDIUM** |
| `upcoming_booking_event_summary.dart` | setState | ~250 | API call + event detail | **MEDIUM** |
| `upcoming_event_summary_managebooking.dart` | setState | ~200 | API call + event detail | **MEDIUM** |
| `Booking_History_screen.dart` | setState | ~250 | API call + list | **MEDIUM** |
| `Favourite_screen.dart` | setState | ~220 | API call + list | **MEDIUM** |
| `Change_Password_screen.dart` | setState | ~280 | Form + API call | **MEDIUM** |
| `delete_account.dart` | setState | ~180 | API call | **MEDIUM** |
| `delete_account_otp_screen.dart` | setState | ~250 | OTP + Timer + API | **MEDIUM** |
| `finding_the_perfect_screen.dart` | setState | ~200 | Loading/search state + API | **MEDIUM** |
| `select_your_dream_team.dart` | setState | ~280 | Selection + API | **MEDIUM** |
| `crew_size_matching_screen.dart` | setState | ~280 | API + search results | **MEDIUM** |
| `recommended_detils_screen.dart` | setState | ~250 | API call + profile detail | **MEDIUM** |
| `payment_method.dart` | setState | ~220 | Stripe + API | **MEDIUM** |
| `new_login_screen.dart` | setState | ~557 | Form + auth API + token storage | **HIGH** |
| `new_new_passwrod_screen.dart` | setState | ~431 | Form + API + navigation chain | **HIGH** |
| `new_forgot_passwrod_screen.dart` | setState | ~487 | Form + API | **HIGH** |
| `new_forgot_otp_screen.dart` | setState + Timer + Stream | ~609 | OTP + Timer + API + nav chain | **HIGH** |
| `myprofile_enter_otp_screen.dart` | setState + Timer | ~300 | OTP + Timer + API | **HIGH** |
| `myprofile_new_password_screen.dart` | setState | ~250 | Form + API + nav | **HIGH** |
| `my_profile.dart` | setState | ~300 | Profile fetch + display + nav | **HIGH** |
| `edit_profile.dart` | setState | ~450 | Form + image + map + location + API | **HIGH** |
| `Home_view_profile.dart` | setState | ~270 | Profile + gallery + API | **HIGH** |
| `new_home_screen.dart` | setState + AnimationController + PageController | ~500 | Mixed — partial controller exists | **HIGH** |
| `more_details_screen.dart` | setState | ~350 | Form + file upload + API | **HIGH** |
| `review_confirm_screen.dart` | setState | ~400 | Stripe + booking + API | **HIGH** |
| `new_sing_up_screen.dart` | setState | ~1,742 | Everything — god widget | **HIGH** |

### Risk Summary

| Risk Level | Count | Notes |
|---|---|---|
| LOW | 11 | Pure UI state, no API — easy 1:1 Notifier wrap |
| MEDIUM | 16 | API calls + moderate state — needs provider + repository layer |
| HIGH | 12 | Complex logic, timers, multi-step flows, or massive god widgets |

---

## 5. KEY FINDINGS

1. **Zero state management libraries** — No Provider, Riverpod, GetX, BLoC, ChangeNotifier, or InheritedWidget anywhere in the project. Pure `setState` throughout.
2. **No separation of concerns** — Business logic (API calls, validation, auth) is mixed directly into widget `setState` methods and `initState`.
3. **No dependency injection** — `ApiService()` is instantiated fresh inside each widget. No shared instance, no injection, no registry.
4. **Shared state is fragile** — Auth token, user ID, and internet status are accessed via `SharedPreferences` static calls and global static variables scattered across files.
5. **11 god widgets** — Screens up to 1,742 lines, handling their own networking, form state, map, image cropping, and navigation simultaneously.
6. **Clean migration target** — No competing libraries to remove, no generated code to update. The gap is large but well-defined.
7. **`new_sing_up_screen.dart` must be split first** — At ~1,742 lines it should be broken into separate screens/flows before any Riverpod migration begins.

---

## 6. MIGRATION STRATEGY NOTES

- **Phase 1 (Foundation):** Add `flutter_riverpod`, establish `lib/core/network/` with Dio interceptors, create repository interfaces.
- **Phase 2 (LOW risk screens first):** Wrap splash, onboarding, main nav in minimal Notifiers to establish the pattern.
- **Phase 3 (MEDIUM screens):** Migrate booking and profile list screens — each gets a `AsyncNotifier` backed by a repository.
- **Phase 4 (HIGH screens):** Auth flow and edit profile last — split god widgets before migrating.
- **DI:** Riverpod providers replace `ApiService()` inline instantiation. One provider per service, scoped at app level.
- **Global keys:** `navigatorKey` and `scaffoldMessengerKey` can stay in `main.dart` — they are infrastructure, not state.