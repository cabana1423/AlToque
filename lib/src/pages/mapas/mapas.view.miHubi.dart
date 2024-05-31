// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart' as latLng;

// class MapsView extends StatefulWidget {
//   MapsView({Key? key}) : super(key: key);

//   @override
//   State<MapsView> createState() => _MapsViewState();
// }

// class _MapsViewState extends State<MapsView> {
//   late double lat=0;
//   late double long=0;

//   void getCurrentLocation() async {
//     var position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     var lastPosition = await Geolocator.getLastKnownPosition();
//     //print(lastPosition);

//     setState(() {
//       lat = double.parse( position.latitude.toString());
//       long = double.parse( position.longitude.toString());
//     });
//   }

//   @override
//   void initState() {
//     getCurrentLocation();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Center(
//             child: lat!=0?FlutterMap(
//           options: MapOptions(
//             center: latLng.LatLng(lat, long),
// 						zoom: 13
//           ),
//           layers: [
//             MarkerLayerOptions(
//               markers: [
//                 Marker(
//                   width: 80.0,
//                   height: 80.0,
//                   point: latLng.LatLng(lat, long),
//                   builder: (ctx) => Container(
//                     child: Icon(Icons.location_on,color: Colors.red.shade600,),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           children: <Widget>[
//             TileLayerWidget(
//                 options: TileLayerOptions(
//                     urlTemplate:
//                         "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                     subdomains: ['a', 'b', 'c'])),
//             // MarkerLayerWidget(options: MarkerLayerOptions(
//             //   markers: [
//             //     Marker(
//             //       width: 20.0,
//             //       height: 20.0,
//             //       point: latLng.LatLng(lat, long),
//             //       builder: (ctx) =>
//             //       Container(
//             //         child: Icon(Icons.location_on),
//             //       ),
//             //     ),
//             //   ],
//             // )),
//           ],
//         ):Text("error de mapa"),
// 				),
//       ),
//     );
//   }
// }
