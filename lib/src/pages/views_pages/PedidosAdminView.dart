import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/gestiones/atender.pedido.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class PedidosAdminView extends StatefulWidget {
  var propiedad;

  PedidosAdminView({Key? key, required this.propiedad}) : super(key: key);

  @override
  State<PedidosAdminView> createState() => _PedidosAdminViewState();
}

class _PedidosAdminViewState extends State<PedidosAdminView> {
  @override
  void initState() {
    super.initState();
    datosListNoti();
  }

  late List datos = [];
  Future datosListNoti() async {
    var url =
        "${Constant.shared.urlApi}/cont/?id_adm=${widget.propiedad['_id']}&order=fecha_reg,-1";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (json.decode(response.body).length != 0) {
      if (this.mounted) {
        setState(() {
          datos = json.decode(response.body);
        });
        // print(datos);
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: cuerpo(),
      ),
    );
  }

  Widget cuerpo() {
    return Column(
      children: [lista()],
    );
  }

  var fecha = '';
  Widget lista() {
    return Expanded(
      child: datos.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () => datosListNoti(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                    itemCount: datos.length,
                    itemBuilder: (context, index) {
                      if (datos[index]['fecha_reg'].substring(0, 7) != fecha) {
                        fecha = datos[index]['fecha_reg'].substring(0, 7);
                        return Column(
                          children: [cardFecha(index), cardCuentas(index)],
                        );
                      } else {
                        return cardCuentas(index);
                      }
                    }),
              ),
            )
          : const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'cargando datos',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }

  Widget cardFecha(index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 1,
              color: Colors.black54,
            ),
            Container(
              color: Color.fromARGB(255, 212, 212, 212),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  datos[index]['fecha_reg'].substring(0, 7),
                  style: const TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              width: 80,
              height: 1,
              color: Colors.black54,
            ),
          ],
        ),
        // const SizedBox(
        //   height: 5,
        // ),
        // cardCuentas(index)
      ],
    );
  }

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);

  Widget cardCuentas(index) {
    DateTime fechaTime = DateTime.parse(datos[index]['fecha_reg']);
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
                  builder: (context) => AtenderPedido(
                        tipo: 'admin',
                        cuenta: datos[index],
                      )),
            ).then((value) => setState(() {
                  datosListNoti();
                  //FocusScope.of(context).unfocus();
                }));
          },
          title: Text(
            datos[index]["nombreTienda"],
            style: stilo,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              datos[index]["estado"] == ''
                  ? const Text(
                      'No atendida',
                      style: TextStyle(color: Colors.redAccent),
                    )
                  : Text(
                      datos[index]["estado"],
                      style: TextStyle(
                          color: datos[index]["estado"] == 'aceptado'
                              ? Colors.blue
                              : datos[index]["estado"] == 'enviado'
                                  ? Colors.green
                                  : datos[index]["estado"] == 'entregado'
                                      ? Colors.purple
                                      : Colors.red),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fechaTime.toString().substring(0, 16)),
                  Text(
                    'Pago ${datos[index]["tipoDePago"]['tipo'] ?? ''}',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            datos[index]["tipoDePago"]['tipo'] == 'En efectivo'
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
