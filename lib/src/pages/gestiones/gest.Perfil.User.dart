// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/configuraciones/EliminarCuenta.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';

class GestPerfilUser extends StatefulWidget {
  const GestPerfilUser({Key? key}) : super(key: key);

  @override
  State<GestPerfilUser> createState() => _GestPerfilUserState();
}

final _formkey = GlobalKey<FormState>();
var lastpass = '';
String passnewText1 = '';
String passnewText2 = '';

class _GestPerfilUserState extends State<GestPerfilUser> {
  Future<String> _update(aux, val) async {
    String url = Constant.shared.urlApi +
        "/users/?id=" +
        Constant.shared.dataUser['_id'];
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
      'lastpass': lastpass,
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
        title: const Text('Perfil'),
        backgroundColor: Colors.white,
        // actions: [
        //   TextButton(
        //     child: const Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(
        //           Icons.settings_outlined,
        //           color: Colors.black87,
        //         ),
        //         SizedBox(width: 8.0),
        //         Text(
        //           'opciones',
        //           style: TextStyle(color: Colors.black87, fontSize: 10),
        //         ),
        //       ],
        //     ),
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) =>
        //                   EliminarCuenta(onpressed: _update)));
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ListView(children: [
          fotoPerfil(),
          const Divider(),
          nombre(),
          const Divider(),
          apellido(),
          const Divider(),
          email_(),
          const Divider(),
          fechaNac(),
          const Divider(),
          _telefono(),
          const Divider(),
          contrasenia(),
          const Divider(),
          Visibility(
            visible: passView,
            child: contenidoBottomSheet(),
          ),
          const Divider(),
        ]),
      ),
    );
  }

  Widget fotoPerfil() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Constant.shared.dataUser['img_user'][0]['Url'] == ''
            ? CircleAvatar(
                radius: 55,
                child: Text(
                  Constant.shared.dataUser['nombre']
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 80),
                ),
              )
            : CachedNetworkImage(
                imageUrl: Constant.shared.dataUser['img_user'][0]['Url'],
                imageBuilder: (context, imageProvider) => Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: imageProvider,
                    )),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                ),
                errorWidget: (context, url, error) => new Icon(Icons.error),
                fadeOutDuration: const Duration(seconds: 1),
                fadeInDuration: const Duration(seconds: 3),
              ),
        // ElevatedButton(onPressed: () {}, child: Text('cambiar'))
      ],
    );
  }

  //edit nombre

  Widget listile(icon, titulo, subtitulo, iconTrailing, value) {
    return SizedBox(
      width: double.infinity,
      child: ListTile(
        leading: Icon(icon),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: Icon(iconTrailing),
        onTap: () {
          setState(() {
            switch (value) {
              case 'nombre':
                nom = !nom;
                break;
              case 'apellido':
                ape = !ape;
                break;
              case 'email':
                ema = !ema;
                break;
              case 'fecha':
                actualizarFecha();
                break;
              default:
                return;
            }
          });
        },
      ),
    );
  }

  bool nom = false;
  Widget nombre() {
    String nombre = Constant.shared.dataUser['nombre'];
    String val = "";
    return nom == false
        ? listile(Icons.account_box, 'Editar nombre', nombre,
            Icons.navigate_next_outlined, 'nombre')
        : SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: true,
                    controller: TextEditingController(text: val),
                    onChanged: (value) {
                      val = value;
                    },
                    decoration: InputDecoration(hintText: nombre),
                    enabled: nom,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      nom = !nom;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        _update('nombre', val);
                        Constant.shared.dataUser['nombre'] = val;
                        nom = !nom;
                      } else {
                        ToastNotification.toastNotificationError(
                            'no se aeptan espacios vacios', context);
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.replay_circle_filled_rounded,
                    color: Color.fromARGB(255, 49, 247, 56),
                  ),
                ),
              ],
            ));
  }

  bool ape = false;
  Widget apellido() {
    String apellido = Constant.shared.dataUser['apellidos'];
    String val = "";
    return ape == false
        ? listile(Icons.badge, 'Editar apellido', apellido,
            Icons.navigate_next_outlined, 'apellido')
        : SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: true,
                    controller: TextEditingController(text: val),
                    onChanged: (value) {
                      val = value;
                    },
                    decoration: new InputDecoration(hintText: apellido),
                    enabled: ape,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      ape = !ape;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        _update('apellidos', val);
                        Constant.shared.dataUser['apellidos'] = val;
                        ape = !ape;
                      } else {
                        ToastNotification.toastNotificationError(
                            'no se aeptan espacios vacios', context);
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.replay_circle_filled_rounded,
                    color: Color.fromARGB(255, 49, 247, 56),
                  ),
                ),
              ],
            ));
  }

  bool ema = false;
  Widget email_() {
    String _email = Constant.shared.dataUser['email'];
    String val = "";
    return ema == false
        ? listile(Icons.mail_outline, 'Editar correo electronico', _email,
            Icons.navigate_next_outlined, 'email')
        : SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: true,
                    controller: TextEditingController(text: val),
                    onChanged: (value) {
                      val = value;
                    },
                    decoration: InputDecoration(hintText: _email),
                    enabled: ema,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      ema = !ema;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    if (val != '') {
                      if (RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[aa-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val)) {
                        _update('email', val).then((value) {
                          if (value == 'success') {
                            setState(() {
                              Constant.shared.dataUser['email'] = val;
                              ema = !ema;
                            });
                          }
                        });
                      } else {
                        ToastNotification.toastNotificationError(
                            'no es un correo valido', context);
                      }
                    } else {
                      ToastNotification.toastNotificationError(
                          'no se aceptan espacios vacios', context);
                    }
                  },
                  icon: const Icon(
                    Icons.replay_circle_filled_rounded,
                    color: Color.fromARGB(255, 49, 247, 56),
                  ),
                ),
              ],
            ));
  }

  Widget fechaNac() {
    return listile(
        Icons.date_range_rounded,
        'Fecha de nacimiento',
        Constant.shared.dataUser['fecha_nac'] == ''
            ? 'no definido'
            : Constant.shared.dataUser['fecha_nac'],
        Icons.navigate_next_outlined,
        'fecha');
  }

  void actualizarFecha() async {
    var datePicked = await DatePicker.showSimpleDatePicker(context,
        titleText: 'ACtualizar fecha',
        initialDate: DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime(2012),
        dateFormat: "dd-MMMM-yyyy",
        locale: DateTimePickerLocale.es,
        looping: true,
        confirmText: 'actualizar');
    if (datePicked != null) {
      _update('fecha_nac', Constant.shared.dataUser['fecha_nac']).then((value) {
        if (value == 'success') {
          setState(() {
            Constant.shared.dataUser['fecha_nac'] =
                '${datePicked.day}/${datePicked.month}/${datePicked.year}';
          });
        }
      });
    }
  }

  var telefono = '';
  Widget _telefono() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              if (telefono.length >= 12) {
                // print('OKokOK');
                _update('telefono', telefono);
                Constant.shared.dataUser['telefono'] = telefono;
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Actualizar número ',
                  style: GoogleFonts.actor(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: telefono.length >= 12 ? Colors.blue : Colors.red,
                    ),
                  ),
                ),
                Icon(
                  Icons.save,
                  color: telefono.length >= 12 ? Colors.blue : Colors.red,
                  size: 17,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          IntlPhoneField(
            // ignore: deprecated_member_use
            searchText: 'Buscar pais',
            invalidNumberMessage: 'Numero invalido',
            decoration: InputDecoration(
              focusColor: Colors.orange,
              label: Text(Constant.shared.dataUser['telefono']),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.green, width: 1),
              ),
            ),
            initialCountryCode: 'BO',
            onChanged: (phone) {
              setState(() {
                telefono = phone.completeNumber;
              });

              print(phone.completeNumber);
            },
          ),
        ],
      ),
    );
  }

  Widget contrasenia() {
    return TextButton.icon(
        onPressed: () {
          setState(() {
            passView = !passView;
          });
        },
        icon: passView == false
            ? const Icon(Icons.lock)
            : const Icon(Icons.lock_outline_rounded),
        label: Text(
          passView == false ? 'Modificar contraseña' : 'Cancelar',
          style: const TextStyle(color: Colors.black),
        ));
  }

  bool passView = false;
  bool passAct = true;
  bool passnew1 = true;
  bool passnew2 = true;
  Widget contenidoBottomSheet() {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: TextEditingController(text: lastpass),
              onChanged: (value) {
                lastpass = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Los campos estan vacios';
                }
                return null;
              },
              obscureText: passAct,
              decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  hintText: 'Ingrese su contraseña actual',
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
                          passAct = !passAct;
                        });
                      },
                      icon: passAct == true
                          ? const Icon(Icons.remove_red_eye_outlined)
                          : const Icon(Icons.remove_red_eye_rounded))),
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
                          ? const Icon(Icons.remove_red_eye_outlined)
                          : const Icon(Icons.remove_red_eye_rounded))),
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
                          ? const Icon(Icons.remove_red_eye_outlined)
                          : const Icon(Icons.remove_red_eye_rounded))),
              style: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
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
                    _update('password', passnewText1).then((value) {
                      if (value == 'success') {
                        setState(() {
                          passView = !passView;
                          Constant.shared.dataUser['password'] = passnewText1;
                          passnewText1 = passnewText2 = lastpass = '';
                        });
                      }
                    });
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
