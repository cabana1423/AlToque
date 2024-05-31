// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class EstadisticasGestion extends StatefulWidget {
  var productos;

  EstadisticasGestion({Key? key, @required this.productos}) : super(key: key);

  @override
  State<EstadisticasGestion> createState() => EstadisticasGestionState();
}

class EstadisticasGestionState extends State<EstadisticasGestion> {
  // final pageViewController =
  //     PageController(initialPage: 0, viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    setState(() {
      armarTabla(widget.productos);
    });
  }

  var suma = 0;
  List<Map<String, dynamic>> data = [];
  void armarTabla(productos) {
    for (var i = 0; i < productos.length; i++) {
      var aux = {
        'name': productos[i]['nombre'] ?? '',
        'value': productos[i]['numVentas'] ?? 0
      };
      suma = suma + int.parse(productos[i]['numVentas'].toString());
      data.add(aux);
    }

    log(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    //final _size = MediaQuery.of(context).size;
    return Scaffold(
      body: pageView(),
    );
  }

  Widget pageView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: suma == 0
          ? const Center(child: Text('no existe ninguna venta'))
          : ListView(
              scrollDirection: Axis.vertical,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                      height: 30,
                      child: const Text(
                        'Grafica  de productos con mas ventas',
                        textAlign: TextAlign.center,
                      )),
                ),
                graficoDeBarra(),
                Visibility(
                  visible: data.length > 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Container(
                        height: 40,
                        child: const Text(
                          'Grafico de rosa de productos con mas ventas',
                          textAlign: TextAlign.center,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                data.length <= 1
                    ? const Center(
                        child: Text(
                            'datos insuficientes para realizar grafico de rosa'),
                      )
                    : graficoCircular()
              ],
            ),
    );
  }

  Widget graficoCircular() {
    return Container(
      color: const Color.fromARGB(31, 180, 180, 180),
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 1,
      child: Container(
        height: 500,
        child: Chart(
          data: data,
          variables: {
            'name': Variable(
              accessor: (Map map) => map['name'] as String,
            ),
            'value': Variable(
              accessor: (Map map) => map['value'] as num,
              scale: LinearScale(min: 0, marginMax: 0.1),
            ),
          },
          marks: [
            IntervalMark(
              label: LabelEncode(
                  encoder: (tuple) => Label(tuple['name'].toString())),
              shape: ShapeEncode(
                  value: RectShape(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              )),
              color: ColorEncode(variable: 'name', values: Defaults.colors10),
              elevation: ElevationEncode(value: 5),
            )
          ],
          coord: PolarCoord(startRadius: 0.15),
        ),
      ),
    );
  }

  Widget graficoDeBarra() {
    return Container(
      color: Color.fromARGB(31, 180, 180, 180),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 1,
      child: Container(
        height: 500,
        child: Chart(
          data: data,
          variables: {
            'genre': Variable(
              accessor: (Map map) => map['name'] as String,
            ),
            'sold': Variable(
              accessor: (Map map) => map['value'] as num,
            ),
          },
          marks: [
            IntervalMark(
              size: SizeEncode(value: 18),
              label: LabelEncode(
                  encoder: (tuple) => Label(
                      tuple['sold'].toString(),
                      LabelStyle(
                          maxWidth: 20,
                          maxLines: 2,
                          textStyle: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold)))),
              gradient: GradientEncode(
                  value: const LinearGradient(colors: [
                    Color(0x8883bff6),
                    Color(0x88188df0),
                    Color(0xcc188df0),
                  ], stops: [
                    0,
                    0.5,
                    1
                  ]),
                  updaters: {
                    'tap': {
                      true: (_) => const LinearGradient(colors: [
                            Color.fromARGB(237, 131, 246, 246),
                            Color.fromARGB(237, 63, 195, 247),
                            Color.fromARGB(255, 25, 92, 238),
                          ], stops: [
                            0,
                            0.7,
                            1
                          ])
                    }
                  }),
            )
          ],
          coord: RectCoord(transposed: true),
          axes: [
            Defaults.verticalAxis
              ..line = Defaults.strokeStyle
              ..grid = null,
            Defaults.horizontalAxis
              ..line = null
              ..grid = Defaults.strokeStyle,
          ],
          selections: {'tap': PointSelection(dim: Dim.x)},
        ),
      ),
    );
  }
}
