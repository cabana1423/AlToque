import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/gestiones/atender.pedido.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class PedidosAdminCuentasView extends StatefulWidget {
  var propiedad;

  PedidosAdminCuentasView({super.key, required this.propiedad});

  @override
  State<PedidosAdminCuentasView> createState() =>
      _PedidosAdminCuentasViewState();
}

class _PedidosAdminCuentasViewState extends State<PedidosAdminCuentasView> {
  @override
  void initState() {
    super.initState();
    datoscont();
  }

  List datos = [];
  Future datoscont() async {
    var url =
        "${Constant.shared.urlApi}/cont/ordenarFecha?idProp=${widget.propiedad['_id']}";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          datos = json.decode(response.body);
          build(context);
        });
        log(datos.length.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(alignment: Alignment.center, child: lista()),
    );
  }

  Widget lista() {
    return Expanded(
      child: datos.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () => datoscont(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                    itemCount: datos.length,
                    itemBuilder: (context, index) {
                      return cardCuentas(index);
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

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);

  Widget cardCuentas(index) {
    String formattedDate = '';
    DateTime dateTime =
        DateTime.parse(datos[index]['documentos'][0]["fecha_reg"]);
    formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
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
                  builder: (context) => CuentasAdminPorDias(
                        data: datos[index]['documentos'],
                      )),
            ).then((value) => setState(() {
                  datoscont();
                  //FocusScope.of(context).unfocus();
                }));
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'semana ${datos[index]['_id']} del año',
                style: stilo,
              ),
              const Text('Total')
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate ?? '',
              ),
              Text(
                '${calcular(datos[index]['documentos'])} Bs',
                style: TextStyle(
                    color: calcular(datos[index]['documentos']).contains('-')
                        ? Colors.red
                        : calcular(datos[index]['documentos']) == '0.0'
                            ? null
                            : Colors.green),
              )
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}

String calcular(data) {
  var cantidad = data.length;
  double sumaTotal = 0.0;
  for (var i = 0; i < cantidad; i++) {
    if (data[i]['repartidor'] != null) {
      var estdcuent = data[i]['estado'];
      var estdRep = data[i]['repartidor']['estado'];
      if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
          (estdcuent == 'entregado' && estdRep == 'entregado') ||
          (estdcuent == 'enviado' && estdRep == 'no entregada')) {
        sumaTotal = sumaTotal + double.parse(data[i]['tipoDePago']['cuenta']);
      }
    }
  }
  return sumaTotal.toStringAsFixed(1);
}

class CuentasAdminPorDias extends StatefulWidget {
  List data;
  CuentasAdminPorDias({super.key, required this.data});

  @override
  State<CuentasAdminPorDias> createState() => _CuentasAdminPorDiasState();
}

class _CuentasAdminPorDiasState extends State<CuentasAdminPorDias> {
  @override
  void initState() {
    super.initState();
    // calculo();
    ordenarLista();
  }

  List<Map<String, dynamic>> transformedList = [];

  void ordenarLista() {
    for (var group
        in groupBy(widget.data, (obj) => obj['fecha_reg'].substring(0, 10))
            .entries) {
      List documentos = group.value;
      String dia = group.key;
      transformedList.add({
        'dia': dia,
        'documentos': documentos,
      });
    }

    // log(transformedList.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: lista(),
    ));
  }

  var vect = [];

  Widget lista() {
    return Expanded(
      child: transformedList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                  itemCount: transformedList.length,
                  itemBuilder: (context, index) {
                    return cardCuentas(index, context);
                  }),
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

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);

  Widget cardCuentas(index, context) {
    DateTime fecha = DateTime.parse(transformedList[index]['dia']);
    // DateTime fechaTime = DateTime.parse(widget.data[index]['fecha_reg']);
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
                  builder: (context) => ViewCuentasAdminDelDia(
                        data: transformedList[index]['documentos'],
                      )),
            );
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(obtenerNombreDia(fecha)),
                  Text('Total'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(transformedList[index]['dia'].toString()),
                  Text(
                    '${calcular(transformedList[index]['documentos'])} Bs',
                    style: TextStyle(
                        color: calcular(transformedList[index]['documentos'])
                                .contains('-')
                            ? Colors.red
                            : calcular(transformedList[index]['documentos']) ==
                                    '0.0'
                                ? null
                                : Colors.green),
                  )
                ],
              )
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  String calcular(data) {
    var cantidad = data.length;
    double sumaTotal = 0.0;
    for (var i = 0; i < cantidad; i++) {
      if (data[i]['repartidor'] != null) {
        var estdcuent = data[i]['estado'];
        var estdRep = data[i]['repartidor']['estado'];
        if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
            (estdcuent == 'entregado' && estdRep == 'entregado') ||
            (estdcuent == 'enviado' && estdRep == 'no entregada')) {
          sumaTotal = sumaTotal + double.parse(data[i]['tipoDePago']['cuenta']);
        }
      }
    }
    return sumaTotal.toStringAsFixed(1);
  }

  String obtenerNombreDia(DateTime fecha) {
    final formatter = DateFormat('EEEE', 'es');
    return formatter.format(fecha);
  }
}

class ViewCuentasAdminDelDia extends StatefulWidget {
  List data;
  ViewCuentasAdminDelDia({super.key, required this.data});

  @override
  State<ViewCuentasAdminDelDia> createState() => _ViewCuentasAdminDelDiaState();
}

class _ViewCuentasAdminDelDiaState extends State<ViewCuentasAdminDelDia> {
  @override
  void initState() {
    super.initState();
    calculo();
  }

  double sumaFinal = 0;
  void calculo() {
    double suma = 0;
    for (var i = 0; i < widget.data.length; i++) {
      if (widget.data[i]['repartidor'] != null) {
        var estdcuent = widget.data[i]['estado'];
        var estdRep = widget.data[i]['repartidor']['estado'];
        if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
            (estdcuent == 'entregado' && estdRep == 'entregado') ||
            (estdcuent == 'enviado' && estdRep == 'no entregada')) {
          suma = suma + (double.parse(widget.data[i]['tipoDePago']['cuenta']));
        }
      }
    }
    log(sumaFinal.toString());
    setState(() {
      sumaFinal = suma;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: lista(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Container(
              width: 200,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 214, 214, 214),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(sumaFinal.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  var vect = [];
  bool vacio = true;
  Widget lista() {
    return Expanded(
      child: widget.data.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) {
                    var estdRep = '';
                    var estdcuent = widget.data[index]['estado'];
                    if (widget.data[index]['repartidor'] != null) {
                      estdRep =
                          widget.data[index]['repartidor']['estado'] ?? '';
                    }
                    if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
                        (estdcuent == 'entregado' && estdRep == 'entregado') ||
                        (estdcuent == 'enviado' && estdRep == 'no entregada')) {
                      vacio = false;
                      return cardCuentas(index, context);
                    }
                    if (index == widget.data.length - 1 && vacio == true) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: Text(
                          'Ningun Pedido se a completado este dia',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
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

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);

  Widget cardCuentas(index, context) {
    DateTime fechaTime = DateTime.parse(widget.data[index]['fecha_reg']);
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
                        cuenta: widget.data[index],
                      )),
            );
          },
          title: Text(
            widget.data[index]["nombreTienda"],
            style: stilo,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.data[index]["estado"] == ''
                      ? const Text(
                          'No atendida',
                          style: TextStyle(color: Colors.redAccent),
                        )
                      : Text(widget.data[index]["estado"]),
                  widget.data[index]['tipoDePago']['tipo'] == 'En efectivo'
                      ? Text(
                          '${widget.data[index]['tipoDePago']['cuenta']} Bs',
                          style: const TextStyle(color: Colors.red),
                        )
                      : Text(
                          '${widget.data[index]['tipoDePago']['cuenta']} Bs',
                          style: const TextStyle(color: Colors.green),
                        )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fechaTime.toString().substring(0, 16)),
                  Text(
                    'Pago ${widget.data[index]["tipoDePago"]['tipo'] ?? ''}',
                    style: TextStyle(
                        fontSize: 11,
                        color: widget.data[index]["tipoDePago"]['tipo'] ==
                                'En efectivo'
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
