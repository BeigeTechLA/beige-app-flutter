import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_remote_data_source.dart';


class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesRemoteDataSource _remoteDataSource;

  MessagesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<dynamic>>> getRooms({
    int page = 1,
    int limit = 100,
    String sortBy = 'updatedAt:desc',
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getRooms(
        page: page,
        limit: limit,
        sortBy: sortBy,
      );

      _assertNoError(response);

      final data = response['results'];
      if (data is List) return data;

      return <dynamic>[];
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
  Future<Either<AppException, List<dynamic>>> getChatMessages({required String roomId, int page = 1, int limit = 50}) {
    // TODO: implement getChatMessages
    throw UnimplementedError();
  }
}