// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gowin/src/pages/Home_Nav.dart';
import 'package:gowin/src/pages/sing_in.dart';
import 'package:gowin/src/utils.pages/loading.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class SplashLoading extends StatefulWidget {
  SplashLoading({Key? key}) : super(key: key);

  @override
  State<SplashLoading> createState() => _SplashLoadingState();
}

class _SplashLoadingState extends State<SplashLoading> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

  Future login(email, id, tokenFB) async {
    print(email + ' ' + id + ' ' + tokenFB);
    String url = "${Constant.shared.urlApi}/users/compStorage";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'email': email.toString(),
      'id': id.toString(),
      'tokenFB': Constant.shared.tokenFB,
      //'zonaHoraria': Constant.shared.zonaHoraria,
    });
    if (res.statusCode == 200) {
      Constant.shared.dataUser = jsonDecode(res.body)['res'];
      Constant.shared.listLikes =
          jsonDecode(res.body)['listaLike']['listaLikes'];
      Constant.shared.interacciones =
          jsonDecode(res.body)['listaLike']['interacciones'];
      Constant.shared.token = jsonDecode(res.body)['tokens']['token'];
      // print('AQUI EL TOKEN WEEEEEY');
      // print(jsonDecode(res.body)['tokens']['token']);
      Constant.shared.refreshToken =
          jsonDecode(res.body)['tokens']['refreshToken'];

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeNav(
                      enlace: '',
                      prod: '',
                    )));
      }
    } else {
      if (res.statusCode == 404) {
        ToastNotification.toastNotificationError(
            'Error al conectarse al servidor', context);
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SingIn()));
        ToastNotification.toastNotificationSucces(
            'Inicie sesion porfavor', context);
        // print(jsonDecode(res.body)['msn']);
      }
    }
  }

  Future<void> checkLogin() async {
    final email = await UserSecureStorages.getEmail();
    final id = await UserSecureStorages.getId();
    final tokenFB = await UserSecureStorages.getTokenFB();
    print(email);
    if (email == '' || id == '') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SingIn()));
      //Navigator.of(context).pushReplacementNamed('/Sing_in');
      return;
    }
    // print('inicio session');

    login(email, id, tokenFB);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Loadings());
  }
}
