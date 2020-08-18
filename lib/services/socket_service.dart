import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket socket;

  createSocketConnection() {
    socket = IO.io('https://flutter-chatapp.herokuapp.com/', <String, dynamic>{
      'transports': ['websocket'],
    });

//    socket.on("connect", (_) => print('Connected'));
//    socket.on("disconnect", (_) => print('Disconnected'));
//    socket.on("connect_error", (data) => print(data));
  }

}