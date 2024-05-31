// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:gowin/src/pages/repartidores/Formulario.Registro2.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class RepartidoresFormulario1 extends StatefulWidget {
  RepartidoresFormulario1({Key? key}) : super(key: key);

  @override
  State<RepartidoresFormulario1> createState() =>
      _RepartidoresFormulario1State();
}

class _RepartidoresFormulario1State extends State<RepartidoresFormulario1> {
  var nombre, apellido, fechaNac, telefono, ci, direccion = '';
  String? vehiculo;
  final _formkey = GlobalKey<FormState>();

  Future<String> update() async {
    String url =
        "${Constant.shared.urlApi}/users/?id=${Constant.shared.dataUser['_id']}";
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      "vehiculo": vehiculo!,
      "nombre": nombre,
      "apellidos": apellido,
      "fecha_nac": fechaNac,
      "telefono": telefono,
      "ci": ci,
      "direccion": direccion
    });
    if (res.statusCode == 200) {
      pushNewScreen(
        context,
        screen: const ReaprtidorFormulario2(),
        withNavBar: true, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.fade,
      );
      ToastNotification.toastNotificationSucces('Actualizado', context);
      return 'success';
      //print(json.decode(res.body));
    } else {
      ToastNotification.toastNotificationError(
          json.decode(res.body)['msn'].toString(), context);
      return 'fail';
    }
  }

  @override
  void initState() {
    super.initState();
    valores();
  }

  void valores() {
    setState(() {
      nombre = Constant.shared.dataUser['nombre'];
      apellido = Constant.shared.dataUser['apellidos'];
      fechaNac = Constant.shared.dataUser['fecha_nac'];
      telefono = Constant.shared.dataUser['telefono'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: cuerpo(),
        ),
      ),
    );
  }

  Widget cuerpo() {
    return Form(
      key: _formkey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: parrafoInformmativo(),
            ),
            nombre_(),
            apellido_(),
            fechaNac_(),
            telefono == '' ? telefono_() : const SizedBox(),
            ci_(),
            direccion_(),
            vehiculo_(),
            boton()
          ],
        ),
      ),
    );
  }

  Widget nombre_() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 3, 53, 14)),
          controller: TextEditingController(text: nombre),
          onChanged: (value) {
            nombre = value;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Error al ingresar datos';
            }
            return null;
          },
          decoration: deco('Nombre')),
    );
  }

  Widget ci_() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(color: Color.fromARGB(255, 3, 53, 14)),
          controller: TextEditingController(text: ci),
          onChanged: (value) {
            ci = value;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Error al ingresar datos';
            }
            return null;
          },
          decoration: deco('Cedula de identidad')),
    );
  }

  Widget direccion_() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 3, 53, 14)),
          controller: TextEditingController(text: direccion),
          onChanged: (value) {
            direccion = value;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Error al ingresar datos';
            }
            return null;
          },
          decoration: deco('Direccion')),
    );
  }

  Widget apellido_() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 3, 53, 14)),
          controller: TextEditingController(text: apellido),
          onChanged: (value) {
            apellido = value;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Error al ingresar datos';
            }
            return null;
          },
          decoration: deco('Apellido')),
    );
  }

  Widget fechaNac_() {
    return InkWell(
      onTap: () async {
        var datePicked = await DatePicker.showSimpleDatePicker(
          context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime(2012),
          dateFormat: "dd-MMMM-yyyy",
          locale: DateTimePickerLocale.es,
          looping: true,
        );
        if (datePicked != null) {
          setState(() {
            fechaNac =
                '${datePicked.day}/${datePicked.month}/${datePicked.year}';
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
        child: TextFormField(
            style: const TextStyle(color: Color.fromARGB(255, 3, 53, 14)),
            enabled: false,
            controller: TextEditingController(text: fechaNac),
            validator: (value) {
              if (value!.isEmpty) {
                return 'error fecha nacimiento';
              }
              return null;
            },
            decoration: deco('Fecha de nacimiento')),
      ),
    );
  }

  Widget telefono_() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: IntlPhoneField(
        initialValue: telefono,
        // ignore: deprecated_member_use
        searchText: 'Buscar pais',
        style: const TextStyle(color: Color.fromARGB(255, 19, 19, 19)),
        invalidNumberMessage: 'Numero invalido',
        decoration: InputDecoration(
          focusColor: Colors.orange,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green, width: 1),
          ),
        ),
        initialCountryCode: 'BO',
        onChanged: (phone) {
          telefono = phone.number.toString();
        },
      ),
    );
  }

  List<String> opciones = ['Moto', 'Auto'];
  Widget vehiculo_() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
        child: DropdownButton(
          value: vehiculo,
          hint: const Text('Selecciona el tipo de vehículo '),
          items: opciones.map((String opcion) {
            return DropdownMenuItem<String>(
              value: opcion,
              child: Text(opcion),
            );
          }).toList(),
          onChanged: (nuevoValor) {
            setState(() {
              vehiculo = nuevoValor!;
            });
          },
        ),
      ),
    );
  }

  Widget boton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 3),
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
              if (vehiculo == null) {
                ToastNotification.toastNotificationError(
                    'Falta seleccionar un vehiculo', context);
                return;
              }
              update();
              log('YEEEEEEES');
            } else {
              print("not ok :(");
            }
          },
          child: const Text("Siguiente paso",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  deco(val) {
    return InputDecoration(
      labelText: val,
      labelStyle: const TextStyle(color: Color.fromARGB(255, 14, 162, 0)),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
        borderRadius: BorderRadius.circular(15),
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
      fillColor: const Color.fromARGB(70, 116, 239, 208),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
    );
  }

  Widget parrafoInformmativo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          width: 1.0,
          color: const Color.fromARGB(255, 224, 224, 224),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Importante!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Por favor, complete el formulario utilizando como referencia sus documentos originales. Es importante asegurarse de que la información proporcionada sea precisa y coincida con los detalles tal y como aparecen en los documentos oficiales correspondientes. Si hay discrepancias en la información proporcionada, es posible que se retrase o se niegue el procesamiento del registro.',
            style: TextStyle(
              fontSize: 14.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
