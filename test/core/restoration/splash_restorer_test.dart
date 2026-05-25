import 'package:beige/core/restoration/splash_restorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const restorer = SplashRestorer();

  group('SplashRestorer.shouldRestore', () {
    test('returns true on happy path', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          isGuest: false,
          hasDeepLink: false,
          persistedRoute: '/favourites',
        ),
        isTrue,
      );
    });

    test('returns false when disabled by flag', () {
      expect(
        restorer.shouldRestore(
          isEnabled: false,
          isLoggedIn: true,
          isGuest: false,
          hasDeepLink: false,
          persistedRoute: '/favourites',
        ),
        isFalse,
      );
    });

    test('returns false when logged out', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: false,
          isGuest: false,
          hasDeepLink: false,
          persistedRoute: '/favourites',
        ),
        isFalse,
      );
    });

    test('returns false in guest mode', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          isGuest: true,
          hasDeepLink: false,
          persistedRoute: '/favourites',
        ),
        isFalse,
      );
    });

    test('returns false when deep link present', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          isGuest: false,
          hasDeepLink: true,
          persistedRoute: '/favourites',
        ),
        isFalse,
      );
    });

    test('returns false when persisted route is null or empty', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          isGuest: false,
          hasDeepLink: false,
          persistedRoute: null,
        ),
        isFalse,
      );
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          isGuest: false,
          hasDeepLink: false,
          persistedRoute: '',
        ),
        isFalse,
      );
    });

    test('refuses to restore forbidden routes', () {
      for (final r in const [
        '/splash',
        '/login',
        '/signup',
        '/profile-otp',
        '/delete-account-otp',
      ]) {
        expect(
          restorer.shouldRestore(
            isEnabled: true,
            isLoggedIn: true,
            isGuest: false,
            hasDeepLink: false,
            persistedRoute: r,
          ),
          isFalse,
          reason: 'expected $r to be refused',
        );
      }
    });
  });
}
