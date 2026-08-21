import 'package:beige/core/notifications/data/push_token_remote_datasource.dart';
import 'package:beige/core/notifications/data/push_token_repository_impl.dart';
import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements PushTokenRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late PushTokenRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = PushTokenRepositoryImpl(remote);
  });

  group('saveToken', () {
    test('happy path returns Right(unit)', () async {
      when(
        () => remote.saveToken(
          fcmToken: any(named: 'fcmToken'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenAnswer((_) async => {'error': false});

      final result = await repo.saveToken(fcmToken: 'tok', sessionId: 'sid');

      expect(result, equals(const Right<AppException, Unit>(unit)));
      verify(
        () => remote.saveToken(fcmToken: 'tok', sessionId: 'sid'),
      ).called(1);
    });

    test('backend error flag maps to Left(AppException)', () async {
      when(
        () => remote.saveToken(
          fcmToken: any(named: 'fcmToken'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenAnswer((_) async => {'error': true, 'message': 'nope'});

      final result = await repo.saveToken(fcmToken: 'tok', sessionId: 'sid');

      expect(result.isLeft(), isTrue);
    });

    test('thrown exception is caught as Left', () async {
      when(
        () => remote.saveToken(
          fcmToken: any(named: 'fcmToken'),
          sessionId: any(named: 'sessionId'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await repo.saveToken(fcmToken: 'tok', sessionId: 'sid');

      expect(result.isLeft(), isTrue);
    });
  });

  group('removeToken', () {
    test('happy path returns Right(unit)', () async {
      when(
        () => remote.removeToken(sessionId: any(named: 'sessionId')),
      ).thenAnswer((_) async => {'error': false});

      final result = await repo.removeToken(sessionId: 'sid');

      expect(result, equals(const Right<AppException, Unit>(unit)));
      verify(() => remote.removeToken(sessionId: 'sid')).called(1);
    });

    test('backend error flag maps to Left(AppException)', () async {
      when(
        () => remote.removeToken(sessionId: any(named: 'sessionId')),
      ).thenAnswer((_) async => {'error': true, 'message': 'nope'});

      final result = await repo.removeToken(sessionId: 'sid');

      expect(result.isLeft(), isTrue);
    });
  });
}
