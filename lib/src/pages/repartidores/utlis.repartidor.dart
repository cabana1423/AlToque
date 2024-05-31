import 'dart:convert';
import 'dart:developer' as log;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gowin/main.dart';
import 'package:gowin/src/utils/Enviar.Mensaje.FCM.dart';
import 'package:gowin/src/utils/Providers.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:http/http.dart' as http;

class UtilsRep {
  static final func = UtilsRep();
  static Future enviarNotRep(data) async {
    var send = json.decode(data);
    // print(['url']);
    String url = "${Constant.shared.urlApi}/fcm/notRep";
    var time = DateTime.now().toString().substring(0, 16);
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id_user': Constant.shared.dataUser['_id'],
      'id_cont': send['id_cont'],
      'body': 'talvez pueda interesarte \n ¿Quieres tomarla?',
      'time': send['time'],
      'url': send['url'],
      'title': send['title'],
      'tipo': 'repartidor',
      'estado': 'Sin Atender',
      'id_tienda': send['id_tienda']
    });
    // if (res.statusCode == 200) {
    // }
  }

  static double calculoDist(long, lat) {
    var position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position position2) {
      Constant.shared.mylat = position2.latitude;
      Constant.shared.mylong = position2.longitude;
      print(position2.latitude.toString() + position2.longitude.toString());
    });

    int radiusEarth = 6371;
    double distanceKm;
    // double distanceMts;
    double dlat, dlng;
    double a;
    double c;
    print('AQUI ESTA' +
        Constant.shared.mylat.toString() +
        Constant.shared.mylong.toString());
    var mylat = math.radians(Constant.shared.mylat);
    lat = math.radians(lat);
    var mylong = math.radians(Constant.shared.mylong);
    long = math.radians(long);
    // Fórmula del semiverseno
    dlat = lat - mylat;
    dlng = long - mylong;
    a = sin(dlat / 2) * sin(dlat / 2) +
        cos(mylat) * cos(lat) * (sin(dlng / 2)) * (sin(dlng / 2));
    c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distanceKm = radiusEarth * c;
    return distanceKm;
    //return distanceMts;
  }

  static Future respuestaSendFcm(title, body, id, page) async {
    String url = "${Constant.shared.urlApi}/fcm/fcmOtros";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id_user': id,
      'body': body,
      'title': title,
      'page': page
    });
    // if (res.statusCode == 200) {
    // }
  }

  // final GlobalKey<OverlayState> navigatorKey = GlobalKey<OverlayState>();
  funcionCoordenadas(tipo, token, lat, long) async {
    if (tipo == 'DameCordenadas') {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position2) {
        Constant.shared.mylat = position2.latitude;
        Constant.shared.mylong = position2.longitude;
        print(position2.latitude.toString() + position2.longitude.toString());
        SendFcm.func.sendNotification(
            'tomaCordenadas',
            position2.latitude.toString(),
            position2.longitude.toString(),
            token);
      });
    } else {
      // log.log('COORDENADAS DEL REPARTDOR ${lat} ${long} ${token}');
      // final context = navigatorKey.currentState!.context;
      // print(context);
      BuildContext? context = globalNavigatorKey.currentContext;
      final estadoGlobal = Provider.of<EstadoGlobal>(context!, listen: false);
      estadoGlobal.coordenadas(true, lat, long);
    }
  }

  refreshListaRep() {
    print('ENTRO A PROVIDEEEEEER');
    BuildContext? context = globalNavigatorKey.currentContext;
    final estadoGlobal = Provider.of<EstadoGlobal>(context!, listen: false);
    estadoGlobal.refreshLista(true);
  }
}
