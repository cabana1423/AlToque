import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/pages/views_pages/propiedadView.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

class SearchPropiedad extends StatefulWidget {
  var enlace;

  var prod;

  SearchPropiedad({Key? key, required this.enlace, required this.prod})
      : super(key: key);
  @override
  _SearchPropiedadState createState() => _SearchPropiedadState();
}

class _SearchPropiedadState extends State<SearchPropiedad> {
  @override
  void initState() {
    super.initState();
    print('aqui esta longi');

    print(Constant.shared.mylong);
    descargarPropiedad();
  }

  // void aguante() async {
  //   //await UserSecureStorages.delEmail();
  //   // final email = await UserSecureStorages.getEmail();
  //   // print(email);
  // }

  List dataDist = [];
  Future<String> mostrarPropPorDist(value) async {
    var url =
        "${Constant.shared.urlApi}/prop/dist?lat=${Constant.shared.mylat}&long=${Constant.shared.mylong}&pal=$value";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          dataDist = json.decode(response.body);
          // print(dataDist);
        });
      }
    }
    return "exito";
  }

  bool filtro = false;
  bool isChecked = false;

  List? data;
  Future<String> descargarPropiedad() async {
    var url = "${Constant.shared.urlApi}/prop?estado=vigente";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    if (mounted) {
      setState(() {
        data = json.decode(response.body) /*['propiedad']*/;
        datanew = data!;
      });
    }
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 35,
            ),
            buscar(),
            //search(),
            //filtro2(),
            filters(),
            Expanded(child: lista_propiedad()),
          ],
        ),
      ),
    );
  }

  final textController = TextEditingController();
  bool activityText = false;
  Widget buscar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.search,
        onSubmitted: filtro == true
            ? (value) {
                mostrarPropPorDist(value);
              }
            : null,
        onChanged: (value) {
          filtro == false ? _runFilter(value) : null;
          if (value.isNotEmpty) {
            setState(() {
              activityText = true;
            });
          } else {
            setState(() {
              activityText = false;
              datanew = data!;
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'buscar',
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 206, 206, 206),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 216, 216, 216),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF95A1AC),
          ),
          suffixIcon: activityText == true
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      textController.clear();
                      activityText = false;
                      datanew = data!;
                    });
                  },
                  icon: const Icon(Icons.close),
                  color: const Color.fromARGB(255, 178, 178, 178),
                )
              : null,
        ),
      ),
    );
  }

  // Widget search() {
  //   final _size = MediaQuery.of(context).size;
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(
  //           context,
  //           new MaterialPageRoute(
  //               builder: (context) => SearchP(
  //                     lista: data,
  //                   )));
  //     },
  //     child: Container(
  //       width: _size.width * 0.85,
  //       height: 50,
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(9),
  //           border: Border.all(
  //               color: Color.fromARGB(255, 207, 207, 207),
  //               width: 1,
  //               style: BorderStyle.solid)),
  //       child: Padding(
  //         padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.search_rounded,
  //               color: Color.fromARGB(255, 117, 117, 117),
  //             ),
  //             SizedBox(
  //               width: 8,
  //             ),
  //             Text('Buscar')
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget filters() {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.white,
          //fillColor: MaterialStateProperty.resolveWith(getColor),
          value: filtro,
          onChanged: (bool? value) {
            setState(() {
              filtro = value!;
            });
          },
        ),
        Text(
          'Filtrar por distancia',
          style: GoogleFonts.aBeeZee(fontSize: 18),
        ),
        const Icon(
          Icons.location_on,
          size: 18,
        ),
      ],
    );
  }

  Widget lista_propiedad() {
    return filtro == false
        ? datanew.length == 0
            ? const Center(child: Text('no hay resultados'))
            : RefreshIndicator(
                onRefresh: () => descargarPropiedad(),
                child: StaggeredGridView.countBuilder(
                    staggeredTileBuilder: (index) =>
                        const StaggeredTile.count(4, 1.5),
                    crossAxisCount: 4,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: datanew.isEmpty ? 0 : datanew.length,
                    itemBuilder: (context, index) {
                      //calculardis(datanew[index]);
                      return card(datanew[index]);
                    }),
              )
        : dataDist.length == 0
            ? Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: const Center(
                    child: Text(
                  'Realiza la busqueda de comercios mas cercanos a tu ubicación',
                  textAlign: TextAlign.center,
                )),
              )
            : StaggeredGridView.countBuilder(
                staggeredTileBuilder: (index) =>
                    const StaggeredTile.count(4, 1.5),
                crossAxisCount: 4,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                padding: const EdgeInsets.all(10.0),
                // ignore: unnecessary_null_comparison
                itemCount: dataDist == null ? 0 : dataDist.length,
                itemBuilder: (context, index) {
                  //calculardis(datanew[index]);
                  return card(dataDist[index]);
                });
  }

  // Future<double> calculardis(longitud, latitud) async {
  //   double distanceEnMetres = await distance2point(
  //     GeoPoint(
  //       longitude: Constant.shared.mylong,
  //       latitude: Constant.shared.mylat,
  //     ),
  //     GeoPoint(
  //       longitude: longitud,
  //       latitude: latitud,
  //     ),
  //   );
  //   print(distanceEnMetres);
  //   return distanceEnMetres;
  // }

  double calculoDist(long, lat) {
    int radiusEarth = 6371;
    double distanceKm;
    // double distanceMts;
    double dlat, dlng;
    double a;
    double c;
    var mylat = math.radians(Constant.shared.mylat);
    lat = math.radians(lat);
    var mylong = math.radians(Constant.shared.mylong);
    long = math.radians(long);
    // Fórmula del semiverseno
    dlat = lat - mylat;
    dlng = long - mylong;
    a = sin(dlat / 2) * sin(dlat / 2) +
        cos(mylat) * cos(lat) * (sin(dlng / 2)) * (sin(dlng / 2));
    c = 2 * atan2(sqrt(a), sqrt(1 - a));

    distanceKm = radiusEarth * c;
    //print('Distancia en Kilométros:$distanceKm');
    // distanceMts = 1000 * distanceKm;
    // print('Distancia en Metros:$distanceMts');
    return distanceKm;
    //return distanceMts;
  }

  // Widget newCard(dynamic item) {
  //   final _size = MediaQuery.of(context).size;
  //   return Padding(
  //     padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
  //     child: Container(
  //       width: MediaQuery.of(context).size.width * 0.96,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             blurRadius: 4,
  //             color: Color(0x33000000),
  //             offset: Offset(0, 2),
  //           )
  //         ],
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.max,
  //             children: [
  //               Padding(
  //                 padding: EdgeInsetsDirectional.fromSTEB(30, 2, 16, 0),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       mainAxisSize: MainAxisSize.max,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           item['nombre'].toString(),
  //                           style: GoogleFonts.oswald(
  //                               fontSize: 18, color: Colors.black),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 4),
  //                           child: RatingBarIndicator(
  //                             itemBuilder: (context, index) => Icon(
  //                               Icons.star_rounded,
  //                               color: Color(0xFFFFA130),
  //                             ),
  //                             direction: Axis.horizontal,
  //                             rating: 5,
  //                             unratedColor: Color(0xFF95A1AC),
  //                             itemCount: 5,
  //                             itemSize: 15,
  //                           ),
  //                         ),
  //                         Text(
  //                           item['calle'].toString(),
  //                           style: GoogleFonts.sourceSansPro(
  //                               fontSize: 16, color: Colors.black),
  //                         ),
  //                         SizedBox(
  //                           height: 3,
  //                         ),
  //                         Text(
  //                           calculoDist(item['location']['coordinates'][0],
  //                                       item['location']['coordinates'][1])
  //                                   .toStringAsPrecision(3) +
  //                               ' km',
  //                           style: GoogleFonts.raleway(
  //                               fontSize: 15,
  //                               color: Color.fromARGB(255, 65, 65, 65)),
  //                         ),
  //                       ],
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         Navigator.push(
  //                             context,
  //                             new MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     PropiedadPageView(propiedad: item)));
  //                       },
  //                       child: Card(
  //                         clipBehavior: Clip.antiAliasWithSaveLayer,
  //                         color: Color(0xFFDBE2E7),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(30),
  //                         ),
  //                         child: Padding(
  //                           padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
  //                           child: CachedNetworkImage(
  //                             width: _size.width * 0.28,
  //                             height: _size.height * 0.12,
  //                             fit: BoxFit.cover,
  //                             imageUrl: item['img_prop'][0]['Url'],
  //                             placeholder: (context, url) => Center(
  //                               child: new CircularProgressIndicator(
  //                                   valueColor: AlwaysStoppedAnimation<Color>(
  //                                       Colors.black)),
  //                             ),
  //                             errorWidget: (context, url, error) =>
  //                                 new Icon(Icons.error),
  //                             fadeOutDuration: new Duration(seconds: 1),
  //                             fadeInDuration: new Duration(seconds: 3),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget card(item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: (() {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => PropiedadPageView(propiedad: item)));
        }),
        child: Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              const BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          item['nombre'].toString(),
                          style: GoogleFonts.oswald(
                              fontSize: 18, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 4),
                      //   child: RatingBarIndicator(
                      //     itemBuilder: (context, index) => Icon(
                      //       Icons.star_rounded,
                      //       color: Color(0xFFFFA130),
                      //     ),
                      //     direction: Axis.horizontal,
                      //     rating: 5,
                      //     unratedColor: Color(0xFF95A1AC),
                      //     itemCount: 5,
                      //     itemSize: 15,
                      //   ),
                      // ),
                      Flexible(
                        child: Text(
                          item['calle'].toString(),
                          style: GoogleFonts.sourceSansPro(
                              fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Text(
                        '${calculoDist(item['location']['coordinates'][0], item['location']['coordinates'][1]).toStringAsPrecision(3)} km',
                        style: GoogleFonts.raleway(
                            fontSize: 15,
                            color: const Color.fromARGB(255, 65, 65, 65)),
                      ),
                    ],
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: const Color(0xFFDBE2E7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CachedNetworkImage(
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    imageUrl: item['img_prop'][0]['Url'],
                    placeholder: (context, url) => Center(
                      child: new CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.black)),
                    ),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    fadeOutDuration: new Duration(seconds: 1),
                    fadeInDuration: new Duration(seconds: 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List datanew = [];
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = data!;
    } else {
      results = data!
          // .where((producto) => producto["nombre"]
          //     .toLowerCase()
          //     .contains(enteredKeyword.toLowerCase()))
          // .toList();
          .where((producto) =>
              producto["nombre"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              producto["tipo"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      datanew = results;
    });
  }
}
