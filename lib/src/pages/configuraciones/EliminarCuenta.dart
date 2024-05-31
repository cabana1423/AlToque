// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gowin/src/pages/views_pages/cerrandoSesion.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:http/http.dart' as http;

class EliminarCuenta extends StatefulWidget {
  EliminarCuenta({super.key});

  @override
  State<EliminarCuenta> createState() => _EliminarCuentaState();
}

class _EliminarCuentaState extends State<EliminarCuenta> {
  Future<String> _update(aux, val) async {
    String url =
        "${Constant.shared.urlApi}/users/?id=${Constant.shared.dataUser['_id']}";
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
      'lastpass': '',
    });
    if (res.statusCode == 200) {
      if (mounted) {
        ToastNotification.toastNotificationSucces('Actualizado', context);
      }
      return 'success';
    } else {
      ToastNotification.toastNotificationError(
          json.decode(res.body)['msn'].toString(), context);
      return 'fail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrar Cuenta'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          children: [
            cuerpo(),
          ],
        ),
      ),
    );
  }

  Widget cuerpo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '¿Seguro que quieres borrar tu cuenta?',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Has decidido borrar tu cuenta de AlToque, la app que conecta usuarios con propietarios y repartidores de forma rápida y segura. Antes de confirmar tu decisión, queremos informarte de las consecuencias de esta acción. Al borrar tu cuenta, perderás el acceso a todos los servicios y beneficios de AlToque, como la búsqueda de propiedades, el contacto con los propietarios, el seguimiento de los pedidos, las valoraciones y más. Sin embargo, tu información no se eliminará de forma definitiva, sino que se guardará en nuestros servidores por un plazo de 30 días. Durante este tiempo, podrás recuperar tu cuenta si cambias de opinión y quieres volver a usar AlToque. Solo tendrás que iniciar sesión con tu correo electrónico y contraseña, y tu cuenta se restaurará automáticamente. Pasados los 30 días, tu información se eliminará por completo, tanto si eres propietario de un negocio o repartidor. Esto significa que no podrás recuperar tu cuenta ni los datos asociados a ella, como las fotos, los mensajes, las valoraciones, los pedidos, etc. Por lo tanto, te recomendamos que pienses bien tu decisión y que solo borres tu cuenta si estás seguro',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _ventana();
          },
          child: const Text('Borrar mi cuenta'),
        ),
      ],
    );
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
      title: '¿Confirma eliminar su cuenta?',
      //desc: 'Esta seguro de salir?',
      showCloseIcon: true,
      // btnCancelOnPress: () {
      //   print("hola");
      // },
      btnOkOnPress: () {
        _update('estado', 'suspendido');
        cerrarSession();
      },
    )..show();
  }

  void cerrarSession() async {
    await UserSecureStorages.delEmail();
    await UserSecureStorages.delId();
    await UserSecureStorages.delTokenFB();
    borrarToken();
    signOut();
    cerrarPestanias();
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
      // log('delToken');
      Constant.shared.dataUser = null;
    }
    //print(jsonDecode(res.body));
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  Future<void> signOut() async {
    if (await _googleSignIn.isSignedIn()) {
      // log('cerro session Google');
      _googleSignIn.disconnect();
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
}
