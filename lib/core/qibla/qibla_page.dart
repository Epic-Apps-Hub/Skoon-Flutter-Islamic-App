// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttericon/mfg_labs_icons.dart';
// import 'package:nabd/GlobalHelpers/constants.dart';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:nabd/GlobalHelpers/hive_helper.dart';
// import 'package:nabd/core/qibla/qibla_compass.dart';
// import 'package:nabd/core/qibla/qibla_maps.dart';
// class QiblaPage extends StatefulWidget {
//   const QiblaPage({super.key});

//   @override
//   State<QiblaPage> createState() => _QiblaPageState();
// }

// class _QiblaPageState extends State<QiblaPage> {
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     return  Scaffold(backgroundColor: backgroundColor,
//         appBar: AppBar(
          
      
//           elevation: 0,
//           centerTitle: true,
//           // leading: Padding(
//           //   padding: const EdgeInsets.all(8.0),
//           //   child: IconButton(
//           //       icon: const Icon(
//           //         MfgLabs.right_open,
//           //         color: Colors.black,
//           //       ),
//           //       onPressed: () {}),
//           // ),
//           backgroundColor:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,automaticallyImplyLeading: true,
//           iconTheme: const IconThemeData(
//             color: Colors.white
//           ),
//           title: Text(
//             'qibla'.tr(),
//             style: const TextStyle(
//                         fontFamily: "cairo",
// ),
//           ),
//         ),
//         body: SizedBox(
//           height: screenSize.height,
//           child: Column(
//             children: [SizedBox(height: 30.h,),
//               const QiblahMaps(),SizedBox(height: 30.h,),
//               const QiblahCompassWidget(),
              
//             ],
//           ),
//         ),
      
//     );
//   }
// }
