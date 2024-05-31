import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gowin/src/utils.pages/loading.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multi_image_picker/multi_image_picker.dart';

class PageEditProduc extends StatefulWidget {
  var producto;

  PageEditProduc({Key? key, @required this.producto}) : super(key: key);

  @override
  _PageEditProducState createState() => _PageEditProducState();
}

class _PageEditProducState extends State<PageEditProduc> {
  //late final Future<Produc> producto;
  bool nom = false, prec = false, desc = false, btn = false;
  List<File> images = [];
  final ImagePicker _imagePicker = ImagePicker();
  multiimagePicker() async {
    final List<XFile> pickeimage = await _imagePicker.pickMultiImage();
    if (pickeimage != null) {
      pickeimage.forEach((element) {
        if (images.length >= tamanio) {
          ToastNotification.toastPeque(
              'Solo puedes cargar 5 imagenes como maximo', context);
          setState(() {});
          return;
        }
        if (!images.any((elemento) =>
            elemento.path.split('/').last ==
            File(element.path).path.split('/').last)) {
          images.add(File(element.path));
          // log(element.path.toString());
        }
        // log(element.path.toString());
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    this.getJSONData();
    super.initState();
  }

  var datosProducto;
  var tamanio;
  List data = [];
  Future<String> getJSONData() async {
    String url =
        "${Constant.shared.urlApi}/produc/id?id=" + widget.producto['_id'];
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        data = json.decode(response.body)['img_produc'];
        // log(data.toString());

        //datosProducto = json.decode(response.body)[0];
        //print(datosProducto);
        tamanio = 5 - data.length;
      });
    }
    return 'Successfull';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _cuerpo(widget.producto));
  }

  bool loading = false;
  Widget _cuerpo(dynamic elem) {
    return loading == true
        ? const Loadings()
        : Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListView(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text('Imagenes actuales'),
                          ),

                          _imagenessubidas(),
                          const Divider(),
                          Visibility(
                            visible: data.length < 5 ? true : false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 8),
                                  child: Text('Cargar imagenes'),
                                ),
                                _cargar(),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: images.isNotEmpty ? true : false,
                            child: _btn(),
                          ),
                          const Divider(),
                          _nombre(elem),
                          _precio(elem),
                          _descrip(elem),

                          // _precio(elem),
                          // _descrip(elem),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget _imagenessubidas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemBuilder: (context, index) {
          return _laimagen(data[index]);
        },
        itemCount: data.length,
      ),
    );
  }

  Widget _laimagen(dynamic datas) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black87, width: 0.8)),
            child: Image.network(
              datas['Url'],
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
              onPressed: () {
                setState(() {
                  if (data.length > 1) {
                    _deleteImage(datas['key']);
                  }
                });
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 52, 45),
              )),
        ),
      ],
    );
  }

  Future _deleteImage(String key) async {
    String url = "${Constant.shared.urlApi}/produc/deleteimg/?k=$key";
    var res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Context-Type': 'application/json;charSet=UTF-8'
      },
    );
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        tamanio = 5 - data.length;
      });
      print(res.body);
    } else
      print(res.statusCode);
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
                      size: 40,
                      color: Color.fromARGB(159, 0, 0, 0),
                    ),
                  ),
                ),
                Expanded(child: buildGridView()),
              ],
            )),
        const SizedBox(
          height: 4,
        ),
        Visibility(
            visible: images.isEmpty ? false : true,
            child: const Text(
              'desliza arriba o abajo para eliminar la imagen',
              style: TextStyle(fontSize: 12),
            ))
      ],
    );
  }

  Widget buildGridView() {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      mainAxisSpacing: images.isEmpty ? 0 : 8,
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

  Widget _btn() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        width: 400,
        // ignore: deprecated_member_use
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 52, 107, 184),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          ),
          onPressed: () {
            _uploadImages(images);
            images = [];
          },
          child: const Text("subir", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _nombre(dynamic elem) {
    String aux = "nombre";
    String val = "";
    return nom == false
        ? listile(Icons.shopping_bag, 'Editar nombre producto', elem['nombre'],
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
                    decoration: InputDecoration(hintText: elem['nombre']),
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
                        _update(aux, val);
                        elem['nombre'] = val;
                      } else {
                        toastNotification();
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

  Widget listile(icon, titulo, subtitulo, iconTrailing, value) {
    return SizedBox(
      width: double.infinity,
      child: ListTile(
        leading: Icon(icon),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: Icon(iconTrailing),
        onTap: () {
          print('tecleado');
          setState(() {
            switch (value) {
              case 'nombre':
                nom = !nom;
                break;
              case 'precio':
                prec = !prec;
                break;
              case 'descripcion':
                desc = !desc;
                break;
              default:
                return;
            }
          });
        },
      ),
    );
  }

  double val = 0;
  Widget _precio(dynamic elem) {
    String aux = "precio";

    return prec == false
        ? listile(Icons.money_sharp, 'Editar precio', elem['precio'],
            Icons.navigate_next_outlined, 'precio')
        : SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),
                        ],
                        onChanged: (value) {
                          if (value == '') {
                            value = '0';
                          }
                          setState(() {
                            val = double.parse(value);
                          });
                        },
                        decoration: InputDecoration(hintText: elem['precio']),
                        enabled: prec,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.red.shade400,
                      onPressed: () {
                        setState(() {
                          prec = !prec;
                        });
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (val != 0) {
                            _updateprecio(aux, val);
                            elem['precio'] = '${val + (val * 0.10)}';
                          } else {
                            toastNotification();
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.replay_circle_filled_rounded,
                        color: Color.fromARGB(255, 49, 247, 56),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '+21% = ${val + double.parse((val * 0.21).toStringAsFixed(1))}',
                  style:
                      const TextStyle(color: Color.fromARGB(255, 49, 238, 55)),
                )
              ],
            ));
  }

  Widget _descrip(dynamic elem) {
    String aux = "descripcion";
    String val = "";
    return desc == false
        ? listile(Icons.description, 'Editar descripcion', elem['descripcion'],
            Icons.navigate_next_outlined, 'descripcion')
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
                    decoration: InputDecoration(hintText: elem['descripcion']),
                    enabled: desc,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      desc = !desc;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        _update(aux, val);
                        elem['descripcion'] = val;
                        //elem.nombre = val;
                      } else {
                        toastNotification();
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

  void _preseed(aux) {
    switch (aux) {
      case "nombre":
        {
          setState(() {
            nom = !nom;
          });
        }
        break;
      case "precio":
        {
          setState(() {
            prec = !prec;
          });
        }
        break;
      case "descripcion":
        {
          setState(() {
            desc = !desc;
          });
        }
        break;
      case "btn":
        {
          setState(() {
            btn = !btn;
          });
        }
        break;
    }
  }

  Future _update(aux, val) async {
    String url =
        "${Constant.shared.urlApi}/produc/?id=" + widget.producto['_id'];
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
    });
    if (res.statusCode == 200) {
      _preseed(aux);
      print(res.body);
    } else
      print(res.statusCode);
  }

  Future _updateprecio(aux, double val) async {
    try {
      FormData formdata = FormData.fromMap({
        'precio': val + double.parse((val * 0.21).toStringAsFixed(1)),
        'comision': double.parse((val * 0.21).toStringAsFixed(1))
      });
      String url =
          "${Constant.shared.urlApi}/produc/?id=" + widget.producto['_id'];
      Dio dio = Dio();
      dio.put(url, data: formdata).then((response) {
        _preseed(aux);
        //print(response);
      }).catchError((error) => print(error));
    } catch (e) {
      print('ERROR: $e');
    }
  }

  Future _uploadImages(List<File> images) async {
    setState(() {
      loading = true;
    });
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
        'media': sends,
      });
      // ignore: prefer_interpolation_to_compose_strings
      String url = "${Constant.shared.urlApi}/produc/addimg/?id=" +
          widget.producto['_id'];
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
          data = data + response.data;
          log(data.toString());
          tamanio = 5 - data.length;
        });
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

  toastNotification() {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      boxShadows: [
        const BoxShadow(
            color: Color.fromARGB(147, 250, 143, 82),
            offset: Offset(0.0, 2.0),
            blurRadius: 2.0)
      ],
      backgroundGradient: const LinearGradient(colors: [
        Color.fromARGB(216, 96, 125, 139),
        Color.fromARGB(164, 0, 0, 0)
      ]),
      isDismissible: false,
      duration: const Duration(seconds: 1),
      animationDuration: const Duration(milliseconds: 800),
      icon: const Icon(
        Icons.error_outline,
        size: 30,
        color: Color.fromARGB(255, 238, 63, 40),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: const Text(
        "ERROR",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: Color.fromARGB(255, 226, 114, 23),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: const Text(
        'no se aceptan espacios vacios',
        style: TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 202, 127, 15),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }
}

// class Produc {
//   final String nombre;
//   final String precio;
//   final String descripcion;

//   Produc({
//     required this.nombre,
//     required this.precio,
//     required this.descripcion,
//   });

//   factory Produc.fromJson(Map<String, dynamic> json) {
//     return Produc(
//       nombre: json['nombre'],
//       precio: json['precio'],
//       descripcion: json['descripcion'],
//     );
//   }
// }
