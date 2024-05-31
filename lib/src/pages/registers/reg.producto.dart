import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gowin/src/utils.pages/news.PushNotifications.dart';
import 'package:gowin/src/utils/producto.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class RegProduc extends StatefulWidget {
  RegProduc({Key? key}) : super(key: key);

  @override
  _RegProducState createState() => _RegProducState();
}

class _RegProducState extends State<RegProduc> {
  // coneccion a internet inicio
  final Connectivity _connectivity = Connectivity();
  bool coneccion = false;

// coneccion a internet fin

  final _formkey = GlobalKey<FormState>();
  String? _botonselecionado;
  List<File> images = [];
  // final List<File?> images = List.generate(5, (_) => null);
  final ImagePicker _imagePicker = ImagePicker();
  multiimagePicker() async {
    final List<XFile> pickeimage = await _imagePicker.pickMultiImage();
    if (pickeimage != null) {
      pickeimage.forEach((element) {
        if (images.length >= 5) {
          ToastNotification.toastPeque(
              'Solo puedes cargar 5 imagenes como maximo', context);
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

  Future save(List<File> images) async {
    setState(() {
      loading = true;
    });
    // print('esta es $_botonselecionado');
    if (images.length == 0) {
      ToastNotification.toastNotificationError(
          'es necesario cargar imagenes', context);
      setState(() {
        loading = false;
      });
      return;
    }
    if (_botonselecionado == null) {
      ToastNotification.toastNotificationError(
          'falta seleccionar categoría', context);
      setState(() {
        loading = false;
      });
      return;
    }
    var sends = [];
    try {
      if (images != null) {
        for (var i = 0; i < images.length; i++) {
          List<int> imageData = await images[i].readAsBytes();
          MultipartFile multipartFile = MultipartFile.fromBytes(imageData,
              filename: images[i].path.split('/').last,
              contentType: MediaType('image', 'jpg'));
          sends.add(multipartFile);
        }
      }

      FormData formdata = FormData.fromMap({
        'nombre': produc.nombre,
        'precio': produc.precio +
            double.parse((produc.precio * 0.21).toStringAsFixed(1)),
        'comision': double.parse((produc.precio * 0.21).toStringAsFixed(1)),
        'descripcion': produc.descripcion,
        'categoria': _botonselecionado,
        'media': sends,
        'estado': 'vigente'
      });
      String url =
          Constant.shared.urlApi + "/produc/?id=" + Constant.shared.id_prop;
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
        if (mounted) {
          setState(() {
            loading = !loading;
            Navigator.pop(context);
            ToastNotification.toastNotificationSucces(
                'Producto creado', context);
          });
        }
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

  Product produc = Product('', 0, '');
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading == true
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formkey,
                child: ListView(
                  children: <Widget>[
                    _cargar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: categoriaSeleccion(),
                    ),
                    _nombre(),
                    _precio(),
                    descripcion(),
                    _btnReg(),
                  ],
                ),
              ),
            ),
          );
  }

  Widget categoriaSeleccion() {
    return ListTile(
      title: const Text('Categoria'),
      trailing: DropdownButton(
          value: _botonselecionado,
          hint: const Text('seleccionar'),
          onChanged: dropdownCallBack,
          items: const [
            DropdownMenuItem<String>(
              value: 'comida',
              child: Row(children: [
                Icon(Icons.flatware),
                SizedBox(
                  width: 5,
                ),
                Text('comida')
              ]),
            ),
            DropdownMenuItem<String>(
              value: 'postres',
              child: Row(children: [
                Icon(Icons.icecream),
                SizedBox(
                  width: 5,
                ),
                Text('postres y dulces')
              ]),
            ),
            // Dr|
            DropdownMenuItem<String>(
              value: 'Herramientas',
              child: Row(children: [
                Icon(Icons.hardware),
                SizedBox(
                  width: 5,
                ),
                Text('Herramientas')
              ]),
            ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.chair),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('muebles')
            //   ]),
            //   value: 'muebles',
            // ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.devices_other_sharp),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('electrónica')
            //   ]),
            //   value: 'electronica',
            // ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.sports_tennis_sharp),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('deporte')
            //   ]),
            //   value: 'deporte',
            // ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.maps_home_work),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('inmuebles')
            //   ]),
            //   value: 'inmueble',
            // ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.library_music),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('música')
            //   ]),
            //   value: 'musica',
            // ),
            DropdownMenuItem<String>(
              value: 'salud',
              child: Row(children: [
                Icon(Icons.medical_information),
                SizedBox(
                  width: 5,
                ),
                Text('salud')
              ]),
            ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.handshake_rounded),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('servicios')
            //   ]),
            //   value: 'servicios',
            // ),
            // DropdownMenuItem<String>(
            //   child: Row(children: [
            //     const Icon(Icons.color_lens),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     const Text('arte')
            //   ]),
            //   value: 'arte',
            // ),
            DropdownMenuItem<String>(
              value: 'supermercado',
              child: Row(children: [
                Icon(Icons.storefront_outlined),
                SizedBox(
                  width: 5,
                ),
                Text('Supermercado')
              ]),
            ),
            DropdownMenuItem<String>(
              value: 'otros',
              child: Row(children: [
                Icon(Icons.pending),
                SizedBox(
                  width: 5,
                ),
                Text('otros')
              ]),
            ),
          ]),
    );
  }

  void dropdownCallBack(String? selectValue) {
    setState(() {
      _botonselecionado = selectValue.toString();
      //print(_botonselecionado);
    });
  }

  Widget _nombre() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: TextFormField(
        controller: TextEditingController(text: produc.nombre),
        onChanged: (value) {
          produc.nombre = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Error al ingresar nombre';
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
            Icons.production_quantity_limits_sharp,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _precio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 180,
            child: TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.]+')),
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    produc.precio = double.parse(value);
                  });
                }
              },
              validator: (value) {
                if (value!.isEmpty || double.parse(value) == 0) {
                  return 'Error al ingresar precio';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'precio',
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
                  Icons.price_change,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Text(
            '+21% = ${produc.precio + double.parse((produc.precio * 0.21).toStringAsFixed(1))}',
            style: const TextStyle(color: Color.fromARGB(255, 49, 238, 55)),
          )
        ],
      ),
    );
  }

  Widget descripcion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: TextFormField(
        minLines:
            3, // any number you need (It works as the rows for the textarea)
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: TextEditingController(text: produc.descripcion),
        onChanged: (value) {
          produc.descripcion = value;
        },
        decoration: InputDecoration(
            hintText: 'Descripción',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.green),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.green),
            )),
      ),
    );
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
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black87, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 6,
          ),
          SizedBox(
              width: double.infinity,
              height: 120,
              child: Row(
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: InkWell(
                      onTap: () {
                        multiimagePicker();
                      },
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Color.fromARGB(152, 0, 0, 0),
                      ),
                    ),
                  ),
                  Expanded(child: buildGridView()),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Visibility(
                visible: images.isEmpty ? false : true,
                child: const Text(
                  'desliza arriba o abajo para eliminar la imagen',
                  style: TextStyle(fontSize: 12),
                )),
          )
        ],
      ),
    );
  }

  // Future<void> loadAssets() async {
  //   List<Asset> resultList = [];
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       maxImages: 5,
  //       enableCamera: true,
  //       selectedAssets: images,
  //       cupertinoOptions: const CupertinoOptions(
  //         takePhotoIcon: "chat",
  //       ),
  //       materialOptions: const MaterialOptions(
  //         actionBarColor: "#abcdef",
  //         actionBarTitle: "Cargar imagenes",
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
      mainAxisSpacing: images.length == 0 ? 0 : 1,
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
