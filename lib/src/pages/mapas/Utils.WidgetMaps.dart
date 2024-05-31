import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilMaps {
  late String _btn3SelectedVal;
  static final func = UtilMaps();

  static const menuItems = <String>[
    'Abrir ruta completa',
    'Abrir ruta Tienda',
    'Abrir ruta cliente',
  ];
  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();
  popMenu(context, lat, lon, data) {
    return PopupMenuButton<String>(
      child: CircleAvatar(
        backgroundColor: Colors.black54,
        backgroundImage: AssetImage('images/GM.png'),
      ),
      onSelected: (String newValue) {
        _btn3SelectedVal = newValue;
        switch (newValue) {
          case 'Abrir ruta completa':
            _launchURL(
                'https://www.google.com/maps/dir/?api=1&origin=${lat},${lon}&destination=${data['ubicacion']['lat_u']},${data['ubicacion']['lon_u']}&travelmode=car&waypoints=${data['ubicacion']['lat_t']},${data['ubicacion']['lon_t']}&hl=es-41');
            break;
          case 'Abrir ruta Tienda':
            _launchURL(
                'https://www.google.com/maps/search/?api=1&query=${data['ubicacion']['lat_t']},${data['ubicacion']['lon_t']}&zoom=20');
            break;
          case 'Abrir ruta cliente':
            _launchURL(
                'https://www.google.com/maps/search/?api=1&query=${data['ubicacion']['lat_u']},${data['ubicacion']['lon_u']}&zoom=20');
            break;
          default:
            return;
        }
      },
      itemBuilder: (BuildContext context) => _popUpMenuItems,
    );
  }

  void _launchURL(url) async {
    // String _url = "geo:$l1,$l2?z=16&q=$l1,$l2(Position)";
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }
}
