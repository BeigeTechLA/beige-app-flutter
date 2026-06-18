# Clean Architecture + Riverpod — Beginner's Guide

This guide explains how the Beige app is organized. Read this first if you're
new to the codebase.

## Why Clean Architecture?

We split code into **layers**, each with one job. UI code doesn't talk to the
network directly. Business logic doesn't know about widgets. This keeps things:

- **Testable** — swap a real API for a fake one without touching the UI.
- **Predictable** — bugs live in a known layer.
- **Replaceable** — change Dio to another HTTP client, only the data layer cares.

## The Three Layers

Every feature in `lib/features/<name>/` has three folders:

```
features/auth/
├── data/           ← Talks to the outside world (API, DB, storage)
├── domain/         ← Pure Dart — entities + repository contracts
└── presentation/   ← Flutter UI + Riverpod state
```

Rule of thumb: **arrows only point inward**.

```
presentation  →  domain  ←  data
   (UI)        (contract)   (impl)
```

UI depends on domain. Data implements domain. UI never imports data directly.

### 1. Data Layer — the "how"

- **datasources/** — raw API calls using `DioClient`. Returns `Map<String, dynamic>`.
- **repositories/** — the implementation. Wraps the datasource, catches errors,
  maps raw JSON to domain entities, returns `Either<AppException, T>`.

### 2. Domain Layer — the "what"

- **entities/** — plain Dart classes (e.g. `UserEntity`). No JSON, no Flutter.
- **repositories/** — an **abstract class** describing what operations exist.
  This is the contract the UI depends on.

Example contract (`auth_repository.dart`):
```dart
abstract class AuthRepository {
  Future<Either<AppException, UserEntity>> login({
    required String email,
    required String password,
  });
}
```

### 3. Presentation Layer — the UI

- **providers/** — Riverpod `Notifier` + `State` classes. Holds screen state.
- **screens/** — `ConsumerWidget` / `ConsumerStatefulWidget`. Reads state,
  renders UI, calls notifier methods on user input.

## Riverpod in 60 Seconds

Riverpod is our state manager. Three concepts to know:

| Concept | Purpose |
|---------|---------|
| **Provider** | A global handle that gives you a value. Created once, looked up by `ref`. |
| **Notifier** | A class that holds mutable state. UI rebuilds when state changes. |
| **State class** | An **immutable** snapshot of what the screen needs to render. |

### Ref methods

| Method | Use it when |
|--------|-------------|
| `ref.watch(p)` | Inside `build()` — rebuild when `p` changes. |
| `ref.read(p)` | Inside callbacks (button taps, notifier methods). One-shot read. |
| `ref.listen(p, cb)` | Side effects (navigate, snackbar) when state changes. |

**Never call `ref.read` inside `build()`.** Always `ref.watch`.

## How a Feature Wires Together

Real example: login.

**1. State** (`login_state.dart`) — what the screen shows:
```dart
enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  final UserEntity? user;
  // + copyWith()
}
```

**2. Notifier** (`login_notifier.dart`) — what the screen does:
```dart
class LoginNotifier extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: LoginStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password);

    result.fold(
      (error) => state = state.copyWith(
        status: LoginStatus.error, errorMessage: error.message),
      (user)  => state = state.copyWith(
        status: LoginStatus.success, user: user),
    );
  }
}

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
```

**3. Screen** — reads state, calls notifier:
```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginNotifierProvider);

    // Side effects via listen — never inside build logic
    ref.listen(loginNotifierProvider, (prev, next) {
      if (next.status == LoginStatus.success) {
        context.goNamed(RouteNames.home);
      }
    });

    return ElevatedButton(
      onPressed: () => ref
          .read(loginNotifierProvider.notifier)
          .login(email: '...', password: '...'),
      child: state.status == LoginStatus.loading
          ? const CircularProgressIndicator()
          : const Text('Log in'),
    );
  }
}
```

## Data Flow (Top to Bottom)

User taps "Login":

```
LoginScreen
  └─ ref.read(loginNotifierProvider.notifier).login(...)
       └─ LoginNotifier sets state to loading
            └─ calls AuthRepository.login()        ← domain contract
                 └─ AuthRepositoryImpl.login()     ← data impl
                      └─ AuthRemoteDataSource     ← raw API
                           └─ DioClient.post(...)
                      ← returns Map
                 ← wraps in Either<AppException, UserEntity>
            ← Notifier folds Either → updates state
       └─ Screen rebuilds via ref.watch
```

The screen never knows Dio exists. The data layer never knows widgets exist.

## Golden Rules (Don't Break These)

1. **UI never imports `data/`** — only `domain/` and `presentation/`.
2. **Repositories return `Either<AppException, T>`** — never throw, never return raw maps.
3. **All API calls go through `DioClient`** — never `Dio()` or `http` directly.
4. **Screen providers use `.autoDispose`** — state clears when screen closes.
5. **No `ref.read` inside `build()`** — use `ref.watch`.
6. **No `Navigator.push`** — always `context.goNamed()` / `context.pushNamed()`.
7. **No magic numbers / inline colors / inline text styles** — use `AppSpacing`,
   `AppColors`, `AppTextStyles`.

## Where to Look Next

- `lib/features/auth/` — small, complete example of all three layers.
- `lib/core/network/` — `DioClient`, interceptors, `AppException` hierarchy.
- `lib/app/router.dart` — navigation + auth guard.
- `docs/guides/FLUTTER_BASE_GUIDELINES.md` — coding standards.
- `docs/guides/FLUTTER_DESIGN_SYSTEM.md` — design tokens.
- `docs/guides/FLUTTER_TESTING_GUIDELINES.md` — testing patterns.

## Scaffolding Shortcuts

Don't hand-write boilerplate. Use slash commands:

| Command | What it builds |
|---------|---------------|
| `/new-feature` | Whole feature module (data + domain + presentation) |
| `/new-screen` | Screen + notifier + state + route wiring |
| `/new-endpoint` | API method across datasource → repo interface → repo impl |
| `/add-route` | GoRoute + `RouteNames` constant |