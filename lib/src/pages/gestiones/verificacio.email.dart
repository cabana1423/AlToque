import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:gowin/src/pages/sing_in.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class VerificarEmail extends StatefulWidget {
  final idUser;
  final page;

  VerificarEmail({Key? key, @required this.idUser, this.page})
      : super(key: key);

  @override
  State<VerificarEmail> createState() => _VerificarEmailState();
}

class _VerificarEmailState extends State<VerificarEmail> {
  final _formkey = GlobalKey<FormState>();
  Codigo cod = Codigo('');

  void postVerificarEmail() async {
    String url = Constant.shared.urlApi + "/users/verifi-mail";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id': widget.idUser['_id'],
      'codigo': cod.codigo,
    });
    if (res.statusCode == 200) {
      _showSnack(jsonDecode(res.body)['msn'].toString());
      //Navigator.pop(context);
      if (widget.page == "registro") {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return SingIn();
        }), (route) => false);
      } else {
        Navigator.pop(context);
      }
    } else {
      toastNotification(jsonDecode(res.body)['msn']);
    }
  }

  void _showSnack(String texto) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texto),
          duration: Duration(milliseconds: 1500),
        ),
      );
  FocusNode blankNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                    'se acaba de enviar un correo electronico con un codigo de verificacion a la cuenta '),
              ),
              Container(
                width: _size.width * 0.7,
                child: textFormField(),
              ),
              botonSend()
            ],
          ),
        ),
      ),
    );
  }

  Widget textFormField() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller:
            TextEditingController(text: /*'vedia@gmail.com'*/ cod.codigo),
        onChanged: (value) {
          cod.codigo = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Ingrese el codigo de verificacion';
          } else if (value.length < 5) {
            return 'codigo incompleto';
          } else {
            return null;
          }
        },
        obscureText: false,
        decoration: InputDecoration(
          hintText: 'Ingrese el codigo...',
          hintStyle: TextStyle(color: Color.fromARGB(255, 132, 132, 132)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(0, 184, 18, 18),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(78, 30, 70, 91),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Color.fromARGB(101, 214, 214, 214),
          contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
        ),
        style: null,
      ),
    );
  }

  Widget botonSend() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        width: 150,
        //botton signIn
        // ignore: deprecated_member_use
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 52, 184, 184),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          ),
          onPressed: () {
            if (_formkey.currentState!.validate()) {
              print('ok :)');
              postVerificarEmail();
            }
          },
          child: Text("Siguiente", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  toastNotification(mensaje) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      boxShadows: [
        BoxShadow(
            color: Color.fromARGB(255, 228, 93, 15),
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      backgroundGradient: LinearGradient(colors: [
        Color.fromARGB(216, 96, 125, 139),
        Color.fromARGB(164, 0, 0, 0)
      ]),
      isDismissible: false,
      duration: Duration(seconds: 2),
      icon: Icon(
        Icons.error,
        size: 40,
        color: Color.fromARGB(255, 238, 63, 40),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Text(
        "ERROR",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Color.fromARGB(255, 226, 114, 23),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        mensaje,
        style: TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 202, 127, 15),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }
}

class Codigo {
  String codigo;
  Codigo(
    this.codigo,
  );
}
