// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gowin/src/pages/mapas/MapasNoRepartidor.dart';
import 'package:gowin/src/pages/mapas/Utils.WidgetMaps.dart';
import 'package:gowin/src/pages/repartidores/utlis.repartidor.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as log;
import 'package:latlong2/latlong.dart';
import 'package:dart_ipify/dart_ipify.dart';

class GestionarPedidoRepartidor extends StatefulWidget {
  var title;
  var id_cuenta;

  var id_tienda;

  var idNotifi;

  var tipo;

  GestionarPedidoRepartidor({
    Key? key,
    required this.id_cuenta,
    required this.title,
    required this.idNotifi,
    required this.id_tienda,
    required this.tipo,
  }) : super(key: key);

  @override
  State<GestionarPedidoRepartidor> createState() =>
      _GestionarPedidoRepartidorState();
}

class _GestionarPedidoRepartidorState extends State<GestionarPedidoRepartidor>
    with AutomaticKeepAliveClientMixin {
  MapController? _mapController;
  final List<LatLng> _points = [];
  Position? _currentPosition;
  List<LatLng> polylineCoordinates = [];
  String errorMessage = '';
  var lat = Constant.shared.mylat;
  var lon = Constant.shared.mylong;
  var distTienda = 0.0;
  var distUser = 0.0;
  var position;

  bool vacio = false;
  @override
  void initState() {
    super.initState();
    // log.log(widget.tipo);
    _mapController = MapController();
    if (widget.tipo == 'repartidor_lista') {
      setState(() {
        datos = widget.id_cuenta;
        repartidor = widget.id_cuenta['repartidor'];
        nombreP = widget.id_cuenta['nombreTienda'];
      });
      // log.log(datos.toString());
      return;
    }
    verificarDisponivilidad();
    // if (widget.tipo == 'repartidor') {
    //   _getCurrentLocation();
    // }
    datosListCuenta();

    // log.log('${widget.idNotifi}');
  }

  Future<void> verificarDisponivilidad() async {
    var url =
        '${Constant.shared.urlApi}/cont/verificar?id_u=${Constant.shared.dataUser['_id']}';
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      log.log('${json.decode(response.body).length}');
      if (json.decode(response.body).isEmpty) {
        vacio = true;
      } else {
        vacio = false;
      }
    } else {
      ToastNotification.toastNotificationSucces(
          'Error al verificar disponibilidad', context);
    }
  }

  var timer;
  var seguimiento;
  @override
  Future<void> dispose() async {
    super.dispose();
    _mapController!.dispose();

    if (timer != null) {
      timer.cancel();
    }

    if (seguimiento != null) {
      seguimiento.cancel();
    }
  }

  Future<String> update(est, estado) async {
    var repartidor = {
      'id': Constant.shared.dataUser['_id'],
      'nombre': Constant.shared.dataUser['nombre'],
      'estado': estado,
      'tokenFcm': Constant.shared.tokenFB,
      'cuenta': ganancia
    };
    String url =
        '${Constant.shared.urlApi + "/cont/?id=" + widget.id_cuenta}&idNot=' +
            widget.idNotifi;
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'repartidor': json.encode(repartidor),
      'estado_rep': est
    });
    if (res.statusCode == 200) {
      setState(() {
        reFreshCuenta();
      });
      return 'exito';
    } else {
      ToastNotification.toastNotificationError(
          'algo paso al procesar la informacion', context);
      return 'fail';
    }
  }

  var datos;
  var detalles;
  var repartidor;
  var nombreP;
  Future datosListCuenta() async {
    var url = '${Constant.shared.urlApi}/cont/?id_cont=${widget.id_cuenta}';
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      //print(response.body);
      if (mounted) {
        setState(() {
          datos = json.decode(response.body)[0];
          repartidor = json.decode(response.body)[0]['repartidor'];
          nombreP = json.decode(response.body)[0]['nombreTienda'];
          // log.log(datos['estado'].toString());
          if (widget.tipo == 'repartidor') {
            actualizarCarretera();
            if (repartidor != null) {
              reiterarCarretera();
            }
          }
        });
      }
    }
  }

  Future reFreshCuenta() async {
    var url = '${Constant.shared.urlApi}/cont/?id_cont=${widget.id_cuenta}';
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          datos = json.decode(response.body)[0];
          repartidor = json.decode(response.body)[0]['repartidor'];
          nombreP = json.decode(response.body)[0]['nombreTienda'];
          // log.log(datos['estado'].toString());
        });
      }
    }
  }

  void actualizarCarretera() {
    String url = '';
    if (datos['estado'] == 'enviado') {
      url =
          'http://router.project-osrm.org/route/v1/driving/${lon},${lat};${datos['ubicacion']['lon_u']},${datos['ubicacion']['lat_u']}?overview=full&geometries=geojson';
    } else {
      url =
          'http://router.project-osrm.org/route/v1/driving/${lon},${lat};${datos['ubicacion']['lon_t']},${datos['ubicacion']['lat_t']};${datos['ubicacion']['lon_u']},${datos['ubicacion']['lat_u']}?overview=full&geometries=geojson';
    }
    // print(url);
    fetchPolylineCoordinates(url);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: repartidor == null ||
              repartidor['id'] == Constant.shared.dataUser['_id']
          ? FloatingActionButton(
              onPressed: () {
                reFreshCuenta();
              },

              child: Icon(Icons.refresh),
              backgroundColor: Colors.blue, // Color de fondo del botón
            )
          : null,
      body: SafeArea(
        child: Container(
            alignment: Alignment.center,
            child: datos == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : widget.tipo == 'repartidor'
                    ? ((distUser / 1000) + (distTienda / 1000)) < 10.0 &&
                            ((distUser / 1000) + (distTienda / 1000)) > 0.0
                        ? cuerpo()
                        : noAceptarPedido()
                    : cuerpo()),
      ),
    );
  }

  Widget noAceptarPedido() {
    return Center(
      child: FutureBuilder(
        // Simulamos una operación asincrónica que dura 3 segundos
        future:
            Future.delayed(const Duration(seconds: 3), () => 'Datos cargados'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un widget de carga mientras se espera
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // Muestra el texto después de 3 segundos
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  'La distancia entre Usted y la orden es considerable, lo que hace inconveniente que pueda aceptarla'),
            );
          } else {
            // Maneja errores si es necesario
            return const Text('Error al cargar datos');
          }
        },
      ),
    );
  }

  Widget cuerpo() {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                datos != null ? verLista() : const SizedBox(),
                repartidor == null ||
                        repartidor['id'] == Constant.shared.dataUser['_id']
                    ? boton()
                    : const SizedBox(),
              ],
            ),
            widget.tipo == 'repartidor'
                ? repartidor != null && repartidor['estado'] == 'entregado'
                    ? ordenEntregada
                    : Expanded(child: mapa())
                : datos != null && widget.tipo != 'repartidor_lista'
                    ? repartidor['estado'] != 'entregado'
                        ? Expanded(child: MapaNoRepartidor(data: datos))
                        : ordenEntregada
                    : ordenEntregada
          ],
        ),
        datos == null
            ? const SizedBox()
            : Visibility(
                visible: datos['repartidor'] != null &&
                    datos['repartidor']['estado'] == 'entregado' &&
                    widget.tipo == 'respTienda-EnCamino' &&
                    datos['estado'] != 'entregado',
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                      child: Container(
                        width: 300,
                        height: 160,
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'La orden figura como entregada, podria confirmarlo?',
                                textAlign: TextAlign.center,
                              ),
                              ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color.fromARGB(255, 92, 207, 159))),
                                  onPressed: () {
                                    updateEsta();
                                  },
                                  child: const Text(
                                    'Confirmar entrega',
                                    style: const TextStyle(color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    )),
              )
      ],
    );
  }

  var ordenEntregada = const Expanded(
    child: Align(
      alignment: Alignment.center,
      child: Text('Orden entregada'),
    ),
  );

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);
  Widget verLista() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: ListTile(
            onTap: () {
              abrirLista();
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => RutaRepartidor(
              //             osm: widget.osm, puntos: datos['ubicacion'])));
            },
            title: Text(
              'Detalles',
              style: stilo,
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ),
      ),
    );
  }

  void abrirLista() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            repartidor != null ? descripcion() : descripcionSinRepartidor(),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Lista de Productos',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: listaPedido(),
            ),
          ],
        );
      },
    );
  }

  Widget listaPedido() {
    var auxiliar = datos['productos'];

    final List<Map<String, String>> data = [];
    for (var i = 0; i < auxiliar.length; i++) {
      // log.log(auxiliar[i].toString());
      data.add({
        "nombre": auxiliar[i]['nombre_p'],
        "precio": auxiliar[i]['total_p'],
        "cantidad": auxiliar[i]['cantidad'].toString()
      });
    }
    return DataTable(
      horizontalMargin: 10,
      dataRowColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return const Color.fromARGB(255, 216, 237, 255);
          }
          return const Color.fromARGB(255, 248, 248, 248);
        },
      ),
      headingRowColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return const Color.fromARGB(255, 200, 216, 230);
          }
          return Colors.grey[200];
        },
      ),
      columns: const [
        DataColumn(label: Text("Producto")),
        DataColumn(label: Text("Cantidad")),
        DataColumn(label: Text("Precio")),
      ],
      rows: data
          .map((item) => DataRow(selected: true, cells: <DataCell>[
                DataCell(Text(item["nombre"].toString())),
                DataCell(Text(item["cantidad"].toString())),
                DataCell(Text(item["precio"].toString()))
              ]))
          .toList(),
    );
  }

  Widget descripcion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Tienda: ${nombreP ?? ''}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Repartidor asignado: ${repartidor['nombre'] ?? ''}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Estado Repartidor: ${repartidor['estado'] ?? ''}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Estado pedido: ${datos['estado'] ?? ''}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'distancia a la tienda: ${(distTienda / 1000).toStringAsFixed(1).substring(0, 3)} km',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'distancia de tienda al cliente: ${(distUser / 1000).toString().substring(0, 3)} km',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'Ganancia: ${calcularGanancia((distUser / 1000) + (distTienda / 1000))} Bs',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget descripcionSinRepartidor() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'distancia a la tienda: ${(distTienda / 1000).toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'distancia de tienda al cliente: ${(distUser / 1000).toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'distancia Total: ${((distUser / 1000) + (distTienda / 1000)).toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            Visibility(
              visible: widget.tipo == 'repartidor',
              child: Text(
                'Ganancia: ${calcularGanancia((distUser / 1000) + (distTienda / 1000))} Bs',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String ganancia = '';
  String calcularGanancia(distancia) {
    if (distancia < 5) {
      ganancia = '5';
      return ganancia;
    }
    if (distancia > 5) {
      ganancia = distancia.toStringAsFixed(0);
      return ganancia;
    }

    return '$distancia';
  }

  Widget boton() {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 5, 2, 2),
      child: Container(
        height: 50,
        width: size.width * 0.4,
        // ignore: deprecated_member_use
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 52, 184, 184),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          ),
          onPressed: repartidor != null &&
                  repartidor['estado'] == 'entregado' &&
                  repartidor['id'] == Constant.shared.dataUser['_id']
              ? null
              : () async {
                  if (repartidor == null) {
                    if (!vacio) {
                      ToastNotification.toastNotificationError(
                          'tienes una orden pendiente por completar', context);
                      return;
                    }
                    update(Constant.shared.dataUser['_id'], 'no entregada')
                        .then((value) {
                      if (value == 'exito') {
                        // log.log(value);
                        UtilsRep.respuestaSendFcm(
                            'pedido aseptado por ${Constant.shared.dataUser['nombre']}',
                            'Aguarde! nuestro repartidor ya esta en camino',
                            datos['id_destino'],
                            'otro');
                      }
                    });
                    return;
                  }
                  if (repartidor['id'] == Constant.shared.dataUser['_id'] &&
                      repartidor['estado'] != 'entregado' &&
                      datos['estado'] == 'enviado') {
                    update('entregado', 'entregado').then((value) {
                      // log.log(value);
                      if (value == 'exito') {
                        UtilsRep.respuestaSendFcm(
                            'El pedido fue entregado con exito por:${Constant.shared.dataUser['nombre']}',
                            'puede verificarlo en cualquier instante',
                            datos['id_destino'],
                            'otro');
                      }
                    });
                    print('ENTREGADOOOO');
                    return;
                  } else {
                    ToastNotification.toastNotificationError(
                        'El pedido aun no puede ser entregado.\nfaltan completar procesos',
                        context);
                  }
                },
          child: Text(repartidor == null ? "Aceptar pedido" : 'Entregar',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void reiterarCarretera() {
    var a = 0;
    if (repartidor != null &&
        repartidor['id'] == Constant.shared.dataUser['_id'] &&
        repartidor['estado'] != 'entregado') {
      timer = Timer.periodic(const Duration(seconds: 50), (timer) {
        actualizarCarretera();
        print('${a++}');
      });
    }
  }

  //FUNCIONES MAPA

  Widget mapa() {
    return Stack(children: [
      Scaffold(
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            onMapReady: () {
              if (widget.tipo == 'repartidor') {
                _getCurrentLocation();
              }
            },
            center: LatLng(0, 0),
            zoom: 16.0,
            minZoom: 1.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
              minZoom: 1.0,
              maxZoom: 18.0,
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylineCoordinates,
                  strokeWidth: 4.0,
                  color: const Color.fromARGB(255, 26, 236, 255),
                )
              ],
            ),
            MarkerLayer(
              markers: [
                if (_currentPosition != null)
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 30.0,
                      ),
                    ),
                  ),
                if (datos != null)
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(datos['ubicacion']['lat_t'],
                        datos['ubicacion']['lon_t']),
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color.fromARGB(255, 54, 70, 244),
                        size: 30.0,
                      ),
                    ),
                  ),
                if (datos != null)
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(datos['ubicacion']['lat_u'],
                        datos['ubicacion']['lon_u']),
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.person_pin,
                        color: Color.fromARGB(255, 1, 159, 19),
                        size: 30.0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
          child: UtilMaps.func.popMenu(context, lat, lon, datos),
        ),
      ),
    ]);
  }
  // datos['ubicacion']['lat_t']

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    position = await Geolocator.getCurrentPosition();
    print(position);
    try {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _mapController!
              .move(LatLng(position.latitude, position.longitude), 15);
        });
      }
    } catch (e) {}

    seguimiento = Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _points.add(LatLng(position.latitude, position.longitude));
          lon = position.longitude;
          lat = position.latitude;
        });
      }
    });
  }

  void fetchPolylineCoordinates(url) async {
    http.Response response = await http.get(Uri.parse(url));
    if (mounted) {
      if (response.statusCode == 200) {
        setState(() {
          if (datos['estado'] != 'enviado') {
            distTienda = jsonDecode(response.body)['routes'][0]['legs'][0]
                    ['distance'] +
                0.0;
            distUser = jsonDecode(response.body)['routes'][0]['legs'][1]
                    ['distance'] +
                0.0;
            polylineCoordinates = (jsonDecode(response.body)['routes'][0]
                    ['geometry']['coordinates'] as List)
                .map((coordinatePair) =>
                    LatLng(coordinatePair[1], coordinatePair[0]))
                .toList();
          } else {
            distUser = jsonDecode(response.body)['routes'][0]['legs'][0]
                    ['distance'] +
                0.0;
            polylineCoordinates = (jsonDecode(response.body)['routes'][0]
                    ['geometry']['coordinates'] as List)
                .map((coordinatePair) =>
                    LatLng(coordinatePair[1], coordinatePair[0]))
                .toList();
          }
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
        });
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future updateEsta() async {
    String url = '${Constant.shared.urlApi}/cont/?id=${datos['_id']}';
    var response = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'estado': 'entregado',
    });
    if (response.statusCode == 200) {
      ToastNotification.toastNotificationSucces('Realizado con exito', context);
    } else {
      ToastNotification.toastPeque('Error en el proceso', context);
    }
  }
}
