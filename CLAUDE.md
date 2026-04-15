# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run in development
flutter run --flavor dev -t lib/main_dev.dart

# Run in production
flutter run --flavor prod -t lib/main_prod.dart

# Build APK (release)
flutter build apk --flavor prod -t lib/main_prod.dart --release

# Build iOS (release)
flutter build ios --flavor prod -t lib/main_prod.dart --release

# Analyze / lint
flutter analyze

# Run tests
flutter test

# Regenerate launcher icons
flutter pub run flutter_launcher_icons:main
```

## Architecture

**Beige** is a Flutter app for booking photography/videography services. Users are either **Clients** (who book shoots) or **Creatives** (who offer services).

### State Management
No state management library — uses `StatefulWidget` + `setState()` throughout. `SharedPreferences` handles persistence (auth token, login state).

### Navigation
Standard `Navigator.push()/pop()` — no routing library. `MainScreen` manages a 4-tab bottom nav (Home, Book Shoot, Bookings, Messages) using `TabBar` + `setState`. Global `navigatorKey` and `scaffoldMessengerKey` are defined in `main.dart`.

### Environment / Config
`lib/config/env.dart` — `Env.init(environment)` sets API URLs and Stripe key per environment. Separate entry points select the environment:
- `lib/main_dev.dart` → dev (`https://mobile.beige.app/api/`)
- `lib/main_prod.dart` → prod (`https://api.naturecuretech.com/api/`)

Run with: `flutter run --flavor dev -t lib/main_dev.dart`

### API Layer
`lib/service/api_service.dart` — wraps `dio` + `http` with `fetchData()`, `postData()`, `putData()`. Auto-injects Bearer token from SharedPreferences. Endpoints are centralized in `lib/service/api_endpoints.dart`.

### Key Directories under `lib/`
| Path | Purpose |
|------|---------|
| `auth/` | Login, signup, forgot password, OTP |
| `Home/` | Home screen + all booking flow screens |
| `Home/NewBookingFlow/` | Multi-step booking: shoot type → crew size → review/payment |
| `Booking/` | Manage existing bookings, cancellation |
| `MyProfile/` | Profile view/edit, account deletion |
| `Creative/` | Creative user signup flow |
| `service/` | API client, endpoints, config, SharedPreferences wrapper |
| `utility/` | Color constants (`ColorCode.dart`), image asset paths (`images.dart`) |
| `widgets/` | Shared UI components |

### Assets
- Fonts: **Unbounded**, **Outfit**, **HelveticaNeue**
- SVGs, Lottie animations, and images live under `assets/`

### Payment
Stripe integration via `flutter_stripe` — payment screens are in `Home/NewBookingFlow/Book_Confirm/`.

### Maps / Location
Google Maps (`google_maps_flutter`), geolocation (`geolocator`), place search (`google_places_flutter`). `SelectLocationMapScreen.dart` handles location picking.