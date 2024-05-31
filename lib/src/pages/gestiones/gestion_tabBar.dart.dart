// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/gestiones/gestio.producto.dart';
import 'package:gowin/src/pages/gestiones/gestion.Estadistisca.dart';
import 'package:gowin/src/pages/gestiones/gestion_propiedad.dart';
import 'package:gowin/src/pages/views_pages/tabBarPedidosAdminView.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class Tabar extends StatefulWidget {
  var propiedad;

  Tabar({Key? key, @required this.propiedad}) : super(key: key);
  @override
  _TabarState createState() => _TabarState();
}

class _TabarState extends State<Tabar> {
  @override
  void initState() {
    super.initState();
    getProducto();
  }

  Future editarEstado(estado) async {
    String url =
        "${Constant.shared.urlApi}/prop/?id=${widget.propiedad['_id']}";
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'estado': estado,
    });
    if (res.statusCode == 200) {
      widget.propiedad['estado'] = estado;
      Navigator.pop(context);
      if (estado != 'eliminado') {
        Navigator.pop(context);
      }
      //print(res.body);
    } else {
      var mensaje = json.decode(res.body)['msn'];
      ToastNotification.toastNotificationError(mensaje, context);
    }
  }

  Future editarEntrega(estado) async {
    // log();
    String url =
        "${Constant.shared.urlApi}/prop/?id=${widget.propiedad['_id']}";
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'entregas': estado,
    });
    if (res.statusCode == 200) {
      setState(() {
        widget.propiedad['entregas'] = estado;
      });
      Navigator.pop(context);
    } else {
      var mensaje = json.decode(res.body)['msn'];
      ToastNotification.toastNotificationError(mensaje, context);
    }
  }

  final pageViewController = PageController(initialPage: 0);
  var productos;
  Future<String> getProducto() async {
    String url =
        "${Constant.shared.urlApi + "/produc?id_p=" + widget.propiedad['_id']}&order=numLikes,-1";
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      'token': Constant.shared.token
    });
    if (this.mounted) {
      setState(() {
        productos = json.decode(response.body) /*['propiedad']*/;
        //print(producto);
      });
    }
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(widget.propiedad['nombre']),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TabBarPedidosAdmView(propiedad: widget.propiedad)));
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt_sharp,
                  color: Colors.black87,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Pedidos',
                  style: TextStyle(color: Colors.black87, fontSize: 10),
                ),
              ],
            ),
          ),
          const VerticalDivider(
            width: 2,
          ),
          TextButton(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Colors.black87,
                ),
                SizedBox(width: 8.0),
                Text(
                  'opciones',
                  style: TextStyle(color: Colors.black87, fontSize: 10),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                menuGestionPropiedad();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _bartab(),
        ],
      ),
    );
  }

  Widget _bartab() {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            height: 120,
            color: const Color.fromARGB(255, 255, 255, 255),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  TabBar(indicatorColor: Colors.black, tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_rounded,
                            color: Color.fromARGB(255, 45, 45, 45),
                            size: 12,
                          ),
                          Text(
                            "Productos",
                            style: GoogleFonts.aBeeZee(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: const Color.fromARGB(255, 35, 35, 35)),
                          )
                        ],
                      ),
                    ),
                    // Tab(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       const Icon(
                    //         Icons.list_alt_sharp,
                    //         color: Color.fromARGB(255, 45, 45, 45),
                    //         size: 12,
                    //       ),
                    //       Text(
                    //         "Pedidos",
                    //         style: GoogleFonts.aBeeZee(
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 11,
                    //             color: const Color.fromARGB(255, 35, 35, 35)),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.settings,
                            color: Color.fromARGB(255, 45, 45, 45),
                            size: 12,
                          ),
                          Text(
                            "Administar",
                            style: GoogleFonts.aBeeZee(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: const Color.fromARGB(255, 35, 35, 35)),
                          )
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.insert_chart_outlined_outlined,
                            color: Color.fromARGB(255, 45, 45, 45),
                            size: 12,
                          ),
                          Text(
                            "Estadísticas",
                            style: GoogleFonts.aBeeZee(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: const Color.fromARGB(255, 35, 35, 35)),
                          )
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            GesProducto(productos: productos),
            GestioProp(propiedad: widget.propiedad),

            // PedidosAdminView(propiedad: widget.propiedad),
            EstadisticasGestion(productos: productos)
          ],
        ),
      ),
    );
  }

  void menuGestionPropiedad() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return menuEliminar();
      },
    );
  }

  var habilitText = 'Habilitar';
  var aux = 'habilitado';
  var suspText = '';
  var aux2 = '';
  Widget menuEliminar() {
    String nomPropierdad = widget.propiedad['nombre'];
    final _size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            trailing: Switch(
              value:
                  widget.propiedad['entregas'] == 'habilitado' ? true : false,
              onChanged: (bool value) {},
            ),
            onTap: () {
              setState(() {
                if (widget.propiedad['entregas'] == 'habilitado') {
                  habilitText = 'Deshabilitar';
                  aux = 'deshabilitado';
                } else {
                  habilitText = 'Habilitar';
                  aux = 'habilitado';
                }
              });
              _ventanaEntregas('$habilitText entregas de ', aux, nomPropierdad);
            },
            leading: const Icon(Icons.pause_circle_outline),
            title: widget.propiedad['entregas'] == 'habilitado'
                ? Text('Deshabilitar entregas de $nomPropierdad')
                : Text('Habilitar entregas de $nomPropierdad'),
            subtitle: Text(widget.propiedad['entregas'] == 'habilitado'
                ? 'Estado de Entregas Habilitado '
                : 'Al habilitar esta opcion todos los productos de esta tienda estaran habilitadas para pedidos'),
          ),
          const Divider(
            height: 1,
          ),
          ListTile(
            trailing: Switch(
              value: widget.propiedad['estado'] == 'vigente' ? true : false,
              onChanged: (bool value) {},
            ),
            onTap: () {
              log('entra');
              setState(() {
                if (widget.propiedad['estado'] == 'suspendido') {
                  suspText = 'Habilitar';
                  aux2 = 'vigente';
                } else {
                  suspText = 'Suspender';
                  aux2 = 'suspendido';
                }
              });
              _ventana('$suspText', aux2, nomPropierdad);
            },
            leading: const Icon(Icons.remove_shopping_cart_outlined),
            title: widget.propiedad['estado'] == 'suspendido'
                ? Text('Habilitar $nomPropierdad')
                : Text('Suspender $nomPropierdad'),
            subtitle: Text(widget.propiedad['estado'] == 'suspendido'
                ? ''
                : 'Cuando $nomPropierdad este en estado de suspension, los productos y este no estarn visibles para todos los usuarios'),
          ),
          const Divider(
            height: 1,
          ),
          ListTile(
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              _ventana('eliminara', 'eliminado', nomPropierdad);
            },
            leading: const Icon(Icons.delete_outline_outlined),
            title: Text('Eliminar $nomPropierdad'),
            subtitle: const Text(
                'Eliminaras toda la propiedad incluido sus productos, ya no podra recuperarlo'),
          ),
        ],
      ),
    );
  }

  // Widget menuEliminar() {
  //   String nomPropierdad = widget.propiedad['nombre'];
  //   final _size = MediaQuery.of(context).size;
  //   return AnimatedPositioned(
  //       duration: Duration(milliseconds: 250),
  //       width: _size.width,
  //       height: _size.height * 0.50,
  //       top: position ? _size.height * 0.5 : _size.height * 1,
  //       child: ClipRect(
  //         child: BackdropFilter(
  //           filter: new ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               //color: Color.fromARGB(97, 9, 15, 19),
  //               borderRadius: BorderRadius.circular(20),
  //               color: Color.fromARGB(255, 245, 245, 245).withOpacity(0.7),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     IconButton(
  //                         onPressed: () {
  //                           setState(() {
  //                             position = !position;
  //                           });
  //                         },
  //                         icon: Icon(
  //                           Icons.close,
  //                           size: 30,
  //                         )),
  //                   ],
  //                 ),
  //                 Divider(
  //                   height: 0.8,
  //                 ),
  //                 SizedBox(
  //                   height: 20,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
  //                   child: InkWell(
  //                     onTap: () {
  //                       _alertDialog('eliminara', 'eliminado');
  //                     },
  //                     child: ListTile(
  //                       leading: Icon(Icons.delete_outline_outlined),
  //                       title: Text('Eliminar $nomPropierdad'),
  //                       subtitle: Text(
  //                           'Eliminaras toda la propiedad incluido sus productos, ya no podra recuperarlo'),
  //                     ),
  //                   ),
  //                 ),
  //                 Divider(
  //                   height: 1,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
  //                   child: InkWell(
  //                     onTap: () {
  //                       _alertDialog('suspendera', 'suspendido');
  //                     },
  //                     child: ListTile(
  //                       leading: Icon(Icons.pause_circle_outline),
  //                       title: Text('suspender $nomPropierdad'),
  //                       subtitle: Text(
  //                           'cuando $nomPropierdad este en suspencion no sera visible para otras personas'),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ));
  // }

  // void _alertDialog(mensaje, estado) {
  //   String nomPropierdad = widget.propiedad['nombre'];
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           actionsAlignment: MainAxisAlignment.center,
  //           actionsOverflowAlignment: OverflowBarAlignment.center,
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text("$mensaje $nomPropierdad"),
  //               SizedBox(
  //                 height: 20,
  //               ),
  //               Text('¿esta seguro?')
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text("Cancelar")),
  //             TextButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     editarEstado(estado);
  //                   });
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text("Aceptar"))
  //           ],
  //         );
  //       });
  // }

  _ventana(mensaje, estado, nombre) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      borderSide: const BorderSide(color: Colors.yellow, width: 0.5),
      width: 400,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(5)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: '$mensaje $nombre',
      desc: 'Esta seguro?',
      showCloseIcon: true,
      btnOkText: 'Continuar',
      btnOkOnPress: () {
        editarEstado(estado);
      },
    )..show();
  }

  _ventanaEntregas(mensaje, estado, nombre) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      borderSide: const BorderSide(color: Colors.yellow, width: 0.5),
      width: 400,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(5)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: '$mensaje $nombre',
      desc: 'Esta seguro?',
      showCloseIcon: true,
      btnOkText: 'Continuar',
      btnOkOnPress: () {
        editarEntrega(estado);
      },
    )..show();
  }
}
