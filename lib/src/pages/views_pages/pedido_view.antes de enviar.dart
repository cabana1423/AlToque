// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/repartidores/utlis.repartidor.dart';
import 'package:gowin/src/utils.pages/loading.dart';
import 'package:gowin/src/utils.pages/news.PushNotifications.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// import 'package:pay/pay.dart';

class PedidoView extends StatefulWidget {
  final datos;
  final cant;
  final prein;
  final total;
  final id_dest;
  final nombre_dest;
  var id_tienda;

  var long;

  var lat;

  PedidoView(
      {Key? key,
      @required this.datos,
      this.prein,
      this.cant,
      this.total,
      this.id_dest,
      this.id_tienda,
      this.long,
      this.lat,
      this.nombre_dest})
      : super(key: key);

  @override
  _PedidoViewState createState() => _PedidoViewState();
}

class _PedidoViewState extends State<PedidoView> {
  final Connectivity _connectivity = Connectivity();
  bool coneccion = true;

  @override
  void initState() {
    super.initState();
    // log('AQUI ESTA COMISION ${widget.datos}');

    obtenercuentas();
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

  double card = 0;
  double efectivo = 0;

  void obtenercuentas() {
    for (var i = 0; i < widget.cant.length; i++) {
      efectivo = efectivo +
          (double.parse(widget.datos[i]['comision']) * widget.cant[i]);
    }
    // log('${efectivo}');
    card = double.parse(widget.total) - efectivo;
    // log(card.toString());
  }

  String notas = "";
  Future pedir(tipoPago) async {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    String time = dateFormat.format(now);
    var cuenta;
    if (tipoPago == 'En efectivo') {
      cuenta = efectivo * -1;
    } else {
      cuenta = card;
    }
    setState(() {
      loading = true;
    });
    var cord = {
      'lon_u': double.parse(Constant.shared.mylong.toString()),
      'lat_u': double.parse(Constant.shared.mylat.toString()),
      'lon_t': widget.long,
      'lat_t': widget.lat
    };
    var datas = widget.datos;
    String totales = datas[0]['precio'];
    String nombres = datas[0]['nombre'];
    String cantidad = widget.cant[0].toString();
    log(cantidad.toString());

    String ids = datas[0]['_id'];
    if (datas.length > 1) {
      for (var i = 1; i < datas.length; i++) {
        totales = totales + "," + datas[i]['precio'];
        nombres = nombres + "," + datas[i]['nombre'];
        cantidad = cantidad + "," + widget.cant[i].toString();
        ids = ids + "," + datas[i]['_id'];
      }
    }
    log(cantidad.toString());

    String url =
        "${Constant.shared.urlApi}/cont/?id_u=${Constant.shared.dataUser['_id']}";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'nombre': nombres,
      'total': totales,
      'id': ids,
      'time': time,
      'cantidades': cantidad,
      'nota': notas,
      'totalcont': widget.total,
      'id_dest': widget.id_dest,
      'coord': json.encode(cord),
      'nombreTienda': widget.nombre_dest,
      'tipoDePago': tipoPago,
      'cuenta': cuenta.toString(),
      'idTienda': widget.id_tienda,
      'user': json.encode({
        'nombre': Constant.shared.dataUser['nombre'],
        'url': Constant.shared.dataUser['img_user'][0]['Url']
      })
    });
    if (res.statusCode == 200) {
      setState(() {
        loading = false;
      });
      UtilsRep.respuestaSendFcm(
          'Tienes un pedido de ${Constant.shared.dataUser['nombre']}',
          'recibiste un pedido para ${widget.nombre_dest}',
          widget.id_dest,
          'atender_p');
      retrocederDospestanias();
      // fcm_notification(jsonDecode(res.body)['id_cont']);
    } else {
      ToastNotification.toastNotificationError('Error en el registro', context);
    }
  }

  retrocederDospestanias() {
    if (mounted) {
      Navigator.pop(context); // Retrocede a la pantalla anterior
      Navigator.pop(context);
      ToastNotification.toastNotificationSucces(
          'Pedido realizado exitosamente le avisaremos cuando hayga respuesta del comerciante',
          context);
    }
  }

  // Future fcm_notification(id_cont) async {
  //   String url = Constant.shared.urlApi + "/fcm";
  //   var time = DateTime.now().toString().substring(0, 16);
  //   var res = await http.post(Uri.parse(url), headers: <String, String>{
  //     'Context-Type': 'application/json;charSet=UTF-8'
  //   }, body: <String, String>{
  //     'id_2': widget.id_dest,
  //     'title': widget.nombre_dest,
  //     'body': Constant.shared.dataUser['nombre'] +
  //         ' ' +
  //         Constant.shared.dataUser['apellidos'],
  //     'page': "atender_p",
  //     'id_cont': id_cont,
  //     'time': time,
  //     'url': Constant.shared.dataUser['img_user'][0]['Url'],
  //     'id_tienda': widget.id_tienda
  //   });
  //   if (res.statusCode == 200) {
  //   } else
  //     print(res.statusCode);
  // }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading == true
        ? const Loadings()
        : Scaffold(
            body: SafeArea(
                child: Stack(
              children: [
                Column(
                  children: [
                    _tabla(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "TOTAL",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.karla(
                              fontSize: 25,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            widget.total,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.fjallaOne(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ]),
                    comentario(),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        botonRadio(),
                        pagoTipo == 'efectivo' ? _botom() : pagarEnlinea(),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          );
  }

  Widget _botom() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      //botton signIn
      // ignore: deprecated_member_use
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        onPressed: () {
          if (coneccion) {
            pedir('En efectivo');
            // retrocederDospestanias();
          } else {
            Push_Notification.ventanaConeccionInternet(context);
          }
        },
        child:
            const Text("Hacer pedido", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget pagarEnlinea() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.6,
      //botton signIn
      // ignore: deprecated_member_use
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        onPressed: () {
          if (coneccion) {
            // log();
            createPaymentIntent(
                '${(double.parse(widget.total) * 100).toInt()}', 'bob');
          } else {
            Push_Notification.ventanaConeccionInternet(context);
          }
        },
        child: const Text("Paga y hacer pedido",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  var paymentIntent;
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51NyMnGIRaH9pIO5zH9DVNkn7DfCuSdkPlyCHZVHkoajJyPyNHQtDMekyWEB9fwF8sitdLLVOi7qxNW6DM6irGKYE00VlTYKTgn',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      paymentIntent = json.decode(response.body);
      print(paymentIntent);
    } catch (err) {
      log(err.toString());

      throw Exception(err.toString());
    }

    var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: 'GB', currencyCode: 'GBP', testEnv: true);

    await Stripe.instance
        .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntent![
                    'client_secret'], //Gotten from payment intent
                style: ThemeMode.light,
                merchantDisplayName: 'Abhi',
                googlePay: gpay))
        .then((value) {});

    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        pedir('Con tarjeta');
        print("Payment Successfully");
      });
    } catch (e) {
      ToastNotification.toastNotificationError(
          'Error En la trasaccion', context);
      print('$e');
    }
  }

  Widget _tabla() {
    var auxiliar = widget.datos;
    final List<Map<String, String>> data = [];
    for (var i = 0; i < auxiliar.length; i++) {
      data.add(
          {"nombre": auxiliar[i]['nombre'], "precio": auxiliar[i]['precio']});
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text("Producto")),
        DataColumn(label: Text("Cantidad")),
        DataColumn(label: Text("Precio")),
      ],
      rows: data
          .map((item) => DataRow(selected: true, cells: <DataCell>[
                DataCell(Text(item["nombre"].toString())),
                DataCell(Text(widget.cant[data.indexOf(item)].toString())),
                DataCell(Text(item["precio"].toString()))
              ]))
          .toList(),
    );
  }

  var pagoTipo = 'efectivo';
  var paymentMethod = 1;
  Widget botonRadio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Pagar como:'),
          const SizedBox(
            width: 16,
          ),
          Row(
            children: [
              Radio(
                value: 1,
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value as int;
                    pagoTipo = 'efectivo';
                    print(paymentMethod);
                  });
                },
              ),
              const Text('Efectivo'),
              Radio(
                value: 2,
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value as int;
                    pagoTipo = 'En linea';
                  });
                  // payment();
                },
              ),
              const Text('Tarjeta'),
            ],
          ),
        ],
      ),
    );
  }

//    AQUI SE REALIZA LOS PAGOS ONLINE INICIO :)
  // Map<String, dynamic>? paymentIntent;

  // Future<void> payment() async {
  //   try {
  //     Map<String, dynamic> body = {'amount': widget.total, 'currency': 'USD'};

  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization':
  //             'Bearer sk_test_51MWx8OAVMyklfe3C3gP4wKOhTsRdF6r1PYhhg1PqupXDITMrV3asj5Mmf0G5F9moPL6zNfG3juK8KHgV9XNzFPlq00wmjWwZYA',
  //         'Content-Type': 'application/x-www-form-urlencoded'
  //       },
  //       body: body,
  //     );
  //     paymentIntent = json.decode(response.body);
  //   } catch (e) {
  //     throw Exception(e);
  //   }

  //   await Stripe.instance
  //       .initPaymentSheet(
  //           paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret:
  //             paymentIntent!['client_secret'], //Gotten from payment intent
  //         style: ThemeMode.light,
  //         merchantDisplayName: 'Abhi',
  //       ))
  //       .then((value) {});

  //   try {
  //     await Stripe.instance
  //         .presentPaymentSheet()
  //         .then((value) => print('TRANSACCION CORRECTA'));
  //   } catch (e) {
  //     throw Exception(e);
  //   }
  // }

  Widget comentario() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        child: TextFormField(
          minLines:
              5, // any number you need (It works as the rows for the textarea)
          keyboardType: TextInputType.multiline,
          maxLines: null,
          controller: TextEditingController(text: notas),
          onChanged: (value) {
            notas = value;
          },
          decoration: InputDecoration(
              hintText: 'Puede agregar notas adicionales si desea',
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

  // Widget botonGooglePay() {
  //   return GooglePayButton(
  //     paymentConfiguration:
  //         PaymentConfiguration.fromJsonString(defaultGooglePay),
  //     paymentItems: paymentItems_,
  //     type: GooglePayButtonType.pay,
  //     onPaymentResult: onGooglePayResult,
  //     loadingIndicator: const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //     // margin: const EdgeInsets.only(top: 15.0),
  //   );
  // }

  // void onGooglePayResult(paymentResult) {
  //   // Send the resulting Apple Pay token to your server / PSP
}
// var paymentItems_ = [
//   const PaymentItem(
//     label: 'Total',
//     amount: '99.99',
//     status: PaymentItemStatus.final_price,
//   )
// ];
// }

const String defaultGooglePay = '''{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "example",
            "gatewayMerchantId": "gatewayMerchantId"
          }
        },
        "parameters": {
          "allowedCardNetworks": ["VISA", "MASTERCARD"],
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "billingAddressRequired": true,
          "billingAddressParameters": {
            "format": "FULL",
            "phoneNumberRequired": true
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "01234567890123456789",
      "merchantName": "Example Merchant Name"
    },
    "transactionInfo": {
      "countryCode": "US",
      "currencyCode": "USD"
    }
  }
}''';
