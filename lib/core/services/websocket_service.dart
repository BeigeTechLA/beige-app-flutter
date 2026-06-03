import 'package:socket_io_client/socket_io_client.dart' as IO; //

class SocketService {

  static final SocketService _instance = SocketService._internal();
  //  Private constructor —
  SocketService._internal();

  factory SocketService() => _instance;
  IO.Socket? _socket;

  bool roomJoined = false;
  String socketStatus = 'Disconnected';
  String? _currentRoomId;



}