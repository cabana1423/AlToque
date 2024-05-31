import 'dart:convert';
import 'dart:developer';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/repartidores/Gestionar.pedido.repartidor.dart';
import 'package:gowin/src/pages/repartidores/ViewCuentasRepartidorSemana.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RepartidorPanelControl extends StatefulWidget {
  RepartidorPanelControl({Key? key}) : super(key: key);

  @override
  State<RepartidorPanelControl> createState() => Repartidor_PanelControlState();
}

class Repartidor_PanelControlState extends State<RepartidorPanelControl>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 1, vsync: this);
    datosListNoti();
  }

  List pendiente = [];
  void obtenerPendiente(data) {
    pendiente = data.where((element) {
      final estado = element['estado'];
      final repartidorEstado = element['repartidor']['estado'];
      return (estado == 'enviado' || estado == 'aceptado') &&
          repartidorEstado == 'no entregada';
    }).toList();
    log(pendiente.toString());
    if (pendiente.isNotEmpty) {
      getIdNoti();
    }
  }

  var id_not = '';
  Future getIdNoti() async {
    var url =
        "${Constant.shared.urlApi}/cont/id_not?id_u=${Constant.shared.dataUser['_id']}";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          id_not = json.decode(response.body)['id'];
        });
        // print(id_not);
      }
    }
  }

  late List datos = [];
  Future datosListNoti() async {
    var url =
        "${Constant.shared.urlApi}/cont/?id_rep=${Constant.shared.dataUser['_id']}&order,-1";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (json.decode(response.body).length != 0) {
      if (this.mounted) {
        setState(() {
          datos = json.decode(response.body).where((element) {
            final estado = element['estado'];
            final repartidorEstado = element['repartidor']['estado'];
            return estado == 'entregado' ||
                estado == 'enviado' && repartidorEstado == 'entregado';
          }).toList();
          // log(datos.toString());
          obtenerPendiente(json.decode(response.body));
        });
        // print(datos);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => const ViewCuentasRepartidorSemana()));
      //       },
      //       child: const Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Icon(
      //             Icons.library_books_outlined,
      //             color: Colors.black87,
      //           ),
      //           SizedBox(width: 8.0),
      //           Text(
      //             'Cuentas',
      //             style: TextStyle(color: Colors.black87, fontSize: 10),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      //   // automaticallyImplyLeading: false,
      // ),
      body: Column(
        children: [
          TabBar(
            labelColor: Colors.black87,
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.delivery_dining),
                    const Text('Pedido actual'),
                    if (pendiente.isNotEmpty) ...[
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 4.0,
                      )
                    ],
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.list_alt_rounded),
                    Text('Cuentas'),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                pendiente.isNotEmpty
                    ? GestionarPedidoRepartidor(
                        tipo: 'repartidor',
                        idNotifi: id_not,
                        title: '',
                        id_cuenta: pendiente[0]['_id'],
                        id_tienda: '')
                    : const Center(child: Text('No tiene pedidos pendiente')),
                const ViewCuentasRepartidorSemana()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget lista() {
    return Column(
      children: [
        const SizedBox(height: 5),
        Expanded(
          child: datos.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () => datosListNoti(),
                  child: ListView.builder(
                      itemCount: datos.length,
                      itemBuilder: (context, index) {
                        DateTime fecha =
                            DateTime.parse('${datos[index]["fecha_reg"]}');
                        String fechaFormateada =
                            DateFormat("dd/MM/yyyy HH:mm:ss", "es")
                                .format(fecha);
                        return cardCont(index, fechaFormateada);
                      }),
                )
              : const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Aun no hay notificaciones',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
        ),
      ],
    );
  }

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);
  Widget cardCont(index, fecha) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -0.5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GestionarPedidoRepartidor(
                      tipo: 'repartidor_lista',
                      idNotifi: '',
                      title: '',
                      id_cuenta: datos[index],
                      id_tienda: '')),
            );
          },
          title: Text(
            datos[index]["nombreTienda"],
            style: stilo,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orden entregada'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fecha),
                  Text(
                    'Pago ${datos[index]['tipoDePago']['tipo'] ?? ''}',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            datos[index]['tipoDePago']['tipo'] == 'En efectivo'
                                ? const Color.fromARGB(255, 150, 83, 244)
                                : const Color.fromARGB(255, 40, 169, 44)),
                  )
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
