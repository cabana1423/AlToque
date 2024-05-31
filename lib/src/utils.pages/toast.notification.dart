import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ToastNotification {
  static toastNotificationError(mensaje, context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      boxShadows: const [
        BoxShadow(
            color: Color.fromARGB(255, 228, 93, 15),
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      backgroundGradient: const LinearGradient(colors: [
        Color.fromARGB(216, 96, 125, 139),
        Color.fromARGB(164, 0, 0, 0)
      ]),
      isDismissible: false,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.error,
        size: 40,
        color: Color.fromARGB(255, 238, 63, 40),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: const Text(
        "ERROR",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Color.fromARGB(255, 226, 114, 23),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        mensaje.toString(),
        style: const TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 202, 127, 15),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  static toastNotificationAlert(mensaje, context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      boxShadows: const [
        BoxShadow(
            color: Color.fromARGB(255, 242, 255, 121),
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      backgroundGradient: const LinearGradient(colors: [
        Color.fromARGB(214, 182, 184, 115),
        Color.fromARGB(164, 0, 0, 0)
      ]),
      isDismissible: false,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.warning_amber,
        size: 40,
        color: Color.fromARGB(255, 255, 242, 121),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: const Text(
        "AVISO",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
            color: Color.fromARGB(255, 255, 252, 85),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        mensaje.toString(),
        style: const TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 248, 255, 144),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  static toastNotificationSucces(mensaje, context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      boxShadows: const [
        BoxShadow(
            color: Color.fromARGB(255, 15, 228, 125),
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      backgroundGradient: const LinearGradient(colors: [
        Color.fromARGB(216, 96, 125, 139),
        Color.fromARGB(164, 0, 0, 0)
      ]),
      isDismissible: false,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.done_outline_rounded,
        size: 40,
        color: Color.fromARGB(255, 129, 238, 40),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: const Text(
        "EXITO",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Color.fromARGB(255, 171, 255, 191),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        mensaje,
        style: const TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 170, 242, 99),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  static toastPeque(texto, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
