import 'package:flutter/material.dart';
import 'package:gowin/src/utils/guardar.session.dart';

class EstadoGlobal with ChangeNotifier {
  bool carga = false;
  String lat = '';
  String long = '';
  Future<void> coordenadas(bool newcarga, String newlat, String newlong) async {
    carga = newcarga;
    lat = newlat;
    long = newlong;
    notifyListeners(); // Notificar a los listeners que el valor ha cambiado
  }

  bool get _carga => carga;
  String get _lat => lat;
  String get _long => long;

  //cargar lista repartidor
  bool refreshList = false;
  Future<void> refreshLista(bool newRefresh) async {
    refreshList = newRefresh;
    notifyListeners();
  }

  bool get _refreshList => refreshList;

  // cambiar brillo

  bool _brillo = false;
  Future<void> setBrillo(bool nuevoBrillo) async {
    _brillo = nuevoBrillo;
    await UserSecureStorages.setTheme(nuevoBrillo);
    notifyListeners(); // Notificar a los listeners que el valor ha cambiado
  }

  bool get brillo => _brillo;
}
