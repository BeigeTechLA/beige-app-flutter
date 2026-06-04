import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_remote_data_source.dart';


class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesRemoteDataSource _remoteDataSource;

  MessagesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<dynamic>>> getChatRooms({
    int page = 1,
    int limit = 100,
    String sortBy = 'updatedAt:desc',
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getChatRooms(
        page: page,
        limit: limit,
        sortBy: sortBy,
      );
      _assertNoError(response);
      final data = response['data'];
      // API may return { data: { results: [...] } } or { data: [...] }
      if (data is Map && data['results'] is List) {
        return data['results'] as List<dynamic>;
      }
      if (data is List) return data;
      return <dynamic>[];
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getChatMessages({
    required String roomId,
    int page = 1,
    int limit = 50,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getChatMessages(
        roomId: roomId,
        page: page,
        limit: limit,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }
  

  void _assertNoError(Map<String, dynamic> response) {
    if (response['error'] == true) {
      throw UnknownException(
        message: (response['message'] as String?) ?? 'Request failed',
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> markAllRead({required String roomId}) {
    // TODO: implement markAllRead
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> markMessageRead({required String roomId, required String messageId}) {
    // TODO: implement markMessageRead
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> sendMessage({required String roomId, required Map<String, dynamic> data}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }
}