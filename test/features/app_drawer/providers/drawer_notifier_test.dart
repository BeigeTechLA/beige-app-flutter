import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/app_drawer/providers/drawer_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('drawerUserProvider', () {
    test(
      'refreshes user details after logout and login as another user',
      () async {
        final prefs = await createMockPrefs({
          'isLoggedIn': true,
          'user_id': '1',
          'name': 'User One',
          'email': 'one@example.com',
          'profile_image_url': 'user-one.jpg',
        });
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final firstUser = await container.read(drawerUserProvider.future);
        expect(firstUser['name'], 'User One');
        expect(firstUser['email'], 'one@example.com');

        await prefs.clear();
        container.read(authStateProvider.notifier).updateState(false);

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('user_id', '2');
        await prefs.setString('name', 'User Two');
        await prefs.setString('email', 'two@example.com');
        await prefs.setString('profile_image_url', 'user-two.jpg');
        container.read(authStateProvider.notifier).updateState(true);

        final secondUser = await container.read(drawerUserProvider.future);
        expect(secondUser['name'], 'User Two');
        expect(secondUser['email'], 'two@example.com');
        expect(secondUser['profile_image_url'], 'user-two.jpg');
      },
    );
  });
}
