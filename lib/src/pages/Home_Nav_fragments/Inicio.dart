import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/views_pages/View.categoria.produc.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/PanelControl.AdmUser.dart';
import 'package:gowin/src/pages/chat/home_screen.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class Inicio extends StatefulWidget {
  var enlace;

  var prod;

  Inicio({Key? key, required this.enlace, required this.prod})
      : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  //    ESTILOS
  var letraMostrar2 = GoogleFonts.amaranth(fontSize: 20, color: Colors.white);

  List? inicio = [];
  List destacado = [];
  List intereses = [];
  Future<String> datosProductos() async {
    var url = "${Constant.shared.urlApi}/produc?order=fecha_reg,-1";
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      'token': Constant.shared.token
    });
    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          inicio = json.decode(response.body);
        });
        interes();
      }
    } else {
      setState(() {
        loading = true;
      });
    }

    return "Successfull";
  }
  //para links

  Future<String> interes() async {
    var categos = Constant.shared.interacciones.join(',');
    var url =
        "${Constant.shared.urlApi}/produc/interac?limite=limitado&categorias=" +
            categos;
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
    });
    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          intereses = json.decode(response.body)['interes'];
          destacado = json.decode(response.body)['populares'];
        });
      }
    } else {
      ToastNotification.toastPeque(json.decode(response.body)['msn'], context);
    }

    return "Successfull";
  }

  @override
  void initState() {
    super.initState();
    this.datosProductos();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? const Center(child: CircularProgressIndicator())
        : WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Al Toque',
                  style: GoogleFonts.lobster(color: Colors.black, fontSize: 28),
                ),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  Visibility(
                    visible: Constant.shared.dataUser['tipo'] == 'normal' &&
                            Constant.shared.dataUser['tipo'] != null
                        ? false
                        : true,
                    child: IconButton(
                      icon: const Icon(
                        Icons.build_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PanelAdmin()));
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                  id_u: Constant.shared.dataUser['_id'])));
                    },
                  ),
                ],
              ),
              body: scroll_(),
            ),
          );
  }

  Widget scroll_() {
    return RefreshIndicator(
      onRefresh: () => datosProductos(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: populares(destacado),
            ),
          ),
          SliverToBoxAdapter(
            child: interesante(intereses),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 1, 0, 0),
                    child: Text(
                      'Mas recientes',
                      style: GoogleFonts.oswald(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            sliver: SliverStaggeredGrid.countBuilder(
                staggeredTileBuilder: (index) =>
                    const StaggeredTile.count(2, 3),
                crossAxisCount: 4,
                mainAxisSpacing: 11,
                crossAxisSpacing: 20,
                itemCount: inicio == null ? 0 : inicio!.length,
                itemBuilder: (context, index) {
                  return cardRecientes(inicio![index]);
                }),
          )
        ],
      ),
    );
  }

  Widget atajoVista(texto, exp, tipo) {
    return InkWell(
      onTap: () {
        // print(exp);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewInicio(tipo: tipo, lista: inicio)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texto,
              style: GoogleFonts.oswald(
                fontSize: 25,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded)
          ],
        ),
      ),
    );
  }

  Widget populares(datosList) {
    return Column(
      children: [
        atajoVista('Destacados', 'destacado', 'destacado'),
        Container(
          width: double.infinity,
          height: 195,
          child: StaggeredGridView.countBuilder(
              scrollDirection: Axis.horizontal,
              staggeredTileBuilder: (index) =>
                  const StaggeredTile.count(2, 1.5),
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 3,
              padding: const EdgeInsets.symmetric(vertical: 5),
              itemCount: datosList.length >= 10 ? 10 : datosList.length,
              itemBuilder: (context, index) {
                return index != 9
                    ? cardDestacados(datosList[index])
                    : Container(
                        child: const Center(
                        child: Text('ver mas'),
                      ));
              }),
        ),
      ],
    );
  }

  Widget interesante(datosList) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        atajoVista('esto puede interesarte', 'interesante', 'intereses'),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Container(
            width: double.infinity,
            height: 220,
            child: StaggeredGridView.countBuilder(
                scrollDirection: Axis.horizontal,
                staggeredTileBuilder: (index) => index % 2 == 0
                    ? const StaggeredTile.count(2, 1.5)
                    : const StaggeredTile.count(2, 2),
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 3,
                itemCount: datosList.length >= 12 ? 12 : datosList.length,
                itemBuilder: (context, index) {
                  return cardInteres(datosList[index]);
                }),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Future<void> refresh() async {
    interes();
    datosProductos();
  }

  Widget cardDestacados(dynamic item) {
    // final _size = MediaQuery.of(context).size;
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductoView(
                          producto: item,
                        ))).then((value) => setState(() {
                  datosProductos();
                  //FocusScope.of(context).unfocus();
                }));
          },
          child: CachedNetworkImage(
            imageUrl: item['img_produc'][0]['Url'],
            imageBuilder: (context, imageProvider) => Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 8),
              child: Container(
                width: 130,
                height: 180,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(fit: BoxFit.cover, image: imageProvider),
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
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                width: 130,
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
                          item['nombre'] + ' Bs',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.aBeeZee(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                      Text(
                        "${item['precio']} Bs",
                        style: GoogleFonts.abel(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 63, 255, 133)),
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
            child: Container(
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
            )),
      ],
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
          color: const Color.fromARGB(255, 125, 125, 125),
          width: .5,
        ),
        boxShadow: const [
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
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductoView(producto: item)))
                      .then((value) => setState(() {
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(15),
                      ),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 180,
                height: 80,
                decoration: const BoxDecoration(
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
                  decoration: const BoxDecoration(
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
                )),
          ],
        ),
      ),
    );
  }

  Widget cardInteres(dynamic item) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductoView(producto: item)))
                .then((value) => setState(() {
                      datosProductos();
                      //FocusScope.of(context).unfocus();
                    }));
          },
          child: CachedNetworkImage(
            imageUrl: item['img_produc'][0]['Url'],
            imageBuilder: (context, imageProvider) => Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color(0x64000000),
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
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
                            ..color = const Color.fromARGB(172, 47, 47, 47),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        item['nombre'],
                        style: GoogleFonts.amaranth(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 255, 255, 255),
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
                        color: const Color.fromARGB(175, 158, 158, 158)),
                    child: Center(
                        child: Text(
                      item['precio'] + ' Bs',
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
              decoration: const BoxDecoration(
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
            )),
      ],
    );
  }
}
