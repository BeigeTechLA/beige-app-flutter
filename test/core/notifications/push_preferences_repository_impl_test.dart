import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/notifications/data/push_preferences_remote_datasource.dart';
import 'package:beige/core/notifications/data/push_preferences_repository_impl.dart';
import 'package:beige/core/notifications/domain/notification_preferences.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements PushPreferencesRemoteDataSource {}

class _FakePrefs extends Fake implements NotificationPreferences {}

void main() {
  setUpAll(() => registerFallbackValue(_FakePrefs()));

  late _MockRemote remote;
  late PushPreferencesRepositoryImpl repo;

  const prefs = NotificationPreferences(
    pushEnabled: true,
    topics: {'shoots': true, 'payments': false},
  );

  setUp(() {
    remote = _MockRemote();
    repo = PushPreferencesRepositoryImpl(remote);
  });

  test('happy path returns Right(unit) and forwards args', () async {
    when(
      () => remote.updatePreferences(
        sessionId: any(named: 'sessionId'),
        preferences: any(named: 'preferences'),
      ),
    ).thenAnswer((_) async => {'error': false});

    final result = await repo.updatePreferences(
      sessionId: 'sid',
      preferences: prefs,
    );

    expect(result, equals(const Right<AppException, Unit>(unit)));
    verify(
      () => remote.updatePreferences(sessionId: 'sid', preferences: prefs),
    ).called(1);
  });

  test('backend error flag maps to Left(AppException)', () async {
    when(
      () => remote.updatePreferences(
        sessionId: any(named: 'sessionId'),
        preferences: any(named: 'preferences'),
      ),
    ).thenAnswer((_) async => {'error': true, 'message': 'nope'});

    final result = await repo.updatePreferences(
      sessionId: 'sid',
      preferences: prefs,
    );

    expect(result.isLeft(), isTrue);
  });

  test('thrown exception is caught as Left', () async {
    when(
      () => remote.updatePreferences(
        sessionId: any(named: 'sessionId'),
        preferences: any(named: 'preferences'),
      ),
    ).thenThrow(Exception('boom'));

    final result = await repo.updatePreferences(
      sessionId: 'sid',
      preferences: prefs,
    );

    expect(result.isLeft(), isTrue);
  });

  test('toJson emits push_enabled + topics shape', () {
    expect(prefs.toJson(), {
      'push_enabled': true,
      'topics': {'shoots': true, 'payments': false},
    });
  });

  group('getPreferences', () {
    test('maps a plain response to NotificationPreferences', () async {
      when(
        () => remote.getPreferences(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => {
          'push_enabled': false,
          'topics': {'shoots': true, 'system': false},
        },
      );

      final result = await repo.getPreferences(sessionId: 'sid');

      final value = result.getOrElse(
        () => const NotificationPreferences(pushEnabled: true, topics: {}),
      );
      expect(value.pushEnabled, isFalse);
      expect(value.topics['shoots'], isTrue);
      expect(value.topics['system'], isFalse);
    });

    test('thrown exception is caught as Left', () async {
      when(
        () => remote.getPreferences(sessionId: any(named: 'sessionId')),
      ).thenThrow(Exception('boom'));

      final result = await repo.getPreferences(sessionId: 'sid');

      expect(result.isLeft(), isTrue);
    });
  });

  group('NotificationPreferences.fromMap', () {
    test('unwraps data + notification_preferences envelope', () {
      final parsed = NotificationPreferences.fromMap({
        'data': {
          'notification_preferences': {
            'push_enabled': true,
            'topics': {'shoots': 1, 'payments': 0, 'files': 'true'},
          },
        },
      });

      expect(parsed.pushEnabled, isTrue);
      expect(parsed.topics['shoots'], isTrue);
      expect(parsed.topics['payments'], isFalse);
      expect(parsed.topics['files'], isTrue);
    });

    test('missing push_enabled defaults to true', () {
      final parsed = NotificationPreferences.fromMap({'topics': {}});
      expect(parsed.pushEnabled, isTrue);
    });
  });
}
