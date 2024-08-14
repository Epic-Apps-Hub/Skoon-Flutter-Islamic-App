// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// // import 'package:flutter_qiblah_example/loading_indicator.dart';
// // import 'package:flutter_qiblah_example/location_error_widget.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:nabd/core/qibla/qibla_compass.dart';
// import 'package:superellipse_shape/superellipse_shape.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:ui' as ui;

// class QiblahMaps extends StatefulWidget {
//   static const meccaLatLong = LatLng(21.422487, 39.826206);

//   const QiblahMaps({super.key});

//   @override
//   _QiblahMapsState createState() => _QiblahMapsState();
// }

// class _QiblahMapsState extends State<QiblahMaps> {
//   final Completer<GoogleMapController> _controller = Completer();
//   // LatLng position = const LatLng(36.800636, 10.180358);
//   BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
// late LatLng position ;
//   late final _future = _checkLocationStatus();
//   final _positionStream = StreamController<LatLng>.broadcast();
//   late Marker meccaMarker ;

//   @override
//   void dispose() {
//     _positionStream.close();
//     super.dispose();
//   }

//   Future<Uint8List> getBytesFromAsset(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetWidth: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }

//   void addCustomIcon() async {
//     final Uint8List markerIcon =
//         await getBytesFromAsset('assets/images/Makkah.png', 100);

//     setState(() {
//       meccaMarker = Marker(
//         markerId: const MarkerId("mecca"),
//         position: QiblahMaps.meccaLatLong,
//         icon: BitmapDescriptor.fromBytes(markerIcon),
//         draggable: false,
//       );
//     });
//   }

//   @override
//   void initState() {
//     addCustomIcon(); // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Material(
//         color: Colors.transparent,
//         shape: SuperellipseShape(),
//         child: Container(
//           decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(19)),
//           height: MediaQuery.of(context).size.height * .29,
//           width: MediaQuery.of(context).size.width * .98,
//           child: FutureBuilder(
//             future: _future,
//             builder: (_, AsyncSnapshot<Position?> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const LoadingIndicator();
//               }
//               if (snapshot.hasError) {
//                 return LocationErrorWidget(
//                   error: snapshot.error.toString(),
//                 );
//               }

//               if (snapshot.hasData) {
//                 final loc =
//                     LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
//                 position = loc;
//               }

//               return StreamBuilder(
//                 stream: _positionStream.stream,
//                 builder: (_, AsyncSnapshot<LatLng> snapshot) => Material(
//                   color: Colors.transparent,
//                   shape: SuperellipseShape(),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: GoogleMap(
//                       mapType: MapType.normal,
//                       zoomGesturesEnabled: true,
//                       compassEnabled: true,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                       initialCameraPosition: CameraPosition(
//                         target:snapshot.hasData? position:const LatLng(26.8206, 30.8025),
//                         zoom: 3,
//                       ),
//                       markers: <Marker>{
//                   // ignore: unnecessary_null_comparison
//                     meccaMarker,
//                     if(snapshot.hasData)    Marker(
//                           draggable: true,
//                           markerId: const MarkerId('Marker'),
//                           position: position,
//                           icon: BitmapDescriptor.defaultMarker,
//                           onTap: _updateCamera,
//                           onDragEnd: (LatLng value) {
//                             position = value;
//                             _positionStream.sink.add(value);
//                           },
//                           zIndex: 5,
//                         ),
//                       },
//                       circles: <Circle>{
//                       if(snapshot.hasData)   Circle(
//                           circleId: const CircleId("Circle"),
//                           radius: 10,
//                           center: position,
//                           fillColor: Theme.of(context)
//                               .primaryColorLight
//                               .withAlpha(100),
//                           strokeWidth: 1,
//                           strokeColor:
//                               Theme.of(context).primaryColorDark.withAlpha(100),
//                           zIndex: 3,
//                         )
//                       },
//                       polylines: <Polyline>{
//                       if(snapshot.hasData)  Polyline(
//                           polylineId: const PolylineId("Line"),
//                           points: [position, QiblahMaps.meccaLatLong],
//                           color: Theme.of(context).primaryColor,
//                           width: 5,
//                           zIndex: 4,
//                         )
//                       },
//                       onMapCreated: (GoogleMapController controller) {
//                         _controller.complete(controller);
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Future<Position?> _checkLocationStatus() async {
//     final locationStatus = await FlutterQiblah.checkLocationStatus();
//     if (locationStatus.enabled) {
//       return await Geolocator.getCurrentPosition();
//     }
//     return null;
//   }

//   void _updateCamera() async {
//     final controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newLatLngZoom(position, 20));
//   }
// }
