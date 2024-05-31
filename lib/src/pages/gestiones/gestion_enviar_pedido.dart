import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/iconcaba_icons.dart';
import 'package:gowin/src/pages/views_pages/pedido_view.antes%20de%20enviar.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class GestionPedido extends StatefulWidget {
  // final String id_dest;
  // final String nombre_dest;

  final propiedad;

  final producto;

  GestionPedido({Key? key, @required this.propiedad, this.producto})
      : super(key: key);

  @override
  _GestionPedidoState createState() => _GestionPedidoState();
}

class _GestionPedidoState extends State<GestionPedido> {
  String tOTAL = "";
  var vec = [];
  List<int> cantidades = [];
  Object num = 1;
  var unos = [];
  var pagoTipo = 'efectivo';
  // Future<String> getJSONData() async {
  //   var url = Constant.shared.urlApi +
  //       "/produc/id/?id=" +
  //       Constant.shared.id_produc_ped;
  //   var response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (this.mounted) {
  //     setState(() {
  //       data = json.decode(response.body);
  //       _llenarvec(data![0]['precio']);
  //       _tOTAL(data);
  //     });
  //   }
  //   return "Successfull";
  // }

  // void llenarDatosProductos() {
  //   // listaProductos = widget.listproduc;
  //   // print(listaProductos.length);
  //   if (this.mounted) {
  //     setState(() {
  //       data.add(widget.producto);
  //       _llenarvec(data[0]['precio']);
  //       _tOTAL(data);
  //     });
  //   }
  // }
  @override
  void initState() {
    super.initState();
    //llenarDatosProductos();
    // data!.add(widget.producto);
    //this.getJSONData();
    // log(widget.propiedad['location']['coordinates'][0].toString());
    getProductos();
  }

  List? data;
  List? listaProductos;
  var precioUni = '';
  Future<String> getProductos() async {
    var url =
        Constant.shared.urlApi + "/produc?id_p=" + widget.propiedad['_id'];
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      'token': Constant.shared.token
    });
    if (response.statusCode == 200) {
      listaProductos = json.decode(response.body);
      data = listaProductos!
          .where((product) => product['_id'] == widget.producto['_id'])
          .toList();
      if (this.mounted) {
        setState(() {
          precioUni = data![0]['precio'];
          listaProductos!
              .removeWhere((item) => item['_id'] == widget.producto['_id']);
          _llenarvec(data![0]['precio']);
          _tOTAL(data);
        });
      }
    }
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 16.0,
                      ),
                      _buildListView(),
                    ],
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.70,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(-4, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "TOTAL",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.karla(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '$tOTAL Bs',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.fjallaOne(
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 3,
                        ),
                        _botonesGestion(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _botonesGestion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        height: 55,
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: BoxDecoration(
          color: const Color.fromARGB(215, 191, 191, 191),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(-3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextButton.icon(
                onPressed: () {
                  _showModalBottomSheet();
                },
                icon: const Icon(Icons.add_shopping_cart_sharp),
                label: const Text("Mas productos"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade300,
                  side: BorderSide(color: Colors.green.shade900, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextButton.icon(
                onPressed: () {
                  _llenarCant(data);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PedidoView(
                              long: widget.propiedad['location']['coordinates']
                                  [0],
                              lat: widget.propiedad['location']['coordinates']
                                  [1],
                              datos: data,
                              prein: vec,
                              cant: cantidades,
                              total: tOTAL,
                              id_dest: widget.producto['id_user'],
                              id_tienda: widget.propiedad['_id'],
                              nombre_dest: widget.propiedad['nombre'])));
                },
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text("Siguiente"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade300,
                  side: BorderSide(color: Colors.green.shade900, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return StaggeredGridView.countBuilder(
        staggeredTileBuilder: (index) => const StaggeredTile.count(4, 1.6),
        shrinkWrap: true,
        crossAxisCount: 4,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        padding: const EdgeInsets.all(10.0),
        itemCount: data == null ? 0 : data!.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(color: Colors.green[50]),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.fromLTRB(2, 0, 10, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _imagen(data![index]),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data![index]['nombre'],
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.karla(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Unidad/${precioUni} Bs.',
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.karla(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _scoped(index),
                              Text(
                                data![index]['precio'],
                                textAlign: TextAlign.start,
                                style: GoogleFonts.fjallaOne(
                                  color: Colors.green,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: index > 0 ? true : false,
                child: Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            data![index]['precio'] = vec[index];
                            listaProductos!.add(data![index]);
                            _quitarvec(vec[index]);
                            data!.remove(data![index]);
                            _tOTAL(data);
                          });
                        },
                        icon: Icon(
                          Iconcaba.delete_forever,
                          size: 30,
                          color: Colors.red.shade600,
                        ))),
              ),
            ],
          );
        });
  }

  Widget _scoped(index) {
    return Container(
      color: const Color.fromARGB(30, 255, 255, 255),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove,
                color: Color.fromARGB(255, 220, 86, 76)),
            onPressed: () {
              setState(() {
                if (unos[index] > 1) {
                  unos[index]--;
                }
                data![index]['precio'] =
                    (double.parse(vec[index]) * unos[index]).toStringAsFixed(1);
                _tOTAL(data);
              });
            },
          ),
          Text(
            unos[index].toString(),
            style: Theme.of(context).textTheme.headline4,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  if (unos[index] < 20) {
                    unos[index]++;
                  }
                  data![index]['precio'] =
                      (double.parse(vec[index]) * unos[index])
                          .toStringAsFixed(1);
                  _tOTAL(data);
                });
              },
              icon: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 54, 140, 211),
              )),
        ],
      ),
    );
  }

  Widget _imagen(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Stack(children: <Widget>[
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.12,
            backgroundImage: item['img_produc'].length == 0
                ? const Icon(Icons.error) as ImageProvider
                : NetworkImage(item['img_produc'][0]['Url']),
          ),
        ]),
      ),
    );
  }

  void _showModalBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _bottomSheetContent();
      },
    );
  }

  Widget _bottomSheetContent() {
    return SizedBox(
      height: 450,
      child: Column(
        children: [
          const SizedBox(
            height: 70,
            child: Center(
              child: Text(
                "Mas productos de la tienda",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: listaProductos!.length > 0
                ? ListView.builder(
                    itemCount: listaProductos!.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        setState(() {
                          data!.add(listaProductos![index]);
                          _llenarvec(listaProductos![index]['precio']);
                          listaProductos!.remove(listaProductos![index]);
                          _tOTAL(data);

                          Navigator.pop(context);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 5, 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              listaProductos![index]["img_produc"][0]["Url"],
                              width: 110,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listaProductos![index]["precio"],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.fjallaOne(
                                        fontSize: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      listaProductos![index]["nombre"],
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.karla(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Text(
                    ':)',
                    style: TextStyle(fontSize: 24),
                  ),
          ),
        ],
      ),
    );
  }

  void _llenarvec(dynamic data) {
    vec.add(data);
    unos.add(1);
  }

  void _quitarvec(dynamic data) {
    vec.remove(data);
  }

  void _tOTAL(dynamic data) {
    double result = 0;
    for (int i = 0; i < data.length; i++) {
      result = result + double.parse(data[i]['precio']);
    }
    tOTAL = result.toStringAsFixed(1);
  }

  void _llenarCant(data) {
    cantidades = [];
    for (var i = 0; i < data.length; i++) {
      int auxi = double.parse(data[i]['precio']) ~/ double.parse(vec[i]);
      cantidades.add(auxi);
    }
  }
}
