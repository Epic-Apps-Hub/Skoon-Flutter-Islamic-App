// import 'dart:async';
// import 'dart:math' show pi;

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';

// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import 'package:nabd/GlobalHelpers/constants.dart';
// import 'package:smooth_compass/utils/smooth_compass.dart';
// import 'package:smooth_compass/utils/src/compass_ui.dart';

// class QiblahCompass extends StatefulWidget {
//   const QiblahCompass({super.key});

//   @override
//   _QiblahCompassState createState() => _QiblahCompassState();
// }

// class _QiblahCompassState extends State<QiblahCompass> {
//   final _locationStreamController =
//       StreamController<LocationStatus>.broadcast();

//   Stream<LocationStatus> get stream => _locationStreamController.stream;

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationStatus();
//   }

//   @override
//   void dispose() {
//     _locationStreamController.close();
//     FlutterQiblah().dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       padding: const EdgeInsets.all(8.0),
//       child: StreamBuilder(
//         stream: stream,
//         builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const LoadingIndicator();
//           }
//           if (snapshot.data!.enabled == true) {
//             switch (snapshot.data!.status) {
//               case LocationPermission.always:
//               case LocationPermission.whileInUse:
//                 return const QiblahCompassWidget();

//               case LocationPermission.denied:
//                 return LocationErrorWidget(
//                   error: "Location service permission denied",
//                   callback: _checkLocationStatus,
//                 );
//               case LocationPermission.deniedForever:
//                 return LocationErrorWidget(
//                   error: "Location service Denied Forever !",
//                   callback: _checkLocationStatus,
//                 );
//               // case GeolocationStatus.unknown:
//               //   return LocationErrorWidget(
//               //     error: "Unknown Location service error",
//               //     callback: _checkLocationStatus,
//               //   );
//               default:
//                 return const SizedBox();
//             }
//           } else {
//             return LocationErrorWidget(
//               error: "Please enable Location service",
//               callback: _checkLocationStatus,
//             );
//           }
//         },
//       ),
//     );
//   }

//   Future<void> _checkLocationStatus() async {
//     final locationStatus = await FlutterQiblah.checkLocationStatus();
//     if (locationStatus.enabled &&
//         locationStatus.status == LocationPermission.denied) {
//       await FlutterQiblah.requestPermissions();
//       final s = await FlutterQiblah.checkLocationStatus();
//       _locationStreamController.sink.add(s);
//     } else {
//       _locationStreamController.sink.add(locationStatus);
//     }
//   }
// }

// class QiblahCompassWidget extends StatefulWidget {
//   const QiblahCompassWidget({super.key});

//   @override
//   State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
// }

// class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SmoothCompass(
//         isQiblahCompass: true,
//         compassBuilder: (context, snapshot, child) {
//           if(snapshot!.hasData){
//             print("has data: ${snapshot.data!.turns} ${(snapshot.data!.qiblahOffset)}" );
//    return AnimatedRotation(
//             turns: (snapshot.data!.turns) / 360,
//             duration: const Duration(milliseconds: 400),
//             child: SizedBox(
//               width: 200.w,
//               height: 200.w,
//               child: Stack(
//                 children: [
//                   Positioned(
//                     bottom: 0,
//                     height: 0,
//                     left: 0,
//                     right: 0,
//                     child: Image.asset('assets/images/compassn.png',
//                         fit: BoxFit.fill),
//                   ),
//               Positioned(
//                     bottom: 20,
//                     height: 0,
//                     left: 0,
//                     right: 20,
//                     child: AnimatedRotation(
//                       turns: (snapshot.data!.qiblahOffset) / 360,
//                       duration: const Duration(milliseconds: 400),
//                       child: SvgPicture.asset('assets/images/needle.svg',
//                           fit: BoxFit.fitHeight),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
       
//           }

//           return Container();
//         },
//       ),
//     );
//   }
// }

// class LoadingIndicator extends StatelessWidget {
//   const LoadingIndicator({super.key});

//   @override
//   Widget build(BuildContext context) => const Center(
//         child: CircularProgressIndicator.adaptive(),
//       );
// }

// class LocationErrorWidget extends StatelessWidget {
//   final String? error;
//   final Function? callback;

//   const LocationErrorWidget({Key? key, this.error, this.callback})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     const box = SizedBox(height: 32);
//     const errorColor = Color(0xffb00020);

//     return Container(
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Lottie.asset("assets/images/enablelocation.json"),
//             box,
//             Text(
//               error!,
//               style: const TextStyle(
//                   color: errorColor, fontWeight: FontWeight.bold),
//             ),
//             box,
//             ElevatedButton(
//               child: Text("Retry".tr()),
//               onPressed: () {
//                 if (callback != null) callback!();
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



