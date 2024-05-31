import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class Buscar extends StatefulWidget {
  var enlace;

  var prod;

  Buscar({Key? key, required this.enlace, required this.prod})
      : super(key: key);

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  //    ESTILOS_TEXTO
  var estilo = GoogleFonts.oswald();

  int _selectedIndex = 0;
  final textController = TextEditingController();
  bool activityText = false;
  bool filtro = false;
  var stiloText = TextStyle(fontSize: 10);

  List? inicio;
  List? auxiliar;
  Future<String> datosProductos() async {
    var url = Constant.shared.urlApi + "/produc";
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      'token': Constant.shared.token
    });
    if (this.mounted) {
      setState(() {
        inicio = json.decode(response.body) /*['propiedad']*/;
        auxiliar = inicio;
      });
    }
    return "Successfull";
  }

  @override
  void initState() {
    this.datosProductos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [buscar(), Expanded(child: buildListView(inicio))],
              ),
            ),
            VerticalDivider(thickness: 1, width: 0.5),
            Container(
              width: 80,
              child: LayoutBuilder(builder: (context, constraint) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraint.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        minExtendedWidth: 65,
                        selectedIndex: _selectedIndex,
                        groupAlignment: -1.0,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                            switch (index) {
                              case 0:
                                auxiliar = inicio;
                                break;
                              case 1:
                                cambioFiltro('comida');
                                break;
                              case 2:
                                cambioFiltro('postres');
                                break;
                              // case 3:
                              //   cambioFiltro('vehiculos');
                              //   break;
                              case 3:
                                cambioFiltro('Herramientas');
                                break;
                              // case 5:
                              //   cambioFiltro('muebles');
                              //   break;
                              // case 6:
                              //   cambioFiltro('electronica');
                              //   break;
                              // case 7:
                              //   cambioFiltro('deporte');
                              //   break;
                              // case 8:
                              //   cambioFiltro('inmueble');
                              //   break;
                              // case 9:
                              //   cambioFiltro('musica');
                              //   break;
                              case 4:
                                cambioFiltro('salud');
                                break;
                              // case 11:
                              //   cambioFiltro('servicios');
                              //   break;
                              // case 12:
                              //   cambioFiltro('arte');
                              //   break;
                              case 5:
                                cambioFiltro('supermercado');
                                break;
                              case 6:
                                cambioFiltro('otros');
                                break;
                              default:
                                return;
                            }
                          });
                        },
                        labelType: NavigationRailLabelType.all,
                        destinations: <NavigationRailDestination>[
                          NavigationRailDestination(
                            icon: Icon(Icons.apps),
                            selectedIcon: Icon(Icons.apps),
                            label: FittedBox(
                                child: Text(
                              'Todo',
                              style: estilo,
                            )),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.fastfood_outlined),
                            selectedIcon: Icon(Icons.fastfood),
                            label: FittedBox(
                                child: Text(
                              'Comida',
                              style: estilo,
                            )),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.icecream_outlined),
                            selectedIcon: Icon(Icons.icecream_sharp),
                            label: FittedBox(
                              child: Text(
                                'Postres y dulces',
                                style: estilo,
                              ),
                            ),
                          ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.directions_car_filled_outlined),
                          //   selectedIcon: Icon(Icons.directions_car),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'vehículos',
                          //     style: estilo,
                          //   )),
                          // ),
                          NavigationRailDestination(
                            icon: Icon(Icons.hardware_outlined),
                            selectedIcon: Icon(Icons.hardware),
                            label: FittedBox(
                                child: Text(
                              'Herramientas',
                              style: estilo,
                            )),
                          ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.chair_outlined),
                          //   selectedIcon: Icon(Icons.chair),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'muebles',
                          //     style: estilo,
                          //   )),
                          // ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.devices_other_sharp),
                          //   selectedIcon: Icon(Icons.devices_other_sharp),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'electrónica',
                          //     style: estilo,
                          //   )),
                          // ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.sports_tennis_sharp),
                          //   selectedIcon: Icon(Icons.sports_tennis_outlined),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'deporte',
                          //     style: estilo,
                          //   )),
                          // ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.maps_home_work_outlined),
                          //   selectedIcon: Icon(Icons.maps_home_work),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'inmuebles',
                          //     style: estilo,
                          //   )),
                          // ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.library_music_outlined),
                          //   selectedIcon: Icon(Icons.library_music),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'música',
                          //     style: estilo,
                          //   )),
                          // ),
                          NavigationRailDestination(
                            icon: Icon(Icons.medical_information_outlined),
                            selectedIcon: Icon(Icons.medical_information),
                            label: FittedBox(
                                child: Text(
                              'salud',
                              style: estilo,
                            )),
                          ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.handshake_rounded),
                          //   selectedIcon: Icon(Icons.handshake_rounded),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'servicios',
                          //     style: estilo,
                          //   )),
                          // ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.color_lens_outlined),
                          //   selectedIcon: Icon(Icons.color_lens),
                          //   label: FittedBox(
                          //       child: Text(
                          //     'arte',
                          //     style: estilo,
                          //   )),
                          // ),
                          NavigationRailDestination(
                            icon: Icon(Icons.local_grocery_store_outlined),
                            selectedIcon: Icon(Icons.local_grocery_store),
                            label: FittedBox(
                                child: Text(
                              'Supermercado',
                              style: estilo,
                            )),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.pending_outlined),
                            selectedIcon: Icon(Icons.pending),
                            label: FittedBox(
                                child: Text(
                              'otros',
                              style: estilo,
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void cambioFiltro(valor) {
    auxiliar =
        (inicio!.where((producto) => producto['categoria'] == valor)).toList();
  }

  Widget buscar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 2),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.search,
        onSubmitted: filtro == true
            ? (value) {
                // mostrarProp_por_dist(value);
              }
            : null,
        onChanged: (value) {
          // filtro == false ? _runFilter(value) : null;
          if (value.length > 0) {
            _runFilter(value);
            setState(() {
              activityText = true;
            });
          } else {
            setState(() {
              activityText = false;
              auxiliar = inicio;
              //datanew = data!;
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'buscar',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 206, 206, 206),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 216, 216, 216),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF95A1AC),
          ),
          suffixIcon: activityText == true
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      textController.clear();
                      activityText = false;
                      auxiliar = inicio;
                      //datanew = data!;
                    });
                  },
                  icon: Icon(Icons.close),
                  color: Color.fromARGB(255, 178, 178, 178),
                )
              : null,
        ),
      ),
    );
  }

  Widget buildListView(datosList) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: RefreshIndicator(
        onRefresh: () => datosProductos(),
        child: StaggeredGridView.countBuilder(
            staggeredTileBuilder: (index) => StaggeredTile.count(2, 3),
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 5,
            padding: const EdgeInsets.all(10.0),
            itemCount: auxiliar == null ? 0 : auxiliar!.length,
            itemBuilder: (context, index) {
              return cardRecientes(auxiliar![index]);
            }),
      ),
    );
  }

  Widget cardRecientes(dynamic item) {
    return Container(
      width: 180,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color.fromARGB(255, 125, 125, 125),
          width: .5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Color(0x64000000),
            offset: Offset(0, 2),
          )
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => ProductoView(
                                producto: item,
                              ))).then((value) => setState(() {
                        datosProductos();
                        //FocusScope.of(context).unfocus();
                      }));
                },
                child: CachedNetworkImage(
                  imageUrl: item['img_produc'][0]['Url'],
                  imageBuilder: (context, imageProvider) => Container(
                    width: 180,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: imageProvider),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(15),
                      ),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 150,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          item['nombre'],
                          style: GoogleFonts.oswald(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        item['precio'] + ' Bs',
                        style: GoogleFonts.anton(),
                      ),
                      Flexible(
                          child: Text(
                        item['descripcion'],
                        style: GoogleFonts.raleway(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 70,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 248, 73, 111),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                      Text(
                        item['numLikes'].toString(),
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = auxiliar!;
    } else {
      results = auxiliar!
          .where((producto) => producto["nombre"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      auxiliar = results;
    });
  }
}
