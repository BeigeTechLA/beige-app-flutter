# Add Route

Quick-add a GoRouter route to the Beige app.

## Gather Info

Ask the user for:
1. **Route name** (snake_case, e.g. `shoot_summary`, `edit_profile`)
2. **Screen class name** (PascalCase, e.g. `ShootSummaryScreen`)
3. **Screen import path** (e.g. `../features/shoot/presentation/screens/shoot_summary_screen.dart`)
4. **Requires auth?** (yes = protected, no = public)
5. **Takes extra params?** (yes = what type, no)
6. **Is it a sub-route?** (yes = nested under which parent route, no = top-level)

## Files to Edit

### 1. Route Names
**File:** `lib/app/route_names.dart`

Add constant inside `RouteNames` class:
```dart
static const $routeNameCamelCase = '$route_name_snake';
```

Place it in the correct section (Auth, Main tabs, Booking flow, etc.) alphabetically within that section.

### 2. Router
**File:** `lib/app/router.dart`

**Add import** at top (alphabetically among feature imports):
```dart
import '$screenImportPath';
```

**Add GoRoute** in the appropriate location:

Basic route (no params):
```dart
GoRoute(
  path: '/$route-name-kebab',
  name: RouteNames.$routeNameCamelCase,
  builder: (context, state) => const ${ScreenClass}(),
),
```

Route with extra params:
```dart
GoRoute(
  path: '/$route-name-kebab',
  name: RouteNames.$routeNameCamelCase,
  builder: (context, state) {
    final data = state.extra as $DataType;
    return ${ScreenClass}(data: data);
  },
),
```

Route with path params:
```dart
GoRoute(
  path: '/$route-name-kebab/:id',
  name: RouteNames.$routeNameCamelCase,
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ${ScreenClass}(id: id);
  },
),
```

**If public route**, add path to `_publicRoutes` set:
```dart
const _publicRoutes = {
  '/splash',
  '/login',
  // ...
  '/$route-name-kebab',  // Add here
};
```

## Naming Conventions

| Input | Format | Example |
|-------|--------|---------|
| Route name constant | camelCase | `shootSummary` |
| Route name value | snake_case | `'shoot_summary'` |
| URL path | kebab-case | `/shoot-summary` |
| Screen class | PascalCase | `ShootSummaryScreen` |

## Navigation Usage

After adding the route, navigate to it using:
```dart
// Replace current screen:
context.goNamed(RouteNames.$routeNameCamelCase);

// Push on stack (allows back):
context.pushNamed(RouteNames.$routeNameCamelCase);

// With extra data:
context.pushNamed(RouteNames.$routeNameCamelCase, extra: yourData);

// With path params:
context.pushNamed(RouteNames.$routeNameCamelCase, pathParameters: {'id': '123'});
```

## After Edit

- Run `flutter analyze` on `lib/app/router.dart` and `lib/app/route_names.dart`
- Verify route loads: check that the screen class constructor matches what the builder passes
