import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/repartidores/ViewListaDia.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ViewCuentasRepartidorSemana extends StatefulWidget {
  const ViewCuentasRepartidorSemana({super.key});

  @override
  State<ViewCuentasRepartidorSemana> createState() =>
      _ViewCuentasRepartidorSemanaState();
}

class _ViewCuentasRepartidorSemanaState
    extends State<ViewCuentasRepartidorSemana> {
  @override
  void initState() {
    datoscont();
    super.initState();
  }

  List datos = [];
  Future datoscont() async {
    var url =
        "${Constant.shared.urlApi}/cont/ordFechaRepa?idRep=${Constant.shared.dataUser['_id']}";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          datos = json.decode(response.body);
          // log(datos.toString());
          build(context);
        });
        // log(datos.length.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: lista(),
      ),
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
                      DateTime fecha = DateTime.parse(
                          '${datos[index]['documentos'][0]["fecha_reg"]}');
                      String fechaFormateada =
                          DateFormat("dd/MM/yyyy HH:mm:ss", "es").format(fecha);
                      return cardCuentas(index, fechaFormateada);
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

  Widget cardCuentas(index, fecha) {
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
                  builder: (context) => CuentasRepartidorPorDias(
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
              Text('Total')
            ],
          ),
          subtitle: datos.isEmpty
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fecha,
                    ),
                    Text(
                      '${calcular(datos[index]['documentos'])} Bs',
                      style: TextStyle(
                          color: calcular(datos[index]['documentos'])
                                  .contains('-')
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
  log('largo $cantidad');
  double sumaTotal = 0.0;
  for (var i = 0; i < cantidad; i++) {
    var estdRep = '';
    var estdcuent = data[i]['estado'];
    if (data[i]['repartidor'] != null) {
      estdRep = data[i]['repartidor']['estado'] ?? '';
    }
    if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
        (estdcuent == 'entregado' && estdRep == 'entregado') ||
        (estdcuent == 'enviado' && estdRep == 'no entregada')) {
      sumaTotal =
          sumaTotal + double.parse(data[i]['repartidor']['cuenta'].toString());
      // log('AQUI ESTA ${data[i]['repartidor']['cuenta'].toString()}');
    }
  }

  return sumaTotal.toStringAsFixed(1);
}

class CuentasRepartidorPorDias extends StatefulWidget {
  List data;
  CuentasRepartidorPorDias({super.key, required this.data});

  @override
  State<CuentasRepartidorPorDias> createState() =>
      _CuentasRepartidorPorDiasState();
}

class _CuentasRepartidorPorDiasState extends State<CuentasRepartidorPorDias> {
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
                  builder: (context) => ViewDiaListaRepartidor(
                        datos: transformedList[index]['documentos'],
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
      var estdRep = '';
      var estdcuent = data[i]['estado'];
      if (data[i]['repartidor'] != null) {
        estdRep = data[i]['repartidor']['estado'] ?? '';
      }
      if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
          (estdcuent == 'entregado' && estdRep == 'entregado') ||
          (estdcuent == 'enviado' && estdRep == 'no entregada')) {
        sumaTotal = sumaTotal + double.parse(data[i]['repartidor']['cuenta']);
      }
    }

    return sumaTotal.toStringAsFixed(1);
  }

  String obtenerNombreDia(DateTime fecha) {
    final formatter = DateFormat('EEEE', 'es');
    return formatter.format(fecha);
  }
}
