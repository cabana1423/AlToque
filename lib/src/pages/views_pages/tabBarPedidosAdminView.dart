import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/views_pages/PedidosAdminCuentasView.dart';
import 'package:gowin/src/pages/views_pages/PedidosAdminView.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class TabBarPedidosAdmView extends StatefulWidget {
  var propiedad;

  TabBarPedidosAdmView({super.key, required this.propiedad});

  @override
  State<TabBarPedidosAdmView> createState() => _TabBarPedidosAdmViewState();
}

class _TabBarPedidosAdmViewState extends State<TabBarPedidosAdmView> {
  // @override
  // void initState() {
  //   super.initState();
  //   datoscont();
  // }

  // List datos = [];
  // Future datoscont() async {
  //   var url =
  //       "${Constant.shared.urlApi}/cont/ordenarFecha?idProp=${widget.propiedad['_id']}";
  //   var response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (response.statusCode == 200) {
  //     if (mounted) {
  //       setState(() {
  //         datos = json.decode(response.body);
  //         build(context);
  //       });
  //       // log(datos.length.toString());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(alignment: Alignment.center, child: cuerpo()),
    );
  }

  Widget cuerpo() {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
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
                            Icons.list_alt_sharp,
                            color: Color.fromARGB(255, 45, 45, 45),
                            size: 12,
                          ),
                          Text(
                            "Pedidos",
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
                            Icons.inventory_rounded,
                            color: Color.fromARGB(255, 45, 45, 45),
                            size: 12,
                          ),
                          Text(
                            "Cuentas",
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
            // PedidosAdminView(cuentas: datos),
            PedidosAdminView(
              propiedad: widget.propiedad,
            ),
            PedidosAdminCuentasView(propiedad: widget.propiedad)
          ],
        ),
      ),
    );
  }
}
