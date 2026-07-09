import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/core/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('currentUserIdProvider', () {
    test('returns persisted user_id when prefs has it', () async {
      final prefs = await createMockPrefs({
        'isLoggedIn': true,
        'user_id': '198',
      });
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserIdProvider), '198');
    });

    test('returns null when user_id key missing (logged out)', () async {
      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserIdProvider), isNull);
    });

    test('returns null when user_id is empty string', () async {
      final prefs = await createMockPrefs({'user_id': ''});
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserIdProvider), isNull);
    });
  });

  group('currentUserProvider', () {
    test('returns CurrentUser snapshot when logged in', () async {
      final prefs = await createMockPrefs({
        'user_id': '198',
        'name': 'Arpit S',
        'email': 'arpits85@gmail.com',
        'user_role': 'client',
      });
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.id, '198');
      expect(user.name, 'Arpit S');
      expect(user.email, 'arpits85@gmail.com');
      expect(user.role, 'client');
    });

    test('returns null when no user_id persisted', () async {
      final prefs = await createMockPrefs({'name': 'Stale'});
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserProvider), isNull);
    });

    test('role is null when user_role not yet persisted', () async {
      final prefs = await createMockPrefs({'user_id': '198'});
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserProvider)?.role, isNull);
    });
  });
}
