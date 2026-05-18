import 'dart:convert';

import 'package:beige/core/restoration/restoration_keys.dart';
import 'package:beige/core/restoration/route_restoration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RouteRestorationService.shouldPersist', () {
    test('skips public auth routes', () {
      expect(RouteRestorationService.shouldPersist('/login'), isFalse);
      expect(RouteRestorationService.shouldPersist('/signup'), isFalse);
      expect(RouteRestorationService.shouldPersist('/forgot-password'),
          isFalse);
      expect(RouteRestorationService.shouldPersist('/forgot-otp'), isFalse);
      expect(RouteRestorationService.shouldPersist('/reset-password'), isFalse);
      expect(
          RouteRestorationService.shouldPersist('/password-success'), isFalse);
    });

    test('skips splash and onboarding', () {
      expect(RouteRestorationService.shouldPersist('/splash'), isFalse);
      expect(RouteRestorationService.shouldPersist('/onboarding'), isFalse);
    });

    test('skips sensitive profile screens', () {
      expect(RouteRestorationService.shouldPersist('/profile-otp'), isFalse);
      expect(
          RouteRestorationService.shouldPersist('/profile-new-password'),
          isFalse);
      expect(
          RouteRestorationService.shouldPersist('/change-password'), isFalse);
      expect(RouteRestorationService.shouldPersist('/delete-account-otp'),
          isFalse);
    });

    test('skips terminal payment-success', () {
      expect(
        RouteRestorationService.shouldPersist('/payment-success/42'),
        isFalse,
      );
    });

    test('persists booking-flow routes (Phase B drafts handle extra)', () {
      expect(RouteRestorationService.shouldPersist('/content-type'), isTrue);
      expect(RouteRestorationService.shouldPersist('/shoot-date-time'), isTrue);
      expect(RouteRestorationService.shouldPersist('/finding-perfect'), isTrue);
      expect(
        RouteRestorationService.shouldPersist('/manage-booking/12'),
        isTrue,
      );
      expect(
        RouteRestorationService.shouldPersist('/cancel-booking/12'),
        isTrue,
      );
    });

    test('persists shell tab + sub-screen routes', () {
      expect(RouteRestorationService.shouldPersist('/'), isTrue);
      expect(RouteRestorationService.shouldPersist('/my-shoots'), isTrue);
      expect(RouteRestorationService.shouldPersist('/favourites'), isTrue);
      expect(RouteRestorationService.shouldPersist('/profile'), isTrue);
      expect(RouteRestorationService.shouldPersist('/edit-profile'), isTrue);
      expect(
        RouteRestorationService.shouldPersist('/view-profile/12'),
        isTrue,
      );
      expect(
        RouteRestorationService.shouldPersist('/payment-method/12'),
        isTrue,
      );
      expect(
        RouteRestorationService.shouldPersist('/review-confirm/12'),
        isTrue,
      );
    });
  });

  group('RouteRestorationService.persist + readRestorable', () {
    late SharedPreferences prefs;
    late RouteRestorationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = RouteRestorationService(prefs);
    });

    test('persisted route round-trips', () async {
      await service.persist(
        matchedLocation: '/view-profile/7',
        queryParameters: const {'src': 'home'},
        pathParameters: const {'id': '7'},
      );
      final restored = service.readRestorable();
      expect(restored, isNotNull);
      expect(restored!.location, '/view-profile/7');
      expect(restored.query, equals({'src': 'home'}));
      expect(restored.pathParams, equals({'id': '7'}));
      expect(restored.toUri(), '/view-profile/7?src=home');
    });

    test('skip-set route is not persisted', () async {
      await service.persist(matchedLocation: '/login');
      expect(service.readRestorable(), isNull);
    });

    test('expired TTL returns null', () async {
      await service.persist(matchedLocation: '/favourites');
      final pastTs = DateTime.now()
          .subtract(kRestorationTtl + const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      await prefs.setInt(RestorationKeys.lastActiveTs, pastTs);
      expect(service.readRestorable(), isNull);
    });

    test('corrupt JSON wipes record', () async {
      await prefs.setString(RestorationKeys.lastRoute, '/favourites');
      await prefs.setString(RestorationKeys.lastQueryJson, 'not-json');
      await prefs.setInt(
        RestorationKeys.lastActiveTs,
        DateTime.now().millisecondsSinceEpoch,
      );
      expect(service.readRestorable(), isNull);
      expect(prefs.getString(RestorationKeys.lastRoute), isNull);
    });

    test('clearAll wipes every restoration key', () async {
      await service.persist(matchedLocation: '/favourites');
      await service.clearAll();
      for (final k in RestorationKeys.allKeys) {
        expect(prefs.get(k), isNull, reason: 'key $k should be cleared');
      }
    });

    test('schema-version mismatch wipes legacy values on construct', () async {
      await prefs.setString(RestorationKeys.lastRoute, '/legacy');
      await prefs.setInt(
        RestorationKeys.lastActiveTs,
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setInt(RestorationKeys.schemaVersion, 999);

      final fresh = RouteRestorationService(prefs);
      expect(fresh.readRestorable(), isNull);
      expect(
        prefs.getInt(RestorationKeys.schemaVersion),
        RestorationKeys.currentSchemaVersion,
      );
    });

    test('toUri encodes query params safely', () async {
      await service.persist(
        matchedLocation: '/recommended/9',
        queryParameters: const {'bookingId': '12', 'src': 'home & away'},
        pathParameters: const {'id': '9'},
      );
      final restored = service.readRestorable()!;
      final parsed = Uri.parse(restored.toUri());
      expect(parsed.path, '/recommended/9');
      expect(parsed.queryParameters['bookingId'], '12');
      expect(parsed.queryParameters['src'], 'home & away');
    });

    test('persisted path params survive JSON round-trip', () async {
      await service.persist(
        matchedLocation: '/view-profile/12',
        pathParameters: const {'id': '12'},
      );
      final raw = prefs.getString(RestorationKeys.lastPathParamsJson);
      expect(jsonDecode(raw!), equals({'id': '12'}));
    });
  });
}
