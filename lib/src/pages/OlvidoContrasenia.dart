import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/gestiones/cambiar.Password.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class OlvidoContrasenia extends StatefulWidget {
  OlvidoContrasenia({Key? key}) : super(key: key);

  @override
  State<OlvidoContrasenia> createState() => _OlvidoContraseniaState();
}

class _OlvidoContraseniaState extends State<OlvidoContrasenia> {
  final _formkey = GlobalKey<FormState>();
  LoginEmail login = LoginEmail('');

  Future renviarCodigo(usuario) async {
    var url = Constant.shared.urlApi + "/users/reverifi";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'nombre': usuario['nombre'],
      'email': usuario['email'],
      'id': usuario['_id'],
      'parametro': 'password'
    });
    if (res.statusCode == 200) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => CambiarPass(user: usuario)));
      ToastNotification.toastNotificationSucces(
          'codigo enviado al correo ingresado', context);
    }
  }

  Future getDatosUser() async {
    var url = Constant.shared.urlApi + "/users/?email=" + login.email;
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (json.decode(response.body).length > 0) {
        // print(json.decode(response.body)[0]);
        renviarCodigo(json.decode(response.body)[0]);
        return;
      }
      ToastNotification.toastNotificationError(
          'Este correo electronico no esta vinculada a ninguna cuenta',
          context);
    } else {
      ToastNotification.toastNotificationError(
          'Error al enviar el codigo intentelo de nuevo', context);
    }
  }

  void _showSnack(String texto) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texto),
          duration: Duration(milliseconds: 1500),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: cuerpo(),
      ),
    );
  }

  Widget cuerpo() {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [textos(), textFormEmail(), botonSend()],
      ),
    );
  }

  Widget botonSend() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 100),
      child: Container(
        height: 50,
        width: 400,
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
              getDatosUser();
            }
          },
          child: Text("Enviar", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget textos() {
    return Column(
      children: [
        Text('¿Olvidaste tu contraseña?'),
        SizedBox(
          height: 40,
        ),
        Text('Ingresa tu correo electrónico, y te enviaremos '),
        Text('un codigo para que recuperes el acceso a tu cuenta.')
      ],
    );
  }

  Widget textFormEmail() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        controller:
            TextEditingController(text: /*'vedia@gmail.com'*/ login.email),
        onChanged: (value) {
          login.email = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Eroor en los datos';
          } else if (RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[aa-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return null;
          } else {
            return 'Ingrese un email válido';
          }
        },
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          hintText: 'Ingrese su email...',
          hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
          fillColor: Color.fromARGB(106, 12, 43, 61),
          contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
        ),
        style: null,
      ),
    );
  }
}

class LoginEmail {
  String email;
  LoginEmail(this.email);
}
