import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gowin/src/utils/Enviar.Mensaje.FCM.dart';
import 'package:gowin/src/utils/Providers.dart';
import 'package:gowin/src/utils/push_notification_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaNoRepartidor extends StatefulWidget {
  var data;

  MapaNoRepartidor({Key? key, required this.data}) : super(key: key);

  @override
  State<MapaNoRepartidor> createState() => _MapaNoRepartidorState();
}

class _MapaNoRepartidorState extends State<MapaNoRepartidor> {
  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();
    solicitarUbiRepartidor();
  }

  void solicitarUbiRepartidor() {
    SendFcm.func.sendNotification(
        'DameCordenadas', 'lat', 'long', widget.data['repartidor']['tokenFcm']);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _mapController.dispose();
  }

  bool carga = false;
  var lat = '0';
  var long = '0';
  @override
  Widget build(BuildContext context) {
    final estadoGlobal = Provider.of<EstadoGlobal>(context);
    carga = estadoGlobal.carga;
    lat = estadoGlobal.lat;
    long = estadoGlobal.long;
    return carga == false
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(double.parse(lat), double.parse(long)),
                    zoom: 15.0,
                    minZoom: 5,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      minZoom: 0.0,
                      maxZoom: 18.0,
                      subdomains: ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        //   Polyline(
                        //     points: _points,
                        //     color: Colors.blue,
                        //     strokeWidth: 4.0,
                        //   ),

                        Polyline(
                          points: [
                            LatLng(double.parse(lat), double.parse(long)),
                            LatLng(widget.data['ubicacion']['lat_u'],
                                widget.data['ubicacion']['lon_u'])
                          ],
                          color: const Color.fromARGB(255, 129, 89, 249),
                          strokeWidth: 2.0,
                        ),
                        if (widget.data['estado'] != 'enviado')
                          Polyline(
                            points: [
                              LatLng(double.parse(lat), double.parse(long)),
                              LatLng(widget.data['ubicacion']['lat_t'],
                                  widget.data['ubicacion']['lon_t'])
                            ],
                            color: const Color.fromARGB(255, 28, 176, 210),
                            strokeWidth: 2.0,
                          )
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (widget.data != null)
                          Marker(
                            width: 30.0,
                            height: 30.0,
                            point: LatLng(widget.data['ubicacion']['lat_u'],
                                widget.data['ubicacion']['lon_u']),
                            builder: (ctx) => Container(
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 30.0,
                              ),
                            ),
                          ),
                        Marker(
                          width: 30.0,
                          height: 30.0,
                          point: LatLng(widget.data['ubicacion']['lat_t'],
                              widget.data['ubicacion']['lon_t']),
                          builder: (ctx) => Container(
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Color.fromARGB(255, 54, 70, 244),
                              size: 30.0,
                            ),
                          ),
                        ),
                        if (lat != '')
                          Marker(
                            width: 30.0,
                            height: 30.0,
                            point:
                                LatLng(double.parse(lat), double.parse(long)),
                            builder: (ctx) => Container(
                              child: const Icon(
                                Icons.delivery_dining,
                                color: Color.fromARGB(255, 0, 218, 51),
                                size: 34.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  // ignore: prefer_const_constructors
                  padding: EdgeInsets.fromLTRB(0, 0, 14, 14),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          carga = false;
                        });
                        solicitarUbiRepartidor();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black87,
                            child: !carga
                                ? const CircularProgressIndicator()
                                : const Icon(
                                    Icons.not_listed_location_outlined,
                                    color: Colors.white,
                                  ),
                          ),
                          const Text(
                            'Ubicación\nrepartidor',
                            style: TextStyle(fontSize: 11),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
