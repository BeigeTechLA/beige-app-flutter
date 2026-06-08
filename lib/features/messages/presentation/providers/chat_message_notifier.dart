// import 'package:flutter/foundation.dart';
//
// import '../../domain/repositories/messages_repository.dart';
//
// enum ChatStatus { initial, loading, loaded, sending, error }
//
// class ChatMessageNotifier extends ChangeNotifier {
//   final MessagesRepository _repository;
//
//   ChatMessageNotifier(this._repository);
//
//   ChatStatus _status = ChatStatus.initial;
//   ChatStatus get status => _status;
//
//   List<dynamic> _messages = [];
//   List<dynamic> get messages => _messages;
//
//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;
//
//   String? _currentRoomId;
//
//   // ── Fetch messages for a room ─────────────────────────────────────────────
//
//   Future<void> fetchMessages({
//     required String roomId,
//     int page = 1,
//     int limit = 50,
//   }) async {
//     _currentRoomId = roomId;
//     _status = ChatStatus.loading;
//     _errorMessage = null;
//     notifyListeners();
//
//     final result = await _repository.getChatMessages(
//       roomId: roomId,
//       page: page,
//       limit: limit,
//     );
//
//     result.fold(
//           (failure) {
//         _status = ChatStatus.error;
//         _errorMessage = failure.message;
//       },
//           (data) {
//         _status = ChatStatus.loaded;
//         // API typically returns { results: [...], totalPages: n, ... }
//         final results = data['results'];
//         _messages = results is List ? results : <dynamic>[];
//       },
//     );
//
//     notifyListeners();
//   }
//
//   // ── Send a message ────────────────────────────────────────────────────────
//
//  /* Future<bool> sendMessage({
//     required String roomId,
//     required String text,
//   }) async {
//     _status = ChatStatus.sending;
//     notifyListeners();
//
//     final result = await _repository.sendMessage(
//       roomId: roomId,
//       data: {'message': text},
//     );
//
//     return result.fold(
//           (failure) {
//         _status = ChatStatus.error;
//         _errorMessage = failure.message;
//         notifyListeners();
//         return false;
//       },
//           (data) {
//         // Optimistically append the new message
//         final newMsg = data['data'];
//         if (newMsg != null) _messages = [..._messages, newMsg];
//         _status = ChatStatus.loaded;
//         notifyListeners();
//         return true;
//       },
//     );
//   }
// */
//   // ── Mark all read ─────────────────────────────────────────────────────────
//
// /*  Future<void> markAllRead({required String roomId}) async {
//     await _repository.markAllRead(roomId: roomId);
//   }*/
//
// /*  void clearMessages() {
//     _messages = [];
//     _status = ChatStatus.initial;
//     _currentRoomId = null;
//     notifyListeners();
//   }*/
// }