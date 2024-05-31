// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class QuitarSuspencion extends StatefulWidget {
  var data;

  final void Function() onpressed;

  QuitarSuspencion({super.key, required this.data, required this.onpressed});

  @override
  State<QuitarSuspencion> createState() => _QuitarSuspencionState();
}

class _QuitarSuspencionState extends State<QuitarSuspencion> {
  Future<void> _update(aux, val) async {
    String url =
        '${Constant.shared.urlApi}/users/?id=${widget.data['res']['_id']}';
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
      'lastpass': '',
    });
    if (res.statusCode == 200) {
      if (json.decode(res.body)['msn'] == 'actualizado') {
        Navigator.pop(context);
        ToastNotification.toastNotificationSucces(
            'Su cuenta esta activa, inicie sesion nuevamente 🙂', context);
        // widget.onpressed();
        // ingresar(widget.data);
      }
      print(json.decode(res.body)['msn']);
    } else {
      ToastNotification.toastNotificationError(
          json.decode(res.body)['msn'].toString(), context);
    }
  }

  Future<void> ingresar(data) async {
    Constant.shared.dataUser = data['res'];
    Constant.shared.listLikes = data['listaLike']['listaLikes'];
    Constant.shared.interacciones = data['listaLike']['interacciones'];
    Constant.shared.token = data['tokens']['token'];
    Constant.shared.refreshToken = data['tokens']['refreshToken'];
    //guardar datos en storage
    await UserSecureStorages.setEmail(data['res']['email']);
    await UserSecureStorages.setId(data['res']['_id']);
    await UserSecureStorages.setTokenFB(Constant.shared.tokenFB);
    Navigator.of(context).pushReplacementNamed('/Home_Nav');
    ToastNotification.toastNotificationSucces(data['msn'].toString(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
            'Reaperturar cuenta',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Está a punto de cancelar la eliminación total de su cuenta de AlToque. Al hacerlo, podrá seguir disfrutando de todos los beneficios de nuestra app. Si está seguro de que quiere cancelar la eliminación de su cuenta, presione “Continuar”.',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _update('estado', 'verificada');
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
