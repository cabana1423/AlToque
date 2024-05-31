import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class ViewInicio extends StatefulWidget {
  var tipo;
  var lista;

  ViewInicio({Key? key, @required this.tipo, this.lista}) : super(key: key);

  @override
  State<ViewInicio> createState() => _ViewInicioState();
}

class _ViewInicioState extends State<ViewInicio> {
  var letraMostrar2 = GoogleFonts.amaranth(fontSize: 20, color: Colors.white);
  final textController = TextEditingController();
  bool activityText = false;
  List auxiliar = [];

  Future<String> interes() async {
    var categos = Constant.shared.interacciones.join(',');
    var url = Constant.shared.urlApi +
        "/produc/interac?limite=sinLimite&categorias=" +
        categos;
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        auxiliar = json.decode(response.body);
        print(auxiliar);
      });
    }
    return "Successfull";
  }

  Future<String> destacado() async {
    var categos = Constant.shared.interacciones.join(',');
    var url = Constant.shared.urlApi + "/produc?order=numLikes,-1" + categos;
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        auxiliar = json.decode(response.body);
        print(auxiliar);
      });
    }
    return "Successfull";
  }

  @override
  void initState() {
    super.initState();
    if (widget.tipo == 'intereses') {
      this.interes();
      // print('interes');
    } else if (widget.tipo == 'destacado') {
      this.destacado();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: cuerpo(),
      ),
    );
  }

  Widget cuerpo() {
    return Column(
      children: [buscar(), Expanded(child: buildListView(widget.tipo))],
    );
  }

  Widget buscar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 2),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.search,
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
              auxiliar = widget.lista;
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
                      auxiliar = widget.lista;
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
    return widget.tipo == 'destacado'
        ? Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: StaggeredGridView.countBuilder(
                staggeredTileBuilder: (index) => StaggeredTile.count(2, 3),
                crossAxisCount: 4,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                padding: const EdgeInsets.all(10.0),
                itemCount: auxiliar.length == 0 ? 0 : auxiliar.length,
                itemBuilder: (context, index) {
                  return cardDestacado(auxiliar[index]);
                }),
          )
        : widget.tipo == 'intereses'
            ? Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: StaggeredGridView.countBuilder(
                    staggeredTileBuilder: (index) => StaggeredTile.count(2, 3),
                    crossAxisCount: 4,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: auxiliar.length == 0 ? 0 : auxiliar.length,
                    itemBuilder: (context, index) {
                      return cardInteres(auxiliar[index]);
                    }),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: StaggeredGridView.countBuilder(
                    shrinkWrap: false,
                    staggeredTileBuilder: (index) => StaggeredTile.count(2, 3),
                    crossAxisCount: 4,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    padding: const EdgeInsets.all(10.0),
                    itemCount:
                        widget.lista.length == 0 ? 0 : widget.lista.length,
                    itemBuilder: (context, index) {
                      return cardDestacado(widget.lista[index]);
                    }),
              );
  }

  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = auxiliar;
    } else {
      results = auxiliar
          .where((producto) => producto["nombre"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      auxiliar = results;
    });
  }

  Widget cardDestacado(dynamic item) {
    final _size = MediaQuery.of(context).size;
    return Container(
      width: 200,
      height: 300,
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
              child: CachedNetworkImage(
                imageUrl: item['img_produc'][0]['Url'],
                imageBuilder: (context, imageProvider) => Container(
                  width: 200,
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
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 200,
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
                      Text(item['precio']),
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
            Positioned(
              top: 8,
              right: 10,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => ProductoView(
                                producto: item,
                              ))).then((value) => setState(() {
                        destacado();
                        //FocusScope.of(context).unfocus();
                      }));
                },
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(170, 0, 0, 0),
                  radius: 15,
                  child: Icon(Icons.navigate_next_outlined),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cardInteres(dynamic item) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: item['img_produc'][0]['Url'],
          imageBuilder: (context, imageProvider) => Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(0x64000000),
                  offset: Offset(1, 2),
                )
              ],
            ),
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: 200,
              height: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    children: [
                      Text(
                        item['nombre'],
                        style: GoogleFonts.amaranth(
                          fontSize: 20,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Color.fromARGB(172, 47, 47, 47),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        item['nombre'],
                        style: GoogleFonts.amaranth(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(175, 158, 158, 158)),
                    child: Center(
                        child: Text(
                      item['precio'],
                      style: letraMostrar2,
                    )),
                  ),
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
              height: 30,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 253, 93, 93),
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
        Positioned(
          top: 8,
          right: 10,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => ProductoView(
                            producto: item,
                          ))).then((value) => setState(() {
                    interes();
                    //FocusScope.of(context).unfocus();
                  }));
            },
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(170, 0, 0, 0),
              radius: 15,
              child: Icon(Icons.navigate_next_outlined),
            ),
          ),
        )
      ],
    );
  }
}
