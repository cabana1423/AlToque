import 'package:gowin/src/utils/variables.dart';
import 'package:socket_io_client/socket_io_client.dart'; // as IO;

class Connect {
  static String socketServer() {
    String estado = '';
    late Socket socket;
    try {
      socket = io(Constant.shared.urlApi, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();
      socket.on('connect', (_) => print("connect:${socket.id}"));
      socket.emit("signin", Constant.shared.dataUser['_id']);
    } catch (e) {
      print(e.toString());
    }
    Constant.shared.socket = socket;
    return estado;
  }
}
