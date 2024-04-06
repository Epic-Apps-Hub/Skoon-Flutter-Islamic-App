// import 'package:better_player_hls/better_player_hls.dart';
// import 'package:dio/io.dart';
// import 'package:easy_container/easy_container.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:nabd/GlobalHelpers/constants.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:logging/logging.dart';
// // import 'package:better_player/better_player.dart';
// class MyHttpOverrides extends HttpOverrides { @override HttpClient CreateHttpClient(SecurityContext context) { return super.createHttpClient(context) ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; } }


// class LiveTvPage extends StatefulWidget {
//   const LiveTvPage({super.key});

//   @override
//   State<LiveTvPage> createState() => _LiveTvPageState();
// }

// class _LiveTvPageState extends State<LiveTvPage> {
//   List links = [
//     {
//       "id": 3,
//       "name": "Quran channel",
//       "url": "https://win.holol.com/live/quran/playlist.m3u8"
//     },
//     {
//       "id": 4,
//       "name": "Sunna channel",
//       "url": "https://win.holol.com/live/sunnah/playlist.m3u8"
//     }
//   ];
//   // Override the HTTP client globally
//   // http.Client = client;

//   var videoPlayerController = VideoPlayerController.networkUrl(
//       formatHint: VideoFormat.hls,
//       UriData.fromString('https://win.holol.com/live/quran/playlist.m3u8').uri);
//   late ChewieController chewieController;
//   @override
//   void initState() { HttpOverrides.global = MyHttpOverrides();

//     // videoPlayerController = VideoPlayerController.networkUrl(
//     //   formatHint: VideoFormat.hls,
//     //   UriData.fromString('https://win.holol.com/live/quran/playlist.m3u8').uri);
//     // chewieController = ChewieController(
//     //     videoPlayerController: videoPlayerController,
//     //     aspectRatio: 3 / 2,
//     //     autoPlay: true,
//     //     allowedScreenSleep: true,
//     //     allowPlaybackSpeedChanging: false,
//     //     isLive: true);
//     Fluttertoast.showToast(msg: "loading..."); // TODO: implement initState
//     BetterPlayerConfiguration betterPlayerConfiguration =
//         const BetterPlayerConfiguration(
//       aspectRatio: 16 / 9,
//       fit: BoxFit.contain,
//       autoPlay: true,
//       looping: true,
//       deviceOrientationsAfterFullScreen: [
//         DeviceOrientation.portraitDown,
//         DeviceOrientation.portraitUp
//       ],
//     );
//     _betterPlayerDataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       "https://win.holol.com/live/quran/playlist.m3u8",liveStream: true, 
//       videoFormat: BetterPlayerVideoFormat.hls
//     );
//     _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
//     _betterPlayerController.setupDataSource(_betterPlayerDataSource);
//     super.initState();
//   }
// late BetterPlayerController _betterPlayerController;
//   late BetterPlayerDataSource _betterPlayerDataSource;

//   @override
//   void dispose() {
//     videoPlayerController.dispose();
//     chewieController.dispose(); // TODO: implement dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         // leading: Padding(
//         //   padding: const EdgeInsets.all(8.0),
//         //   child: IconButton(
//         //       icon: const Icon(
//         //         MfgLabs.right_open,
//         //         color: Colors.black,
//         //       ),
//         //       onPressed: () {}),
//         // ),
//         backgroundColor: blueColor, automaticallyImplyLeading: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           'livetv'.tr(),
//           style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 18,
//               color: Colors.white.withOpacity(.9)),
//         ),
//       ),
//       backgroundColor: backgroundColor,
//       body: Center(
//         child: ListView(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 EasyContainer(
//                     color: darkPrimaryColor,
//                     borderRadius: 8.r,
//                     onTap: () {
//                       videoPlayerController =
//                           VideoPlayerController.network(links[0]["url"]);
//                       chewieController = ChewieController(
//                           videoPlayerController: videoPlayerController,
//                           aspectRatio: 3 / 2,
//                           autoPlay: true,
//                           placeholder: const CircularProgressIndicator(
//                             color: darkPrimaryColor,
//                           ),
//                           allowedScreenSleep: true,
//                           allowPlaybackSpeedChanging: false,
//                           isLive: true);
//                       setState(() {});
//                     },
//                     child: Text(
//                       links[0]["name"],
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14.sp,
//                           fontFamily: 'roboto'),
//                     )),
//                 EasyContainer(
//                     color: darkPrimaryColor,
//                     borderRadius: 8.r,
//                     onTap: () {
//                       videoPlayerController =
//                           VideoPlayerController.network(links[1]["url"]);
//                       chewieController = ChewieController(
//                           videoPlayerController: videoPlayerController,
//                           aspectRatio: 3 / 2,
//                           autoPlay: true,
//                           allowedScreenSleep: true,
//                           allowPlaybackSpeedChanging: false,
//                           isLive: true);
//                       setState(() {});
//                     },
//                     child: Text(
//                       links[1]["name"],
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14.sp,
//                           fontFamily: 'roboto'),
//                     )),
//               ],
//             ),
//             // Chewie(controller: chewieController),
//   AspectRatio(
//             aspectRatio: 16 / 9,
//             child: BetterPlayer(controller: _betterPlayerController),
//           ),          ],
//         ),
//       ),
//     );
//   }
// }
