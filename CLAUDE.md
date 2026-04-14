# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run in development
flutter run --dart-define=ENV=dev

# Run in production
flutter run --dart-define=ENV=prod

# Build
flutter build apk --dart-define=ENV=prod
flutter build ios --dart-define=ENV=prod

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
`lib/service/config.dart` — `AppConfig.setEnvironment(env)` reads `--dart-define=ENV=dev|prod` at startup (called from `main()`):
- **dev**: `https://mobile.beige.app/api/`
- **prod**: `https://api.naturecuretech.com/api/`

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