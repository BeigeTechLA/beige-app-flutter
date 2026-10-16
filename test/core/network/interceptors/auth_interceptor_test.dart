import 'dart:convert';
import 'dart:typed_data';

import 'package:beige/core/network/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResponseAdapter implements HttpClientAdapter {
  final int status;
  final Object? body;

  _ResponseAdapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  group('API session invalidation', () {
    for (final status in [200, 401, 403]) {
      for (final code in [
        'SESSION_EXPIRED',
        'TOKEN_INVALID',
        'TOKEN_MISSING',
        'OTHER_ERROR',
        null,
      ]) {
        test(
          '$status / $code only logs out for invalid session codes',
          () async {
            var logoutCount = 0;
            final dio = Dio()
              ..httpClientAdapter = _ResponseAdapter(status, {
                'error': true,
                if (code != null) 'code': code,
                'message': 'Request failed',
              })
              ..interceptors.add(
                AuthInterceptor(
                  getToken: () async => 'saved-token',
                  onUnauthorized: () async {
                    logoutCount++;
                  },
                ),
              );
            addTearDown(() => dio.close());

            if (status == 200) {
              final response = await dio.get<dynamic>('/test');
              expect(response.data['code'], code);
            } else {
              await expectLater(
                dio.get<dynamic>('/test'),
                throwsA(isA<DioException>()),
              );
            }
            expect(
              logoutCount,
              code == 'SESSION_EXPIRED' || code == 'TOKEN_INVALID' ? 1 : 0,
            );
          },
        );
      }
    }

    test('unauthenticated requests do not trigger logout', () async {
      var loggedOut = false;
      final dio = Dio()
        ..httpClientAdapter = _ResponseAdapter(401, {'code': 'TOKEN_INVALID'})
        ..interceptors.add(
          AuthInterceptor(
            getToken: () async => null,
            onUnauthorized: () async {
              loggedOut = true;
            },
          ),
        );
      addTearDown(() => dio.close());
      await expectLater(
        dio.get<dynamic>('/test'),
        throwsA(isA<DioException>()),
      );
      expect(loggedOut, isFalse);
    });

    for (final body in [
      null,
      'Unauthorized',
      <Object?>[],
      {'error': true},
    ]) {
      test('malformed or uncoded response $body preserves session', () async {
        var loggedOut = false;
        final dio = Dio()
          ..httpClientAdapter = _ResponseAdapter(401, body)
          ..interceptors.add(
            AuthInterceptor(
              getToken: () async => 'saved-token',
              onUnauthorized: () async {
                loggedOut = true;
              },
            ),
          );
        addTearDown(() => dio.close());
        await expectLater(
          dio.get<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );
        expect(loggedOut, isFalse);
      });
    }
  });
}
