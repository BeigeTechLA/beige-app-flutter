import '../../../core/network/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/network/exceptions/app_exception.dart';
import '../domain/deletion_request.dart';

class AccountDeletionRepository {
  AccountDeletionRepository(this._dio);
  final Dio _dio;

  // Identity headers (device_type / user_type / user_type_name) come from the
  // global DioClient base options, same as every other endpoint. Only the
  // destructive-retry guard is local: an ambiguous timeout must not
  // automatically repeat a delete.
  Options get _options => Options(extra: {'skipRetry': true});

  Future<Map<String, dynamic>> _call(
    String path,
    String method, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.request<dynamic>(
      path,
      data: data,
      options: _options.copyWith(method: method),
    );
    final body = response.data;
    if (body == null && method == 'PATCH') return {};
    if (body is! Map) {
      throw const FormatException('Invalid account deletion response');
    }
    final result = Map<String, dynamic>.from(body);
    if (result['error'] == true ||
        result['success'] == false ||
        result['code'] == 'ACCOUNT_DELETION_IN_PROGRESS') {
      throw UnknownException(
        message:
            result['message']?.toString() ??
            'Request failed. Please try again.',
      );
    }
    return result;
  }

  Future<void> requestOtp() async {
    await _call(ApiEndpoints.deleteAccountRequest, 'POST');
  }

  Future<DeletionRequest> confirm(String otp) async =>
      DeletionRequest.fromResponse(
        await _call(
          ApiEndpoints.deleteAccountConfirm,
          'POST',
          data: {'otp': otp},
        ),
      );
  Future<DeletionRequest> status() async => DeletionRequest.fromResponse(
    await _call(ApiEndpoints.deleteAccountStatus, 'GET'),
  );
  Future<DeletionRequest> cancel() async => DeletionRequest.fromResponse(
    await _call(ApiEndpoints.deleteAccountCancel, 'PATCH'),
  );
}

final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository>(
  (ref) => AccountDeletionRepository(ref.watch(dioClientProvider).dio),
);
