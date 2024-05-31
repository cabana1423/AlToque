// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gowin/src/utils.pages/loading.dart';
import 'package:gowin/src/utils.pages/news.PushNotifications.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:http/http.dart' as http;
import 'package:gowin/src/utils/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'package:intl/intl.dart';

class GestioProp extends StatefulWidget {
  var propiedad;

  GestioProp({Key? key, @required this.propiedad}) : super(key: key);

  @override
  _GestioPropState createState() => _GestioPropState();
}

class _GestioPropState extends State<GestioProp> {
  final Connectivity _connectivity = Connectivity();
  bool coneccion = true;

  //late final Future<Prop> propiedad;
  List? data;
  bool nom = false,
      nit = false,
      prop = false,
      tel = false,
      call = false,
      img1 = false,
      img2 = false,
      img3 = false,
      img4 = false;
  late int cont = 0;
  var contImg = 0;
  var key = '';
  @override
  void initState() {
    super.initState();
    if (this.mounted) {
      setState(() {
        cont = widget.propiedad['img_prop'].length;
        contImg = widget.propiedad['img_prop'].length;
        if (widget.propiedad['img_prop'].length > 1) {
          key = widget.propiedad['img_prop'][1]['key'];
        }
        if (widget.propiedad['horario'] != '' &&
            widget.propiedad['horario'] != null) {
          getHorariosApi();
        }
        ;
      });
    }

    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        setState(() {
          coneccion = false;
          Push_Notification.ventanaConeccionInternet(context);
        });
      } else {
        setState(() {
          coneccion = true;
        });
      }
    });
    //propiedad = getJSONData();
  }

  void getHorariosApi() {
    if (widget.propiedad['horario'] == null ||
        widget.propiedad['horario'] == '') {
      return;
    }
    String horariosApi = widget.propiedad['horario'];
    final elem = horariosApi.split(',');
    log(elem.toString());
    largeHorario = elem.length;
    for (var i = 0; i < elem.length; i++) {
      switch (i) {
        case 0:
          time1 = elem[i].substring(0, 5);
          time11 = elem[i].substring(6, 11);
          log(time1.toString() + time11.toString());
          break;
        case 1:
          time2 = elem[i].substring(0, 5);
          time22 = elem[i].substring(6, 11);
          break;
        case 0:
          time3 = elem[i].substring(0, 5);
          time33 = elem[i].substring(6, 11);
          break;
        default:
      }
    }
  }

  // Future<Prop> getJSONData() async {
  //   String url =
  //       Constant.shared.urlApi + "/prop/id?id=" + Constant.shared.id_prop;
  //   final response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (response.statusCode == 200) {
  //     data = json.decode(response.body)['img_prop'];
  //     //print(data);
  //     return Prop.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load post');
  //   }
  // }
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading == true ? const Loadings() : _encabezado(widget.propiedad);
  }

  Widget _encabezado(dynamic elem) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, 0),
              child: ListView(
                children: [
                  _images(elem),
                  const Divider(),
                  horario(),
                  const Divider(),
                  _nombre(elem),
                  _propietario(elem),
                  _nit(elem),
                  _telefono(elem),
                  _calle(elem)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  int largeHorario = 0;
  late String time1 = '';
  late String time2 = '';
  late String time3 = '';
  late String time11 = '';
  late String time22 = '';
  late String time33 = '';
  DateTime fechaMedianoche =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Widget widgetHorario(int index, visible) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Desde'),
            TimePickerSpinnerPopUp(
              mode: CupertinoDatePickerMode.time,
              initTime: largeHorario == 2
                  ? DateTime.parse(
                      '1970-01-01 ${time2.isEmpty ? '00:00' : time2}:00')
                  : largeHorario == 1
                      ? DateTime.parse(
                          '1970-01-01 ${time1.isEmpty ? '00:00' : time1}:00')
                      : DateTime.parse('1970-01-01 00:00:00'),
              onChange: (dateTime) {
                var timeAux = '00:00';
                DateFormat timeFormat = DateFormat('HH:mm');
                timeAux = timeFormat.format(dateTime);
                // log('esta + $timeAux  $dateTime');
                if (index == 0) {
                  time1 = timeAux;
                } else if (index == 1) {
                  time2 = timeAux;
                } else if (index == 2) {
                  time3 = timeAux;
                }
                // log('$timeAux');
              },
            ),
            const Text('Hasta'),
            TimePickerSpinnerPopUp(
              mode: CupertinoDatePickerMode.time,
              initTime: largeHorario == 2
                  ? DateTime.parse(
                      '1970-01-01 ${time22.isEmpty ? '00:00' : time22}:00')
                  : largeHorario == 1
                      ? DateTime.parse(
                          '1970-01-01 ${time11.isEmpty ? '00:00' : time11}:00')
                      : DateTime.parse('1970-01-01 00:00:00'),
              onChange: (dateTime) {
                DateFormat timeFormat = DateFormat('HH:mm');
                var timeAux = timeFormat.format(dateTime);
                // log('esta + $timeAux  $dateTime');
                if (index == 0) {
                  time11 = timeAux;
                } else if (index == 1) {
                  time22 = timeAux;
                } else if (index == 2) {
                  time33 = timeAux;
                }
                // log('$timeAux');
              },
            )
          ],
        ),
        if (visible) ...[
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                log('registrar $largeHorario');
                if (largeHorario == 1 && ('$time1|$time11').length == 11) {
                  HoraFinal = '$time1|$time11';
                  print(HoraFinal);
                  _update('horario', HoraFinal);
                } else if (largeHorario == 2 &&
                    ('$time1|$time11').length == 11 &&
                    ('$time2|$time22').length == 11) {
                  HoraFinal = '$time1|$time11,$time2|$time22';
                  print(HoraFinal);
                  _update('horario', HoraFinal);
                } else if (largeHorario == 3 &&
                    ('$time1|$time11').length == 11 &&
                    ('$time2|$time22').length == 11 &&
                    ('$time3|$time33').length == 11) {
                  HoraFinal = '$time1|$time11,$time2|$time22,$time3|$time33';
                  print(HoraFinal);
                  _update('horario', HoraFinal);
                } else {
                  ToastNotification.toastNotificationError(
                      'Falta seleccionar alguna hora', context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 99, 212, 88)),
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ]
      ],
    );
  }

  String HoraFinal = '';

  Widget horario() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Añadir hoarios de atencion \n por defecto estara abierto todo el dia',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: ElevatedButton(
                    onPressed: () {
                      if (largeHorario < 3) {
                        largeHorario++;
                        setState(() {});
                      }
                    },
                    child: const Text('Añadir'),
                  ),
                ),
                if (largeHorario > 0) ...[
                  ElevatedButton(
                    onPressed: () {
                      if (largeHorario == 1) {
                        time1 = time11 = '';
                        _update('horario', '');
                      }
                      if (largeHorario == 2) {
                        time2 = time22 = '';
                        _update('horario', '$time1|$time11');
                      }
                      if (largeHorario == 3) {
                        time3 = time33 = '';
                        _update('horario', '$time1|$time11,$time2|$time22');
                      }
                      if (largeHorario > 0) {
                        largeHorario--;
                      }
                      log('$largeHorario $time1 $time11 $time2 $time22 $time3 $time33');
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ],
            ),
            Container(
                // ignore: prefer_const_constructors
                // padding: EdgeInsets.fromLTRB(0, 3, 0, 2),
                width: MediaQuery.of(context).size.width * 0.75,
                child: ListView.builder(
                  // padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: largeHorario,
                  itemBuilder: (context, index) {
                    if (index == largeHorario - 1) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                        child: widgetHorario(index, true),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                        child: textos(index),
                      );
                    }
                  },
                )),
          ],
        )
      ],
    );
  }

  Widget textos(index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (index == 0) ...[Text('Desde  $time1  -   Hasta  $time11')],
            if (index == 1) ...[Text('Desde  $time2  -   Hasta  $time22')],
            if (index == 2) ...[Text('Desde  $time3  -   Hasta  $time33')]
          ],
        )
      ],
    );
  }

  Widget _images(elem) {
    String aux1 = "img1";
    String aux2 = "img2";
    String aux3 = "img3";
    String aux4 = "img4";
    String imag1 = "imagen1";
    String imag2 = "imagen2";
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: elem['img_prop'][0]['Url'],
                imageBuilder: (context, imageProvider) => Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1),
                      image: DecorationImage(
                          image: _imageFile == null
                              ? imageProvider
                              : FileImage(File(_imageFile!.path)),
                          fit: BoxFit.fill)),
                  height: 140,
                  width: MediaQuery.of(context).size.width * 0.45,
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Positioned(
                bottom: img1 == false ? null : 02.0,
                top: img1 == false ? 1.0 : null,
                right: img1 == false ? 1.0 : 45.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: img1 == false
                            ? const Icon(
                                Icons.refresh,
                              )
                            : const Icon(Icons.close),
                        color: img1 == false
                            ? const Color.fromARGB(255, 96, 214, 241)
                            : Colors.red.shade800,
                        iconSize: 35,
                        onPressed: img1 == false
                            ? () {
                                setState(() {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: ((builder) =>
                                          bottomSheet(imag1)));
                                });
                              }
                            : () {
                                _imageFile = null;
                                _preseed(aux1);
                                _preseed(aux2);
                              }),
                    Visibility(
                      visible: img2 == false ? false : true,
                      child: IconButton(
                        icon: const Icon(Icons.done),
                        color: Colors.lightGreenAccent.shade400,
                        iconSize: 35,
                        onPressed: () {
                          setState(() {
                            _updateimag(_imageFile);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
//SEGUNDA IMAGEN
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: cont > 1
                    ? widget.propiedad['img_prop'][1]['Url']
                    : "https://fondosmil.com/fondo/17538.jpg",
                imageBuilder: (context, imageProvider) => Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(1.0),
                  decoration: new BoxDecoration(
                      color: Colors.transparent,
                      border: new Border.all(color: Colors.black, width: 1),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: _imageFile2 == null
                              ? imageProvider
                              : FileImage(File(_imageFile2!.path)))),
                  height: 140,
                  width: MediaQuery.of(context).size.width * 0.45,
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Positioned(
                bottom: img3 == false ? 95 : 02.0,
                right: img3 == false ? 2.0 : 45.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: contImg > 1
                      ? [
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            color: const Color.fromARGB(255, 255, 84, 84),
                            iconSize: 35,
                            onPressed: () {
                              confirmDelImg();
                            },
                          ),
                        ]
                      : [
                          IconButton(
                              icon: img3 == false
                                  ? Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey.shade400,
                                      size: 35.0,
                                    )
                                  : const Icon(Icons.close),
                              color: img3 == false
                                  ? Colors.white
                                  : Colors.red.shade800,
                              iconSize: 35,
                              onPressed: img3 == false
                                  ? () {
                                      setState(() {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: ((builder) =>
                                                bottomSheet(imag2)));
                                      });
                                    }
                                  : () {
                                      setState(() {
                                        _imageFile2 = null;
                                        _preseed(aux3);
                                        _preseed(aux4);
                                      });
                                    }),
                          Visibility(
                            visible: img4 == false ? false : true,
                            child: IconButton(
                              icon: const Icon(Icons.done),
                              color: Colors.lightGreenAccent.shade400,
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  _addImage(_imageFile2);
                                });
                              },
                            ),
                          ),
                        ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void confirmDelImg() {
    final _size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollable: false,
            content: Container(
              height: _size.height * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Desea eliminar la imagen?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _delImage();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'eliminar',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 78, 65)),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('cancelar'))
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _delImage() async {
    String aux1 = "img3";
    String url = Constant.shared.urlApi + "/prop/deleteimg/?k=" + key;

    Dio dio = new Dio();
    dio.post(url).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          print('eliminado');
          cont = 0;
          contImg = 0;
          _imageFile2 = null;
        });
      }
    }).catchError((error) => print(error));
  }

  Future _addImage(filePath) async {
    setState(() {
      loading = true;
    });
    String aux1 = "img3";
    String aux2 = "img4";
    dynamic archivo;
    String fileName = filePath.path.split('/').last;
    archivo = await MultipartFile.fromFile(filePath.path, filename: fileName);
    FormData formdata = new FormData.fromMap({'media': archivo});
    String url =
        Constant.shared.urlApi + "/prop/addimg/?id=" + Constant.shared.id_prop;
    Dio dio = new Dio();
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
      ToastNotification.toastNotificationSucces(
          'Imagen añadida con exito', context);
      setState(() {
        _preseed(aux1);
        _preseed(aux2);
        contImg = 2;
        key = response.data['msn']['key'];
        print(response.data['msn']);
        print(widget.propiedad);
      });
    } else {
      setState(() {
        loading = false;
      });
      ToastNotification.toastNotificationError(response.data['msn'], context);
    }

    // .then((response) {
    //   if (response.statusCode == 200) {
    //     setState(() {
    //       _preseed(aux1);
    //       _preseed(aux2);
    //       contImg = 2;
    //       key = response.data['msn']['key'];
    //       print(response.data['msn']);
    //       print(widget.propiedad);
    //     });
    //   }
    // }).catchError((error) => print(error));
  }

  Future _updateimag(filePath) async {
    setState(() {
      loading = true;
    });
    if (coneccion) {
      String aux1 = "img1";
      String aux2 = "img2";
      dynamic archivo;
      String fileName = filePath.path.split('/').last;
      archivo = await MultipartFile.fromFile(filePath.path, filename: fileName);
      FormData formdata = new FormData.fromMap({'media': archivo});
      String url = Constant.shared.urlApi +
          "/prop/file/?key=" +
          widget.propiedad['img_prop'][0]['key'];
      Dio dio = new Dio();
      var response = await dio.put(url,
          data: formdata,
          options: Options(
              followRedirects: false,
              validateStatus: (status) => true,
              headers: {
                "Accept": "application/json",
              }));
      if (response.statusCode == 200) {
        ToastNotification.toastNotificationSucces(
            'Imagen actualizada con exito', context);
        setState(() {
          loading = false;
        });
        _preseed(aux1);
        _preseed(aux2);
      } else {
        setState(() {
          loading = false;
        });
        ToastNotification.toastNotificationError(response.data['msn'], context);
      }
    } else {
      Push_Notification.ventanaConeccionInternet(context);
    }
  }

  Widget listile(icon, titulo, subtitulo, iconTrailing, value) {
    return Container(
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
              case 'nit':
                nit = !nit;
                break;
              case 'propietario':
                prop = !prop;
                break;
              case 'telefono':
                tel = !tel;
                break;
              case 'calle':
                call = !call;
                break;
              default:
                return;
            }
          });
        },
      ),
    );
  }

  Widget _nombre(dynamic elem) {
    // String texto = elem['nombre'];
    String aux = "nombre";
    String val = "";
    return nom == false
        ? listile(Icons.store, 'nombre', elem['nombre'],
            Icons.navigate_next_outlined, 'nombre')
        : Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
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
                        if (coneccion) {
                          _update(aux, val);
                          nom = !nom;
                          elem['nombre'] = val;
                        } else {
                          Push_Notification.ventanaConeccionInternet(context);
                        }
                      } else {
                        toast_notification();
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

  Widget _propietario(elem) {
    String aux = "propietario";
    String val = "";
    return prop == false
        ? listile(Icons.account_box, 'Propietario', elem['propietario'],
            Icons.navigate_next_outlined, 'propietario')
        : Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: new TextFormField(
                      autofocus: true,
                      controller: TextEditingController(text: val),
                      onChanged: (value) {
                        val = value;
                      },
                      decoration:
                          new InputDecoration(hintText: elem['propietario']),
                      enabled: prop,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      prop = !prop;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        if (coneccion) {
                          _update(aux, val);
                          prop = !prop;
                          elem['propietario'] = val;
                        } else {
                          Push_Notification.ventanaConeccionInternet(context);
                        }
                      } else {
                        toast_notification();
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

  Widget _nit(elem) {
    String aux = "nit";
    String val = "";
    return nit == false
        ? listile(Icons.numbers, 'Nit', elem['nit'].toString(),
            Icons.navigate_next_outlined, 'nit')
        : Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: new TextFormField(
                      autofocus: true,
                      controller: TextEditingController(text: val),
                      onChanged: (value) {
                        val = value;
                      },
                      decoration:
                          new InputDecoration(hintText: elem['nit'].toString()),
                      enabled: nit,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      nit = !nit;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        if (coneccion) {
                          _update(aux, val);
                          nit = !nit;
                          elem['nit'] = val;
                        } else {
                          Push_Notification.ventanaConeccionInternet(context);
                        }
                      } else {
                        toast_notification();
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

  Widget _telefono(elem) {
    String aux = "telefono";
    String val = "";
    return tel == false
        ? listile(Icons.phone, 'Teléfono', elem['telefono'],
            Icons.navigate_next_outlined, 'telefono')
        : Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: new TextFormField(
                      autofocus: true,
                      controller: TextEditingController(text: val),
                      onChanged: (value) {
                        val = value;
                      },
                      decoration:
                          new InputDecoration(hintText: elem['telefono']),
                      enabled: tel,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      tel = !tel;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        if (coneccion) {
                          _update(aux, val);
                          tel = !tel;
                          elem['telefono'] = val;
                        } else {
                          Push_Notification.ventanaConeccionInternet(context);
                        }
                      } else {
                        toast_notification();
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

  Widget _calle(elem) {
    String aux = "calle";
    String val = "";
    return call == false
        ? listile(Icons.store, 'Direccion', elem['calle'],
            Icons.navigate_next_outlined, 'calle')
        : Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: new TextFormField(
                      autofocus: true,
                      controller: TextEditingController(text: val),
                      onChanged: (value) {
                        val = value;
                      },
                      decoration: new InputDecoration(hintText: elem['calle']),
                      enabled: call,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  color: Colors.red.shade400,
                  onPressed: () {
                    setState(() {
                      call = !call;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (val != '') {
                        if (coneccion) {
                          _update(aux, val);
                          call = !call;
                          elem['calle'] = val;
                        } else {
                          Push_Notification.ventanaConeccionInternet(context);
                        }
                      } else {
                        toast_notification();
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

  Widget bottomSheet(String imag) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Cargar foto",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera, imag);
                  Navigator.of(context).pop(context);
                },
                icon: const Icon(Icons.camera),
                label: const Text("camara"),
              ),
              // ignore: deprecated_member_use
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery, imag);
                  Navigator.of(context).pop(context);
                },
                icon: const Icon(Icons.image),
                label: const Text("Galeria"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PickedFile? _imageFile, _imageFile2;
  final ImagePicker _picker = ImagePicker();
  void takePhoto(ImageSource source, String imag) async {
    String aux1 = "img1";
    String aux2 = "img2";
    String aux3 = "img3";
    String aux4 = "img4";
    // ignore: non_constant_identifier_names
    final PickedFile = await _picker.getImage(source: source);
    setState(() {
      if (imag == "imagen1")
        _imageFile = PickedFile;
      else
        _imageFile2 = PickedFile;

      if (_imageFile != null) {
        _preseed(aux1);
        _preseed(aux2);
      }
      if (_imageFile2 != null) {
        _preseed(aux3);
        _preseed(aux4);
      }
    });
  }

  void _preseed(aux) {
    setState(() {
      switch (aux) {
        case "img1":
          img1 = !img1;
          break;
        case "img2":
          img2 = !img2;
          break;
        case "img3":
          img3 = !img3;
          break;
        case "img4":
          img4 = !img4;
          break;
        default:
          return;
      }
    });
  }

  toast_notification() {
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

  toastAsept() {
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
        Icons.update,
        size: 30,
        color: Color.fromARGB(221, 57, 255, 53),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: const Text(
        "Exito",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: Color.fromARGB(255, 0, 185, 58),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: const Text(
        'datos actualizados',
        style: TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 142, 244, 133),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  Future _update(aux, val) async {
    String url =
        Constant.shared.urlApi + "/prop/?id=" + Constant.shared.id_prop;
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      '$aux': val,
    });
    if (res.statusCode == 200) {
      toastAsept();
      if (aux == 'horario') {
        setState(() {
          widget.propiedad['horario'] = val;
        });
      }
    } else
      print(res.statusCode);
  }
}



// class Prop {
//   final String nombre;
//   final int nit;
//   final String calle;
//   final String telefono;
//   final String propietario;

//   Prop(
//       {required this.nombre,
//       required this.nit,
//       required this.calle,
//       required this.telefono,
//       required this.propietario});

//   factory Prop.fromJson(Map<String, dynamic> json) {
//     return Prop(
//       nombre: json['nombre'],
//       nit: json['nit'],
//       calle: json['calle'],
//       telefono: json['telefono'],
//       propietario: json['propietario'],
//     );
//   }
// }
