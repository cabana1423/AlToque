// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/Inicio.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/Notificaciones.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/Perfil.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/SearchTienda.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/buscar.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils/Providers.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeNav extends StatefulWidget {
  var enlace;
  var prod;

  HomeNav({Key? key, required this.enlace, required this.prod})
      : super(key: key);

  @override
  _HomeNavState createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _paginaActual = 0;
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   log('entro del enlace');
    //   if (widget.enlace == 'enlace') {
    //     if (mounted) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => ProductoView(producto: widget.prod)),
    //       );
    //     }
    //   }
    // });

    determinePosition();
    requestPermission();
  }

  Future<void> requestPermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print('YA HAY PERMISO');
    } else if (status.isDenied) {
      print('NOOOOO HAY PERMISO');
    } else if (status.isPermanentlyDenied) {
      print('SENEGO NIMODO NO HAY PERMISO');
    }
  }

  void determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position position2) {
      Constant.shared.mylat = position2.latitude;
      Constant.shared.mylong = position2.longitude;
      zonaT(position2.latitude, position2.longitude);
      print(
        Constant.shared.mylat,
      );
      // print(Constant.shared.mylong);
    });
  }

  void zonaT(lat, lon) async {
    String deviceCountry = await FlutterNativeTimezone.getLocalTimezone();
    print(deviceCountry);
    _update(deviceCountry, lat, lon);
  }

  Future<String> _update(aux, lat, lon) async {
    String url =
        "${Constant.shared.urlApi}/users/?id=${Constant.shared.dataUser['_id']}";
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, dynamic>{
      'zonaHoraria': aux,
      'lat': lat.toString(),
      'long': lon.toString(),
      'locacion': 'posi'
    });
    Constant.shared.dataUser['zonaHoraria'] = aux;
    // print('ve esta horaaaaaaaaaa');
    // print(Constant.shared.dataUser['zonaHoraria']);

    return '';
  }

  List<Widget> _paginas() {
    return [
      Inicio(enlace: '', prod: ''),
      Buscar(enlace: '', prod: ''),
      SearchPropiedad(enlace: '', prod: ''),
      Notificaciones(enlace: '', prod: ''),
      Perfil(enlace: '', prod: '')
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(punto) {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Inicio"),
        activeColorPrimary: const Color.fromARGB(255, 52, 184, 184),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.search),
        title: ("Busqueda"),
        activeColorPrimary: const Color.fromARGB(255, 52, 184, 184),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.assistant_direction_outlined),
        title: ("Lugares"),
        activeColorPrimary: const Color.fromARGB(255, 52, 184, 184),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        // ignore: prefer_const_constructors
        icon: Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(
              Icons.notifications_none,
            ),
            if (punto.refreshList) ...[
              const Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 5,
                ),
              )
            ]
          ],
        ),
        title: ("Notificaciones"),
        activeColorPrimary: const Color.fromARGB(255, 52, 184, 184),
        inactiveColorPrimary: CupertinoColors.systemGrey,
        // onSelectedTabPressWhenNoScreensPushed: () {
        //   // log('message');
        // }
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person),
        title: ("perfil"),
        activeColorPrimary: const Color.fromARGB(255, 52, 184, 184),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  late PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  @override
  Widget build(BuildContext context) {
    final punto = Provider.of<EstadoGlobal>(context);
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        onItemSelected: (value) {
          if (value == 3) {
            // log(value.toString());
            final estadoGlobal =
                Provider.of<EstadoGlobal>(context, listen: false);
            estadoGlobal.refreshLista(false);
          }
        },
        screens: _paginas(),
        items: _navBarsItems(punto),
        confineInSafeArea: true,
        backgroundColor: Colors.white, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(04.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.easeInQuad,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style9, // Choose the nav bar style with this property.
      ),
    );
  }
}
