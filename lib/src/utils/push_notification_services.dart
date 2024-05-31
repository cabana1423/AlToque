import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gowin/src/utils/variables.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<String> _messageStream = StreamController.broadcast();
  static Stream<String> get messageStream => _messageStream.stream;

  static Future _backgrounHandler(RemoteMessage message) async {
    print('_backgrounHandler');
    Constant.shared.estadoPushNoti = 'news';
    _messageStream.add(message.data['data1']);
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print('escucho papa :)  on message');
    _messageStream.add(message.data['data1']);
  }

  static Future initializeApp() async {
    //push notification
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    log(token.toString());
    Constant.shared.tokenFB = token!;

    // FirebaseMessaging.onBackgroundMessage(_backgrounHandler);
    //FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }

  static closeStreams() {
    _messageStream.close();
  }
}
