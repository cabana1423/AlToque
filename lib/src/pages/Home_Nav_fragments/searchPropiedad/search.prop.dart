import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/searchPropiedad/mostrar.propis.dart';

class SearchP extends StatefulWidget {
  final lista;

  SearchP({Key? key, @required this.lista}) : super(key: key);
  @override
  _SearchPState createState() => _SearchPState();
}

class _SearchPState extends State<SearchP> {
  late double mylat = 0;
  late double mylong = 0;
  List? data;

  @override
  void initState() {
    _getCurrentLocation();
    setState(() {
      data = widget.lista;
      datanew = widget.lista;
    });

    super.initState();
  }

  void _getCurrentLocation() {
    var position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position position2) {
      mylat = position2.latitude;
      mylong = position2.longitude;
      print(mylat);
    });
  }

  bool estado = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => MostrarProp(
                              palabra: value, lat: mylat, long: mylong)));
                },
                autofocus: true,
                onChanged: (value) {
                  if (value.length > 0) {
                    setState(() {
                      estado = true;
                    });
                  } else
                    estado = false;
                  _runFilter(value);
                },
                decoration: InputDecoration(
                  hintText: 'buscar',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 206, 206, 206),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 216, 216, 216),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(
                    Icons.arrow_back,
                    color: Color(0xFF95A1AC),
                  ),
                ),
              ),
            ),
            Expanded(
              child: estado == true
                  ? ListView.builder(
                      itemCount: datanew.length,
                      itemBuilder: (context, index) => Card(
                        color: Color.fromARGB(255, 255, 255, 255),
                        elevation: 1,
                        margin: EdgeInsets.symmetric(vertical: 0.54),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => MostrarProp(
                                        palabra: datanew[index]['nombre'],
                                        lat: mylat,
                                        long: mylong)));
                          },
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(datanew[index]['nombre']),
                            ),
                            // subtitle:
                            //     Text((datanew[index]["descripcion"].toString())),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      'no hay resultados',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List datanew = [];
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = data!;
    } else {
      results = data!
          .where((producto) => producto["nombre"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      datanew = results;
    });
  }
}
