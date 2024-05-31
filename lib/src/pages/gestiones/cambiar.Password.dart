import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class CambiarPass extends StatefulWidget {
  var user;

  CambiarPass({Key? key, @required this.user}) : super(key: key);

  @override
  State<CambiarPass> createState() => _CambiarPassState();
}

class _CambiarPassState extends State<CambiarPass> {
  final _formkey = GlobalKey<FormState>();
  String passnewText1 = '';
  String passnewText2 = '';
  bool passnew1 = true;
  bool passnew2 = true;
  bool passView = false;
  Codigo cod = Codigo('');

  Future<String> updatePassword(aux, val) async {
    String url = Constant.shared.urlApi + "/users/?id=" + widget.user['_id'];
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
      'lastpass': '',
    });
    if (res.statusCode == 200) {
      Navigator.of(context).pushReplacementNamed('/Sing_in');
      ToastNotification.toastNotificationSucces(
          'Contraseña Actualizada', context);
      return 'success';
      //print(json.decode(res.body));
    } else {
      ToastNotification.toastNotificationError(
          json.decode(res.body)['msn'].toString(), context);
      return 'fail';
    }
  }

  void verificarCodigo() async {
    String url = Constant.shared.urlApi + "/users/verifi-mail";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id': widget.user['_id'],
      'codigo': cod.codigo,
      'tipo': 'password'
    });
    if (res.statusCode == 200) {
      updatePassword('password', passnewText1);
    } else {
      ToastNotification.toastNotificationError(
          jsonDecode(res.body)['msn'], context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cuerpo(),
    );
  }

  Widget cuerpo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        formularioPassword(),
      ],
    );
  }

  Widget formularioPassword() {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                cod.codigo = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Ingrese el codigo de verificacion';
                } else if (value.length < 5) {
                  return 'el codigo es mas de 5 digitos';
                } else {
                  return null;
                }
              },
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Ingrese el codigo...',
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 132, 132, 132)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(0, 184, 18, 18),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(78, 30, 70, 91),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: const Color.fromARGB(101, 214, 214, 214),
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
              ),
              style: null,
            ),
          ),
          //  PASSNEW--1
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: TextEditingController(text: passnewText1),
              onChanged: (value) {
                passnewText1 = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Los campos estan vacios';
                }
                return null;
              },
              obscureText: passnew1,
              decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  hintText: 'Nueva Contraseña',
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(0, 184, 18, 18),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(78, 30, 70, 91),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(106, 12, 43, 61),
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passnew1 = !passnew1;
                        });
                      },
                      icon: passnew1 == true
                          ? const Icon(Icons.remove_red_eye_outlined,
                              color: Color.fromARGB(255, 60, 62, 69))
                          : const Icon(Icons.remove_red_eye_rounded,
                              color: Color.fromARGB(255, 10, 43, 232)))),
              style: null,
            ),
          ),
          //    PASSNEW -->2
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: TextEditingController(text: passnewText2),
              onChanged: (value) {
                passnewText2 = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Los campos estan vacios';
                } else if (value != passnewText1) {
                  return 'las contraseñas no coinciden';
                }
                return null;
              },
              obscureText: passnew2,
              decoration: InputDecoration(
                  labelText: 'Repita Nueva Contraseña',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  hintText: 'Repita Nueva Contraseña',
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(0, 184, 18, 18),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(78, 30, 70, 91),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(106, 12, 43, 61),
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passnew2 = !passnew2;
                        });
                      },
                      icon: passnew2 == true
                          ? const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Color.fromARGB(255, 60, 62, 69),
                            )
                          : const Icon(
                              Icons.remove_red_eye_rounded,
                              color: Color.fromARGB(255, 10, 43, 232),
                            ))),
              style: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 50,
              width: 400,
              // ignore: deprecated_member_use
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 184, 184),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                ),
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    verificarCodigo();
                  }
                },
                child: const Text("Actualizar",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Codigo {
  String codigo;
  Codigo(
    this.codigo,
  );
}
