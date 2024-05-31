// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gowin/src/pages/gestiones/verificacio.email.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/user.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SingUp extends StatefulWidget {
  var lat;

  var long;

  SingUp({Key? key, required this.long, required this.lat}) : super(key: key);

  @override
  _SingUpState createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  //validacion evento http
  final _formkey = GlobalKey<FormState>();
  var telefono = '';
  Future save(filePath) async {
    setState(() {
      loading = true;
    });
    try {
      dynamic archivo;
      if (filePath == null) {
        archivo = null;
      } else {
        String fileName = filePath.path.split('/').last;
        archivo =
            await MultipartFile.fromFile(filePath.path, filename: fileName);
      }
      FormData formdata = FormData.fromMap({
        'nombre': user.nombre,
        'apellidos': user.apellidos,
        'email': user.email,
        'password': user.password,
        'fecha_nac': fecha_nac,
        'est': '',
        'media': archivo,
        'telefono': telefono,
        'direccion': 'aloja',
        'long': Constant.shared.mylong.toString(),
        'lat': Constant.shared.mylat.toString(),
      });
      var url = Constant.shared.urlApi + "/users";
      Dio dio = new Dio();
      var response = await dio.post(url,
          data: formdata,
          options: Options(
              followRedirects: false,
              validateStatus: (status) => true,
              headers: {
                "Accept": "application/json",
              }));
      var idUser = response.data;
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    VerificarEmail(idUser: idUser, page: "registro")));
      } else {
        setState(() {
          loading = false;
        });
        ToastNotification.toastNotificationError(response.data['msn'], context);
      }
    } catch (e) {
      print('ERROR: $e');
    }
  }

  User user = User(
    '',
    '',
    '',
    '',
    '',
  );
  bool passView = true;
  var fecha_nac = '';
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return loading == true
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Stack(
              children: [
                SvgPicture.asset('images/registro.svg', fit: BoxFit.fill),
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formkey,
                      child: ListView(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                          ),
                          _avatar(),
                          //_select_img(),
                          //NOMBRE
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                            child: TextFormField(
                              style: TextStyle(
                                  color: Color.fromARGB(255, 163, 250, 182)),
                              controller:
                                  TextEditingController(text: user.nombre),
                              onChanged: (value) {
                                user.nombre = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Error al ingresar datos';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'nombre',
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                hintText: 'Ingrese su nombre...',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                    20, 24, 20, 24),
                              ),
                            ),
                          ),
                          //APELLIDOS
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: TextFormField(
                              style: TextStyle(
                                  color: Color.fromARGB(255, 163, 250, 182)),
                              controller:
                                  TextEditingController(text: user.apellidos),
                              onChanged: (value) {
                                user.apellidos = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Error al ingresar datos';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Apellidos',
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                hintText: 'Ingrese sus apellidos',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                    20, 24, 20, 24),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                            child: TextFormField(
                              style: TextStyle(
                                  color: Color.fromARGB(255, 163, 250, 182)),
                              controller:
                                  TextEditingController(text: user.email),
                              onChanged: (value) {
                                user.email = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Eroor en los datos';
                                } else if (RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[aa-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                                  return null;
                                } else {
                                  return 'Ingrese un email valido';
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Correo Electronico',
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                hintText: 'Ingrese su Correo electronico',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
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
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                    20, 24, 20, 24),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            child: Text(
                              'La contraseña debe contener al menos una letra mayúscula, minúscula y un número.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                            child: TextFormField(
                              style: TextStyle(
                                  color: Color.fromARGB(255, 163, 250, 182)),
                              controller:
                                  TextEditingController(text: user.password),
                              onChanged: (value) {
                                user.password = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Error en los datos';
                                }
                                return null;
                              },
                              obscureText: passView,
                              decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  hintText: 'Ingrese una contraseña',
                                  hintStyle: TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
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
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          20, 24, 20, 24),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passView = !passView;
                                        });
                                      },
                                      icon: passView == true
                                          ? Icon(Icons.remove_red_eye_outlined)
                                          : Icon(
                                              Icons.remove_red_eye_rounded))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                            child: IntlPhoneField(
                              // ignore: deprecated_member_use
                              searchText: 'Buscar pais',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 19, 19, 19)),
                              invalidNumberMessage: 'Numero invalido',
                              decoration: InputDecoration(
                                focusColor: Colors.orange,
                                label: Text('Telefono'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: Colors.green, width: 1),
                                ),
                              ),
                              initialCountryCode: 'BO',
                              onChanged: (phone) {
                                telefono = phone.number.toString();
                                //print(phone.completeNumber);
                              },
                            ),
                          ),

                          InkWell(
                            onTap: () async {
                              var datePicked =
                                  await DatePicker.showSimpleDatePicker(
                                context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2012),
                                dateFormat: "dd-MMMM-yyyy",
                                locale: DateTimePickerLocale.es,
                                looping: true,
                              );

                              // final snackBar = SnackBar(
                              //     content: Text("Date Picked $datePicked"));
                              // ScaffoldMessenger.of(context)
                              //     .showSnackBar(snackBar);
                              if (datePicked != null) {
                                setState(() {
                                  fecha_nac = datePicked.day.toString() +
                                      '/' +
                                      datePicked.month.toString() +
                                      '/' +
                                      datePicked.year.toString();
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Color.fromARGB(255, 163, 250, 182)),
                                enabled: false,
                                controller:
                                    TextEditingController(text: fecha_nac),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'error fecha nacimiento';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Fecha de nacimiento',
                                  hintStyle: TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
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
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          20, 24, 20, 24),
                                ),
                              ),
                            ),
                          ),
                          //BOTTON_REGISTRO
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 5, 16, 3),
                            child: Container(
                              height: 50,
                              width: 400,
                              // ignore: deprecated_member_use
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 52, 184, 184),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.0)),
                                ),
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    save(_imageFile);
                                  } else {
                                    print("not ok :(");
                                  }
                                },
                                child: Text("Registrar",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

//desarrolo FECHA
  // var fechaT;
  // DateTime date = DateTime.now();
  // Future<Null> selectTimePicker(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: date,
  //       firstDate: DateTime(1940),
  //       lastDate: DateTime(2030));
  //   if (picked != null && picked != date) {
  //     setState(() {
  //       date = picked;
  //       fechaT = date.day.toString() +
  //           "/" +
  //           date.month.toString() +
  //           "/" +
  //           date.year.toString();
  //       user.fechaNac = fechaT;
  //     });
  //   }
  // }

//Logica IMAGEN PERFIL
  Widget _avatar() {
    return Center(
      child: Stack(children: <Widget>[
        CircleAvatar(
          radius: 60.0,
          backgroundImage: _imageFile == null
              ? AssetImage("images/person.png") as ImageProvider
              : FileImage(File(_imageFile!.path)),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: context, builder: ((builder) => bottomSheet()));
            },
            child: Icon(
              Icons.add_a_photo,
              color: Colors.teal,
              size: 28.0,
            ),
          ),
        )
      ]),
    );
  }

//logica cargar foto perfil o galeria
  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Cargar foto de perfil",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ignore: deprecated_member_use
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                  Navigator.of(context).pop(context);
                },
                icon: Icon(Icons.camera),
                label: Text("camara"),
              ),
              // ignore: deprecated_member_use
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.of(context).pop(context);
                },
                icon: Icon(Icons.image),
                label: Text("Galeria"),
              ),
            ],
          ),
        ],
      ),
    );
  }

//funcion para subir imagen
  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  void takePhoto(ImageSource source) async {
    // ignore: non_constant_identifier_names
    final PickedFile = await _picker.getImage(source: source);
    setState(() {
      _imageFile = PickedFile;
    });
  }
}
