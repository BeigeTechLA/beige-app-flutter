import 'package:beige/config/env.dart';
import 'package:beige/core/network/dio_client.dart';
import 'package:beige/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:beige/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/core/storage/secure_token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:beige/core/providers/account_status_provider.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/core/network/interceptors/auth_interceptor.dart';
import 'package:beige/core/network/interceptors/retry_interceptor.dart';
import 'package:beige/features/account_deletion/data/account_deletion_repository.dart';
import 'package:beige/features/account_deletion/domain/deletion_request.dart';
import 'package:beige/features/account_deletion/presentation/deletion_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  Object? response = {
    'data': {
      'request_id': 'DEL-42',
      'status': 'deletion_pending',
      'scheduled_deletion_date': '2027-01-16',
    },
  };
  int statusCode = 200;
  Completer<void>? gate;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await gate?.future;
    return ResponseBody.fromString(
      jsonEncode(response),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RecordingAdapter adapter;
  late AccountDeletionRepository repo;
  late ProviderContainer container;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    adapter = RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'))
      ..httpClientAdapter = adapter;
    repo = AccountDeletionRepository(dio);
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        accountDeletionRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    dio.close();
  });

  for (final status in [
    'active',
    'deletion_pending',
    'deleted',
    'unexpected',
  ]) {
    test('login parses account_status $status without losing token', () async {
      Env.init(Environment.dev);
      final client = DioClient(getToken: () async => null);
      client.dio.httpClientAdapter = adapter;
      addTearDown(() => client.dio.close());
      adapter.response = {
        'account_status': status,
        'data': {
          'token': 'token',
          'user': {'id': 42},
        },
      };
      final result = await AuthRepositoryImpl(
        AuthRemoteDataSource(client),
      ).login(email: 'person@example.com', password: 'unused');
      result.fold((error) => fail(error.message), (user) {
        expect(user.accountStatus, AccountStatus.parse(status));
        expect(user.token, 'token');
      });
    });
  }

  test('four endpoints use documented methods, payloads and headers', () async {
    dio.interceptors.add(
      AuthInterceptor(getToken: () async => 'restricted-token'),
    );
    await repo.requestOtp();
    final result = await repo.confirm('012345');
    await repo.status();
    await repo.cancel();
    expect(adapter.requests.map((r) => r.method), [
      'POST',
      'POST',
      'GET',
      'PATCH',
    ]);
    expect(adapter.requests.map((r) => r.path), [
      'auth/user/delete-account/request',
      'auth/user/delete-account/confirm',
      'auth/user/delete-account/requests/me',
      'auth/user/delete-account/requests/me/cancel',
    ]);
    expect(adapter.requests.first.data, isNull);
    expect(adapter.requests[1].data, {'otp': '012345'});
    for (final request in adapter.requests) {
      expect(request.headers['Authorization'], 'Bearer restricted-token');
      expect(request.headers['user-type'], 3);
      expect(request.headers['user-type-name'], 'client');
      expect(request.headers['device-type'], anyOf('ios', 'android'));
    }
    expect(result.id, 'DEL-42');
    expect(result.dateLabel, 'January 16, 2027');
  });

  test(
    'server failures do not automatically repeat a deletion request',
    () async {
      adapter.statusCode = 503;
      dio.interceptors.add(
        RetryInterceptor(dio: dio, retryInterval: Duration.zero),
      );
      await expectLater(repo.confirm('123456'), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(1));
    },
  );

  test(
    'OTP only advances on server success and errors keep account active',
    () async {
      final notifier = container.read(deletionProvider.notifier);
      expect(await notifier.confirm('123456'), isFalse);
      expect(adapter.requests, isEmpty);
      expect(await notifier.requestOtp(), isTrue);
      expect(await notifier.confirm('12345'), isFalse);
      adapter.response = {'error': true, 'message': 'Code expired'};
      expect(await notifier.confirm('123456'), isFalse);
      expect(container.read(deletionProvider).error, 'Code expired');
      expect(container.read(accountStatusProvider), AccountStatus.active);
      adapter.response = {
        'data': {
          'request_id': 'DEL-42',
          'scheduled_deletion_date': '2027-01-16',
        },
      };
      expect(await notifier.confirm('123456'), isTrue);
      expect(
        container.read(accountStatusProvider),
        AccountStatus.deletionPending,
      );
      expect(
        container.read(sharedPreferencesProvider).getString('account_status'),
        'deletion_pending',
      );
      expect(container.read(deletionProvider).request?.id, 'DEL-42');
    },
  );

  test(
    'cancel failure stays restricted; success restores and retains request ID',
    () async {
      await container
          .read(accountStatusProvider.notifier)
          .setStatus(AccountStatus.deletionPending);
      final notifier = container.read(deletionProvider.notifier);
      await notifier.load();
      adapter.response = {'error': true, 'message': 'Unable to cancel'};
      expect(await notifier.cancel(), isFalse);
      expect(
        container.read(accountStatusProvider),
        AccountStatus.deletionPending,
      );
      expect(container.read(deletionProvider).cancelled, isFalse);
      adapter.response = {'message': 'Cancelled'};
      expect(await notifier.cancel(), isTrue);
      expect(container.read(accountStatusProvider), AccountStatus.active);
      expect(container.read(deletionProvider).cancelled, isTrue);
      expect(container.read(deletionProvider).request?.id, 'DEL-42');
    },
  );

  test(
    'double submission is ignored and detached responses cannot change session',
    () async {
      final notifier = container.read(deletionProvider.notifier);
      await notifier.requestOtp();
      adapter.gate = Completer<void>();
      final first = notifier.confirm('123456');
      expect(await notifier.confirm('123456'), isFalse);
      await Future<void>.delayed(Duration.zero);
      container.invalidate(deletionProvider);
      adapter.gate!.complete();
      expect(await first, isFalse);
      expect(container.read(accountStatusProvider), AccountStatus.active);
    },
  );

  test(
    'pending response code restricts authenticated session without logging out',
    () async {
      var loggedOut = false;
      adapter.statusCode = 403;
      adapter.response = {'code': 'ACCOUNT_DELETION_IN_PROGRESS'};
      dio.interceptors.add(
        AuthInterceptor(
          getToken: () async => 'token',
          onUnauthorized: () async {
            loggedOut = true;
          },
          onDeletionPending: () => container
              .read(accountStatusProvider.notifier)
              .setStatus(AccountStatus.deletionPending),
        ),
      );
      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      expect(loggedOut, isFalse);
      expect(
        container.read(accountStatusProvider),
        AccountStatus.deletionPending,
      );
    },
  );

  test('restart restores pending status', () async {
    await container
        .read(accountStatusProvider.notifier)
        .setStatus(AccountStatus.deletionPending);
    container.invalidate(accountStatusProvider);
    expect(
      container.read(accountStatusProvider),
      AccountStatus.deletionPending,
    );
  });

  test(
    'routing guards Home, deep links, OTP back navigation and recovery access',
    () {
      String? redirect(
        String path, {
        bool authenticated = true,
        AccountStatus status = AccountStatus.deletionPending,
        bool cancelled = false,
      }) => accountStatusRedirect(
        authenticated: authenticated,
        status: status,
        location: path,
        cancellationComplete: cancelled,
      );
      for (final path in [
        '/',
        '/booking/123',
        '/login',
        '/profile',
        '/splash',
      ]) {
        expect(redirect(path), '/account-deletion-pending');
      }
      expect(redirect('/delete-account-otp'), '/account-deletion-pending');
      expect(
        accountStatusRedirect(
          authenticated: true,
          status: AccountStatus.deletionPending,
          location: '/delete-account-otp',
          confirmedReceipt: true,
        ),
        '/delete-account-success',
      );
      expect(redirect('/account-deletion-pending'), isNull);
      expect(redirect('/cancel-account-deletion'), isNull);
      expect(
        redirect('/cancel-account-deletion', authenticated: false),
        '/login',
      );
      expect(
        redirect('/cancel-account-deletion', status: AccountStatus.active),
        '/',
      );
      expect(
        redirect(
          '/cancel-account-deletion',
          status: AccountStatus.active,
          cancelled: true,
        ),
        isNull,
      );
      expect(redirect('/', status: AccountStatus.deleted), '/login');
      expect(redirect('/', status: AccountStatus.unknown), '/login');
    },
  );

  test(
    'receipt remains visible after real session cleanup without retaining credentials',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'restricted-token',
      });
      final prefs = container.read(sharedPreferencesProvider);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', 'person@example.com');
      container
          .read(deletionReceiptProvider.notifier)
          .save(const DeletionRequest(id: 'DEL-42'));
      expect(container.read(authStateProvider), isTrue);
      await container.read(authStateProvider.notifier).logout();
      expect(container.read(authStateProvider), isFalse);
      expect(await SecureTokenStorage.read(), isNull);
      expect(prefs.getBool('isLoggedIn'), isNull);
      expect(prefs.getString('email'), isNull);
      expect(container.read(deletionReceiptProvider)?.id, 'DEL-42');
      expect(
        accountStatusRedirect(
          authenticated: false,
          status: AccountStatus.active,
          location: '/delete-account-success',
          confirmedReceipt: true,
        ),
        isNull,
      );
      expect(
        accountStatusRedirect(
          authenticated: false,
          status: AccountStatus.active,
          location: '/delete-account-success',
        ),
        '/login',
      );
    },
  );

  test('unknown details never fabricate a date, ID or email confirmation', () {
    final result = DeletionRequest.fromResponse({'data': {}});
    expect(result.scheduledAt, isNull);
    expect(result.id, isNull);
    expect(result.confirmationEmailSent, isFalse);
  });
}
