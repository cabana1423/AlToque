import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/configuraciones/EliminarCuenta.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/Providers.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ConfiguracionesApp extends StatefulWidget {
  const ConfiguracionesApp({super.key});

  @override
  State<ConfiguracionesApp> createState() => _ConfiguracionesAppState();
}

class _ConfiguracionesAppState extends State<ConfiguracionesApp> {
  bool _cambiarTema = false;
  @override
  void initState() {
    super.initState();
    tema();
  }

  Future<void> tema() async {
    final boleano = await UserSecureStorages.GetTheme();
    if (boleano != '') {
      bool myBool = boleano.toLowerCase() == 'true';
      _cambiarTema = myBool;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoGlobal = Provider.of<EstadoGlobal>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('cambiar tema'),
            trailing: Switch(
              value: _cambiarTema,
              onChanged: (value) {
                estadoGlobal.setBrillo(value);
                setState(() {
                  _cambiarTema = value;
                  // print(_cambiarTema);
                });
              },
            ),
          ),
          const Divider(
            height: 1,
          ),
          ListTile(
            title: Text('eliminar cuenta'),
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EliminarCuenta()));
            },
          ),
          const Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
