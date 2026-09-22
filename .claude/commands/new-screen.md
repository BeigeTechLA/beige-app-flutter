# New Screen

Add a new screen with Notifier + State to an existing feature in the Beige app.

## Gather Info

Ask the user for:
1. **Feature name** (existing feature, snake_case, e.g. `auth`, `booking`, `shoot`)
2. **Screen name** (snake_case, e.g. `forgot_password`, `shoot_summary`)
3. **Does this screen fetch data on load?** (yes = auto-fetch in build(), no = action-triggered)
4. **Which repository provider?** (e.g. `authRepositoryProvider` — check `lib/features/$feature/presentation/providers/${feature}_providers.dart`)

## Files to Create

Given feature `$feature` and screen `$screen`:

### 1. State
**Path:** `lib/features/$feature/presentation/providers/${screen}_state.dart`

```dart
enum ${Screen}Status { initial, loading, success, error }

class ${Screen}State {
  final ${Screen}Status status;
  final String? errorMessage;

  const ${Screen}State({
    this.status = ${Screen}Status.initial,
    this.errorMessage,
  });

  ${Screen}State copyWith({
    ${Screen}Status? status,
    String? errorMessage,
  }) {
    return ${Screen}State(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

Add feature-specific fields as needed (data models, form values, etc.). Every field must appear in both the constructor and `copyWith()`.

### 2. Notifier
**Path:** `lib/features/$feature/presentation/providers/${screen}_notifier.dart`

**Action-triggered pattern** (form submit, button press):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '${feature}_providers.dart';
import '${screen}_state.dart';

class ${Screen}Notifier extends AutoDisposeNotifier<${Screen}State> {
  @override
  ${Screen}State build() => const ${Screen}State();

  Future<void> submit({required String param}) async {
    state = state.copyWith(status: ${Screen}Status.loading);

    final repo = ref.read(${feature}RepositoryProvider);
    final result = await repo.methodName(param: param);

    result.fold(
      (error) => state = state.copyWith(
        status: ${Screen}Status.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: ${Screen}Status.success,
      ),
    );
  }
}

final ${screen}NotifierProvider =
    NotifierProvider.autoDispose<${Screen}Notifier, ${Screen}State>(
  ${Screen}Notifier.new,
);
```

**Data-fetch pattern** (loads data on screen open):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '${feature}_providers.dart';
import '${screen}_state.dart';

class ${Screen}Notifier extends AutoDisposeNotifier<${Screen}State> {
  @override
  ${Screen}State build() {
    _fetchData();
    return const ${Screen}State(status: ${Screen}Status.loading);
  }

  Future<void> _fetchData() async {
    final repo = ref.read(${feature}RepositoryProvider);
    final result = await repo.getData();

    result.fold(
      (error) => state = state.copyWith(
        status: ${Screen}Status.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: ${Screen}Status.success,
        // Set data fields here
      ),
    );
  }
}

final ${screen}NotifierProvider =
    NotifierProvider.autoDispose<${Screen}Notifier, ${Screen}State>(
  ${Screen}Notifier.new,
);
```

### 3. Screen
**Path:** `lib/features/$feature/presentation/screens/${screen}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/route_names.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/${screen}_notifier.dart';
import '../providers/${screen}_state.dart';

class ${Screen}Screen extends ConsumerStatefulWidget {
  const ${Screen}Screen({super.key});

  @override
  ConsumerState<${Screen}Screen> createState() => _${Screen}ScreenState();
}

class _${Screen}ScreenState extends ConsumerState<${Screen}Screen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(${screen}NotifierProvider);
    final isLoading = state.status == ${Screen}Status.loading;

    ref.listen(${screen}NotifierProvider, (prev, next) {
      if (next.status == ${Screen}Status.success) {
        // TODO: Navigate on success
        // context.goNamed(RouteNames.nextScreen);
      }
      if (next.status == ${Screen}Status.error && next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Title'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Placeholder(), // TODO: Build UI
    );
  }
}
```

### 4. Add Route

**In `lib/app/route_names.dart`**, add:
```dart
static const $screenCamelCase = '$screen_snake';
```

**In `lib/app/router.dart`**, add import and GoRoute:
```dart
import '../features/$feature/presentation/screens/${screen}_screen.dart';

// Inside routes list:
GoRoute(
  path: '/$screen-kebab',
  name: RouteNames.$screenCamelCase,
  builder: (context, state) => const ${Screen}Screen(),
),
```

## Conventions

- `$screen` = snake_case (e.g. `forgot_password`)
- `$Screen` = PascalCase (e.g. `ForgotPassword`)
- `$screenCamelCase` = camelCase for RouteNames (e.g. `forgotPassword`)
- `$screen-kebab` = kebab-case for URL path (e.g. `forgot-password`)
- Provider declared at BOTTOM of notifier file, NOT in providers.dart
- Screen uses `ConsumerStatefulWidget` (for controllers, dispose). Use `ConsumerWidget` only if pure reactive with no controllers
- `ref.watch()` in build for UI state
- `ref.listen()` in build for side effects (navigation, snackbars)
- `ref.read()` for method calls outside build
- Never put navigation/dialogs inside Notifiers

## After Creation

- Run `flutter analyze` on created files
- Remind user to wire up the actual repository method if it doesn't exist yet (use `/new-endpoint`)
