import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gowin/src/pages/mapas/LocacionTienda.dart';
import 'package:gowin/src/utils.pages/news.PushNotifications.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/propiedad.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;

class RegProp extends StatefulWidget {
  RegProp({Key? key}) : super(key: key);

  @override
  _RegPropState createState() => _RegPropState();
}

class _RegPropState extends State<RegProp> {
  @override
  final Connectivity _connectivity = Connectivity();
  bool coneccion = false;
  void initState() {
    super.initState();
    prop.telefono = Constant.shared.dataUser['telefono'];
    latitud = Constant.shared.lat = '';
    longitud = Constant.shared.long = '';
  }

  List<File> images = [];
  final ImagePicker _imagePicker = ImagePicker();
  multiimagePicker() async {
    final List<XFile> pickeimage = await _imagePicker.pickMultiImage();
    if (pickeimage != null) {
      pickeimage.forEach((element) {
        if (images.length >= 2) {
          ToastNotification.toastPeque(
              'Solo puedes cargar 2 imagenes como maximo', context);
          setState(() {});
          return;
        }
        if (!images.any((elemento) =>
            elemento.path.split('/').last ==
            File(element.path).path.split('/').last)) {
          images.add(File(element.path));
          log(element.path.toString());
        }
        // log(element.path.toString());
      });
      setState(() {});
    }
  }

  final _formkey = GlobalKey<FormState>();
  Future save(List<File> images) async {
    setState(() {
      loading = true;
    });
    if (Constant.shared.lat == "" || Constant.shared.long == "") {
      ToastNotification.toastNotificationError(
          'La hubicaion es obligatoria', context);
      setState(() {
        loading = false;
      });
      return;
    }
    if (images.length == 0) {
      ToastNotification.toastNotificationError(
          'falta subir almenos una imagen', context);
      setState(() {
        loading = false;
      });
      return;
    }
    var sends = [];
    try {
      if (images != null) {
        // print("el, largo");
        // print(images.length);
        for (var i = 0; i < images.length; i++) {
          List<int> imageData = await images[i].readAsBytes();
          MultipartFile multipartFile = MultipartFile.fromBytes(imageData,
              filename: images[i].path.split('/').last,
              contentType: MediaType('image', 'jpg'));
          sends.add(multipartFile);
        }
      }

      FormData formdata = FormData.fromMap({
        'nombre': prop.nombre,
        'tipo': prop.tipo,
        'nit': prop.nit,
        'calle': prop.calle,
        'propietario': prop.propietario,
        'telefono': prop.telefono,
        'lat': Constant.shared.lat,
        'long': Constant.shared.long,
        'media': sends,
        'estado': 'enEspera'
        //'media': [archivo]
      });
      String url = Constant.shared.urlApi +
          "/prop?id=" +
          Constant.shared.dataUser['_id'];
      Dio dio = Dio();
      var response = await dio.post(url,
          data: formdata,
          options: Options(
              followRedirects: false,
              validateStatus: (status) => true,
              headers: {
                "Accept": "application/json",
              }));
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        Constant.shared.lat = '';
        Constant.shared.long = '';
        Constant.shared.dataUser['tipo'] = 'propietario';
        fcm_notification();
        if (mounted) {
          //Navigator.pop(context);
          Navigator.of(context).pop(context);
        }
        ToastNotification.toastNotificationSucces(
            'Negocio registrado le notificaremos cuando pase la revision',
            context);
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

  Future fcm_notification() async {
    String url = "${Constant.shared.urlApi}/fcm";
    var time = DateTime.now().toString().substring(0, 16);
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id_2': Constant.shared.dataUser['_id'],
      'title': 'AlToque',
      'body':
          'la solicitud para registrar su tienda esta siendo revisada, le notificaremos cuando concluya',
      'page': 'interno',
      'id_cont': '',
      'time': time,
      'url': '',
      'id_tienda': ''
    });
    if (res.statusCode == 200) {
    } else {
      print(res.statusCode);
    }
  }

  Prop prop = Prop('', '', '', '', '', '');

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading == true
        ? const Center(child: CircularProgressIndicator())
        : WillPopScope(
            onWillPop: () async {
              Constant.shared.lat = '';
              Constant.shared.long = '';
              return true;
            },
            child: Scaffold(
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formkey,
                  child: ListView(
                    children: <Widget>[
                      _cargar(),
                      _nombre(),
                      textoDesc(),
                      _tipo(),
                      _propietario(),
                      _nit(),
                      _direccion(),
                      _telefono(),

                      //_butomHubi(),
                      btnHubicacion(),
                      _btnReg()
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget textoDesc() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        'Añada una descripcion deacuerdo a su engocio por ejemplo Restaurante, broasteria, Farmacia, etc. Esto para mejorar la busqueda por parte de el cliente',
        style: TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _nombre() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 3),
      child: TextFormField(
        controller: TextEditingController(text: prop.nombre),
        onChanged: (value) {
          prop.nombre = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Eroor al ingresar nombre';
          } else
            return null;
        },
        decoration: InputDecoration(
          hintText: 'nombre',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: const Icon(
            Icons.store,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _tipo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 3),
      child: TextFormField(
        controller: TextEditingController(text: prop.tipo),
        onChanged: (value) {
          prop.tipo = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Error al ingresar el tipo de negocio';
          } else
            return null;
        },
        decoration: InputDecoration(
          hintText: 'Descripción',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: const Icon(
            Icons.store,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _propietario() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
        controller: TextEditingController(text: prop.propietario),
        onChanged: (value) {
          prop.propietario = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Eroor al ingresar al propietario';
          } else
            return null;
        },
        decoration: InputDecoration(
          hintText: 'propietario',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: const Icon(
            Icons.person,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _nit() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9]+')),
        ],
        onChanged: (value) {
          prop.nit = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Eroor al ingresar nit';
          } else
            return null;
        },
        decoration: InputDecoration(
          hintText: 'nit',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: const Icon(
            Icons.format_list_numbered,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _direccion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
        controller: TextEditingController(text: prop.calle),
        onChanged: (value) {
          prop.calle = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Eroor al ingresar la calle';
          } else
            return null;
        },
        decoration: InputDecoration(
          hintText: 'direccion',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: const Icon(
            Icons.directions,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _telefono() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 3),
      child: IntlPhoneField(
        // ignore: deprecated_member_use
        initialValue: Constant.shared.dataUser['telefono'],
        searchText: 'Buscar pais',
        invalidNumberMessage: 'Numero invalido',
        decoration: InputDecoration(
          focusColor: Colors.orange,
          label: const Text('Telefono'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green, width: 1),
          ),
        ),
        initialCountryCode: 'BO',
        onChanged: (phone) {
          prop.telefono = phone.number;
          //print(phone.completeNumber);
        },
      ),
    );
  }

  Widget btnHubicacion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        latitud == ''
            ? const Text('Añadir ubicación')
            : const Text('Actualizar ubicación'),
        IconButton(
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LocationTienda()))
                  .then((value) => setState(() {
                        tomasDatosLatLon();
                      }));
              FocusScope.of(context).unfocus();
            },
            icon: Icon(
              latitud == ''
                  ? Icons.add_location_alt_outlined
                  : Icons.location_pin,
              color: latitud == '' ? Colors.black : Colors.green,
            ))
      ],
    );
  }

  var latitud;
  var longitud;
  void tomasDatosLatLon() {
    latitud = Constant.shared.lat;
    longitud = Constant.shared.long;
  }

  Widget _btnReg() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        width: 400,
        // ignore: deprecated_member_use
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          ),
          onPressed: () {
            if (_formkey.currentState!.validate()) {
              _connectivity.checkConnectivity().then((value) {
                if (value != ConnectivityResult.none) {
                  save(images);
                } else {
                  Push_Notification.ventanaConeccionInternet(context);
                }
              });
            }
          },
          child: const Text("Registrar", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _cargar() {
    return Column(
      children: [
        SizedBox(
            width: double.infinity,
            height: 120,
            child: Row(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: InkWell(
                    onTap: () {
                      multiimagePicker();
                    },
                    child: const Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Color.fromARGB(159, 0, 0, 0),
                    ),
                  ),
                ),
                Expanded(child: buildGridView()),
              ],
            )),
        Visibility(
            // visible: images.isEmpty ? false : true,
            child: const Text(
          'desliza arriba o abajo para eliminar la imagen',
          style: TextStyle(fontSize: 12),
        ))
      ],
    );
  }

  // Widget _butomHubi() {
  //   return Container(
  //     child: Column(
  //       children: [
  //         //Icon(Icons.location_on, color: Colors.greenAccent.shade400,size: 60,),
  //         ElevatedButton.icon(
  //             onPressed: () {
  //               Navigator.push(context,
  //                   new MaterialPageRoute(builder: (context) => Mapas()));
  //             },
  //             icon: Icon(Icons.location_on),
  //             label: Text("agregar")),
  //         //ElevatedButton(onPressed: (){}, child: Text("Ubicacion"))
  //       ],
  //     ),
  //   );
  // }

  // Future<void> loadAssets() async {
  //   List<Asset> resultList = [];
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       maxImages: 2,
  //       enableCamera: true,
  //       selectedAssets: images,
  //       cupertinoOptions: const CupertinoOptions(
  //         takePhotoIcon: "chat",
  //       ),
  //       materialOptions: const MaterialOptions(
  //         actionBarColor: "#abcdef",
  //         actionBarTitle: "Example App",
  //         allViewTitle: "All Photos",
  //         useDetailsView: false,
  //         selectCircleStrokeColor: "#000000",
  //       ),
  //     );
  //   } on Exception catch (e) {
  //     print(e.toString());
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     images = resultList;
  //   });
  // }

  Widget buildGridView() {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      mainAxisSpacing: images.length == 0 ? 0 : 8,
      children: List.generate(images.length, (index) {
        File file = images[index];
        final String date = (file.path.split('/').last).split('.').first;
        return Stack(
          children: [
            Dismissible(
              key: Key(date),
              direction: DismissDirection.vertical,
              onDismissed: (direction) {
                setState(() {
                  images.removeAt(index);
                });
                // Scaffold.of(context)
                //     .showSnackBar(SnackBar(content: Text("$date dismissed")));
              },
              background: Container(
                color: Colors.black54,
                child: const Center(
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
              child: Image.file(
                file,
                width: 110,
                height: 110,
                fit: BoxFit.fill,
              ),
            )
          ],
        );
      }),
    );
  }
}
