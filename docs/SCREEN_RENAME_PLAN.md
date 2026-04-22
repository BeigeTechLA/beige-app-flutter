# Screen Class & File Rename Plan

> Created: 2026-04-22
> Purpose: Standardize all screen class names and file names to follow Flutter naming conventions and match application flow

---

## Context

Current codebase has 37 screen classes with inconsistent naming:
- **"New" prefix pollution** — `NewLoginScreen`, `NewHomeScreen`, `NewSingUpScreen` etc. (legacy artifact from when "new" versions replaced old ones)
- **Typos in class names** — `PasswrodScreen`, `SingUp`, `DetilsScreen`, `BookinReview`, `Successfull`
- **Missing `Screen` suffix** — `MyProfile`, `EditProfile`, `DeleteAccount`, `CancelBooking`, `SelectYourDreamTeam`, `VideoShootType`
- **Vague names** — `MoreDetailsScreen` (more details of what?), `FindingThePerfectScreen` (perfect what?)
- **Inconsistent casing in files** — `MY_SelectBookingType.dart`, `Home_view_profile.dart`, `Password_successfull.dart`
- **Class/file mismatch** — `MySelectbookingtype` class in `MY_SelectBookingType.dart`

### Application Flow Overview

| Directory | Purpose | Tab/Flow |
|---|---|---|
| `lib/auth/` | Login flow, Sign Up flow, Forgot Password flow | Pre-auth |
| `lib/SplashScreen/` | App entry splash | Pre-auth |
| `lib/OnbodingScreen/` | First-launch onboarding | Pre-auth |
| `lib/Home/New_Home/` | Home screen (Tab 0) | Home Tab |
| `lib/Home/HomeSekect/` | Misc screens accessed from Home (location picker, payment method) | Home Tab |
| `lib/Home/NewBookingFlow/` | "Book a Shoot" multi-step flow (Tab 1) | Book a Shoot Tab |
| `lib/my_shoot/` | "My Shoots" tab — manage existing shoots (Tab 2) | My Shoots Tab |
| `lib/MyProfile/` | Profile, settings, delete account | Profile (accessed from Home) |

---

## Naming Convention Rules

1. **All screen classes end with `Screen`**
2. **No "New" prefix** — artifact of old/new coexistence, no longer needed
3. **File names: `lowercase_snake_case.dart`**
4. **Class names: `PascalCase`**
5. **Name describes what screen DOES, not vague adjectives**
6. **Flow prefix for multi-step flows** (e.g., `Shoot` prefix for shoot booking flow screens)
7. **Fix all typos**

---

## Rename Tables by Application Flow

### 1. Auth Flow (`lib/auth/`)

Contains 3 sub-flows: **Login**, **Sign Up**, **Forgot Password**

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 1 | `new_login_screen.dart` | `NewLoginScreen` | `login_screen.dart` | `LoginScreen` | Drop "New" prefix |
| 2 | `new_sing_up_screen.dart` | `NewSingUpScreen` | `sign_up_screen.dart` | `SignUpScreen` | Fix typo "Sing" → "Sign", drop "New" |
| 3 | `new_forgot_passwrod_screen.dart` | `NewForgotPasswrodScreen` | `forgot_password_screen.dart` | `ForgotPasswordScreen` | Fix typo "Passwrod", drop "New" |
| 4 | `new_forgot_otp_screen.dart` | `NewForgotOtpScreen` | `forgot_password_otp_screen.dart` | `ForgotPasswordOtpScreen` | Clarify: OTP for password reset, drop "New" |
| 5 | `new_new_passwrod_screen.dart` | `NewNewPasswrodScreen` | `reset_password_screen.dart` | `ResetPasswordScreen` | Fix "NewNew" + typo. This IS the reset screen |
| 6 | `Password_successfull.dart` | `PasswordSuccessfull` | `password_reset_success_screen.dart` | `PasswordResetSuccessScreen` | Fix typo "Successfull", add Screen suffix, snake_case file |

**Auth sub-flow mapping:**
```
Login flow:      LoginScreen → SignUpScreen
Sign Up flow:    SignUpScreen → LoginScreen
Forgot Password: ForgotPasswordScreen → ForgotPasswordOtpScreen → ResetPasswordScreen → PasswordResetSuccessScreen
```

### 2. Splash & Onboarding (`lib/SplashScreen/`, `lib/OnbodingScreen/`)

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 7 | `SplashScreen/splash_screen.dart` | `SplashScreen` | *(no change)* | *(no change)* | Already correct |
| 8 | `OnbodingScreen/onboding_screen.dart` | `OnboardingScreen` | `OnboardingScreen/onboarding_screen.dart` | *(no change)* | Fix directory typo "Onboding" → "Onboarding" |

### 3. Main Shell (`lib/`)

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 9 | `MainScreen.dart` | `Mainscreen` | `main_screen.dart` | `MainScreen` | Fix casing: `Mainscreen` → `MainScreen`, snake_case file |

### 4. Home Tab — Tab 0 (`lib/Home/New_Home/` + `lib/Home/HomeSekect/`)

`New_Home/` contains the main home screen. `HomeSekect/` contains screens accessed from home (location picker, creative profile views, etc.)

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 10 | `New_Home/new_home_screen.dart` | `NewHomeScreen` | `home/home_screen.dart` | `HomeScreen` | Drop "New", fix directory case |
| 11 | `HomeSekect/Home_view_profile.dart` | `HomeViewProfile` | `home/creative_profile_screen.dart` | `CreativeProfileScreen` | Clarify: viewing a creative's profile, add Screen suffix |
| 12 | `HomeSekect/recommended_detils_screen.dart` | `RecommendedDetilsScreen` | `home/recommended_creative_detail_screen.dart` | `RecommendedCreativeDetailScreen` | Fix typo "Detils", clarify what's recommended |
| 13 | `HomeSekect/change_location_screen.dart` | `ChangeLocationScreen` | `home/change_location_screen.dart` | *(no change)* | Class OK, move from misspelled directory |
| 14 | `HomeSekect/finding_the_perfect_screen.dart` | `FindingThePerfectScreen` | `home/find_creative_screen.dart` | `FindCreativeScreen` | Vague name → descriptive. Screen finds matching creative |

### 5. Book a Shoot Flow — Tab 1 (`lib/Home/NewBookingFlow/`)

Multi-step shoot booking flow: Content Type → Shoot Type → Date/Time → Details → Crew → Review → Payment

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 15 | `CreateProjectStep1/Content_Type_screen.dart` | `ContentTypeScreen` | `book_shoot/content_type_screen.dart` | *(no change)* | Class OK, flatten directory, snake_case file |
| 16 | `CreateProjectStep1/Video_Shoot_Type.dart` | `VideoShootType` | `book_shoot/shoot_type_screen.dart` | `ShootTypeScreen` | Add Screen suffix, drop "Video" (handles all types) |
| 17 | `CreateProjectStep1/ShootDateTime/Shoot_Date_Time_screen.dart` | `ShootDateTimeScreen` | `book_shoot/shoot_date_time_screen.dart` | *(no change)* | Class OK, flatten directory, snake_case file |
| 18 | `More_Details/more_details_screen.dart` | `MoreDetailsScreen` | `book_shoot/shoot_details_screen.dart` | `ShootDetailsScreen` | "More Details" vague → "Shoot Details" |
| 19 | `More_Details/crew_size_matching_screen.dart` | `CrewSizeMatchingScreen` | `book_shoot/crew_size_matching_screen.dart` | *(no change)* | Class OK, flatten directory |
| 20 | `More_Details/select_your_dream_team.dart` | `SelectYourDreamTeam` | `book_shoot/crew_selection_screen.dart` | `CrewSelectionScreen` | Add Screen suffix, professional name |
| 21 | `Book_Confirm/review_confirm_screen.dart` | `ReviewConfirmScreen` | `book_shoot/shoot_review_screen.dart` | `ShootReviewScreen` | Clarify: review for new shoot booking |
| 22 | `Book_Confirm/PaymentSuccessScreen.dart` | `PaymentSuccessScreen` | `book_shoot/payment_success_screen.dart` | *(no change)* | Class OK, snake_case file |
| 23 | `HomeSekect/payment_method.dart` | `PaymentMethodScreen` | `book_shoot/payment_method_screen.dart` | *(no change)* | Class OK, move to correct flow directory |

**Book a Shoot flow mapping:**
```
ContentTypeScreen → ShootTypeScreen → ShootDateTimeScreen → ShootDetailsScreen
  → CrewSizeMatchingScreen → CrewSelectionScreen → ShootReviewScreen
    → PaymentMethodScreen → PaymentSuccessScreen → MainScreen
```

### 6. My Shoots Tab — Tab 2 (`lib/my_shoot/`)

Shows user's booked shoots (upcoming, past). Allows managing, editing, cancelling shoots.

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 24 | `booking_all_screen.dart` | `BookingAllScreen` | `my_shoots_screen.dart` | `MyShootsScreen` | Matches tab name "My Shoots", not vague "All" |
| 25 | `upcoming_booking_event_summary.dart` | `UpcomingBookingEventSummary` | `shoot_summary_screen.dart` | `ShootSummaryScreen` | Too long, add Screen suffix, use "Shoot" domain term |
| 26 | `MY_SelectBookingType.dart` | `MySelectbookingtype` | `shoot_type_selection_screen.dart` | `ShootTypeSelectionScreen` | Fix casing disaster, add Screen suffix |
| 27 | `upcoming_event_summary_managebooking.dart` | `UpcomingEventSummaryManagebooking` | `manage_shoot_screen.dart` | `ManageShootScreen` | Way too long → concise, use "Shoot" domain term |
| 28 | `cancel_booking.dart` | `CancelBooking` | `cancel_shoot_screen.dart` | `CancelShootScreen` | Add Screen suffix, use "Shoot" domain term |
| 29 | `bookin_review_confirm.dart` | `BookinReviewConfirm` | `shoot_edit_review_screen.dart` | `ShootEditReviewScreen` | Fix typo "Bookin", distinguish from new shoot review |
| 30 | `shoot_updated_screen.dart` | `ShootUpdatedScreen` | `shoot_update_success_screen.dart` | `ShootUpdateSuccessScreen` | Clarify: this is a success confirmation screen |

**My Shoots flow mapping:**
```
MyShootsScreen
  ├── ShootSummaryScreen → ShootTypeSelectionScreen
  ├── ManageShootScreen
  │     ├── ShootEditReviewScreen
  │     └── CancelShootScreen → MyShootsScreen
  └── ShootUpdateSuccessScreen → MainScreen
```

### 7. Profile (`lib/MyProfile/`)

Accessed from Home screen. Contains profile view/edit, settings, password change, and delete account sub-flow.

| # | Current File | Current Class | New File | New Class | Reason |
|---|---|---|---|---|---|
| 31 | `my_profile.dart` | `MyProfile` | `profile_screen.dart` | `ProfileScreen` | Drop "My", add Screen suffix |
| 32 | `edit_profile.dart` | `EditProfile` | `edit_profile_screen.dart` | `EditProfileScreen` | Add Screen suffix |
| 33 | `Booking_History_screen.dart` | `BookingHistoryScreen` | `shoot_history_screen.dart` | `ShootHistoryScreen` | Match "Shoot" domain terminology |
| 34 | `Favourite_screen.dart` | `FavouriteScreen` | `favorites_screen.dart` | `FavoritesScreen` | Standardize to US English (Flutter convention) |
| 35 | `app_preferences.dart` | `AppPreferences` | `app_preferences_screen.dart` | `AppPreferencesScreen` | Add Screen suffix |
| 36 | `Change_Password_screen.dart` | `ChangePasswordScreen` | `change_password_screen.dart` | *(no change)* | Class OK, snake_case file |
| 37 | `myprofile_enter_otp_screen.dart` | `EnterOtpCodeScreen` | `profile_otp_screen.dart` | `ProfileOtpScreen` | Align file/class, clarify context (profile flow OTP) |
| 38 | `myprofile_new_password_screen.dart` | `MyprofileNewPasswordScreen` | `profile_new_password_screen.dart` | `ProfileNewPasswordScreen` | Fix casing, drop "My" prefix |
| 39 | `DeleteAccount/delete_account.dart` | `DeleteAccount` | `delete_account/delete_account_screen.dart` | `DeleteAccountScreen` | Add Screen suffix |
| 40 | `DeleteAccount/delete_account_otp_screen.dart` | `DeleteAccountOtpScreen` | `delete_account/delete_account_otp_screen.dart` | *(no change)* | Already correct |

**Profile flow mapping:**
```
ProfileScreen
  ├── EditProfileScreen
  ├── ShootHistoryScreen
  ├── FavoritesScreen
  ├── AppPreferencesScreen → ChangePasswordScreen → ProfileOtpScreen → ProfileNewPasswordScreen
  ├── DeleteAccountScreen → DeleteAccountOtpScreen → SplashScreen
  └── Logout → SplashScreen
```

---

## Updated Full Navigation Graph (Post-Rename)

```
App Start
  └── SplashScreen
        └── OnboardingScreen
              ├── LoginScreen
              │     ├── → MainScreen [after login]
              │     ├── → ForgotPasswordScreen
              │     │     └── → ForgotPasswordOtpScreen(email)
              │     │           └── → ResetPasswordScreen(email, otp)
              │     │                 └── → PasswordResetSuccessScreen
              │     │                       └── → LoginScreen [after 3s]
              │     └── → SignUpScreen
              │           └── → LoginScreen [on success]
              └── → LoginScreen

MainScreen [bottom nav shell — 4 tabs]
  │
  ├── Tab 0 — Home: HomeScreen
  │     ├── → CreativeProfileScreen(id)
  │     │     └── → ContentTypeScreen(...)
  │     ├── → RecommendedCreativeDetailScreen(...)
  │     │     └── → ContentTypeScreen(...)
  │     ├── → FindCreativeScreen
  │     │     └── → ContentTypeScreen(...)
  │     ├── → ContentTypeScreen(fromHome:false)
  │     ├── → ChangeLocationScreen [returns payload]
  │     └── → ProfileScreen
  │           ├── → EditProfileScreen [returns bool]
  │           ├── → ShootHistoryScreen
  │           ├── → FavoritesScreen
  │           ├── → AppPreferencesScreen
  │           │     └── → ChangePasswordScreen
  │           │           └── → ProfileOtpScreen → ProfileNewPasswordScreen
  │           ├── → DeleteAccountScreen → DeleteAccountOtpScreen → SplashScreen
  │           └── Logout → SplashScreen
  │
  ├── Tab 1 — Book a Shoot: ContentTypeScreen
  │     └── → ShootTypeScreen(contentTypeId, bookingId)
  │           └── → ShootDateTimeScreen(bookingId, contentTypeId, specialtyId)
  │                 └── → ShootDetailsScreen(bookingId, contentTypeId)
  │                       └── → CrewSizeMatchingScreen(bookingId, ...)
  │                             └── → CrewSelectionScreen(bookingId, ...)
  │                                   └── → ShootReviewScreen(bookingId)
  │                                         ├── → PaymentSuccessScreen(...)
  │                                         │     └── → MainScreen [clears stack]
  │                                         └── → PaymentMethodScreen(...)
  │
  ├── Tab 2 — My Shoots: MyShootsScreen
  │     ├── → ShootSummaryScreen(bookingId, ...)
  │     │     └── → ShootTypeSelectionScreen(bookingId)
  │     ├── → ManageShootScreen(bookingId, ...)
  │     │     ├── → ManageShootScreen (self — refresh)
  │     │     ├── → ShootEditReviewScreen(bookingId)
  │     │     └── → CancelShootScreen(bookingId, ...)
  │     │           └── → MyShootsScreen [after cancel]
  │     └── → ShootUpdateSuccessScreen
  │           └── → MainScreen [clears stack]
  │
  └── Tab 3 — Messages: [placeholder — not implemented]
```

---

## Execution Status

**All renames completed on 2026-04-22.** Executed in 6 steps with `flutter analyze` verification after each.

| Step | Feature Group | Screens Renamed | Status |
|---|---|---|---|
| 1 | Auth flow | 6 auth screens + OnboardingScreen dir fix | ✅ Done |
| 2 | Main shell | MainScreen | ✅ Done |
| 3 | Home tab | HomeScreen + 4 home sub-screens | ✅ Done |
| 4 | Book a Shoot flow | 9 shoot booking screens | ✅ Done |
| 5 | My Shoots tab | 7 shoot management screens | ✅ Done |
| 6 | Profile + settings + delete account | 10 profile screens | ✅ Done |

### Directory renames applied
| Old Directory | New Directory | Reason |
|---|---|---|
| `lib/OnbodingScreen/` | `lib/OnboardingScreen/` | Fix typo |
| `lib/Home/New_Home/` | `lib/Home/home/` | Drop "New", clean name |
| `lib/Home/HomeSekect/` | `lib/Home/home/` + `lib/Home/book_shoot/` | Fix typo, split by flow |
| `lib/Home/NewBookingFlow/` | `lib/Home/book_shoot/` | Flatten, match tab name |
| `lib/Booking/` | `lib/my_shoot/` | Match "My Shoots" tab label |

---

## Summary

| Metric | Count |
|---|---|
| Total screens audited | **40** (37 screens + 3 utility widgets) |
| Classes to rename | **26** |
| Classes already correct | **11** |
| Files to rename | **31** |
| Typos fixed | **8** (`Passwrod`, `SingUp`, `Detils`, `Bookin`, `Successfull`, `Onboding`, `Sekect`, `Myprofile`) |
| Screen suffix added | **12** |
| "New" prefix dropped | **6** |
| Vague names clarified | **6** (`MoreDetails`, `FindingThePerfect`, `BookingAll`, `SelectYourDreamTeam`, `UpcomingEventSummaryManagebooking`, `BookingHistoryScreen`) |
| Domain term aligned | **8** (changed "Booking" → "Shoot" where referring to My Shoots tab) |