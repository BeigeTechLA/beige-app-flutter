// lib/core/services/socket_service.dart

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../config/env.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? _socket;
  bool roomJoined = false;
  String? _currentRoomId;

  // ✅ Static userId — screen se set karo login ke baad
  static String userId = '';
  static String userName = '';

  // ✅ Streams
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<bool>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  Stream<bool> get onTyping => _typingController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;
  bool get isConnected => _socket?.connected ?? false;

  // ✅ Connect + Room Join (single method, no duplicate)
  void connect({
    required String roomId,
    required String userId,
    required String userName,
  }) {
    // Same room already connected — skip
    if (_socket != null && _socket!.connected && _currentRoomId == roomId) {
      return;
    }

    _currentRoomId = roomId;
    SocketService.userId = userId;
    SocketService.userName = userName;

    // Already connected but different room — sirf rejoin
    if (_socket != null && _socket!.connected) {
      _joinRoom(roomId: roomId, userId: userId, userName: userName);
      return;
    }

    _socket = IO.io(
      Env.socketUrl,
      IO.OptionBuilder()
          .setPath('/socket.io')
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    // ── Connection Events ──
    _socket!.onConnect((_) {
      print('✅ Socket Connected');
      _connectionController.add(true);
      _joinRoom(roomId: roomId, userId: userId, userName: userName);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket Disconnected');
      roomJoined = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      print('🔴 Connect Error: $err');
      _connectionController.add(false);
    });

    _socket!.on('roomJoined', (data) {
      print('🏠 roomJoined response: $data');
      roomJoined = data is Map && data['success'] == true;
    });

    _socket!.on('new_message', (data) {
      if (data is Map) {
        _messageController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('typing', (_) {
      _typingController.add(true);
    });

    _socket!.on('stop_typing', (_) {
      _typingController.add(false);
    });

    _socket!.connect();
  }

  // ✅ Raw socket event listener (screen ke liye)
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  // ✅ Message Send
  void sendMessage(String content) {
    _socket?.emit('send_message', {
      'roomId': _currentRoomId,
      'senderId': userId,
      'content': content,
      'time': DateTime.now().toIso8601String(),
    });
  }

  // ✅ Typing Emit
  void sendTyping() {
    _socket?.emit('typing', {'roomId': _currentRoomId});
  }

  void sendStopTyping() {
    _socket?.emit('stop_typing', {'roomId': _currentRoomId});
  }

  // ✅ Disconnect + cleanup
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRoomId = null;
    roomJoined = false;
  }

  // Private
  void _joinRoom({
    required String roomId,
    required String userId,
    required String userName,
  }) {
    print('📤 Emitting joinRoom → roomId: $roomId, userId: $userId');
    _socket?.emit('joinRoom', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
    });
  }
}