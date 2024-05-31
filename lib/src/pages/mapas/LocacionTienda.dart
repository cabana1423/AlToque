// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:latlong2/latlong.dart';

class LocationTienda extends StatefulWidget {
  LocationTienda({Key? key}) : super(key: key);

  @override
  State<LocationTienda> createState() => _LocationTiendaState();
}

class _LocationTiendaState extends State<LocationTienda> {
  final MapController mapController = MapController();
  List<Marker> markers = [];
  var lat, lon, lat2, lon2;
  @override
  void initState() {
    super.initState();
    determinePosition();
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
      setState(() {
        lat = position2.latitude;
        lon = position2.longitude;
      });
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        _ventana();
        return false;
      },
      child: SafeArea(
        child: lat == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: Stack(children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: LatLng(lat, lon),
                      zoom: 16.0,
                      minZoom: 0.0,
                      maxZoom: 18,
                      onTap: (tapPosition, point) {
                        setState(() {
                          markers.clear();
                          markers.add(Marker(
                            rotate: true,
                            point: point,
                            builder: (ctx) => Container(
                              child: Icon(Icons.add_home_work_rounded,
                                  size: 35,
                                  color: Color.fromARGB(255, 50, 90, 222)),
                            ),
                          ));
                        });
                        lat2 = point.latitude;
                        lon2 = point.longitude;
                        log('${lat2} ${lon2}');
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: markers),
                      MarkerLayer(
                        markers: [
                          Marker(
                            rotateAlignment: Alignment.center,
                            point: LatLng(lat, lon),
                            builder: (ctx) => Container(
                              child: Icon(Icons.person_pin_circle_rounded,
                                  size: 30,
                                  color: Color.fromARGB(255, 190, 4, 4)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: ElevatedButton(
                            onPressed: () {
                              if (lat2 != null && lon2 != null) {
                                Constant.shared.lat = lat2.toString();
                                Constant.shared.long = lon2.toString();
                                if (mounted) {
                                  Navigator.of(context).pop(context);
                                }
                              } else {
                                ToastNotification.toastNotificationError(
                                    'no se obtuvo ninguna ubicación', context);
                                return;
                              }
                              ;
                            },
                            child: Text("Agregar ubicacion")),
                      )),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: _size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.info_outline),
                              Text(
                                'pulsa en el mapa el lugar donde esta \n hubicado tu empresa o tienda',
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ]),
              ),
      ),
    );
  }

  _ventana() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      borderSide: BorderSide(color: Colors.yellow, width: 1),
      width: 400,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(5)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'No hay una ubicacion',
      desc: 'no se agrego ninguna ubicacion esta seguro que desea salir?',
      showCloseIcon: true,
      // btnCancelOnPress: () {
      //   print("hola");
      // },
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    )..show();
  }
}
