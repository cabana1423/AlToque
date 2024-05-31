import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/gestiones/editar.Product.dart';
import 'package:gowin/src/pages/registers/reg.producto.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
//import 'package:fluttertoast/fluttertoast.dart';

class GesProducto extends StatefulWidget {
  var productos;

  GesProducto({Key? key, @required this.productos}) : super(key: key);

  @override
  _GesProductoState createState() => _GesProductoState();
}

class _GesProductoState extends State<GesProducto> {
  void actualizar(data) {
    widget.productos = data;
  }

  List data = [];
  @override
  void initState() {
    super.initState();
    // setState(() {
    //   data = widget.productos;
    // });
    refhesListProductos();
  }

  Future actualizarEstado(aux, val, item, index) async {
    String url = "${Constant.shared.urlApi}/produc/?id=" + item['_id'];
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
    });
    if (res.statusCode == 200) {
      setState(() {
        Future actualizarEstado(aux, val, item, index) async {
          String url = "${Constant.shared.urlApi}/produc/?id=" + item['_id'];
          var res = await http.put(Uri.parse(url), headers: <String, String>{
            'Context-Type': 'application/json;charSet=UTF-8'
          }, body: <String, String>{
            '$aux': val,
          });
          if (res.statusCode == 200) {
            setState(() {
              data[index]['estado'] = val;
            });
          } else
            print(res.statusCode);
        }
      });
      data[index]['estado'] = val;
    } else
      print(res.statusCode);
  }

  var estado;
  Future<String> refhesListProductos() async {
    String url =
        "${Constant.shared.urlApi}/produc?id_p=${Constant.shared.id_prop}";
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      'token': Constant.shared.token
    });
    if (this.mounted) {
      setState(() {
        data = json.decode(response.body) /*['propiedad']*/;
        widget.productos = data;
      });
    }
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegProduc()))
                .then((value) => setState(() {
                      refhesListProductos();
                    }));
          }),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return StaggeredGridView.countBuilder(
        staggeredTileBuilder: (index) => const StaggeredTile.count(2, 2),
        crossAxisCount: 4,
        mainAxisSpacing: 1,
        crossAxisSpacing: 2,
        padding: const EdgeInsets.all(12.0),
        itemCount: data.isEmpty ? 0 : data.length,
        itemBuilder: (context, index) {
          return cardView(data[index], index);
        });
  }

  Widget cardView(dynamic item, int index) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: item['img_produc'][0]['Url'],
          imageBuilder: (context, imageProvider) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 8),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color(0x64000000),
                    offset: Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fadeOutDuration: const Duration(seconds: 1),
          fadeInDuration: const Duration(seconds: 3),
        ),
        Align(
          alignment: Alignment.center,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 180, 180, 180)
                        .withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_square),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PageEditProduc(producto: item)))
                        .then((value) => refhesListProductos());
                  },
                  iconSize: 38,
                  color: const Color.fromARGB(255, 221, 221, 221),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                width: 180,
                height: 50,
                decoration: BoxDecoration(
                  //color: Color.fromARGB(97, 9, 15, 19),
                  color:
                      const Color.fromARGB(255, 152, 152, 152).withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          item['nombre'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.aBeeZee(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 250, 250, 250)),
                        ),
                      ),
                      Text(
                        "${item['precio']} Bs",
                        style: GoogleFonts.abel(
                            fontSize: 18,
                            color: const Color.fromARGB(
                              255,
                              196,
                              249,
                              215,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(224, 254, 79, 79),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                      Text(
                        item['numLikes'].toString(),
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 126, 126, 126)
                        .withOpacity(0.6),
                  ),
                  child: Text(
                    item['estado'] == 'vigente' ? 'Disponible' : 'Agotado',
                    style: TextStyle(
                        color: item['estado'] == 'vigente'
                            ? const Color.fromARGB(255, 150, 255, 140)
                            : const Color.fromARGB(255, 255, 190, 92),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )),
        Positioned(
            top: 1, right: 15, child: _myPopMenu(item, item['nombre'], index)),
        Align(
          alignment: Alignment.center,
          child: Visibility(
              visible: item['estado'] == 'suspendido' ? true : false,
              child: Text(
                '(Suspendido)',
                style: GoogleFonts.aBeeZee(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color.fromARGB(255, 236, 236, 236)),
              )),
        )
      ],
    );
  }

  Widget _myPopMenu(item, String nombre, int index) {
    return PopupMenuButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: Icon(
            Icons.more_horiz,
            color: Color.fromARGB(255, 24, 24, 24),
            size: 30,
          ),
        ),
        //   Fluttertoast.showToast(
        //       msg: "You have selected " + value.toString(),
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.black,
        //       textColor: Colors.white,
        //       fontSize: 16.0);
        onSelected: (value) {
          if (value == 1) {
            if (item['estado'] == 'vigente') {
              actualizarEstado('estado', 'agotado', item, index);
            } else {
              actualizarEstado('estado', 'vigente', item, index);
            }
          }
          if (value == 2) {
            _alertDialog(item['_id'], nombre);
          }
        },
        itemBuilder: (context) => [
              item['estado'] == 'vigente'
                  ? const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(
                              Icons.close,
                              color: Color.fromARGB(255, 255, 75, 62),
                            ),
                          ),
                          Text('Marcar como agotado')
                        ],
                      ))
                  : const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                          Text('Marcar como disponible')
                        ],
                      )),
              const PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                        child: Icon(Icons.delete),
                      ),
                      Text('Eliminar')
                    ],
                  )),
            ]);
  }

  void _alertDialog(idPr, String nombre) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Esta seguro que desea eliminar: $nombre"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _deleteProduc(idPr);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Si"))
            ],
          );
        });
  }

  Future _deleteProduc(idPrd) async {
    String url = "${Constant.shared.urlApi}/produc/?id=" + idPrd;
    var res = await http.delete(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    });
    if (res.statusCode == 200) {
      setState(() {
        data.removeWhere((item) => item['_id'] == idPrd);
      });
      print(res.body);
    } else
      print(res.statusCode);
  }

  Widget _buildRow(dynamic item) {
    return ListTile(
      title: Text(item['nombre'] == null ? '' : item['nombre']),
    );
  }
}
