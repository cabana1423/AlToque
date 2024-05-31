// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/chat/Individual_page.dart';
import 'package:gowin/src/pages/repartidores/Gestionar.pedido.repartidor.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class AtenderPedido extends StatefulWidget {
  var cuenta;

  var tipo;

  AtenderPedido({Key? key, @required this.cuenta, this.tipo}) : super(key: key);

  @override
  _AtenderPedidoState createState() => _AtenderPedidoState();
}

class _AtenderPedidoState extends State<AtenderPedido> {
  /// otro stepper

  @override
  void initState() {
    super.initState();
    datosCuenta();
    datosPropiedad();
  }

  var nombre;
  var urlU;
  var idTienda;
  var pago;
  void datosCuenta() {
    if (mounted) {
      setState(() {
        nombre = widget.cuenta['user']['nombre'];
        urlU = widget.cuenta['user']['url'];
        idTienda = widget.cuenta['idTienda'];
        idCuenta = widget.cuenta['_id'];
        datos = widget.cuenta["productos"];
        estado = widget.cuenta["estado"];
        pago = widget.cuenta["tipoDePago"]['tipo'];
        // propiedad = json.decode(response.body)['propiedad'];
        id_remitente = widget.cuenta["id_userPed"];
        repartidor_ = widget.cuenta['repartidor'];
      });
    }
  }

  late List datos = [];
  String estado = "";
  var propiedad;
  var id_remitente;
  var repartidor_;
  var idCuenta;
  Future freshCuenta() async {
    var url =
        '${Constant.shared.urlApi + "/cont/id?id=" + idCuenta}&idT=' + idTienda;
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      //print(response.body);
      if (mounted) {
        setState(() {
          // print(json.decode(response.body));
          estado = json.decode(response.body)["cuentas"]["estado"];
          repartidor_ = json.decode(response.body)["cuentas"]['repartidor'];

          // idCuenta = json.decode(response.body)['cuentas']['_id'];
        });
      }
      //print(datos);
    }
  }

  Future<void> datosPropiedad() async {
    String url = "${Constant.shared.urlApi}/prop/id?id=$idTienda";
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      ToastNotification.toastNotificationError(
          'error al obtener los datos', context);
    }
    setState(() {
      propiedad = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          freshCuenta();
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue, // Color de fondo del botón
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _fotoDatosU(),
                const Divider(),
                Text(
                  'Este pedido se a pagado ${pago ?? ""}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: pago == 'En efectivo'
                          ? Color.fromARGB(255, 150, 83, 244)
                          : Color.fromARGB(255, 40, 169, 44)),
                ),
                const Divider(),
                Container(
                  child: estado == 'entregado'
                      ? Text('El cliente  confirmo la entrega del pedido 😊',
                          style: stilo)
                      : estado == 'enviado' &&
                              widget.cuenta['repartidor']['estado'] ==
                                  'entregado'
                          ? Text('el cliente no confirmo la entrega del pedido',
                              style: stilo)
                          : estado == 'enviado'
                              ? Text(
                                  'El cliente esta esperando la entrega del pedido..',
                                  style: stilo)
                              : const SizedBox(),
                ),
                const Divider(),
                repartidor_ != null ? repartidor() : const SizedBox(),
                _botones(),
                const SizedBox(
                  height: 10,
                ),
                _tabla(),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
              ],
            ),
            //###SE PUEDE PONER FIJO SI SE LO PONE FUERA DEL STACK?????
          ],
        ),
      ),
    );
  }

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);
  Widget repartidor() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: ListTile(
          onTap: propiedad == null
              ? null
              : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GestionarPedidoRepartidor(
                                id_cuenta: idCuenta,
                                title: '',
                                idNotifi: '',
                                id_tienda: propiedad['_id'],
                                tipo: 'tienda',
                              ))).then((value) => setState(() {
                        freshCuenta();
                      }));
                },
          leading: Image.asset(
            'images/moto.gif',
            width: 50,
            height: 50,
          ),
          title: Text(
            'Repartidor asignado',
            style: stilo,
          ),
          subtitle: Text(
            'Nombre: ${repartidor_['nombre']}\nEstado del pedido: ${repartidor_['estado']}',
            style: stilo,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ),
    );
  }

  Widget _fotoDatosU() {
    return Stack(
      children: [
        SizedBox(
          height: 90,
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: 80,
                width: MediaQuery.of(context).size.width * 0.20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                        begin: FractionalOffset.centerRight,
                        end: FractionalOffset.centerLeft,
                        colors: estado == 'aceptado'
                            ? [
                                const Color.fromARGB(255, 0, 211, 230),
                                const Color.fromARGB(255, 167, 246, 253)
                              ]
                            : estado == 'enviado'
                                ? [
                                    const Color.fromARGB(255, 17, 249, 102),
                                    const Color.fromARGB(255, 182, 255, 209)
                                  ]
                                : estado == 'entregado'
                                    ? [
                                        const Color.fromARGB(255, 249, 206, 17),
                                        const Color.fromARGB(255, 255, 238, 182)
                                      ]
                                    : estado == 'cancelado'
                                        ? [
                                            const Color.fromARGB(
                                                255, 239, 83, 80),
                                            const Color.fromARGB(
                                                255, 246, 186, 185)
                                          ]
                                        : [
                                            const Color.fromARGB(
                                                255, 132, 132, 132),
                                            const Color.fromARGB(
                                                255, 199, 199, 199),
                                          ],
                        stops: [0.0, 1.0])),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 80.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                        begin: FractionalOffset.centerRight,
                        end: FractionalOffset.bottomLeft,
                        colors: estado == 'aceptado'
                            ? [
                                Colors.grey.withOpacity(0.0),
                                const Color.fromARGB(255, 0, 211, 230),
                              ]
                            : estado == 'enviado'
                                ? [
                                    Colors.grey.withOpacity(0.0),
                                    const Color.fromARGB(255, 17, 249, 102),
                                  ]
                                : estado == 'entregado'
                                    ? [
                                        Colors.grey.withOpacity(0.0),
                                        const Color.fromARGB(255, 249, 206, 17),
                                      ]
                                    : estado == 'cancelado'
                                        ? [
                                            Colors.grey.withOpacity(0.0),
                                            const Color.fromARGB(
                                                255, 239, 83, 80),
                                          ]
                                        : [
                                            Colors.grey.withOpacity(0.0),
                                            const Color.fromARGB(
                                                255, 132, 132, 132),
                                          ],
                        //Colors.grey.withOpacity(0.0),
                        stops: [0.0, 1.0])),
              ),
            ],
          ),
        ),
        Positioned(
          right: 50,
          child: urlU != ''
              ? CircleAvatar(
                  radius: 43,
                  backgroundImage: NetworkImage(urlU),
                )
              : CircleAvatar(
                  radius: 43,
                  child: Text(
                    nombre.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
        ),
        Positioned(right: 38, bottom: 15, child: contactarUser()),
        Positioned(
          top: 8,
          left: 20,
          child: SlideInLeft(
            duration: const Duration(seconds: 4),
            child: Text(
              "Tienes Un Pedido De:",
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 20,
          child: SlideInLeft(
            duration: const Duration(seconds: 4),
            child: Text(
              nombre,
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Visibility contactarUser() {
    return Visibility(
      visible: Constant.shared.dataUser['_id'] == id_remitente ? false : true,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IndividualPage(
                      id_u: Constant.shared.dataUser['_id'],
                      nombre: propiedad['nombre'],
                      url: propiedad['img_prop'][0]['Url'],
                      id_2: id_remitente,
                      nombre2: nombre,
                      url2: urlU,
                      telefono_2: '',
                      id_prop: propiedad['_id'],
                      ultm: '',
                      zt: '',
                      imgProd: '',
                      tituloProd: '')));
        },
        child: const CircleAvatar(
          radius: 18,
          child: Icon(Icons.phone),
          backgroundColor: Color.fromARGB(205, 133, 216, 255),
        ),
      ),
    );
  }

  Widget _tabla() {
    return DataTable(
      horizontalMargin: 10,
      columns: const [
        DataColumn(label: Text("Producto")),
        DataColumn(label: Text("Cantidad")),
        DataColumn(label: Text("Precio")),
      ],
      rows: datos
          .map((item) => DataRow(selected: true, cells: <DataCell>[
                DataCell(Text(item["nombre_p"].toString())),
                DataCell(Text(item["cantidad"].toString())),
                DataCell(Text(item["total_p"].toString()))
              ]))
          .toList(),
    );
  }

  Future _update(val, estado) async {
    if (val == "") {
      val = "aceptado";
    } else if (val == "aceptado") {
      val = "enviado";
    }
    String url = '${Constant.shared.urlApi + "/cont/?id=" + idCuenta}';
    var response = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'estado': val ?? '',
    });
    if (response.statusCode == 200) {
      // print(response.body);
      if (mounted) {
        setState(() {
          widget.cuenta = json.decode(response.body);
        });
      }
      notificarPostUpdate(estado);
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ToastNotification.toastPeque(response.body.toString(), context);
      }
    }
  }

  Future fcm_notification(auxiliar, page) async {
    String url = "${Constant.shared.urlApi}/fcm";
    var time = DateTime.now().toString().substring(0, 16);
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id_2': id_remitente,
      'title': propiedad['nombre'],
      'body': auxiliar,
      'page': page,
      'id_cont': idCuenta,
      'time': time,
      'url': propiedad['img_prop'][0]['Url'] ?? '',
      'id_tienda': propiedad['_id']
    });
    if (res.statusCode == 200) {
    } else {
      print(res.statusCode);
    }
  }

  Widget _botones() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: estado == ""
                    ? () {
                        if (propiedad != null) {
                          _update(estado, 'acep');
                          notificationRepartidores();
                        }
                      }
                    : null,
                child: Column(
                  children: [
                    Icon(
                        estado == "aceptado"
                            ? Icons.shopping_cart_rounded
                            : estado == "enviado"
                                ? Icons.shopping_cart_rounded
                                : Icons.shopping_cart_outlined,
                        size: 40,
                        color: estado == ""
                            ? Colors.grey
                            : estado == "aceptado"
                                ? const Color.fromARGB(255, 0, 211, 230)
                                : estado == "enviado"
                                    ? const Color.fromARGB(255, 0, 211, 230)
                                    : Colors.grey),
                    Text(
                      "aceptar",
                      style: TextStyle(
                          color: estado == ""
                              ? Colors.grey
                              : estado == "aceptado"
                                  ? const Color.fromARGB(255, 0, 211, 230)
                                  : estado == "enviado"
                                      ? const Color.fromARGB(255, 0, 211, 230)
                                      : Colors.grey),
                    )
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: estado == "aceptado"
                    ? () {
                        if (repartidor_ == null) {
                          ToastNotification.toastNotificationAlert(
                              'Aun no hay un repartidor asignado', context);
                          return;
                        }
                        if (propiedad != null) {
                          _update(estado, 'envi');
                        }
                      }
                    : null,
                child: Column(
                  children: [
                    Icon(
                      estado == "enviado" ? Icons.send : Icons.send_outlined,
                      size: 40,
                      color: estado == "enviado"
                          ? const Color.fromARGB(255, 17, 249, 102)
                          : Colors.grey,
                    ),
                    Text(
                      "enviar",
                      style: TextStyle(
                          color: estado == "enviado"
                              ? const Color.fromARGB(255, 1, 203, 106)
                              : Colors.grey),
                    )
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: estado == ""
                    ? () {
                        if (propiedad != null) {
                          _update("cancelado", 'cancel');
                        }
                      }
                    : null,
                child: Column(
                  children: [
                    Icon(
                      estado == "cancelado"
                          ? Icons.cancel
                          : Icons.cancel_outlined,
                      size: 40,
                      color: estado == "cancelado"
                          ? Colors.red.shade400
                          : Colors.grey,
                    ),
                    Text(
                      estado == "cancelado" ? 'cancelado' : "cancelar",
                      style: TextStyle(
                          color: estado == "cancelado"
                              ? Colors.red.shade400
                              : Colors.grey),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void notificarPostUpdate(val) {
    switch (val) {
      case 'envi':
        fcm_notification('su pedido esta en camino.. gracias por preferirnos',
            "respTienda-EnCamino");
        break;
      case 'acep':
        fcm_notification(
          'Su pedido fue atendido le informaremos cuando este listo para enviárselo',
          "respTienda-Cliente",
        );
        break;
      case 'cancel':
        fcm_notification(
            'lo sentimos no podemos atender su pedido', "respTienda-Cancelado");
        break;

      default:
    }
  }

  Future notificationRepartidores() async {
    String url = "${Constant.shared.urlApi}/fcm/sendRep";
    var time = DateTime.now().toString().substring(0, 16);

    var datos = {
      'id_2': id_remitente,
      'id_cont': idCuenta,
      'time': time,
      'url': propiedad['img_prop'][0]['Url'] ?? '',
      'title': '${propiedad['nombre']} tiene una orden',
      'id_tienda': idTienda
    };
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'title': '${propiedad['nombre']} tiene una orden',
      'body': 'talvez pueda interesarte \n ¿Quieres tomarla?',
      'page': "NotRepartidor",
      'datos': json.encode(datos),
      'id_tienda': idTienda
    });
    if (res.statusCode == 200) {
    } else {
      print(res.statusCode);
    }
  }
}
