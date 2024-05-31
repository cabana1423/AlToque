// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gowin/src/pages/chat/Individual_page.dart';
import 'package:gowin/src/pages/gestiones/gestionar.denuncias.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:latlong2/latlong.dart' as ltln;
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PropiedadPageView extends StatefulWidget {
  final propiedad;

  PropiedadPageView({
    Key? key,
    @required this.propiedad,
  }) : super(key: key);

  @override
  _PropiedadPageViewState createState() => _PropiedadPageViewState();
}

class _PropiedadPageViewState extends State<PropiedadPageView> {
  var styloText = GoogleFonts.fjallaOne(
    fontSize: 20,
    color: const Color.fromARGB(255, 255, 255, 255),
  );
  var styleText2 = GoogleFonts.titilliumWeb(
    fontSize: 20,
    color: const Color.fromARGB(255, 3, 3, 3),
  );
  // var wrape= MediaQuery.of(context).size;

  // late final Future<Prop> propiedad;
  List? data;
  List? listaProductos;
  CarouselSliderController? _sliderController;
  //Mapas
  late double lat = 0;
  late double long = 0;
  List aux = [];
  void initState() {
    // propiedad = getJSONData();
    getJSONDataProducts();
    if (widget.propiedad['horario'] != null &&
        widget.propiedad['horario'] != '') {
      obtenerCerrado(widget.propiedad['horario']);
    }

    _sliderController = CarouselSliderController();
    setState(() {
      data = widget.propiedad['img_prop'];
      print(widget.propiedad);
    });
    super.initState();
  }

  bool abierto = true;
  var horarioFinal = '';
  void obtenerCerrado(String horarios) {
    var vec = horarios.split(',');
    for (var i = 0; i < vec.length; i++) {
      setState(() {
        abierto = verificarHoraEnRango(
            vec[i].substring(0, 5), vec[i].substring(6, 11));
        horarioFinal =
            '$horarioFinal ${vec[i].substring(0, 5)} a ${vec[i].substring(6, 11)}  ';
      });
    }
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

  Future getJSONDataProducts() async {
    String url =
        Constant.shared.urlApi + "/produc/?id_p=" + widget.propiedad['_id'];
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          listaProductos = json.decode(response.body);
        });
      }
    } else {
      Navigator.pop(context);
      ToastNotification.toastNotificationError(
          json.decode(response.body)['msn'], context);
    }
  }

  //abrir  GOOGLE MAPS

  void _launchURL(l1, l2) async {
    String _url = "geo:$l1,$l2?z=16&q=$l1,$l2(Position)";
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  //    valores pageview
  String auxiliar = 'prod';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body(widget.propiedad)),
    );
  }

  Widget _body(dynamic item) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          floating: false,
          pinned: false,
          expandedHeight: 390,
          //title: Text(item['nombre']),
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          flexibleSpace: FlexibleSpaceBar(
            //title: Text(item['nombre']),
            background: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Stack(
                    children: [
                      _carusel(item),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _nombre(item)),
                      ),
                    ],
                  ),
                ),
                //_cuerpo(item),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
                  child: pageViewdatosPropiedad(item),
                ),
              ],
            ),
          ),
        ),
        //    datos de la empresa
        SliverFixedExtentList(
            delegate: SliverChildListDelegate([
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(170, 144, 143, 143),
                      offset: Offset(0, -6),
                      blurRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: disponible(),
                ),
                //   child: Center(child: Text('Productos de la tienda')
              ),
              // )
            ]),
            itemExtent: 50),
        auxiliar == 'prod'
            ? listaProductos != null && listaProductos!.isEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            'No hay productos registrados',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                      childCount: 1,
                    ),
                  )
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return inventario(listaProductos![index]);
                      },
                      childCount:
                          listaProductos == null ? 0 : listaProductos!.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 5),
                  )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return auxiliar == 'mapa'
                        ? mapaInformacion(item)
                        : informacionPropiedad(item);
                  },
                  childCount: 1,
                ),
              ),
      ],
    );
  }

  Widget disponible() {
    return Stack(
      children: [
        Text(
          abierto ? 'Tienda Abierta' : 'Tienda cerrada',
          style: GoogleFonts.amaranth(
            fontSize: 22,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color.fromARGB(198, 56, 56, 56),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          abierto ? 'Tienda Abierta' : 'Tienda cerrada',
          style: GoogleFonts.amaranth(
            fontSize: 22,
            color: abierto
                ? const Color.fromARGB(255, 66, 245, 95)
                : Color.fromARGB(255, 253, 91, 42),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  final pageViewController =
      PageController(initialPage: 1, viewportFraction: 0.42);
  Widget pageViewdatosPropiedad(item) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: PageView(
        controller: pageViewController,
        onPageChanged: (int page) {
          setState(() {
            if (page == 0) {
              auxiliar = 'info';
            } else if (page == 1) {
              auxiliar = 'prod';
            } else if (page == 2) {
              auxiliar = 'mapa';
            }
          });
        },
        physics: const BouncingScrollPhysics(),
        children: [
          contenido('images/masInfo.png', item, 'Información', efect2, 0),
          contenido('images/contactanos.png', item, 'Productos', efect4, 1),
          contenido('images/ubicacion.png', item, 'Ubicanos', efect3, 2),
        ],
      ),
    );
  }

  Widget contenido(image, item, texto, efect, page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: InkWell(
        onTap: () {
          pageViewController.animateToPage(page,
              duration: const Duration(microseconds: 3350),
              curve: Curves.bounceInOut);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 89, 128),
              gradient: efect,
              boxShadow: [
                const BoxShadow(
                  color: Color.fromARGB(170, 144, 143, 143),
                  offset: Offset(3, 6),
                  blurRadius: 5,
                ),
              ],
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  image,
                  width: 40,
                  height: 40,
                ),
                Text(
                  texto,
                  style: styloText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget informacionPropiedad(item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // Text(
          //   item['nombre'],
          //   style: styleText2,
          // ),
          ListTile(
              onTap: () {
                ZonHorUser();
              },
              title: const Text('Contactar'),
              subtitle: const Text('contactanos mediante el chat'),
              leading: const Icon(Icons.message),
              trailing: const Icon(Icons.navigate_next)),
          const Divider(),
          ListTile(
            // onTap: () {
            //   ZonHorUser();
            // },
            title: const Text('Horarios de atención'),
            subtitle: Text(horarioFinal),
            leading: const Icon(Icons.access_time),
            // trailing: const Icon(Icons.navigate_next)
          ),
          const Divider(),
          ListTile(
              onTap: () {
                generarLink();
              },
              title: const Text('Compartir'),
              subtitle:
                  Text('Comparte ' + item['nombre'] + ' en tus redes sociales'),
              leading: const Icon(Icons.share),
              trailing: const Icon(Icons.navigate_next)),
          const Divider(),
          ListTile(
            title: const Text('Propietario'),
            subtitle: Text(item['propietario']),
            leading: const Icon(Icons.perm_contact_cal_sharp),
          ),
          const Divider(),
          ListTile(
              onTap: () {
                var tel = item['telefono'];
                // ignore: deprecated_member_use
                launch('tel://$tel');
              },
              title: const Text('Telefono'),
              subtitle: Text(item['telefono']),
              leading: const Icon(Icons.phone_android),
              trailing: const Icon(Icons.navigate_next)),
          const Divider(),
          ListTile(
            title: const Text('NIT'),
            subtitle: Text(item['nit'].toString()),
            leading: const Icon(Icons.numbers),
          ),
          const Divider(),
          ListTile(
            title: const Text('reportar'),
            subtitle: const Text(
                'tienes algo que comunicar sobre esta tienda? reportala con nosotros para ayudarnos a revisarla y realizar acciones deacuerdo a su incidencia'),
            leading: const Icon(
              Icons.report_outlined,
              size: 40,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => DenunciasGestion(
                          id_u: Constant.shared.dataUser['_id'],
                          id_p: widget.propiedad['_id'],
                          clase: 'propiedad')));
            },
          ),
        ],
      ),
    );
  }

  void generarLink() {
    String propiedad = widget.propiedad['_id'];
    late String links = '/viewProp?pr=$propiedad';
    createDynamicLink(links);
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  String? _linkMessage;
  var kUriPrefix = 'https://gowinlinks.page.link';
  Future<void> createDynamicLink(String link) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse(kUriPrefix + link),
        uriPrefix: kUriPrefix,
        androidParameters: const AndroidParameters(
            packageName: "com.example.gowin", minimumVersion: 0));
    Uri url;
    url = await dynamicLinks.buildLink(parameters);
    _linkMessage = url.toString();
    print(_linkMessage);
    share(_linkMessage);
  }

  Future<void> share(cadena) async {
    await FlutterShare.share(
        title: 'Al Toque', text: '', linkUrl: cadena, chooserTitle: 'ejemplo');
  }

  Widget mapaInformacion(item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: ListTile(
            title: const Text('Direccion'),
            subtitle: Text(item['calle']),
            leading: const Icon(
              Icons.location_city,
              size: 38,
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
          child: SizedBox(
            width: double.infinity,
            height: 150,
            child: mapaMiniatura(item),
          ),
        ),
      ],
    );
  }

  Widget _carusel(dynamic item) {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 110, 110, 110),
            offset: Offset(0, 6),
            blurRadius: 7,
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      width: double.infinity,
      child: CarouselSlider.builder(
        unlimitedMode: true,
        controller: _sliderController,
        slideBuilder: (index) {
          return Container(
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: data![index]['Url'],
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image:
                      DecorationImage(fit: BoxFit.cover, image: imageProvider),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                size: 40.0,
              ),
              fadeOutDuration: const Duration(seconds: 4),
              fadeInDuration: const Duration(seconds: 2),
            ),
          );
        },
        slideTransform: const ZoomOutSlideTransform(),
        itemCount: data!.length,
        initialPage: 0,
        autoSliderDelay: const Duration(seconds: 9),
        autoSliderTransitionTime: const Duration(seconds: 2),
        enableAutoSlider: data!.length > 1 ? true : false,
      ),
    );
  }

  Widget mapaMiniatura(item) {
    return Stack(
      children: [
        _mapa(item),
        Positioned(
            top: 1,
            right: 1,
            child: IconButton(
                onPressed: () {
                  _mapazoom(item);
                },
                icon: const Icon(Icons.zoom_out_map_outlined)))
      ],
    );
  }

  _mapazoom(item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollable: false,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  _mapa(item),
                  Positioned(
                    bottom: 1,
                    right: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          Text(
                            'Abrir en ',
                            style: GoogleFonts.mochiyPopOne(
                                color: const Color.fromARGB(255, 27, 27, 27)),
                          ),
                          InkWell(
                            onTap: () {
                              _launchURL(item['location']['coordinates'][1],
                                  item['location']['coordinates'][0]);
                            },
                            child: Image.asset(
                              'images/gmaps.png',
                              width: 120,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _mapa(item) {
    return FlutterMap(
      options: MapOptions(
          center: ltln.LatLng(
              item['location']['coordinates'][1],
              item['location']['coordinates']
                  [0]), // Coordenadas de ejemplo (San Francisco)
          zoom: 17.0,
          minZoom: 0.0,
          maxZoom: 18.0),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: ltln.LatLng(
                  item['location']['coordinates'][1],
                  item['location']['coordinates']
                      [0]), // Coordenadas del marcador
              builder: (ctx) => Container(
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _nombre(dynamic item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
      child: Stack(
        children: [
          Text(
            item['nombre'],
            style: GoogleFonts.fjallaOne(
              fontSize: 30,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..color = const Color.fromARGB(172, 32, 32, 32),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            item['nombre'],
            style: GoogleFonts.fjallaOne(
              fontSize: 30,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  var letraMostrar2 = GoogleFonts.amaranth(fontSize: 20, color: Colors.white);
  Widget inventario(dynamic item) {
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
                    offset: Offset(2, 2),
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
            child: SizedBox(
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

  //      EFECTOS  CAJAS DATOS

  var efect1 = const LinearGradient(
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
      colors: [
        Color.fromARGB(255, 239, 166, 230),
        Color.fromARGB(255, 130, 72, 212),
      ],
      stops: [
        0.0,
        1.0
      ]);
  var efect2 = const LinearGradient(
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
      colors: [
        Color.fromARGB(255, 255, 195, 98),
        Color.fromARGB(255, 241, 106, 39),
      ],
      stops: [
        0.0,
        1.0
      ]);
  var efect3 = const LinearGradient(
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
      colors: [
        Color.fromARGB(255, 109, 244, 208),
        Color.fromARGB(255, 73, 125, 236),
      ],
      stops: [
        0.0,
        1.0
      ]);
  var efect4 = const LinearGradient(
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
      colors: [
        Color.fromARGB(255, 219, 255, 174),
        Color.fromARGB(255, 79, 194, 22),
      ],
      stops: [
        0.0,
        1.0
      ]);

  Future ZonHorUser() async {
    String url =
        Constant.shared.urlApi + "/users/id?id=" + widget.propiedad['id_user'];
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
                  id_2: widget.propiedad['id_user'],
                  nombre2: widget.propiedad['nombre'],
                  url2: widget.propiedad['img_prop'][0]['Url'],
                  telefono_2: widget.propiedad['telefono'],
                  id_prop: widget.propiedad['_id'],
                  ultm: '',
                  imgProd: '',
                  tituloProd: '',
                  zt: zonaH)));
    }
  }
}
