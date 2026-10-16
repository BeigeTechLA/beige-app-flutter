import 'package:beige/features/file_manager/data/repositories/workspace_access_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late WorkspaceAccessRepository repo;
  setUp(() {
    dio = Dio();
    repo = WorkspaceAccessRepository(dio);
  });
  void respond(Map<String, dynamic> body) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.resolve(
            Response(requestOptions: request, data: body, statusCode: 200),
          );
        },
      ),
    );
  }

  test(
    'registered grant succeeds even when email delivery fails and ID is absent',
    () async {
      respond({
        'success': true,
        'message': 'Client access granted',
        'data': {
          'email': 'bhumi@example.com',
          'name': 'Bhoomi',
          'pending': false,
          'emailSent': false,
          'emailError': 'Delivery failed',
        },
      });
      final result = await repo.grant('1384', 'bhumi@example.com');
      expect(result.client.name, 'Bhoomi');
      expect(result.client.pending, false);
      expect(result.client.accessId, isNull);
      expect(result.emailSent, false);
    },
  );
  test('API failure is not treated as successful removal', () async {
    respond({'success': false, 'message': 'Access denied'});
    await expectLater(repo.revoke(1), throwsStateError);
  });
  test('malformed list is not treated as empty access', () async {
    respond({'success': true, 'data': {}});
    await expectLater(repo.list('1384'), throwsA(isA<TypeError>()));
  });
  test('rejects invalid IDs before sending requests', () async {
    await expectLater(repo.revoke(0), throwsArgumentError);
    await expectLater(repo.list(''), throwsArgumentError);
  });
}
