import 'dart:convert';

import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;

class SendFcm {
  static final func = SendFcm();

  void sendNotification(data1, String lat, String long, String token) async {
    var tokenServer =
        'AAAABDFsjos:APA91bG2b4AoHm8HaSskpHMxa8bWlNl5pdA790Sovk7ip_JAIGGA3WJwJzu9_TSoG8jRpn-05-JPDnM1yBNWfLxGAPMiIBOTwNv4Vynf8WHB-XRx4zHOu6rsPvG663AWHbj6YdKk_VmB';
    print(token);
    final data = jsonEncode({
      'to': token,
      'data': {
        'click_Action': 'FLUTTER_NOTIFICATION_CLICK',
        'data1': data1,
        'lat': lat,
        'long': long,
        'token': Constant.shared.tokenFB
      },
      'priority': 'high',
    });

    final headers = {
      'Content-type': 'application/json',
      'Authorization': 'key=$tokenServer' // replace with your server key
    };
    try {
      final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: data,
          headers: headers);

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print(response.body);
      }
    } catch (e) {
      return;
    }
  }
}
