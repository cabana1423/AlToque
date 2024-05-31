import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class Push_Notification {
  static ventanaConeccionInternet(context) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      borderSide: BorderSide(color: Colors.yellow, width: 0.5),

      width: 400,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(5)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Se perdio la coneccion de internet',
      //desc: 'Esta seguro de salir?',
      showCloseIcon: true,
      // btnCancelOnPress: () {
      //   print("hola");
      // },
      btnOkOnPress: () {},
    )..show();
  }
}
