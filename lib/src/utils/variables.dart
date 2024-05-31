// ignore_for_file: non_constant_identifier_names
// import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:socket_io_client/socket_io_client.dart';

class Constant {
  static final shared = Constant();

  // String urlApi = "http://192.168.100.218:8000";
  // String urlApi = 'https://ghmhx067-8000.brs.devtunnels.ms';
  String urlApi = 'https://proyect-final-sxtd.onrender.com';

  //    variables ausuario
  var dataUser;
  var listLikes;
  var interacciones;
  var zonaHoraria;

  String tokenFB = "";
  //  HUBICACION
  late double mylat = 0;
  late double mylong = 0;

  //String urlApi = "https://gowin1423.azurewebsites.net";

  String id_prop = "";
  String id_produc = "";
  String id_produc_ped = "";
  String id_prop_ped = "";
  List? listPedido;

  //sockets
  bool soloUnSocket = true;
  late Socket socket;

  // mensajeria
  var datos = [];
// MAPAS
  String lat = "";
  String long = "";

  //    CAMBIO DE ICONO AL ESCUCHAR PUSH
  var estadoPushNoti = '';

  //    JWT
  var token = '';
  var refreshToken = '';
}
