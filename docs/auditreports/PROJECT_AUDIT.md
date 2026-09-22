# Beige App — Flutter Project Audit

> Audited: 2026-04-19

---

## 1. PROJECT BASICS

| Item | Value |
|---|---|
| Flutter SDK (installed) | 3.38.9 (channel stable, 2026-01-28) |
| Dart SDK (installed) | 3.10.8 |
| Dart SDK constraint (pubspec.yaml) | `^3.9.2` |
| Flutter SDK constraint (pubspec.yaml) | Not pinned — inherits from Flutter |
| Total `.dart` files | 59 (0 `.g.dart`, 0 `.freezed.dart`) |
| Total lines of Dart code | ~34,200 |
| Screens / Pages (files with Screen/Page/View class) | 27 |
| Custom widgets (non-screen widget files) | ~14 (2 in `widgets/`, 1 in `Customtextfiled/`, ~11 embedded in feature dirs) |

---

## 2. DEPENDENCIES

### State Management
| Package | Version | Notes |
|---|---|---|
| *(none)* | — | Uses `StatefulWidget` + `setState()` throughout |

**Target conflict:** `flutter_riverpod` is **absent**.

---

### Navigation
| Package | Version | Notes |
|---|---|---|
| *(none)* | — | Uses Navigator 1.0 (`Navigator.push/pop`) everywhere |

**Target conflict:** `go_router` is **absent**.

---

### Networking
| Package | Version | Notes |
|---|---|---|
| `dio` | `^5.9.0` | Primary HTTP client |
| `http` | `^1.4.0` | Secondary — both present simultaneously |

**Target match:** `dio` ✓. `http` is redundant alongside `dio`.

---

### Local Storage
| Package | Version |
|---|---|
| `shared_preferences` | `^2.5.3` |
| `flutter_dotenv` | `^5.0.2` |
| `path_provider` | `^2.1.2` |

No `flutter_secure_storage` or `hive`.

---

### Firebase
**None.** No Firebase packages in pubspec. No `google-services.json` or `GoogleService-Info.plist` found anywhere in the project.

---

### Code Generation
**None.** No `freezed`, `json_serializable`, or `build_runner`.

**Target conflict:** `freezed` is **absent**.

---

### UI / Design Packages
| Package | Version |
|---|---|
| `cupertino_icons` | `^1.0.8` |
| `flutter_svg` | `^2.0.10` |
| `lottie` | `^3.1.0` |
| `cached_network_image` | `^3.3.1` |
| `photo_view` | `^0.15.0` |
| `dotted_border` | `^3.1.0` |
| `calendar_date_picker2` | `^2.0.1` |
| `fluttertoast` | `^9.0.0` |
| `image_picker` | `^1.0.7` |
| `image_cropper` | `^10.0.0+1` |
| `file_picker` | `^8.0.0` |
| `open_file` | `^3.3.2` |
| `video_player` | `^2.8.2` |
| `intl` | `^0.19.0` |

---

### Maps / Location
| Package | Version |
|---|---|
| `google_maps_flutter` | `^2.6.0` |
| `geolocator` | `^11.0.0` |
| `geocoding` | `^2.1.1` |
| `google_places_flutter` | `^2.0.6` |

---

### Payment
| Package | Version |
|---|---|
| `flutter_stripe` | `^12.1.1` |

---

### Testing
| Package | Version | Notes |
|---|---|---|
| `flutter_test` | SDK | Built-in only |
| `flutter_lints` | `^5.0.0` | Lint rules |

**Target conflict:** `mocktail` is **absent**. No test files exist beyond the default generated `test/widget_test.dart`.

---

### Other
| Package | Version |
|---|---|
| `connectivity_plus` | `^7.0.0` |
| `url_launcher` | `^6.2.5` |
| `flutter_launcher_icons` | `^0.14.3` (dev) |

---

### Target Stack Conflict Summary

| Target Package | Status |
|---|---|
| `flutter_riverpod` | ❌ Absent |
| `go_router` | ❌ Absent |
| `dio` | ✅ Present |
| `freezed` | ❌ Absent |
| `mocktail` | ❌ Absent |

---

## 3. FOLDER STRUCTURE

### Current tree (`lib/`, 2 levels deep)

```
lib/
├── main.dart
├── main_dev.dart
├── main_prod.dart
├── MainScreen.dart
├── auth/
│   ├── new_login_screen.dart
│   ├── new_sing_up_screen.dart
│   ├── new_forgot_passwrod_screen.dart
│   ├── new_forgot_otp_screen.dart
│   ├── new_new_passwrod_screen.dart
│   └── Password_successfull.dart
├── Booking/
│   ├── booking_all_screen.dart
│   ├── bookin_review_confirm.dart
│   ├── cancel_booking.dart
│   ├── MY_SelectBookingType.dart
│   ├── Shoot_updated_screen.dart
│   ├── upcoming_booking_event_summary.dart
│   └── upcoming_event_summary_managebooking.dart
├── config/
│   └── env.dart
├── Customtextfiled/
│   └── CustomInputField.dart
├── Home/
│   ├── HomeSekect/          ← recommended details, profile view, location, payment method
│   ├── NewBookingFlow/      ← multi-step booking (3 subdirs)
│   └── New_Home/            ← new_home_screen.dart, home_controller.dart
├── Model/
│   └── HomeModel.dart
├── MyProfile/
│   ├── DeleteAccount/       ← delete_account.dart, delete_account_otp_screen.dart
│   ├── my_profile.dart
│   ├── edit_profile.dart
│   ├── Booking_History_screen.dart
│   ├── Favourite_screen.dart
│   ├── Change_Password_screen.dart
│   ├── app_preferences.dart
│   ├── myprofile_enter_otp_screen.dart
│   └── myprofile_new_password_screen.dart
├── No_internet/
│   └── internet_helper.dart
├── OnbodingScreen/
│   └── onboding_screen.dart
├── service/
│   ├── api_service.dart
│   ├── api_endpoints.dart
│   ├── google_config.dart
│   ├── internet_service.dart
│   └── shared_service.dart
├── SplashScreen/
│   └── splash_screen.dart
├── utility/
│   ├── ColorCode.dart
│   ├── images.dart
│   ├── commen.dart
│   └── date_time_utils.dart
└── widgets/
    ├── TopMessage.dart
    └── loding.dart
```

### Comparison against target structure

**Target:** `lib/app/`, `lib/core/`, `lib/features/`, `lib/shared/`, `lib/dummy/`

| Target Dir | Present? | Notes |
|---|---|---|
| `lib/app/` | ❌ | No app-level routing/theme dir |
| `lib/core/` | ❌ | `service/`, `config/`, `utility/` serve this role but aren't named `core/` |
| `lib/features/` | ❌ | Feature code lives in `auth/`, `Home/`, `Booking/`, `MyProfile/` at the root |
| `lib/shared/` | ❌ | `widgets/` and `Customtextfiled/` serve this role |
| `lib/dummy/` | ❌ | Absent |

**Rating: Completely different** — no overlap with the target directory naming or hierarchy.

---

## 4. FLAVORS / ENVIRONMENTS

### Configured Environments

| Environment | Entry Point | Notes |
|---|---|---|
| `dev` | `lib/main_dev.dart` | Calls `startApp(Environment.dev)` |
| `prod` | `lib/main_prod.dart` | Calls `startApp(Environment.prod)` |
| `staging` | ❌ Not configured | No `main_staging.dart` |

### `flavor_config.dart` Pattern

**Absent.** The project uses a hand-rolled `lib/config/env.dart` with an `Env` class and `Environment` enum. It does not follow the `FlavorConfig` pattern.

Notable issue: both `dev` and `prod` currently resolve to the **same** `apiUrl` (`https://mobile.beige.app/api/`) and `imageUrl`. The prod Stripe key is a placeholder string (`PLACE_HOLDER_LIVE_STRIPE_KEY`).

### Android Flavor Config

**Configured** in `android/app/build.gradle.kts`:
- `flavorDimensions += "environment"`
- `productFlavors`: `dev` (applicationId suffix `.dev`, app name "Beige Dev") and `prod` (app name "Beige")
- No per-flavor `google-services.json` files — `android/app/src/` only has `debug/`, `main/`, `profile/` (standard Flutter dirs, not flavor dirs)

### iOS Flavor Config

**Configured** via xcconfig + schemes:
- Schemes: `dev.xcscheme`, `prod.xcscheme`, `Runner.xcscheme`
- Per-flavor xcconfig: `Debug-dev.xcconfig`, `Debug-prod.xcconfig`, `Release-dev.xcconfig`, `Release-prod.xcconfig` ✓

### Firebase Config Files Per Flavor

| Platform | Status |
|---|---|
| Android `google-services.json` | ❌ Not found (no Firebase) |
| iOS `GoogleService-Info.plist` | ❌ Not found (no Firebase) |

No Firebase is integrated — the per-flavor Firebase config question is moot for the current state of the project.