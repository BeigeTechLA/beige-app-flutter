import 'package:flutter/foundation.dart';

import '../../domain/repositories/messages_repository.dart';

enum MessagesStatus { initial, loading, loaded, error }

class MessagesNotifier extends ChangeNotifier {
  final MessagesRepository _repository;

  MessagesNotifier(this._repository);

  MessagesStatus _status = MessagesStatus.initial;
  MessagesStatus get status => _status;

  List<dynamic> _rooms = [];
  List<dynamic> get rooms => _rooms;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Fetch all rooms ───────────────────────────────────────────────────────

  Future<void> fetchRooms({
    int page = 1,
    int limit = 100,
    String sortBy = 'updatedAt:desc',
  }) async {
    _status = MessagesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getChatRooms(
      page: page,
      limit: limit,
      sortBy: sortBy,
    );

    result.fold(
          (failure) {
        _status = MessagesStatus.error;
        _errorMessage = failure.message;
      },
          (data) {
        _status = MessagesStatus.loaded;
        _rooms = data;
      },
    );

    notifyListeners();
  }
}