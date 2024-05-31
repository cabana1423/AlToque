import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class SaveProduct extends StatefulWidget {
  SaveProduct({Key? key}) : super(key: key);

  @override
  State<SaveProduct> createState() => _SaveProductState();
}

class _SaveProductState extends State<SaveProduct> {
  List productos = [];
  Future saveProductos() async {
    var listaSave = [];
    for (var i = 0; i < Constant.shared.listLikes.length; i++) {
      listaSave.add(Constant.shared.listLikes[i]['id_producto']);
    }
    // listaSave.join(',');
    print(listaSave);
    var url = Constant.shared.urlApi + "/produc/save";
    var response = await http.post(Uri.parse(url), headers: {
      "Accept": "application/json"
    }, body: <String, String>{
      'save': listaSave.join(','),
    });
    if (response.statusCode == 200) {
      if (this.mounted) {
        // print(json.decode(response.body));
        setState(() {
          productos = json.decode(response.body);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print(Constant.shared.listLikes);
    saveProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elementos guardados'),
      ),
      body: cuerpo(),
    );
  }

  Widget cuerpo() {
    return Column(
      children: [Expanded(child: buildListView())],
    );
  }

  Widget buildListView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: RefreshIndicator(
        onRefresh: () => saveProductos(),
        child: StaggeredGridView.countBuilder(
            staggeredTileBuilder: (index) => StaggeredTile.count(2, 3),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(10.0),
            itemCount: productos.length == 0 ? 0 : productos.length,
            itemBuilder: (context, index) {
              return cards(productos[index]);
            }),
      ),
    );
  }

  var letraMostrar2 = GoogleFonts.amaranth(fontSize: 20, color: Colors.white);
  Widget cards(dynamic item) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductoView(producto: item)))
                .then((value) => setState(() {
                      saveProductos();
                      //FocusScope.of(context).unfocus();
                    }));
          },
          child: CachedNetworkImage(
            imageUrl: item['img_produc'][0]['Url'],
            imageBuilder: (context, imageProvider) => Container(
              width: 180,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color(0x64000000),
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: 150,
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
                            ..color = Color.fromARGB(172, 47, 47, 47),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        item['nombre'],
                        style: GoogleFonts.amaranth(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
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
                        color: Color.fromARGB(175, 158, 158, 158)),
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
              decoration: BoxDecoration(
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
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 18,
                  ),
                  Text(
                    item['numLikes'].toString(),
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            )),
      ],
    );
  }
}
