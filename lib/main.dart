// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer' as log;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gowin/src/pages/Home_Nav.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/Inicio.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/PanelControl.AdmUser.dart';
import 'package:gowin/src/pages/Home_Nav_fragments/Perfil.dart';
import 'package:gowin/src/pages/chat/home_screen.dart';
import 'package:gowin/src/pages/repartidores/utlis.repartidor.dart';
import 'package:gowin/src/pages/sing_in.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gowin/src/pages/splashLoading.dart';
import 'package:gowin/src/pages/views_pages/Productos_view.dart';
import 'package:gowin/src/pages/views_pages/propiedadView.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/Providers.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/push_notification_services.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
final globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("es");
  Stripe.publishableKey =
      "pk_test_51NyMnGIRaH9pIO5zYmZiBKDp4rszWewmrvW7C8iUnaJ6Xhimp2QTBR987JfrKnCahHtfch2YGAMmfoov69bQBMDY00wyKWvWoU";
  // Stripe.instance.applySettings();

  await PushNotificationService.initializeApp();

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title// description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  FirebaseMessaging.onBackgroundMessage(
    _onMessageHandler,
  );

  HttpOverrides.global = MyHttpOverrides();
  runApp(ChangeNotifierProvider(
    create: (_) => EstadoGlobal(),
    child: MyApp(),
  ));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

_onMessageOpenApp(RemoteMessage message) async {
  log.log('SE PRECIONO EN SEGUNDO PLANO');
}

void determinePosition() async {
  bool serviceEnabled;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    log.log('nos se logro');

    return Future.error('Location services are disabled.');
  }
  var position =
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position2) {
    Constant.shared.mylat = position2.latitude;
    Constant.shared.mylong = position2.longitude;
    print(position2.latitude.toString() + position2.longitude.toString());
  });
}

//escucha mientras la app esta activa
bool espera = true;
Future _onMessageHandler(RemoteMessage message) async {
  // log.log(message.toMap().toString());
  espera = false;
  if (message.data['data1'] == 'DameCordenadas' ||
      message.data['data1'] == 'tomaCordenadas') {
    await UtilsRep.func.funcionCoordenadas(message.data['data1'],
        message.data['token'], message.data['lat'], message.data['long']);
    return;
  }
  if (message.data['data1'] == 'NotRepartidor') {
    if (Constant.shared.dataUser['tipo'] != 'repartidor') {
      return;
    }
  }
  UtilsRep.func.refreshListaRep();
  // log.log(message.toMap().toString());
  Constant.shared.estadoPushNoti = 'news';
  RemoteNotification? notification = message.notification;
  Map<String, dynamic> dataValue = message.data;
  String screen = dataValue['data1'];
  //print(screen);
  Constant.shared.datos = dataValue['data2'].toString().split(",");
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: 'launch_background',
        ),
      ),
      payload: screen,
    );
  }
  espera = true;

  //_messageStream.add(message.data['data1']);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkdata) {
      final Uri uri = dynamicLinkdata.link;
      final queryparams = uri.queryParameters;
      print(dynamicLinkdata.link);
      redireccion(dynamicLinkdata.link.path, queryparams);
    }).onError((error) {
      print(error.message);
    });
  }

  Future<void> redireccion(cadena, parametros) async {
    print(parametros);
    final email = await UserSecureStorages.getEmail();
    final id = await UserSecureStorages.getId();
    if (email == '' || id == '') {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SingIn()));
        ToastNotification.toastNotificationSucces(
            'Inicie sesion porfavor', context);
      }
    } else {
      getProducto(parametros['pr']);
    }
  }

  Future<String> getProducto(cadena) async {
    var url = Constant.shared.urlApi + "/produc/id?id=$cadena";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      if (mounted) {
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => HomeNav(
        //             enlace: 'enlace', prod: json.decode(response.body))));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductoView(producto: json.decode(response.body))),
        );
      }
    }

    return "Successfull";
  }

  Future propiedad(cadena) async {
    String url = Constant.shared.urlApi + "/prop/id?id=$cadena";
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      //print(json.decode(response.body));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PropiedadPageView(propiedad: json.decode(response.body))),
      );
    }
  }

  void postTokensAut() async {
    String url = Constant.shared.urlApi + "/users/token";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'refreshToken': Constant.shared.refreshToken,
      'email': Constant.shared.dataUser['email'],
      'nombre': Constant.shared.dataUser['nombre'],
      'id': Constant.shared.dataUser['_id']
    });
    if (res.statusCode == 200) {
      Constant.shared.token = jsonDecode(res.body)['token'];
      // print(Constant.shared.token);
    }
  }

  @override
  void initState() {
    super.initState();
    tema();
    Timer.periodic(const Duration(minutes: 120), (timer) {
      if (Constant.shared.token != '' && Constant.shared.dataUser != null) {
        postTokensAut();
      }
    });
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    initDynamicLinks();
    initNotificatoin();
    // PushNotificationService.messageStream.listen((data) {
    //   //List datos = data.split("|");
    //   if (data == "mensajeria") {
    //     //SaveNotifications.initializeApp(datos[1].toString());
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) =>
    //               HomeScreen(id_u: Constant.shared.dataUser['_id'])),
    //     );
    //   } else if (data == "atender_p") {
    //     //SaveNotifications.initializeApp(datos[1].toString());
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => const HomeNav()),
    //     );
    //   }
    // });
    //#####     acciones onMessage      ###
  }

  void initNotificatoin() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<dynamic> onSelectNotification(payload) async {
    //List datas = payload.toString().split('|');
    log.log(payload.toString());
    if (payload == "mensajeria") {
      print('estoy en onselected');
      // SaveNotifications.initializeApp(datas[1].toString());
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen(id_u: Constant.shared.dataUser['_id'])),
      );
    } else if (payload == "atender_p") {
      //SaveNotifications.initializeApp(datas[1].toString());
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeNav(
                  enlace: '',
                  prod: '',
                )),
      );
    }
  }

  late bool _darkMode;
  Future<void> tema() async {
    final estadoGlobal = Provider.of<EstadoGlobal>(context, listen: false);
    final boleano = await UserSecureStorages.GetTheme();
    if (boleano != '') {
      bool myBool = boleano.toLowerCase() == 'true';

      estadoGlobal.setBrillo(myBool);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoGlobal = Provider.of<EstadoGlobal>(context);
    _darkMode = estadoGlobal.brillo;
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: _darkMode ? Brightness.dark : Brightness.light),
      initialRoute: 'splash',
      routes: <String, WidgetBuilder>{
        '/Sing_in': (BuildContext context) => SingIn(),
        '/produc': (BuildContext context) => ProductoView(
              producto: null,
            ),
        '/perfil': (BuildContext context) => Perfil(
              enlace: '',
              prod: '',
            ),
        'splash': (BuildContext context) => SplashLoading(),
        '/inicio': (BuildContext context) => Inicio(
              enlace: '',
              prod: '',
            ),
        '/PanelAdmin': (BuildContext context) => PanelAdmin(),
        '/Home_Nav': (BuildContext context) => HomeNav(
              enlace: '',
              prod: '',
            ),
        'Home_Screen': (BuildContext context) =>
            HomeScreen(id_u: Constant.shared.dataUser['_id']),
      },
    );
  }
}
