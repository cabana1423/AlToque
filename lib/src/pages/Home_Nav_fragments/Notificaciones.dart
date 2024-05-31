import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/gestiones/atender.pedido.dart';
import 'package:gowin/src/pages/repartidores/Gestionar.pedido.repartidor.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils/Providers.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Notificaciones extends StatefulWidget {
  var enlace;

  var prod;

  Notificaciones({Key? key, required this.enlace, required this.prod})
      : super(key: key);

  @override
  _NotificacionesState createState() => _NotificacionesState();
}

class _NotificacionesState extends State<Notificaciones>
    with SingleTickerProviderStateMixin {
  // final pageViewController = PageController(initialPage: 0);

  late TabController _tabController;

  var loading1 = const Center(
    child: CircularProgressIndicator(),
  );
  var loading2 = const Center(
    child: Text(
      'Aun no tienes notificaciones',
      style: TextStyle(fontSize: 18),
    ),
  );
  bool loadingProp = true;
  bool loadingNoProp = true;
  @override
  void initState() {
    super.initState();

    setState(() {
      Constant.shared.estadoPushNoti = '';
    });
    if (Constant.shared.dataUser['tipo'] == 'propietario') {
      datosListcuentas();
    }
    datosListNoti();
    _tabController = TabController(length: 2, initialIndex: 1, vsync: this);
  }

  var estilo = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  late List datos = [];
  var idNoti;
  Future datosListNoti() async {
    var url =
        "${Constant.shared.urlApi}/noti/?id_u=${Constant.shared.dataUser['_id']}";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    setState(() {
      if (json.decode(response.body).length != 0) {
        if (mounted) {
          datos = json.decode(response.body)[0]["listaNoti"].reversed.toList();
          idNoti = json.decode(response.body)[0]['_id'];
        }
      }
      loadingNoProp = false;
      // print(datos.length);
    });
  }

  List dataCont = [];
  Future datosListcuentas() async {
    var url =
        "${Constant.shared.urlApi}/cont/?id_Uadm=${Constant.shared.dataUser['_id']}&order=time,1";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    setState(() {
      if (json.decode(response.body).length != 0) {
        if (mounted) {
          dataCont = json.decode(response.body);
        }
      }
      loadingProp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Constant.shared.dataUser['tipo'] == 'propietario'
            ? SafeArea(
                child: Scaffold(
                    appBar: Constant.shared.dataUser['tipo'] != 'propietario'
                        ? AppBar(
                            backgroundColor: Colors.white,
                            title: Row(
                              children: [
                                Text(
                                  'Notificaciones',
                                  style: GoogleFonts.lobster(
                                      color: Colors.black, fontSize: 28),
                                ),
                                // if (cargarList) ...[
                                //   const CircleAvatar(
                                //     backgroundColor: Colors.green,
                                //     radius: 4.0,
                                //   )
                                // ],
                              ],
                            ),
                          )
                        : null,
                    body: Column(
                      children: [
                        TabBar(
                          labelColor: Colors.black87,
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.notifications_active_outlined),
                                  Text('Notificaciones'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.fact_check_outlined),
                                  Text('Pedidos'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TabBarView(
                              controller: _tabController,
                              children: [unoWebview(), dosWebView()],
                            ),
                          ),
                        ),
                      ],
                    )),
              )
            : unoWebview(),
        //esat dentro de un Stack
        circleNot(),
      ],
    );
  }

  bool mover = false;
  Widget circleNot() {
    final estadoGlobal = Provider.of<EstadoGlobal>(context);
    mover = estadoGlobal.refreshList;
    return AnimatedPositioned(
      right: mover ? 0 : -75,
      bottom: 0,
      duration: const Duration(seconds: 2),
      onEnd: () {
        _slideBack();
      },
      curve: Curves.easeInOutSine,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.black,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/bell.gif',
                    width: 28,
                    height: 28,
                  ),
                  const Text(
                    'nueva\nnotificacion',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8),
                  )
                ],
              ),
            )),
      ),
    );
  }

  void _slideBack() {
    Timer(const Duration(seconds: 3), () {
      setState(() {
        datosListNoti();
      });
      final estadoGlobal = Provider.of<EstadoGlobal>(context, listen: false);
      estadoGlobal.refreshLista(false);
    });
  }

  // Widget botonesPageView() {
  //   return Visibility(
  //     visible: Constant.shared.dataUser['tipo'] == 'propietario' ? true : false,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 50.0),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: const Color.fromARGB(255, 237, 237, 237),
  //           borderRadius: BorderRadius.circular(4),
  //           boxShadow: [
  //             const BoxShadow(
  //               color: Color.fromARGB(170, 144, 143, 143),
  //               offset: Offset(9, 7),
  //               blurRadius: 6,
  //             ),
  //           ],
  //         ),
  //         width: double.infinity,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 5.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   pageViewController.animateToPage(0,
  //                       duration: const Duration(microseconds: 3350),
  //                       curve: Curves.bounceInOut);
  //                   setState(() {
  //                     ventana = 1;
  //                   });
  //                 },
  //                 child: Column(
  //                   children: [
  //                     Icon(
  //                       Icons.notifications_none_outlined,
  //                       size: 25,
  //                       color: ventana == 1
  //                           ? const Color.fromARGB(255, 7, 172, 255)
  //                           : const Color.fromARGB(255, 63, 63, 63),
  //                     ),
  //                     Text(
  //                       'notificaciones',
  //                       style: TextStyle(
  //                           color: ventana == 1
  //                               ? const Color.fromARGB(255, 7, 172, 255)
  //                               : const Color.fromARGB(255, 63, 63, 63),
  //                           fontSize: 12),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   pageViewController.animateToPage(1,
  //                       duration: const Duration(microseconds: 3350),
  //                       curve: Curves.bounceInOut);
  //                   setState(() {
  //                     ventana = 2;
  //                   });
  //                 },
  //                 child: Column(
  //                   children: [
  //                     Icon(
  //                       Icons.filter_frames_outlined,
  //                       size: 25,
  //                       color: ventana == 2
  //                           ? const Color.fromARGB(255, 7, 172, 255)
  //                           : const Color.fromARGB(255, 63, 63, 63),
  //                     ),
  //                     Text(
  //                       'filtro',
  //                       style: TextStyle(
  //                           color: ventana == 2
  //                               ? const Color.fromARGB(255, 7, 172, 255)
  //                               : const Color.fromARGB(255, 63, 63, 63),
  //                           fontSize: 12),
  //                     )
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget pageView() {
  //   return Expanded(
  //     child: Container(
  //       width: double.infinity,
  //       height: double.infinity,
  //       child: PageView(
  //         physics: const BouncingScrollPhysics(),
  //         controller: pageViewController,
  //         onPageChanged: (int page) {
  //           setState(() {
  //             if (page == 0) {
  //               ventana = 1;
  //             } else {
  //               ventana = 2;
  //             }
  //           });
  //         },
  //         scrollDirection: Axis.horizontal,
  //         children: [unoWebview(), dosWebView()],
  //       ),
  //     ),
  //   );
  // }

  Widget unoWebview() {
    return Scaffold(
      appBar: Constant.shared.dataUser['tipo'] == 'propietario'
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.notifications_none),
                  Text(
                    'Notificaciones',
                    style:
                        GoogleFonts.lobster(color: Colors.black, fontSize: 24),
                  ),
                ],
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
                child: datos.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () => datosListNoti(),
                        child: ListView.builder(
                            itemCount: datos.length,
                            itemBuilder: (context, index) {
                              if (datos[index]['tipo'] == 'interno') {
                                return cardInterno(index);
                              }
                              if (datos[index]['tipo'] != 'atender_p') {
                                return cardNoTienda(index);
                              }
                              return const SizedBox();
                            }),
                      )
                    : loadingNoProp
                        ? loading1
                        : loading2),
          ],
        ),
      ),
    );
  }

  Widget dosWebView() {
    return Column(
      children: [
        botonesRadiusSelectores(),
        const Divider(),
        Expanded(
            child: dataCont.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () => datosListcuentas(),
                    child: ListView.builder(
                        itemCount: dataCont.length,
                        itemBuilder: (context, index) {
                          if (dataCont[index]['estado'] == estadoN ||
                              dataCont[index]['estado'] == aux) {
                            return cardSeleccion(index);
                          }
                          return const SizedBox();
                        }),
                  )
                //datos[index]['estado']=="atender_p"
                : loadingProp
                    ? loading1
                    : loading2),
      ],
    );
  }

  var stilo = const TextStyle(
      fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 16);
  Widget cardNoTienda(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -0.5),
          onTap: () {
            if (datos[index]["tipo"] == 'repartidor' &&
                Constant.shared.dataUser['tipo'] == 'repartidor' &&
                (datos[index]["estado"] == 'Sin Atender' ||
                    datos[index]["estado"] ==
                        Constant.shared.dataUser['_id'])) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GestionarPedidoRepartidor(
                        tipo: 'repartidor',
                        idNotifi: idNoti,
                        title: datos[index]["title"],
                        id_cuenta: datos[index]["id_cont"],
                        id_tienda: datos[index]["id_tienda"])),
              ).then((value) {
                setState(() {
                  datosListNoti();
                });
              });
            }
            if (datos[index]["tipo"] == 'respTienda-EnCamino') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GestionarPedidoRepartidor(
                        tipo: 'respTienda-EnCamino',
                        idNotifi: idNoti,
                        title: datos[index]["title"],
                        id_cuenta: datos[index]["id_cont"],
                        id_tienda: datos[index]["id_tienda"])),
              ).then((value) {
                setState(() {
                  datosListNoti();
                });
              });
            }
          },
          leading: datos[index]["url"] != ''
              ? CircleAvatar(
                  backgroundImage: NetworkImage(datos[index]["url"]),
                  radius: 25,
                )
              : CircleAvatar(
                  radius: 28,
                  child: Text(
                    datos[index]['body'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
          title: Text(
            datos[index]["title"],
            style: stilo,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(datos[index]["body"], style: stilo),
              Text(datos[index]["time"]),
              Visibility(
                visible: datos[index]["tipo"] == 'repartidor' &&
                    datos[index]["estado"] != 'Sin Atender',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: datos[index]["estado"] ==
                            Constant.shared.dataUser['_id']
                        ? Color.fromARGB(255, 24, 155, 207)
                        : Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    datos[index]["estado"] == Constant.shared.dataUser['_id']
                        ? 'Tu pedido'
                        : "De otro repartidor",
                    style: const TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          trailing: Visibility(
              visible: datos[index]["tipo"] == 'respTienda-EnCamino',
              child: const Icon(Icons.arrow_forward_ios)),
        ),
      ),
    );
  }

  Widget cardInterno(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -0.5),
          leading: Image.asset('images/logo.png'),
          title: Text(
            datos[index]["title"],
            style: stilo,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(datos[index]["body"], style: stilo),
              Text(datos[index]["time"]),
            ],
          ),
          trailing: Visibility(
              visible: datos[index]["tipo"] == 'respTienda-EnCamino',
              child: const Icon(Icons.arrow_forward_ios)),
        ),
      ),
    );
  }

  Widget cardSeleccion(index) {
    var fechaTime = dataCont[index]['time'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        //key: ValueKey(datanew[index]['precio']),
        color: dataCont[index]['estado'] == ''
            ? const Color.fromARGB(255, 225, 225, 225)
            : dataCont[index]['estado'] == 'aceptado'
                ? const Color.fromARGB(255, 202, 231, 252)
                : dataCont[index]['estado'] == 'enviado' ||
                        dataCont[index]['estado'] == 'entregado'
                    ? const Color.fromARGB(255, 227, 251, 234)
                    : const Color.fromARGB(255, 255, 219, 209),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AtenderPedido(tipo: '', cuenta: dataCont[index])),
            ).then((value) => setState(() {
                  datosListcuentas();
                  //FocusScope.of(context).unfocus();
                }));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: dataCont[index]['user']["url"] != ''
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(dataCont[index]['user']["url"]),
                          radius: 20,
                        )
                      : CircleAvatar(
                          radius: 20,
                          child: Text(
                            dataCont[index]['user']['nombre']
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                ),
                title:
                    Text('${dataCont[index]['nombreTienda']} tiene un pedido'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataCont[index]['user']['nombre']} tiene una orden en espera',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fechaTime ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Pago ${dataCont[index]['tipoDePago']['tipo'] ?? ''}',
                          style: TextStyle(
                              fontSize: 11,
                              color: dataCont[index]['tipoDePago']['tipo'] ==
                                      'En efectivo'
                                  ? const Color.fromARGB(255, 150, 83, 244)
                                  : const Color.fromARGB(255, 40, 169, 44)),
                        )
                      ],
                    ),
                    Visibility(
                        visible: dataCont[index]['estado'] == 'entregado',
                        child: Row(
                          children: [
                            Text(
                              'Pedido completado con exito  ',
                              style: TextStyle(
                                  color: Colors.blue.shade600, fontSize: 12),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue.shade600,
                              size: 12,
                            ),
                          ],
                        ))
                  ],
                )
                //trailing: Text("12"),
                ),
          ),
        ),
      ),
    );
  }

  int _value = 1;
  var estadoN = '';
  var aux;
  Widget botonesRadiusSelectores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Column(
            children: [
              Text(
                'en espera',
                style: estilo,
              ),
              Radio(
                  value: 1,
                  groupValue: _value,
                  onChanged: (val) {
                    setState(() {
                      estadoN = '';
                      aux = null;
                      _value = val as int;
                    });
                  })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Column(
            children: [
              Text(
                'aceptados',
                style: estilo,
              ),
              Radio(
                  value: 2,
                  groupValue: _value,
                  onChanged: (value) {
                    setState(() {
                      estadoN = 'aceptado';
                      aux = null;
                      _value = value as int;
                    });
                  })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Column(
            children: [
              Text(
                'enviados',
                style: estilo,
              ),
              Radio(
                  value: 3,
                  groupValue: _value,
                  onChanged: (value) {
                    setState(() {
                      estadoN = 'enviado';
                      aux = 'entregado';
                      _value = value as int;
                    });
                  })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Column(
            children: [
              Text(
                'cancelados',
                style: estilo,
              ),
              Radio(
                  value: 4,
                  groupValue: _value,
                  onChanged: (value) {
                    setState(() {
                      estadoN = 'cancelado';
                      aux = null;
                      _value = value as int;
                    });
                  })
            ],
          ),
        )
      ],
    );
  }
}
// ElevatedButton(
//   style: ElevatedButton.styleFrom(
//     primary: Colors.white,
//     onPrimary: Colors.green,
//     padding: EdgeInsets.symmetric(horizontal: 100),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(30.0),
//       side: BorderSide(color: Colors.black, width: 1),
//     ),
//   ),
//   onPressed: () {
//     // Acción al presionar el botón
//   },
//   child: Text('Botón con bordes redondeados'),
// )
