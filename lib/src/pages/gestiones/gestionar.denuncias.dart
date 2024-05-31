import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gowin/src/utils.pages/news.PushNotifications.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class DenunciasGestion extends StatefulWidget {
  var clase;
  var id_p;
  var id_u;

  DenunciasGestion({Key? key, @required this.id_u, this.id_p, this.clase})
      : super(key: key);

  @override
  State<DenunciasGestion> createState() => _DenunciasGestionState();
}

class _DenunciasGestionState extends State<DenunciasGestion> {
  bool coneccion = true;
  final Connectivity _connectivity = Connectivity();

  Future postDenuncia(denuncia) async {
    String url = Constant.shared.urlApi +
        "/denun?id_u=" +
        widget.id_u +
        '&id_p=' +
        widget.id_p;
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'clase': widget.clase,
      'denuncia': denuncia
    });
    if (res.statusCode == 200) {
      ToastNotification.toastNotificationSucces('Denuncia realizada', context);
    }
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: cuerpo(),
      ),
    );
  }

  Widget cuerpo() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                'Indica cuales es el problemas con el contenido de la publicacion.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Productos o servicios ilegales'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('Productos o servicios ilegales');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('venta de drogas recreativas o ilegales'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('venta de drogas recreativas o ilegales.');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(' venta de suplementos ingeribles o no seguros,'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('venta de suplementos ingeribles o no seguros,');
            },
          ),
          const Divider(),
          ListTile(
            title:
                const Text('venta o el uso de armas, municiones o explosivos'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia(
                  'venta o el uso de armas, municiones o explosivos');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('venta de animales.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('venta de animales.');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('contenido sexual o productos para adultos'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('contenido sexual o productos para adultos');
            },
          ),
          ListTile(
            title: const Text('estafa, publicacion falsa o no incluye precio'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('estafa, publicacion falsa o no incluye precio');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('contenido ofensivo o dañino'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('contenido ofensivo o dañino');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('otros (especifique)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              enviarDenuncia('otros (especifique)');
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  void enviarDenuncia(text) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
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
                    title: Text(text),
                    leading: const Icon(Icons.check),
                  ),
                  const Divider(),
                  comentario(),
                  botom(text)
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  //comentarios
  String notas = "";
  Widget comentario() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        child: TextFormField(
          minLines:
              4, // any number you need (It works as the rows for the textarea)
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onChanged: (value) {
            notas = value;
          },
          decoration: InputDecoration(
              hintText: 'desea agregar un comentario?',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.green),
              )),
        ),
      ),
    );
  }

  Widget botom(text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.9,
        //botton signIn
        // ignore: deprecated_member_use
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          ),
          onPressed: () {
            if (coneccion) {
              if (notas != '') {
                postDenuncia('$text\n\n$notas');
              } else {
                postDenuncia(text);
              }
            } else {
              Push_Notification.ventanaConeccionInternet(context);
            }
          },
          child: const Text("Enviar", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
