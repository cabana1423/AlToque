// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:gowin/src/utils.pages/toast.notification.dart';
// //import 'package:aesthetic_dialogs/aesthetic_dialogs.dart';
// //import 'dart:async';

// import 'package:gowin/src/utils/variables.dart';

// class Mapas extends StatefulWidget {
//   Mapas({Key? key}) : super(key: key);

//   @override
//   State<Mapas> createState() => _MapasState();
// }

// class _MapasState extends State<Mapas> {
//   late MapController controller;
//   late GeoPoint geoPoint;
//   ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     controller = MapController(
//       initMapWithUserPosition: false,
//       initPosition: GeoPoint(
//           latitude: Constant.shared.mylat, longitude: Constant.shared.mylong),
//       // areaLimit: BoundingBox(
//       //   east: 10.4922941,
//       //   north: 47.8084648,
//       //   south: 45.817995,
//       //   west: 5.9559113,
//       // ),
//     );

//     controller.listenerMapSingleTapping.addListener(() async {
//       if (controller.listenerMapSingleTapping.value != null) {
//         if (lastGeoPoint.value != null) {
//           controller.removeMarker(lastGeoPoint.value!);
//         }
//         print(controller.listenerMapSingleTapping.value!);
//         lastGeoPoint.value = controller.listenerMapSingleTapping.value;
//         await controller.addMarker(
//           lastGeoPoint.value!,
//           markerIcon: MarkerIcon(
//             icon: Icon(
//               Icons.add_location_alt,
//               color: Color.fromARGB(255, 88, 160, 255),
//               size: 140,
//             ),
//           ),
//           // angle: -pi / 1,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   // Future<void> miPosition() async {
//   //   await controller.addMarker(
//   //     await controller.myLocation(),
//   //     markerIcon: MarkerIcon(
//   //       icon: Icon(
//   //         Icons.add_location_alt,
//   //         color: Color.fromARGB(255, 88, 160, 255),
//   //         size: 140,
//   //       ),
//   //     ),
//   //     // angle: -pi / 1,
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _ventana();
//         return false;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           body: Stack(children: [
//             OSMFlutter(
//               mapIsLoading: Center(child: CircularProgressIndicator()),
//               controller: controller,
//               trackMyPosition: true,
//               initZoom: 16,
//               minZoomLevel: 2,
//               maxZoomLevel: 18,
//               stepZoom: 1.0,
//               userLocationMarker: UserLocationMaker(
//                 personMarker: MarkerIcon(
//                   icon: Icon(
//                     Icons.location_on,
//                     color: Color.fromARGB(255, 255, 102, 91),
//                     size: 55,
//                   ),
//                 ),
//                 directionArrowMarker: MarkerIcon(
//                   icon: Icon(
//                     Icons.location_on,
//                     size: 80,
//                     color: Colors.red.shade400,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//                 bottom: 25,
//                 right: 10,
//                 child: Container(
//                   width: 60,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       IconButton(
//                           onPressed: () async {
//                             await controller.zoomIn();
//                           },
//                           icon: Icon(
//                             Icons.zoom_in,
//                             color: Colors.blueGrey,
//                             size: 40,
//                           )),
//                       IconButton(
//                           onPressed: () async {
//                             await controller.zoomOut();
//                           },
//                           icon: Icon(
//                             Icons.zoom_out_outlined,
//                             color: Colors.blueGrey,
//                             size: 40,
//                           )),
//                       SizedBox(
//                         height: 12,
//                       ),
//                       IconButton(
//                           onPressed: () async {
//                             await controller.currentLocation();
//                           },
//                           icon: Icon(
//                             Icons.my_location,
//                             color: Colors.blueGrey,
//                             size: 30,
//                           ))
//                     ],
//                   ),
//                 )),
//             Positioned(
//                 bottom: 10,
//                 left: 100,
//                 child: ElevatedButton(
//                     onPressed: () {
//                       if (controller.listenerMapSingleTapping.value != null) {
//                         Constant.shared.lat = controller
//                             .listenerMapSingleTapping.value!.latitude
//                             .toString();
//                         Constant.shared.long = controller
//                             .listenerMapSingleTapping.value!.longitude
//                             .toString();
//                         if (mounted) {
//                           Navigator.of(context).pop(context);
//                         }
//                       } else {
//                         ToastNotification.toastNotificationError(
//                             'no hay ninguna ubicación', context);
//                         return;
//                       }

//                       // Navigator.push(context,
//                       //     new MaterialPageRoute(builder: (context) => RegProp()));
//                     },
//                     child: Text("aseptar")))
//           ]),
//         ),
//       ),
//     );
//   }

//   _ventana() {
//     return AwesomeDialog(
//       context: context,
//       dialogType: DialogType.WARNING,
//       borderSide: BorderSide(color: Colors.yellow, width: 1),
//       width: 400,
//       buttonsBorderRadius: BorderRadius.all(Radius.circular(5)),
//       headerAnimationLoop: false,
//       animType: AnimType.BOTTOMSLIDE,
//       title: 'No hay una ubicacion',
//       desc: 'no se agrego ninguna ubicacion esta seguro que desea salir?',
//       showCloseIcon: true,
//       // btnCancelOnPress: () {
//       //   print("hola");
//       // },
//       btnOkOnPress: () {
//         Navigator.pop(context);
//       },
//     )..show();
//   }
// }
