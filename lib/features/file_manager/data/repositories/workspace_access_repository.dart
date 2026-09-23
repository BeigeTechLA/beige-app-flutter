import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/models/fm_workspace_access.dart';

final workspaceAccessRepositoryProvider = Provider<WorkspaceAccessRepository>(
  (ref) => WorkspaceAccessRepository(ref.watch(dioClientProvider).dio),
);

class WorkspaceAccessRepository {
  WorkspaceAccessRepository(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    try {
      final response = await send();
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Invalid workspace access response');
      }
      if (body['success'] != true) {
        throw StateError(
          body['message']?.toString() ?? 'Workspace access request failed',
        );
      }
      return body;
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  void _validate(String externalId) {
    if (externalId.trim().isEmpty) throw ArgumentError('Missing workspace ID');
  }

  Future<FmWorkspaceAccess> list(String externalId) async {
    _validate(externalId);
    final body = await _request(
      () => _dio.get<dynamic>(
        ApiEndpoints.fmWorkspaceAccess,
        queryParameters: {'externalId': externalId},
      ),
    );
    final data = body['data'] as Map<String, dynamic>;
    return FmWorkspaceAccess(
      owner: FmWorkspaceClient.fromJson(data['owner'] as Map<String, dynamic>),
      clients: (data['access'] as List)
          .map((row) => FmWorkspaceClient.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<FmWorkspaceGrant> grant(String externalId, String email) async {
    _validate(externalId);
    if (email.trim().isEmpty) throw ArgumentError('Missing email');
    final body = await _request(
      () => _dio.post<dynamic>(
        ApiEndpoints.fmWorkspaceAccess,
        data: {'externalId': externalId, 'email': email.trim()},
      ),
    );
    final data = body['data'] as Map<String, dynamic>;
    return FmWorkspaceGrant(
      client: FmWorkspaceClient.fromJson(data),
      message: body['message'] as String? ?? 'Workspace access granted',
      emailSent: data['emailSent'] == true,
    );
  }

  Future<void> revoke(int accessId) async {
    if (accessId <= 0) throw ArgumentError('Invalid access ID');
    await _request(
      () => _dio.delete<dynamic>('${ApiEndpoints.fmWorkspaceAccess}/$accessId'),
    );
  }
}
