// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/PanelControl.AdmUser.dart';
import 'package:gowin/src/pages/gestiones/gest.Perfil.User.dart';
import 'package:gowin/src/pages/repartidores/En.Espera.dart';
import 'package:gowin/src/pages/repartidores/Formulario.Registro1.dart';
import 'package:gowin/src/pages/repartidores/PanelControlRepartidor.dart';
import 'package:gowin/src/pages/views_pages/ConfiguracionesApp.dart';
import 'package:gowin/src/pages/views_pages/cerrandoSesion.dart';
import 'package:gowin/src/pages/views_pages/productosGuardados.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class Perfil extends StatefulWidget {
  var enlace;

  var prod;

  Perfil({Key? key, required this.enlace, required this.prod})
      : super(key: key);

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: cuerpo()),
    );
  }

  Widget cuerpo() {
    return ListView(
      children: [
        fotoPerfil(),
        lista(),
      ],
    );
  }

  Widget fotoPerfil() {
    return Stack(
      children: [
        Image.asset(
          "images/muro_perfil.jpg",
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // CachedNetworkImage(
        //   width: double.infinity,
        //   height: 200,
        //   fit: BoxFit.cover,
        //   imageUrl:
        //       'https://img.freepik.com/foto-gratis/textura-pared-estuco-azul-marino-relieve-decorativo-abstracto-grunge-fondo-color-rugoso-gran-angular_1258-28311.jpg?w=900&t=st=1664250743~exp=1664251343~hmac=893b3be417cd5d694a4b24be5688021bf676e5d6f37e0430f3d7dd6214e2cffd',
        //   progressIndicatorBuilder: (context, url, downloadProgress) =>
        //       CircularProgressIndicator(value: downloadProgress.progress),
        //   errorWidget: (context, url, error) =>
        //       Icon(Icons.image_not_supported_sharp),
        // ),
        Container(
          width: double.infinity,
          height: 180,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromARGB(0, 142, 142, 142),
                Color.fromARGB(255, 255, 255, 255)
              ],
                  stops: [
                0,
                .8
              ])),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 40, 8, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Constant.shared.dataUser['img_user'][0]['Url'] == ''
                  ? CircleAvatar(
                      radius: 35,
                      child: Text(
                        Constant.shared.dataUser['nombre']
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: Constant.shared.dataUser['img_user'][0]['Url'],
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 40, backgroundImage: imageProvider),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 0, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(
                          Constant.shared.dataUser['nombre'],
                          style: GoogleFonts.amaranth(
                            fontSize: 18,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = const Color.fromARGB(172, 47, 47, 47),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          Constant.shared.dataUser['nombre'],
                          style: GoogleFonts.amaranth(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Text(
                          '${Constant.shared.dataUser['email']}',
                          style: GoogleFonts.amaranth(
                            fontSize: 14,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = const Color.fromARGB(172, 47, 47, 47),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${Constant.shared.dataUser['email']}',
                          style: GoogleFonts.amaranth(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    Text(
                      Constant.shared.dataUser['estado'] == 'verificada'
                          ? 'Cuenta activa'
                          : 'Cuenta Suspendida',
                      style: GoogleFonts.amaranth(
                          fontSize: 12,
                          color:
                              Constant.shared.dataUser['estado'] == 'verificada'
                                  ? Color.fromARGB(255, 118, 247, 128)
                                  : Color.fromARGB(255, 224, 163, 50)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                    // Text(Constant.shared.dataUser['nombre']),
                    // Text(Constant.shared.dataUser['email'])
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget lista() {
    return Column(
      children: [
        listTile(Icons.account_circle_rounded, 'Editar Perfil',
            Icons.arrow_forward_ios_sharp, const GestPerfilUser()),
        const Divider(
          height: 1,
        ),
        Visibility(
          visible: Constant.shared.dataUser['tipo'] != 'repartidor',
          child: listTile(
              Icons.build_circle_rounded,
              Constant.shared.dataUser['tipo'] == 'normal'
                  ? 'Crear negocio..'
                  : 'Panel de control',
              Icons.arrow_forward_ios_sharp,
              PanelAdmin()),
        ),
        const Divider(height: 1),
        listTile(Icons.shopping_cart_rounded, 'Productos guardados',
            Icons.arrow_forward_ios_sharp, SaveProduct()),
        const Divider(
          height: 1,
        ),
        Visibility(
          visible: Constant.shared.dataUser['tipo'] != 'propietario',
          child: listTile(
              Icons.two_wheeler,
              Constant.shared.dataUser['tipo'] != 'repartidor'
                  ? 'Quiero ser repartidor'
                  : 'Soy Repartidor',
              Icons.arrow_forward_ios_sharp,
              RepartidoresFormulario1()),
        ),
        const Divider(
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfiguracionesApp()));
              },
              leading: const Icon(
                Icons.settings,
                size: 35,
              ),
              title: const Text('Configuración'),
              trailing: const Icon(
                Icons.arrow_forward_ios_sharp,
              )),
        ),
        const Divider(
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
              onTap: () {
                _ventana();
              },
              leading: const Icon(
                Icons.door_sliding_rounded,
                size: 35,
              ),
              title: const Text('cerrar sesion'),
              trailing: const Icon(
                Icons.arrow_forward_ios_sharp,
              )),
        ),
        const Divider(height: 1),
        // TextButton(
        //     onPressed: () {
        //       // setState(() {
        //       //   build(context);
        //       // });

        //     },
        //     child: Text('data'))
      ],
    );
  }

  Widget listTile(icono, texto, icontrailing, funcion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
          onTap: () {
            if (texto == 'Quiero ser repartidor' || texto == 'Soy Repartidor') {
              actualizarDatosUser();
              return;
            }
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => funcion));
          },
          leading: Icon(
            icono,
            size: 35,
          ),
          title: Text(texto),
          trailing: Icon(icontrailing)),
    );
  }

  navegarRepartidor(respuesta) {
    switch (respuesta) {
      case 'SolicitudRepartidor':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => EnEsperaSolicitud()));
        break;
      case 'repartidor':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RepartidorPanelControl()));
        break;
      default:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RepartidoresFormulario1())).then((value) {
          setState(() {
            actualizarDatosUserpostRegistro();
          });
        });
        break;
    }
  }

  actualizarDatosUserpostRegistro() async {
    var url =
        "${Constant.shared.urlApi}/users/id?id=${Constant.shared.dataUser['_id']}";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      Constant.shared.dataUser = json.decode(response.body);
      setState(() {});
    }
  }

  actualizarDatosUser() async {
    // log('entra2');
    var url =
        "${Constant.shared.urlApi}/users/id?id=${Constant.shared.dataUser['_id']}";
    // log(url);
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    // log('${json.decode(response.body)}');
    if (response.statusCode == 200) {
      // log('${json.decode(response.body)}');
      navegarRepartidor(json.decode(response.body)['tipo']);
    }
  }

  void cerrarSession() async {
    await UserSecureStorages.delEmail();
    await UserSecureStorages.delId();
    await UserSecureStorages.delTokenFB();
    borrarToken();
    signOut();
    cerrarPestanias();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  Future<void> signOut() async {
    if (await _googleSignIn.isSignedIn()) {
      log('cerro session Google');
      GoogleSignIn().signOut();
    }
  }

  cerrarPestanias() {
    pushNewScreen(
      context,
      screen: const CerrandoSession(),
      withNavBar: false, // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  Future borrarToken() async {
    if (Constant.shared.tokenFB == '') {
      Constant.shared.tokenFB = await UserSecureStorages.getTokenFB();
    }
    String url = Constant.shared.urlApi + "/users/delToken";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id': Constant.shared.dataUser['_id'],
      'tokenFB': Constant.shared.tokenFB,
      //'zonaHoraria': Constant.shared.zonaHoraria,
    });
    if (res.statusCode == 200) {
      log('delToken');
      Constant.shared.dataUser = null;
    }
    //print(jsonDecode(res.body));
  }

  _ventana() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      borderSide: const BorderSide(color: Colors.yellow, width: 0.5),

      width: 400,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(5)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Esta seguro de salir?',
      //desc: 'Esta seguro de salir?',
      showCloseIcon: true,
      // btnCancelOnPress: () {
      //   print("hola");
      // },
      btnOkOnPress: () {
        cerrarSession();
      },
    )..show();
  }

  // ventanaPop() {
  //   return AwesomeDialog(
  //     padding: EdgeInsets.all(10),
  //     context: context,
  //     dialogType: DialogType.INFO,
  //     borderSide: const BorderSide(color: Colors.yellow, width: 1),
  //     width: 400,
  //     buttonsBorderRadius: const BorderRadius.all(Radius.circular(5)),
  //     headerAnimationLoop: false,
  //     animType: AnimType.BOTTOMSLIDE,
  //     title: 'Esta cuenta no puede optar por ser repartidor',
  //     desc:
  //         'Lamentablemente, no es posible crear una cuenta de repartidor si ya tienes una cuenta de administrador de una propiedad ',
  //     showCloseIcon: true,
  //     // btnCancelOnPress: () {
  //     //   print("hola");
  //     // },
  //   )..show();
  // }
}
