import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/chat/Individual_page.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class HomeScreen extends StatefulWidget {
  // final List<ChatModel> chatmodels;
  // final ChatModel sourcechat;
  final String id_u;

  HomeScreen({
    Key? key,
    required this.id_u,
    /* required this.sourcechat*/
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //late List data = [];
  late List data = [];

  Future<String> getJSONData() async {
    var url = Constant.shared.urlApi +
        "/chat/salaschat/?id=" +
        Constant.shared.dataUser['_id'];
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          data = json.decode(response.body);
          //print(data);
        });
      }
    }
    return "Successfull";
  }

  // Future<String> getJSONData() async {
  //   var url = Constant.shared.urlApi +
  //       "/chat/list/?id_u=" +
  //       Constant.shared.dataUser['_id'];
  //   var response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (json.decode(response.body).length != 0) {
  //     if (this.mounted) {
  //       setState(() {
  //         data = json.decode(response.body);
  //         salas = data[0]["salas"];
  //         //print(salas);
  //         for (int i = 0; i < salas.length; i++) {
  //           String idSala = salas[i]['id_sala'];
  //           //print(idSala);
  //           datos_sala(idSala);
  //         }
  //         //print(datoSala);
  //       });
  //     }
  //   }
  //   return "Successfull";
  // }

  // late List datos = [];
  // late List datoSala = [];
  // Future datos_sala(idSala) async {
  //   var url = Constant.shared.urlApi + "/chat/?id_s=" + idSala;
  //   var response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (json.decode(response.body).length != 0) {
  //     datos = json.decode(response.body)[0]["messages"];
  //     var aux = {
  //       'mensaje': datos[datos.length - 1]["mensaje"],
  //       'time': datos[datos.length - 1]["time"]
  //     };
  //     if (this.mounted) {
  //       setState(() {
  //         datoSala.add(aux);
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getJSONData();
  }

  //CONNECION SOCKET

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensajeria"),
        // actions: [
        //   IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        //   PopupMenuButton<String>(onSelected: (value) {
        //     //print(value);
        //   }, itemBuilder: (BuildContext context) {
        //     return [
        //       PopupMenuItem(child: Text("1"), value: "1"),
        //       PopupMenuItem(child: Text("2"), value: "2"),
        //     ];
        //   })
        // ],
      ),
      body: data.length == 0
          ? Center(child: Text('aun no hay mensajes'))
          : Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: ListView.builder(
                  itemCount: data.length == 0 ? 0 : data.length,
                  itemBuilder: (context, index) => _customCard(data[index])),
            ),
    );
  }

  Widget _customCard(dynamic chat) {
    return InkWell(
      onTap: () {
        pushNewScreen(
          context,
          screen: IndividualPage(
              zt: '',
              id_u: Constant.shared.dataUser['_id'],
              nombre: chat['nombre_ori'],
              url: '',
              id_2: chat['id_2'],
              nombre2: chat['nombre'],
              url2: chat['url'],
              telefono_2: '',
              id_prop: chat['id_prop_d'],
              tituloProd: '',
              imgProd: '',
              ultm: chat['ultmconec'] ?? ''),
          withNavBar: false, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.fade,
        );
      },
      child: Column(
        children: [
          ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(chat["url"]),
                radius: 25,
              ),
              title: Text(
                chat['nombre'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.done_all),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    chat["mensaje"],
                    style: TextStyle(fontSize: 13),
                  )
                ],
              ),
              trailing: Text(
                chat["time"].toString().substring(11, 16),
              )),
          Divider()
        ],
      ),
    );
  }
}
