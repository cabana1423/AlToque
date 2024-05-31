import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gowin/src/pages/repartidores/Gestionar.pedido.repartidor.dart';

class ViewDiaListaRepartidor extends StatefulWidget {
  List datos;

  ViewDiaListaRepartidor({super.key, required this.datos});

  @override
  State<ViewDiaListaRepartidor> createState() => _ViewDiaListaRepartidorState();
}

class _ViewDiaListaRepartidorState extends State<ViewDiaListaRepartidor> {
  @override
  void initState() {
    super.initState();
    obtenerLista();
  }

  List data = [];
  void obtenerLista() {
    setState(() {
      data = widget.datos;
      calculo();
      // log(data.toString());
    });
  }

  double sumaFinal = 0;
  void calculo() {
    double suma = 0;
    for (var i = 0; i < widget.datos.length; i++) {
      if (widget.datos[i]['repartidor'] != null) {
        var estdcuent = widget.datos[i]['estado'];
        var estdRep = widget.datos[i]['repartidor']['estado'];
        if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
            (estdcuent == 'entregado' && estdRep == 'entregado') ||
            (estdcuent == 'enviado' && estdRep == 'no entregada')) {
          suma = suma + (double.parse(widget.datos[i]['repartidor']['cuenta']));
        }
      }
    }
    log(sumaFinal.toString());
    setState(() {
      sumaFinal = suma;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: lista(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Container(
              width: 200,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 214, 214, 214),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(sumaFinal.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  var vect = [];
  bool vacio = true;

  Widget lista() {
    return Expanded(
      child: data.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var estdRep = '';
                    var estdcuent = data[index]['estado'];
                    if (data[index]['repartidor'] != null) {
                      estdRep = data[index]['repartidor']['estado'] ?? '';
                    }
                    if ((estdcuent == 'enviado' && estdRep == 'entregado') ||
                        (estdcuent == 'entregado' && estdRep == 'entregado') ||
                        (estdcuent == 'enviado' && estdRep == 'no entregada')) {
                      vacio = false;

                      return cardCuentas(index, context);
                    }
                    if (index == data.length - 1 && vacio == true) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: Text(
                          'Ningun Pedido se a completado este dia',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
            )
          : const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'cargando datos',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }

  var stilo =
      const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold);

  Widget cardCuentas(index, context) {
    DateTime fechaTime = DateTime.parse(data[index]['fecha_reg']);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -0.5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GestionarPedidoRepartidor(
                      tipo: 'repartidor_lista',
                      idNotifi: '',
                      title: '',
                      id_cuenta: data[index],
                      id_tienda: '')),
            );
          },
          title: Text(
            data[index]["nombreTienda"],
            style: stilo,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  data[index]["estado"] == ''
                      ? const Text(
                          'No atendida',
                          style: TextStyle(color: Colors.redAccent),
                        )
                      : Text(data[index]["estado"]),
                  data[index]['repartidor']['estado'] != 'entregado'
                      ? Text(
                          '${data[index]['repartidor']['cuenta']} Bs',
                          style: const TextStyle(color: Colors.red),
                        )
                      : Text(
                          '${data[index]['repartidor']['cuenta']} Bs',
                          style: const TextStyle(color: Colors.green),
                        )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fechaTime.toString().substring(0, 16)),
                  Text(
                    'Pago ${data[index]["tipoDePago"]['tipo'] ?? ''}',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            data[index]["tipoDePago"]['tipo'] == 'En efectivo'
                                ? const Color.fromARGB(255, 150, 83, 244)
                                : const Color.fromARGB(255, 40, 169, 44)),
                  )
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
