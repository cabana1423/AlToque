import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gowin/src/pages/gestiones/gest.Perfil.User.dart';
import 'package:gowin/src/pages/gestiones/gestion_tabBar.dart.dart';
import 'package:gowin/src/pages/registers/reg_propiedad.dart';
import 'package:gowin/src/pages/sing_in.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class PanelAdmin extends StatefulWidget {
  PanelAdmin({Key? key}) : super(key: key);

  @override
  State<PanelAdmin> createState() => _PanelAdminState();
}

class _PanelAdminState extends State<PanelAdmin> {
  final pageViewController = PageController(initialPage: 0);

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  var stiloText = GoogleFonts.raleway(
    textStyle: const TextStyle(
        color: Color.fromARGB(255, 64, 64, 64),
        letterSpacing: .5,
        fontSize: 15),
  );
  late GoogleSignInAccount _currentUser;
  var datos = Constant.shared.dataUser;
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account!;
      });
    });
    this.getPropiedades();
  }

  var loading = const Center(
    child: CircularProgressIndicator(),
  );
  List data = [];
  Future getPropiedades() async {
    String url = Constant.shared.urlApi +
        "/prop/?id_vig=" +
        Constant.shared.dataUser['_id'];
    var response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      'token': Constant.shared.token
    });
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          data = json.decode(response.body);
          if (data.isEmpty) {
            loading = const Center(
              child: Text(
                'Aun no tienes nada registrado',
                style: TextStyle(fontSize: 15),
              ),
            );
          }
        });
      }
      return;
    }
    ToastNotification.toastNotificationError(
        'Error en la informacion', context);
    return;
  }

  void signOut() {
    _googleSignIn.disconnect();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SingIn()));
  }

  int pages = 0;
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return SafeArea(child: cuerpo());
  }

  Widget cuerpo() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Control',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              icon: const Icon(
                Icons.add_box_outlined,
                size: 30,
                color: Colors.black87,
              ),
              onPressed: () {
                crear();
              },
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      body: photoPerfil(),
    );
  }

  crear() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollable: false,
            content: Container(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ListTile(
                    leading: Image.asset(
                      "images/addP.png",
                    ),
                    title: const Text(
                      "Crea tu ne gocio Ya¡",
                    ),
                    subtitle: Text(
                      "Agrega una propiedad administrala y añade tus produtos 😀",
                      style: stiloText,
                    ),
                  ),
                  const Divider(),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (datos['apellidos'] == '' ||
                            datos['telefono'] == '' ||
                            datos['fecha_nac'] == '') {
                          ventaNot();
                        } else {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegProp()))
                              .then((value) => setState(() {
                                    getPropiedades();
                                  }));
                        }
                      },
                      child: const Text('Continuar'))
                  // Visibility(
                  //   visible: false,
                  //   child: ListTile(
                  //     leading: Image.asset(
                  //       "images/addPr.png",
                  //     ),
                  //     title: Text(
                  //       "Crear un anuncio",
                  //     ),
                  //     subtitle: Text(
                  //       "Sin la necesidad de tener un negocio puedes publicar tu producto o anuncio al instante",
                  //       style: stiloText,
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          );
        });
  }

  // Widget bottomSheet() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     margin: EdgeInsets.symmetric(
  //       horizontal: 20,
  //       vertical: 20,
  //     ),
  //     child: Column(
  //       children: <Widget>[
  //         Text(
  //           "Agregar",
  //           style: TextStyle(
  //             fontSize: 20.0,
  //           ),
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             addPropProduc(
  //                 "images/addP.png",
  //                 "agrega tu ne gocio Ya¡",
  //                 "agrega una propiedad y administrala con mas produtos",
  //                 "propiedad"),
  //             Divider(
  //               height: 10,
  //             ),
  //             addPropProduc(
  //                 "images/addPr.png",
  //                 "Tambien puedes crear un anuncio ",
  //                 "de producto o servicio sera publicado en ",
  //                 "clacificados"),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget photoPerfil() {
    final _size = MediaQuery.of(context).size;
    return Column(
      children: [
        const Divider(),
        Container(
          width: _size.width,
          height: 100,
          child: Stack(
            children: [
              Image.asset(
                "images/mural2.jpg",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              ClipRRect(
                  child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: _size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    //color: Color.fromARGB(97, 9, 15, 19),
                    color: const Color.fromARGB(255, 226, 226, 226),
                    gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          const Color.fromARGB(255, 157, 157, 157)
                              .withOpacity(0.3),
                          const Color.fromARGB(255, 62, 63, 63),
                        ],
                        stops: const [
                          0.3,
                          1.0
                        ]),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
              )),
              Constant.shared.dataUser['img_user'][0]['Url'] == ''
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Text(
                              Constant.shared.dataUser['nombre']
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Container(
                            width: _size.width * 0.7,
                            child: Text(
                              Constant.shared.dataUser['nombre'] +
                                  ' ' +
                                  Constant.shared.dataUser['apellidos'],
                              style: GoogleFonts.openSans(
                                  fontSize: 25,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255)),
                              softWrap: true,
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: Constant.shared.dataUser['img_user'][0]['Url'],
                      imageBuilder: (context, imageProvider) => Container(
                        // color: Colors.amber,
                        width: _size.width,
                        height: _size.height * 0.35,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: imageProvider,
                                radius: 30,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                Constant.shared.dataUser['nombre'] +
                                    ' ' +
                                    Constant.shared.dataUser['apellidos'],
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.openSans(
                                    fontSize: 25,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255)),
                              )
                            ],
                          ),
                        ),
                      ),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black)),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fadeOutDuration: const Duration(seconds: 1),
                      fadeInDuration: const Duration(seconds: 3),
                    ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        //botones_deCambio(),
        _pageView()
      ],
    );
  }

  Widget botones_deCambio() {
    final _size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 224, 224, 224),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(170, 144, 143, 143),
                    offset: Offset(9, 7),
                    blurRadius: 6,
                  ),
                ],
              ),
              width: _size.width * 0.7,
              height: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      pageViewController.animateToPage(0,
                          duration: const Duration(microseconds: 3350),
                          curve: Curves.bounceInOut);
                    },
                    child: Container(
                      width: _size.width * 0.32,
                      // color: Colors.greenAccent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.house_outlined,
                            color: pages == 0
                                ? Colors.blue.shade300
                                : const Color.fromARGB(221, 105, 105, 105),
                            size: 37,
                          ),
                          Text(
                            'Negocios',
                            style: TextStyle(
                              color: pages == 0
                                  ? Colors.blue.shade300
                                  : const Color.fromARGB(221, 105, 105, 105),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    color: Colors.black87,
                    // thickness: 1,
                  ),
                  Visibility(
                    visible: false,
                    child: InkWell(
                      onTap: () {
                        pageViewController.animateToPage(1,
                            duration: const Duration(microseconds: 3350),
                            curve: Curves.bounceInOut);
                      },
                      child: Container(
                        width: _size.width * 0.32,
                        // color: Colors.amber,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopify,
                              color: pages == 1
                                  ? Colors.blue.shade300
                                  : const Color.fromARGB(221, 105, 105, 105),
                              size: 37,
                            ),
                            Text(
                              'Productos',
                              style: TextStyle(
                                color: pages == 1
                                    ? Colors.blue.shade300
                                    : const Color.fromARGB(221, 105, 105, 105),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: _size.width * 0.70,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: _size.width * 0.35,
                    height: 3.5,
                    color: pages == 0 ? Colors.blue.shade300 : null,
                  ),
                  Container(
                    width: _size.width * 0.35,
                    height: 3.5,
                    color: pages == 1 ? Colors.blue.shade300 : null,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _pageView() {
    final _size = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        width: _size.width,
        height: _size.height * 0.5,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: PageView(
                controller: pageViewController,
                onPageChanged: (int page) {
                  setState(() {
                    pages = page;
                  });
                },
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 25, 8, 0),
                      child: ClipRRect(
                        child: data.isEmpty ? loading : listaPrtopiedades(),
                      ),
                    ),
                  ),
                  // Container(
                  //   child: Padding(
                  //     padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(10),
                  //       child: null,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listaPrtopiedades() {
    return RefreshIndicator(
      onRefresh: () => getPropiedades(),
      child: StaggeredGridView.countBuilder(
          staggeredTileBuilder: (index) => const StaggeredTile.count(4, 1.7),
          crossAxisCount: 4,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          padding: const EdgeInsets.all(10.0),
          itemCount: data.isEmpty ? 0 : data.length,
          itemBuilder: (context, index) {
            return cardView(data[index]);
          }),
    );
  }

  Widget cardView(dynamic item) {
    return InkWell(
      onTap: () {
        Constant.shared.id_prop = item['_id'];
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => Tabar(propiedad: item)))
            .then((value) => setState(() {
                  getPropiedades();
                }));
      },
      child: CachedNetworkImage(
        imageUrl: item['img_prop'][0]['Url'],
        imageBuilder: (context, imageProvider) => Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 8, 0),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: imageProvider,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(0x33000000),
                  offset: Offset(0, 2),
                )
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0x65090F13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            item['nombre'],
                            style: GoogleFonts.aBeeZee(
                                backgroundColor:
                                    const Color.fromARGB(90, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                color:
                                    const Color.fromARGB(255, 236, 236, 236)),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: item['estado'] == 'suspendido' ? true : false,
                      child: Text(
                        '(Suspendido)',
                        style: GoogleFonts.aBeeZee(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: const Color.fromARGB(255, 236, 236, 236)),
                      ))
                ],
              ),
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
    );
  }

  ventaNot() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      borderSide: const BorderSide(color: Colors.yellow, width: 0.5),

      width: 400,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(5)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title:
          'Para registrar una propiedad debe completar los datos faltantes de tu perfil?',
      //desc: 'Esta seguro de salir?',
      showCloseIcon: true,
      // btnCancelOnPress: () {
      //   print("hola");
      // },
      btnOkOnPress: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const GestPerfilUser()));
      },
    )..show();
  }
}
