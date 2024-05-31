import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class MostrarProp extends StatefulWidget {
  final palabra;
  final lat;
  final long;

  MostrarProp({Key? key, @required this.palabra, this.lat, this.long})
      : super(key: key);

  @override
  State<MostrarProp> createState() => _MostrarPropState();
}

class _MostrarPropState extends State<MostrarProp> {
  List? dataDist;
  Future<String> propiedades_por_dist() async {
    var url = Constant.shared.urlApi +
        "/prop/dist?" +
        "lat=" +
        widget.lat.toString() +
        "&long=" +
        widget.long.toString() +
        "&palabra=" +
        widget.palabra;
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        dataDist = json.decode(response.body) /*['propiedad']*/;
        print(dataDist);
      });
    }
    return "Successfull";
  }

  @override
  void initState() {
    propiedades_por_dist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
