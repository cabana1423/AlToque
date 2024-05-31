// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/gestiones/gestionar.denuncias.dart';
import 'package:gowin/src/pages/views_pages/View.categoria.produc.dart';
import 'package:gowin/src/pages/chat/Individual_page.dart';
import 'package:gowin/src/pages/gestiones/gestion_enviar_pedido.dart';
import 'package:gowin/src/pages/views_pages/propiedadView.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductoView extends StatefulWidget {
  var producto;

  ProductoView({Key? key, @required this.producto}) : super(key: key);

  @override
  _ProductoViewState createState() => _ProductoViewState();
}

class _ProductoViewState extends State<ProductoView> {
  var letraMostrar2 = GoogleFonts.amaranth(fontSize: 20, color: Colors.white);
  //late final Future<Produc> producto;
  // List? data;
  List? dataP;
  List? listimgP;
  //dynamic propi;
  late bool isLiked = false;
  late int a = 0, b = 0;

///////time inicio
  DateTime? loginClickTime;
  bool isRedundentClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      print("first click");
      return false;
    }
    print('diff is ${currentTime.difference(loginClickTime!).inSeconds}');
    if (currentTime.difference(loginClickTime!).inSeconds < 2) {
      //set this difference time in seconds
      return true;
    }
    loginClickTime = currentTime;
    return false;
  }
/////fin time

  CarouselSliderController? _sliderController;
  var invertirComent = [];
  Future<Map<String, dynamic>>? _propiedad;
  @override
  void initState() {
    super.initState();
    getListas();
    setState(() {
      invertirComent = widget.producto['comentarios'].reversed.toList();
    });

    selecionListas();
    _propiedad = datos_propiedad();
    estadoLike();
    _sliderController = CarouselSliderController();
  }

  var listaProductosPropiedad = [];
  var similares = [];
  var mismaCategoria = [];

  var mayor = 0;
  var auxiliarP;

  Future getListas() async {
    var url = Constant.shared.urlApi +
        "/produc/mostProd?id=" +
        widget.producto['id_prop'] +
        "&cat=" +
        widget.producto['categoria'];
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          listaProductosPropiedad = json.decode(response.body)['masProductos'];
          listaProductosPropiedad
              .removeWhere((item) => item['_id'] == widget.producto['_id']);
          mismaCategoria = json.decode(response.body)['mismaCatego'];
          mismaCategoria.removeWhere(
              (item) => item['id_prop'] == widget.producto['id_prop']);
        });
      }
    }
  }

  void selecionListas() {
    // PRODUCTOS DE LA TIENDA
    // listaProductosPropiedad = widget.listaP
    //     .where((product) => product['id_prop'] == widget.producto['id_prop'])
    //     .toList();
    // listaProductosPropiedad
    //     .removeWhere((item) => item['_id'] == widget.producto['_id']);
    //Productosrecomendados
    // var vector = widget.producto['nombre'].split(" ");
    // for (int i = 0; i < vector.length; i++) {
    //   if (vector[i] != "") {
    //     auxiliarP = widget.listaP
    //         .where((producto) => producto["nombre"]
    //             .toLowerCase()
    //             .contains(vector[i].toLowerCase()) as bool)
    //         .toList();
    //   }
    //   if (auxiliarP.length > mayor) {
    //     similares = auxiliarP;
    //   }
    //   auxiliarP = [];
    // }
    // similares
    //     .removeWhere((item) => item['id_prop'] == widget.producto['id_prop']);
    // PRODUCTOS MISMA CATEGORIA
    // mismaCategoria = widget.listaP
    //     .where(
    //         (product) => product['categoria'] == widget.producto['categoria'])
    //     .toList();
    // mismaCategoria
    //     .removeWhere((item) => item['id_prop'] == widget.producto['id_prop']);
  }

  // Future<Produc> getJSONData() async {
  //   String url = Constant.shared.urlApi +
  //       "/produc/id?id=" +
  //       Constant.shared.id_produc_ped;
  //   final response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (response.statusCode == 200) {
  //     data = json.decode(response.body)[0]['img_produc'];
  //     return Produc.fromJson(json.decode(response.body)[0]);
  //   } else {
  //     throw Exception('Failed to load post');
  //   }
  // }
  var sendPropiedad;
  var telefono = '';
  var horarioApi = '';
  Future<Map<String, dynamic>> datos_propiedad() async {
    String url =
        Constant.shared.urlApi + "/prop/id?id=" + widget.producto['id_prop'];
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      print('error al cargar');
    }
    setState(() {
      telefono = json.decode(response.body)['telefono'].toString();
    });
    if (json.decode(response.body)['entregas'] != 'deshabilitado') {
      if (json.decode(response.body)['horario'] != null &&
          json.decode(response.body)['horario'] != '') {
        horarioApi = json.decode(response.body)['horario'];
        obtenerCerrado(json.decode(response.body)['horario']);
        setState(() {});
      }
    } else {
      abierto = false;
    }
    return json.decode(response.body);
  }

  bool abierto = true;
  var horarioFinal = '';
  void obtenerCerrado(String horarios) {
    if (horarios == '') {
      return;
    }
    setState(() {
      horarioFinal = horarios.replaceAll('|', ' ').replaceAll(',', '  ');
      var vec = horarios.split(',');
      for (var i = 0; i < vec.length; i++) {
        abierto = verificarHoraEnRango(
            vec[i].substring(0, 5), vec[i].substring(6, 11));
        if (abierto) {
          break;
        }
      }
    });
  }

  bool verificarHoraEnRango(String horaApertura, String horaCierre) {
    log(horaApertura + horaCierre);
    final horaActual = DateTime.now();

    final horaAperturaParsed = DateTime(
      horaActual.year,
      horaActual.month,
      horaActual.day,
      int.parse(horaApertura.split(':')[0]),
      int.parse(horaApertura.split(':')[1]),
    );

    final horaCierreParsed = DateTime(
      horaActual.year,
      horaActual.month,
      horaActual.day,
      int.parse(horaCierre.split(':')[0]),
      int.parse(horaCierre.split(':')[1]),
    );

    return horaActual.isAfter(horaAperturaParsed) &&
        horaActual.isBefore(horaCierreParsed);
  }

  //  publicar COMENTARIOS
  Future enviarComentarios(comment) async {
    isButtonDisabled = true;

    String url =
        Constant.shared.urlApi + "/produc/coment?id=" + widget.producto['_id'];
    final response = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'nombre': Constant.shared.dataUser['nombre'],
      'url': Constant.shared.dataUser['img_user'][0]['Url'],
      'comentario': comment,
      'fecha': DateTime.now().toString().substring(0, 16),
      'id_u': Constant.shared.dataUser['_id']
    });
    if (response.statusCode == 200) {
      setState(() {
        invertirComent.insert(0, {
          'nombre': Constant.shared.dataUser['nombre'],
          'url': Constant.shared.dataUser['img_user'][0]['Url'],
          'comentario': _controller.text,
          'fecha': DateTime.now().toString().substring(0, 16)
        });
        _controller.text = '';
        FocusScope.of(context).requestFocus(FocusNode());
        isButtonDisabled = false;
      });
    } else {
      print('comeentario No publicado');
    }
  }

  Future ZonHorUser(propiedad) async {
    String url =
        Constant.shared.urlApi + "/users/id?id=" + propiedad['id_user'];
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      var zonaH = json.decode(response.body)['zonaHoraria'];

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => IndividualPage(
                  id_u: Constant.shared.dataUser['_id'],
                  nombre: Constant.shared.dataUser['nombre'],
                  url: Constant.shared.dataUser['img_user'][0]['Url'],
                  id_2: propiedad['id_user'],
                  nombre2: propiedad['nombre'],
                  url2: propiedad['img_prop'][0]['Url'],
                  telefono_2: propiedad['telefono'],
                  id_prop: propiedad['_id'],
                  ultm: '',
                  imgProd: widget.producto['img_produc'][0]['Url'],
                  tituloProd: widget.producto['nombre'],
                  zt: zonaH)));
    }
  }

  // Future getJSONDataProducts() async {
  //   String url = Constant.shared.urlApi +
  //       "/produc/idnot?id_p=" +
  //       widget.productos['id_prop'] +
  //       "&id_not=" +
  //       widget.productos['_id'];
  //   final response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (this.mounted) {
  //     setState(() {
  //       listimgP = json.decode(response.body);
  //     });
  //   }
  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to load post');
  //   }
  // }

  // late List likesP = [];
  // Future postLikes() async {
  //   String url = Constant.shared.urlApi +
  //       "/produc/likes?id_u=" +
  //       Constant.shared.dataUser['_id'];
  //   final response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (json.decode(response.body).length != 0) {
  //     likesP = json.decode(response.body)[0]['listaLikes'];
  //     print(likesP);
  //     estadoLike(widget.productos['_id']);
  //   }
  // }

  estadoLike() {
    if (mounted) {
      setState(() {
        isLiked = Constant.shared.listLikes
            .any((produc) => produc['id_producto'] == widget.producto['_id']);
      });
      if (isLiked) {
        b = 1;
      } else {
        a = 1;
      }
      return;
    }
    // print(Constant.shared.listLikes
    //     .any((produc) => produc['id_producto'] == widget.productos['_id']));
    // // for (int i = 0; i < likesP.length; i++) {
    // //   if (likesP[i]['id_producto'] == id_p) {
    // //     if (mounted) {
    // //       setState(() {
    // //         isLiked = true;
    // //       });
    // //       b = 1;
    // //       return;
    // //     }
    // //   }
    // // // }
    // // if (mounted) {
    // //   setState(() {
    // //     isLiked = false;
    // //   });
    // //   a = 1;
    // // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _propiedad,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //propi = snapshot.data!;
            return cuerpo(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // Por defecto, muestra un loading spinner
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget cuerpo(prop) {
    return Stack(children: [
      _customScroll(widget.producto),
      Positioned(
        bottom: 5,
        left: 0,
        child: Column(
          children: [
            _botonesGestion(widget.producto, prop),
          ],
        ),
      ),
    ]);
  }

  Widget _customScroll(dynamic elem) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 320,
            actions: [
              disponible(elem),
              const VerticalDivider(),
              IconButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (context) {
                        return denuncias();
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.warning,
                    color: Color.fromARGB(255, 255, 251, 42),
                  )),
            ],
            title: Stack(
              children: [
                Text(
                  elem['nombre'],
                  style: GoogleFonts.amaranth(
                    fontSize: 28,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = const Color.fromARGB(172, 47, 47, 47),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  elem['nombre'],
                  style: GoogleFonts.amaranth(
                    fontSize: 28,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            backgroundColor: const Color.fromARGB(252, 232, 232, 232),
            flexibleSpace: FlexibleSpaceBar(
              background: _carusel(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _cuerpo(elem);
            }, childCount: 1),
          ),
        ],
      ),
    );
  }

  Widget disponible(dynamic elem) {
    return Stack(
      children: [
        Text(
          abierto ? 'Disponible' : 'Cerrado',
          style: GoogleFonts.amaranth(
            fontSize: 20,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color.fromARGB(198, 56, 56, 56),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          abierto ? 'Disponible' : 'Cerrado',
          style: GoogleFonts.amaranth(
            fontSize: 20,
            color: abierto
                ? const Color.fromARGB(255, 66, 245, 95)
                : const Color.fromARGB(255, 255, 163, 88),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _cuerpo(dynamic elem) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch
      children: [
        if (elem['descripcion'] != '') ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ListTile(
              // title: const Text('descripción'),
              subtitle: Text(
                elem['descripcion'],
                textAlign: TextAlign.start,
                style: GoogleFonts.karla(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: const Color.fromARGB(255, 94, 94, 94),
                ),
              ),
            ),
          ),
        ],
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              elem['precio'] + ' Bs',
              textAlign: TextAlign.center,
              style: GoogleFonts.fjallaOne(
                fontSize: 35,
              ),
            ),
            Container(
              width: 0.5,
              height: 45,
              color: const Color.fromARGB(221, 110, 110, 110),
            ),
            likeButtom(elem),
          ],
        ),
        const Divider(),
        Center(child: Text('Comentarios (${invertirComent.length})')),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 5),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            tileColor: const Color.fromARGB(255, 224, 224, 224),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) {
                  return contenidoComentarios();
                },
              );
            },
            title: invertirComent.isNotEmpty
                ? Text(invertirComent[0]['comentario'])
                : null,
            leading: invertirComent.isNotEmpty
                ? invertirComent[0]['url'] != ''
                    ? CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          invertirComent[0]['url'],
                        ),
                      )
                    : CircleAvatar(
                        radius: 18,
                        child: Text(
                          invertirComent[0]['nombre']
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      )
                : null,
            trailing: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
        const Divider(),
        //    PROPIEDAD
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: Text(
                'Tienda de origen..',
                style: GoogleFonts.karla(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 50, 50, 50),
                ),
              ),
            ),
          ],
        ),
        Container(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _propiedad,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return datosPropiedad(snapshot.data!);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // Por defecto, muestra un loading spinner
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
        const Divider(
          height: 8,
        ),

        const Divider(
          height: 8,
        ),
        // Container(
        //   height: 100,
        //   child: ListView(
        //     children: [
        //       _matrizImg(listaProductosPropiedad),
        //       Text('Productos similares'),
        //       _matrizImg(similares),
        //       Text('misma Categoria'),
        //       _matrizImg(mismaCategoria),
        //     ],
        //   ),
        // )
        listasCards(listaProductosPropiedad),
        Visibility(
          visible: similares.isNotEmpty ? true : false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Productos Similares",
                textAlign: TextAlign.center,
                style: GoogleFonts.fjallaOne(
                  fontSize: 24,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewInicio(
                                tipo: 'sinCategoria', lista: similares)));
                  },
                  icon: const Icon(Icons.arrow_forward_sharp))
            ],
          ),
        ),
        proSimilar(similares),
        Visibility(
          visible: mismaCategoria.isNotEmpty ? true : false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Explore productos de la misma categoria",
                textAlign: TextAlign.center,
                style: GoogleFonts.fjallaOne(
                  fontSize: 18,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewInicio(
                                tipo: 'sinCategoria', lista: mismaCategoria)));
                  },
                  icon: const Icon(Icons.arrow_forward_sharp))
            ],
          ),
        ),
        mismaCate(mismaCategoria),
        const SizedBox(
          height: 40,
        )
      ],
    );
  }

  Widget contenidoComentarios() {
    return Container(
      height: MediaQuery.of(context).size.height * 6,
      width: MediaQuery.of(context).size.width * 1,
      color: MediaQuery.of(context).viewInsets.bottom == 0
          ? Colors.white
          : Colors.black26,
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    "Comentarios",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Divider(thickness: 1),
              // Expanded(child: comentarios),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 55),
                  child: comentarios(),
                ),
                // Center(
                //   child: Text(
                //     'Aun no hay comentarios..',
                //     style: TextStyle(fontSize: 18),
                //   ),
                // ),
              ),
            ],
          ),
          botonEnviarComent()
        ],
      ),
    );
  }

  Widget comentarios() {
    return ListView.builder(
        itemCount: invertirComent.isEmpty ? 0 : invertirComent.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: invertirComent[index]['url'] != ''
                  ? CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        invertirComent[index]['url'],
                      ),
                    )
                  : CircleAvatar(
                      radius: 22,
                      child: Text(
                        invertirComent[0]['nombre']
                            .substring(0, 1)
                            .toUpperCase(),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
              title: Text(invertirComent[index]['nombre']),
              // ' - ' +
              // widget.producto['comentarios'][index]['fecha']
              //     .toString()
              //     .substring(5, 10)),
              subtitle: Text(invertirComent[index]['comentario']),
              trailing: invertirComent[index]['id_u'] ==
                      Constant.shared.dataUser['_id']
                  ? _myPopMenu(
                      invertirComent[index]['_id'], invertirComent[index])
                  : null);
        });
  }

  Widget _myPopMenu(id, data) {
    return PopupMenuButton(
        icon: const Icon(
          Icons.keyboard_control_rounded,
          color: Color.fromARGB(255, 36, 36, 36),
          size: 35,
        ),
        onSelected: (value) {
          if (value == 1) {
            deleteComent(id, data);
          }
        },
        itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                        child: Icon(Icons.delete),
                      ),
                      Text('Eliminar')
                    ],
                  )),
            ]);
  }

  Future deleteComent(idC, data) async {
    var url = Constant.shared.urlApi +
        "/produc/deleteComentario?idP=" +
        widget.producto['_id'] +
        "&idC=" +
        idC;
    var response = await http
        .post(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          print('borrado coment');
          invertirComent.remove(data);
          widget.producto['comentarios'].remove(data);
          Navigator.of(context).pop();
        });
      }
    }
  }

  TextEditingController _controller = TextEditingController();
  bool isButtonDisabled = false;
  Widget botonEnviarComent() {
    return Align(
      alignment: MediaQuery.of(context).viewInsets.bottom == 0
          ? Alignment.bottomCenter
          : Alignment.topCenter,
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Padding(
                    padding: MediaQuery.of(context).viewInsets.bottom == 0
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 55,
                      child: Card(
                        margin:
                            const EdgeInsets.only(left: 2, right: 2, bottom: 8),
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
                            onChanged: (value) {},
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Comentario",
                              contentPadding: EdgeInsets.all(5),
                            ),
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
                            if (!isButtonDisabled) {
                              if (_controller.text != '') {
                                enviarComentarios(_controller.text);
                              }
                            }
                          },
                          icon: const Icon(Icons.send_sharp),
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

  Widget _botonesGestion(dynamic item, prop) {
    return Visibility(
      visible:
          Constant.shared.dataUser['_id'] == item['id_user'] ? false : true,
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: BoxDecoration(
          color: const Color.fromARGB(215, 191, 191, 191),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(-3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: TextButton.icon(
                onPressed: () {
                  crearUrl();
                },
                icon: const Icon(Icons.share),
                label: const Text("Compartir"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(129, 199, 132, 1),
                  side: BorderSide(color: Colors.green.shade900, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: TextButton.icon(
                onPressed: () {
                  // ZonHorUser(prop);
                  // showModalBottomSheet(
                  //     backgroundColor: Colors.transparent,
                  //     context: context,
                  //     elevation: 200,
                  //     builder: (builder) => _botoomSheet(prop));
                  crearContact(prop);
                },
                icon: const Icon(Icons.phone),
                label: const Text("contactar"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade300,
                  side: BorderSide(color: Colors.green.shade900, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            // SizedBox(
            //   width: 2,
            // ),
            Visibility(
              visible: prop['entregas'] == 'habilitado' ? true : false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: TextButton.icon(
                  onPressed: () {
                    obtenerCerrado(horarioApi);
                    if (abierto) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GestionPedido(
                                    propiedad: prop,
                                    producto: widget.producto,
                                  ))).then((value) => setState(() {
                            selecionListas();
                          }));
                    } else {
                      ToastNotification.toastNotificationError(
                          'El local esta cerrado o fuera de servicio', context);
                    }
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("pedido"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green.shade300,
                    side: BorderSide(color: Colors.green.shade900, width: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botoomSheet(prop, context2) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconCreation(
                      'images/whatssap.png', 50, "WhatsApp", 1, prop, context2),
                  const SizedBox(width: 40),
                  _iconCreation(
                      'images/llama.png', 47, "Marcar", 2, prop, context2),
                  const SizedBox(width: 40),
                  _iconCreation(
                      'images/message.png', 47, "Mensaje", 3, prop, context2),
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
    );
  }

  Widget _iconCreation(
      image, double tam, String text, double function, prop, context2) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (function == 1) {
              abrirWhatssap();
            } else if (function == 2) {
              launch('tel://$telefono');
            } else if (function == 3) {
              ZonHorUser(prop);
              Navigator.pop(context2);
            }
          },
          child: Image.asset(
            image,
            width: tam,
            height: tam,
            //color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  abrirWhatssap() async {
    var number = "+59170452262";
    launch("https://wa.me/${number}?text=Hello");
  }

  Widget datosPropiedad(dynamic items) {
    return Stack(children: <Widget>[
      CachedNetworkImage(
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        imageUrl: items['img_prop'][0]['Url'],
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          size: 20.0,
        ),
        fadeOutDuration: const Duration(seconds: 1),
        fadeInDuration: const Duration(seconds: 2),
      ),
      Container(
        height: 120.0,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.grey.withOpacity(0.0),
                  Colors.black,
                ],
                stops: [
                  0.0,
                  1.0
                ])),
      ),
      Positioned(
        top: 8,
        left: 50,
        child: SlideInLeft(
          duration: const Duration(seconds: 4),
          child: Text(
            items['nombre'],
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 5,
        left: 30,
        child: TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PropiedadPageView(propiedad: items)));
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade400,
            side: BorderSide(color: Colors.green.shade400, width: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Text(
            "Visitar",
          ),
        ),
      ),
      Positioned(
        bottom: 5,
        right: 10,
        child: Visibility(
          visible: horarioFinal != '',
          child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.70,
                child: Column(
                  children: [
                    const Text(
                      'Horarios de atención ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SlideInLeft(
                      duration: const Duration(seconds: 4),
                      child: Text(
                        horarioFinal,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      )
    ]);
  }

  // Widget horarios() {
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: vec.length,
  //     itemBuilder: (context, index) {
  //       return Text(
  //           '${vec[index].substring(0, 5)}  a  ${vec[index].substring(6, 11)}');
  //     },
  //   );
  // }

  Widget listasCards(listas) {
    return Column(
      children: [
        Visibility(
          visible: listas != null,
          child: Center(
            child: Text(
              "Mas productos de la tienda",
              textAlign: TextAlign.center,
              style: GoogleFonts.fjallaOne(
                fontSize: 28,
              ),
            ),
          ),
        ),
        const Divider(),
        StaggeredGridView.countBuilder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          staggeredTileBuilder: (index) => const StaggeredTile.count(2, 3),
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: const EdgeInsets.all(1),
          itemBuilder: (context, index) {
            return cards(listas[index]);
          },
          itemCount: listas == null ? 0 : listas.length,
        ),
      ],
    );
  }

  Widget proSimilar(datosList) {
    return Visibility(
      visible: datosList.length > 0 ? true : false,
      child: Container(
        width: double.infinity,
        height: 200,
        child: StaggeredGridView.countBuilder(
            scrollDirection: Axis.horizontal,
            staggeredTileBuilder: (index) => const StaggeredTile.count(2, 1.5),
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 3,
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: datosList.length >= 15 ? 15 : datosList.length,
            itemBuilder: (context, index) {
              return index != 9
                  ? cards(datosList[index])
                  : Container(
                      child: const Center(
                      child: Text('ver mas'),
                    ));
            }),
      ),
    );
  }

  Widget mismaCate(datosList) {
    return Visibility(
      visible: datosList.length > 0 ? true : false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Container(
          width: double.infinity,
          height: 350,
          child: StaggeredGridView.countBuilder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              staggeredTileBuilder: (index) => index % 3 == 0
                  ? const StaggeredTile.count(2, 1.5)
                  : const StaggeredTile.count(2, 2),
              crossAxisCount: 4,
              mainAxisSpacing: 15,
              crossAxisSpacing: 8,
              itemCount: datosList.length >= 15 ? 15 : datosList.length,
              itemBuilder: (context, index) {
                return cards(datosList[index]);
              }),
        ),
      ),
    );
  }

  Widget cards(dynamic item) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => ProductoView(
                          producto: item,
                        )));
          },
          child: CachedNetworkImage(
            imageUrl: item['img_produc'][0]['Url'],
            imageBuilder: (context, imageProvider) => Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  const BoxShadow(
                    blurRadius: 3,
                    color: Color(0x64000000),
                    offset: Offset(1, 2),
                  )
                ],
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: 200,
              height: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    children: [
                      Text(
                        item['nombre'],
                        style: GoogleFonts.amaranth(
                          fontSize: 20,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = const Color.fromARGB(172, 47, 47, 47),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        item['nombre'],
                        style: GoogleFonts.amaranth(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(175, 158, 158, 158)),
                    child: Center(
                        child: Text(
                      item['precio'],
                      style: letraMostrar2,
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 70,
              height: 30,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 253, 93, 93),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 18,
                  ),
                  Text(
                    item['numLikes'].toString(),
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            )),
      ],
    );
  }

  Widget _carusel() {
    return ListView(
      children: <Widget>[
        Container(
          height: 320,
          color: const Color.fromARGB(255, 80, 80, 80),
          width: double.infinity,
          child: CarouselSlider.builder(
            unlimitedMode: true,
            controller: _sliderController,
            slideBuilder: (index) {
              return Container(
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  height: MediaQuery.of(context).size.width * 1,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: widget.producto['img_produc'][index]['Url'],
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black)),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    size: 40.0,
                  ),
                  fadeOutDuration: const Duration(seconds: 1),
                  fadeInDuration: const Duration(seconds: 2),
                ),
              );
            },
            slideTransform: const AccordionTransform(),
            slideIndicator: CircularWaveSlideIndicator(
              padding: const EdgeInsets.only(bottom: 32),
              indicatorBorderColor: Colors.black,
            ),
            itemCount: widget.producto['img_produc'].length,
            initialPage: 0,
            enableAutoSlider:
                widget.producto['img_produc'].length > 1 ? true : false,
          ),
        ),
      ],
    );
  }

  Widget likeButtom(elem) {
    // print(isLiked);
    // String auxi = elem['likes'].toString();
    return TextButton.icon(
      onPressed: () async {
        if (isRedundentClick(DateTime.now())) {
          //print('hold on, processing');
          return;
        }
        if (isLiked == false) {
          addLike(elem['_id']);
          setState(() {
            isLiked = !isLiked;
          });
        } else {
          restLike(elem['_id']);
          setState(() {
            isLiked = !isLiked;
          });
        }
      },
      icon: isLiked == true
          ? Icon(
              Icons.favorite,
              color: Colors.purpleAccent.shade400,
              size: 30,
            )
          : const Icon(
              Icons.favorite_border,
              color: Colors.black87,
              size: 30,
            ),
      label: isLiked == true
          ? Text((elem['numLikes'] + a).toString())
          : Text((elem['numLikes'] - b).toString()),
    );
  }

  Future addLike(String id) async {
    String url = Constant.shared.urlApi +
        "/produc/likes?id_u=" +
        Constant.shared.dataUser['_id'];
    final res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'id_producto': id,
      'categoria': widget.producto['categoria'],
    });
    if (res.statusCode == 200) {
      Constant.shared.listLikes = json.decode(res.body)['lista'];
      Constant.shared.interacciones = json.decode(res.body)['interacciones'];
      //print(json.decode(res.body));
    }
  }

  Future restLike(String id) async {
    String url = Constant.shared.urlApi +
        "/produc/deletelike?id_u=" +
        Constant.shared.dataUser['_id'] +
        "&id_p=" +
        id;
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    });
    if (res.statusCode == 200) {
      print(json.decode(res.body));
      Constant.shared.listLikes = json.decode(res.body)['lista'];
    }
  }

  //Compartir en redes Sociales....
  void crearUrl() async {
    String producto = widget.producto['_id'];
    late String links = '/viewPrd?pr=$producto';
    createDynamicLink(false, links);
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  String? _linkMessage;
  var kUriPrefix = 'https://altoqueapp.page.link';
  Future<void> createDynamicLink(bool short, String link) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse(kUriPrefix + link),
        uriPrefix: kUriPrefix,
        // socialMetaTagParameters: SocialMetaTagParameters(
        //     description: 'te interesa este producto?',
        //     imageUrl: Uri.parse(widget.producto['img_produc'][0]['Url']),
        //     title: 'Al Toque'),
        androidParameters: const AndroidParameters(
            packageName: "com.AlToque.entregas", minimumVersion: 0));

    Uri url;
    url = await dynamicLinks.buildLink(parameters);
    setState(() {
      _linkMessage = url.toString();
    });
    //compartir(_linkMessage);
    log(_linkMessage.toString());
    crearShare(_linkMessage);
  }

  crearShare(link) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollable: false,
            content: Container(
              height: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            share(link);
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.link,
                                size: 50,
                                color: Color.fromARGB(255, 92, 247, 183),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Compartir solo\n enlace',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 92, 247, 183)),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 1,
                        color: Colors.black87,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            compartir(link);
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.photo_album_outlined,
                                  size: 50,
                                  color: Color.fromARGB(255, 175, 117, 255)),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Compartir contenido\n en redes sociales',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 175, 117, 255)),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  crearContact(prop) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              scrollable: false,
              content:
                  SizedBox(height: 145, child: _botoomSheet(prop, context)));
        });
  }

  Future<void> share(cadena) async {
    await FlutterShare.share(
        title: '',
        text: 'Al Toque tiene un producto que puede interesarte',
        linkUrl: cadena,
        chooserTitle: 'ejemplo');
  }

  void compartir(cadena) async {
    final urlImg = Uri.parse(widget.producto['img_produc'][0]['Url']);
    final response = await http.get(urlImg);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/img.jpg';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles([path],
        text: 'Al Toque\nTenemos algo que puede interesarte\n$cadena');
  }

  Widget denuncias() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width * 1,
      color: MediaQuery.of(context).viewInsets.bottom == 0
          ? Colors.white
          : Colors.black26,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DenunciasGestion(
                        id_u: Constant.shared.dataUser['_id'],
                        id_p: widget.producto['_id'],
                        clase: 'producto'))),
            title: const Text('Reportar producto'),
            subtitle: const Text(
                'Encuentras algo extraño en este producto? reportala con nosotros para revisarla y realizar acciones deacuerdo a su incidencia'),
            leading: const Icon(
              Icons.report_outlined,
              size: 40,
            ),
          )
        ],
      ),
    );
  }
}
