// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:gowin/src/pages/sing_in.dart';
// import 'package:gowin/src/pages/sing_up.dart';

// class RouteServices {
//   static Route<dynamic> generateRoute(RouteSettings routeSettings) {
//     final agrs = routeSettings.arguments;
//     switch (routeSettings.name) {
//       case '/Sing_Up':
//         return CupertinoPageRoute(builder: (_) {
//           return SingUp();
//         });
//       case '/Sing_in':
//         if (agrs is Map) {
//           return CupertinoPageRoute(builder: (_) {
//             return SingIn();
//           });
//         }
//         return _errorRoute();
//       default:
//         return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(builder: (_) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('pageno found')),
//       );
//     });
//   }
// }
