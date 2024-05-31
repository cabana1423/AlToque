import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gowin/src/pages/chat/CustomUi/own_message_Card.dart';
import 'package:gowin/src/pages/chat/CustomUi/receibe_message_card.dart';
import 'package:gowin/src/pages/chat/models/message-model.dart';
import 'package:gowin/src/utils.pages/news.PushNotifications.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:gowin/src/utils/ConnectS.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest.dart' as tz;

class IndividualPage extends StatefulWidget {
  final String id_u;
  final String nombre;
  final String url;
  final String id_2;
  final String nombre2;
  final String url2;
  final String telefono_2;
  final String id_prop;
  final String ultm;
  var zt;
  var imgProd;
  var tituloProd;
  IndividualPage(
      {Key? key,
      required this.zt,
      required this.id_u,
      required this.nombre,
      required this.url,
      required this.id_2,
      required this.nombre2,
      required this.url2,
      required this.telefono_2,
      required this.id_prop,
      required this.imgProd,
      required this.tituloProd,
      required this.ultm})
      : super(key: key);

  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  final Connectivity _connectivity = Connectivity();
  bool coneccion = true;

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool oneFBM = true;
  bool sendButon = false;
  List<MessageModel> messages = [];

  void emitdEnLinea(String estado) {
    Constant.shared.socket
        .emit("enLinea", {"idDest": widget.id_2.toString(), "emite": estado});
    //print('consultando');
  }

  void escucharEnLineaContacto() {
    Constant.shared.socket.on('resp_linea', (message) {
      if (this.mounted) {
        setState(() {
          if (message['estado'].toString().substring(0, 6) == 'Ultima') {
            estado = message['estado'];
          }
          if (message['estado'] == 'En linea') {
            //print('escuchado en linea');
            estado = message['estado'];
            respEnlinea(estado);
          }
        });
      }
    });
  }

  // si recive en linea de sala emite resp
  void respEnlinea(String estado) {
    Constant.shared.socket.emit(
        "enLinearesp", {"idDest": widget.id_2.toString(), "emite": estado});
    //print('respuesta en linea');
  }

  void escuchaResp() {
    Constant.shared.socket.on('escuchaResp', (message) {
      if (this.mounted) {
        setState(() {
          estado = message['estado'];
        });
      }
      //print('escucha respuesta');
    });
  }

  //mensajeria
  void escucha() {
    Constant.shared.socket.on("receive_message", (message) {
      // print(message);
      setMessageList(message["content"], message["id_origen"], message["time"]);
    });
  }

  void sendMessage(String message, String idOri, String idFin, time) {
    setMessageList(message, idOri, time);
    Constant.shared.socket.emit("send_message", {
      "content": message,
      "id_origen": idOri,
      "id_fin": idFin,
      "time": time
    });
  }

  void setMessageList(String message, String id, time) {
    var aux = {'id_u': id, 'mensaje': message, 'time': time};
    if (mounted) {
      setState(() {
        data.insert(0, aux);
      });
    }
  }

  var mural;
  void muralProd() {
    //print('entro a m uro');
    mural = {
      'id_u': widget.id_u,
      'mensaje': widget.imgProd,
      'time': '*#%&%#@' + widget.tituloProd
    };
    setState(() {
      data.add(mural);
    });
  }

  var idSala = '';
  Future enviarMsg(message, time) async {
    String url = Constant.shared.urlApi + "/chat" + "?id_2=" + widget.id_2;
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id': widget.id_u,
      'nombre': widget.nombre,
      'url': widget.url,
      'nombre2': widget.nombre2,
      'url2': widget.url2,
      'mensaje': message,
      'time': time,
      'id_prop': widget.id_prop,
      'zonahUser1': Constant.shared.dataUser['zonaHoraria'],
      'zonaHuser2': widget.zt
    });
    // if (res.statusCode == 200) {
    //   //idSala = json.decode(res.body)['id_sala'];
    //   //print('imprime el id sala $idSala');
    //   //print(json.decode(res.body)['id_sala']);
    // } //else
    //   //print(res.statusCode);
  }

  Future fcm_notification(message) async {
    String url = Constant.shared.urlApi + "/fcm";
    var time = DateTime.now().toString().substring(0, 16);
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id_2': widget.id_2,
      'title': widget.nombre,
      'body': message,
      'page': "mensajeria",
      'url': widget.url,
      'time': time
    });
    if (res.statusCode == 200) {
      print(json.decode(res.body));
    } //else
    //   print(res.statusCode);
  }

  Future updateUltmConeccion(ultmHora) async {
    //print(idSala);
    String url = Constant.shared.urlApi +
        "/chat/updateUltm" +
        "?id_u=" +
        Constant.shared.dataUser['_id'] +
        '&id_s=' +
        idSala.toString();
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'ultm': ultmHora,
    });
    // if (res.statusCode == 200) {
    //   // print(json.decode(res.body));
    // } else
    //   print(res.statusCode);
  }

  List data = [];
  //var id_sala;
  String estado = '';
  Future getJSONmensajes() async {
    var url = Constant.shared.urlApi +
        "/chat" +
        "?id_s=" +
        widget.id_u +
        widget.id_prop;
    var url2 = Constant.shared.urlApi +
        "/chat" +
        "?id_s=" +
        widget.id_2 +
        widget.id_prop;

    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (json.decode(response.body).length != 0) {
      // print('entro 0');
      setState(() {
        data = json.decode(response.body)[0]['messages'];
        data = data.reversed.toList();
        idSala = json.decode(response.body)[0]['id_sala'];
        estado = json.decode(response.body)[0]['ZonaTime']['user2']['hora'];
        if (widget.tituloProd != '') {
          data.insert(0, mural);
        }
        // if (widget.id_u ==
        //     json.decode(response.body)[0]['ZonaTime']['user1']['id_u']) {
        //   timeZone =
        //       json.decode(response.body)[0]['ZonaTime']['user2']['zonaHoraria'];
        //   if (estado == '') {
        //     estado = ultmHoraList['user2']['hora'];
        //   }
        // } else {
        //   timeZone =
        //       json.decode(response.body)[0]['ZonaTime']['user1']['zonaHoraria'];
        //   if (estado == '') {
        //     estado = ultmHoraList['user1']['hora'];
        //   }
        // }
      });
      // }
    } else {
      var response = await http
          .get(Uri.parse(url2), headers: {"Accept": "application/json"});
      if (json.decode(response.body).length != 0) {
        //print('entro 1');
        if (this.mounted) {
          setState(() {
            data = json.decode(response.body)[0]['messages'];
            data = data.reversed.toList();
            idSala = json.decode(response.body)[0]['id_sala'];
            estado = json.decode(response.body)[0]['ZonaTime']['user1']['hora'];
            if (widget.tituloProd != '') {
              data.add(mural);
            }
            // if (widget.id_u ==
            //     json.decode(response.body)[0]['ZonaTime']['user1']['id_u']) {
            //   timeZone = json.decode(response.body)[0]['ZonaTime']['user2']
            //       ['zonaHoraria'];
            //   if (estado == '') {
            //     estado = ultmHoraList['user2']['hora'];
            //   }
            // } else {
            //   timeZone = json.decode(response.body)[0]['ZonaTime']['user1']
            //       ['zonaHoraria'];
            //   if (estado == '') {
            //     estado = ultmHoraList['user1']['hora'];
            //   }
            // }
            // print(widget.zt);
            // if (estado == '') {
            //   if (ultmHoraList['user1']['id_u'] == widget.id_u) {
            //     estado = ultmHoraList['user1']['hora'];
            //   } else {
            //     estado = ultmHoraList['user2']['hora'];
            //   }
            // }
          });
        }
      }
    }
  }

  //obtener Hora  oyente
  // String obtenerHoraUno(hora) {
  //   try {
  //     var timeZone = tz.getLocation(hora);
  //     var now = tz.TZDateTime.now(timeZone);
  //     //print(now);
  //     return now.toString();
  //   } catch (e) {
  //     //print(e);
  //     return e.toString();
  //   }
  // }

  var timeZone;
  bool muralProduc = false;

  @override
  void initState() {
    super.initState();
    if (widget.tituloProd != '') {
      this.muralProd();
      muralProduc = true;
    }
    getJSONmensajes();
    tz.initializeTimeZones();
    //print(widget.zt);
    Connect.socketServer();
    emitdEnLinea("En linea");
    escucharEnLineaContacto();
    escuchaResp();
    escucha();
    if (widget.telefono_2 == '') {
      datos_propiedad();
    } else {
      setState(() {
        telefono = widget.telefono_2;
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
  }

  var telefono;
  Future datos_propiedad() async {
    String url = Constant.shared.urlApi + "/prop/id?id=" + widget.id_prop;
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      setState(() {
        //print(json.decode(response.body));
        telefono = json.decode(response.body)['telefono'].toString();
      });
    }
  }

  bool denada = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (data.length > 1) {
          log('ENTRA POR AQUI');
          var ultm =
              'Ultima conexión ${DateTime.now().toString().substring(0, 16)}';
          emitdEnLinea(ultm);
          updateUltmConeccion(ultm);
        }
        Constant.shared.socket.close();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          leadingWidth: 70,
          titleSpacing: 0,
          leading: InkWell(
            onTap: () {
              emitdEnLinea('Ultima conexión ');
              //print('se desconecto');
              Constant.shared.socket.close();
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
                CircleAvatar(
                  //IMAGEN DE PERFIL
                  backgroundImage: NetworkImage(widget.url2),
                  radius: 20,
                  backgroundColor: Colors.blueGrey,
                )
              ],
            ),
          ),
          title: Container(
              margin: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombre2,
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    estado,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        elevation: 200,
                        builder: (builder) => _botoomSheet());
                  },
                  icon: Icon(Icons.settings_phone_sharp)),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                      //height: MediaQuery.of(context).size.height - 140,
                      child: ListView.builder(
                          reverse: true,
                          //controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: data == null ? 0 : data.length,
                          itemBuilder: (context, index) {
                            if (index == data.length) {
                              return Container(
                                height: 70,
                              );
                            }
                            if (data[index]["id_u"] ==
                                Constant.shared.dataUser['_id']) {
                              if (data[index]['time']
                                      .toString()
                                      .substring(0, 7) ==
                                  '*#%&%#@') {
                                return muralProducto(
                                    data[index]['mensaje'],
                                    data[index]['time'].toString().substring(7,
                                        data[index]['time'].toString().length),
                                    index);
                              }
                              return OwnMessageCard(
                                message: data[index]['mensaje'],
                                time: data[index]['time']
                                    .toString()
                                    .substring(11, 16),
                              );
                            } else {
                              if (data[index]['time']
                                      .toString()
                                      .substring(0, 7) ==
                                  '*#%&%#@') {
                                return muralProducto(
                                    data[index]['mensaje'],
                                    data[index]['time'].toString().substring(7,
                                        data[index]['time'].toString().length),
                                    index);
                              }
                              return ReceibedMessageCard(
                                message: data[index]['mensaje'],
                                time: data[index]['time']
                                    .toString()
                                    .substring(11, 16),
                              );
                            }
                          })),
                  _botonsend(),
                ],
              ),
            ),
            // Align(
            //   alignment: Alignment.topCenter,
            //   child: Container(
            //     child: Text('data'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget muralProducto(foto, titulo, index) {
    return Container(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
        child: Card(
          color: Color.fromARGB(255, 246, 246, 246),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      foto,
                      fit: BoxFit.cover,
                      //radius: 28,
                    ),
                  ),
                ),
                title: Text(titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Me interesa este articulo'.toString(),
                      style: TextStyle(color: Color.fromARGB(221, 52, 52, 52)),
                    )
                  ],
                ),
                trailing: index == 0
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            data.removeAt(0);
                            muralProduc = false;
                          });
                        },
                        icon: Icon(Icons.close_sharp))
                    : null),
          ),
        ),
      )),
    );
  }

  abrirWhatssap() async {
    var number = "+59170452262";
    launch("https://wa.me/${number}?text=Hello");
  }

  Widget _botonsend() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 55,
                    child: Card(
                      margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: TextFormField(
                          autofocus: false,
                          controller: _controller,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          minLines: 1,
                          // onChanged: (value) {
                          // },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Mensaje",
                            contentPadding: EdgeInsets.all(5),
                            // suffixIcon: Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       IconButton(
                            //         onPressed: () {
                            //           showModalBottomSheet(
                            //               backgroundColor: Colors.transparent,
                            //               context: context,
                            //               builder: (builder) => Center(
                            //                     child: _botoomSheet(),
                            //                   ));
                            //         },
                            //         icon: Icon(Icons.attach_file),
                            //       )
                            //     ])
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8, right: 2, left: 2),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.green.shade400,
                      child: IconButton(
                          onPressed: () {
                            if (coneccion == true) {
                              var time =
                                  DateTime.now().toString().substring(0, 16);

                              sendMessage(_controller.text, widget.id_u,
                                  widget.id_2, time);
                              if (muralProduc == true) {
                                enviarMuroi(mural['mensaje'], mural['time'],
                                    _controller.text, time);
                                muralProduc = false;
                              } else {
                                enviarMsg(_controller.text, time);
                              }
                              if (estado != 'En linea') {
                                if (oneFBM == true) {
                                  fcm_notification(_controller.text);
                                  oneFBM = false;
                                }
                              }

                              _controller.clear();

                              setState(() {
                                sendButon = false;
                              });
                            } else {
                              Push_Notification.ventanaConeccionInternet(
                                  context);
                            }
                          },
                          icon: Icon(Icons.send_sharp),
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botoomSheet() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 160,
        child: Card(
          margin: EdgeInsets.all(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconCreation('images/whatssap.png', 50, "WhatsApp", 1),
                    SizedBox(width: 40),
                    _iconCreation('images/llama.png', 47, "Marcar", 2),
                    // SizedBox(
                    //   width: 40,
                    // ),
                    // _iconCreation(Icons.insert_photo, Colors.purple, "Gallery")
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconCreation(image, double tam, String text, double function) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (function == 1) {
              abrirWhatssap();
            } else if (function == 2) {
              launch('tel://$telefono');
            }
          },
          child: Image.asset(
            image,
            width: tam,
            height: tam,
            //color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future enviarMuroi(imagen, titulo, message, time) async {
    //print(Constant.shared.dataUser['zonaHoraria']);
    String url = Constant.shared.urlApi + "/chat" + "?id_2=" + widget.id_2;
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id': widget.id_u,
      'nombre': widget.nombre,
      'url': widget.url,
      'nombre2': widget.nombre2,
      'url2': widget.url2,
      'mensaje': imagen,
      'time': titulo,
      'id_prop': widget.id_prop,
      'zonahUser1': Constant.shared.dataUser['zonaHoraria'],
      'zonaHuser2': widget.zt
    });
    if (res.statusCode == 200) {
      setState(() {
        if (json.decode(res.body)['id_sala'] != null) {
          idSala = json.decode(res.body)['id_sala'];
        }
      });
      //print('aqui esta la sala $idSala');
      enviarMsg(message, time);
      //print(json.decode(res.body));
    } //else
    //print(res.statusCode);
  }
}
