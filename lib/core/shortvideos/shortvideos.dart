import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:video_player/video_player.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List videos = [
    {"reciter": "quran1", "url": "https://survey-king.herokuapp.com/q.mp4"},
    {"reciter": "quran2", "url": "https://survey-king.herokuapp.com/q1.mp4"},
    {"reciter": "quran3", "url": "https://survey-king.herokuapp.com/q2.mp4"},
    {"reciter": "quran4", "url": "https://survey-king.herokuapp.com/q3.mp4"},
    {"reciter": "quran5", "url": "https://survey-king.herokuapp.com/q4.mp4"},
    {"reciter": "quran6", "url": "https://survey-king.herokuapp.com/q5.mp4"},
    {"reciter": "quran7", "url": "https://survey-king.herokuapp.com/q6.mp4"},
    {"reciter": "quran8", "url": "https://survey-king.herokuapp.com/q7.mp4"},
    {"reciter": "quran9", "url": "https://survey-king.herokuapp.com/q8.mp4"},
    {"reciter": "quran10", "url": "https://survey-king.herokuapp.com/q9.mp4"},
    {"reciter": "quran11", "url": "https://survey-king.herokuapp.com/q10.mp4"},
    {"reciter": "quran12", "url": "https://survey-king.herokuapp.com/q11.mp4"},
    {"reciter": "quran13", "url": "https://survey-king.herokuapp.com/q12.mp4"},
    {"reciter": "quran14", "url": "https://survey-king.herokuapp.com/q13.mp4"},
    {"reciter": "quran15", "url": "https://survey-king.herokuapp.com/q14.mp4"},
    {"reciter": "quran16", "url": "https://survey-king.herokuapp.com/q15.mp4"},
    {"reciter": "quran17", "url": "https://survey-king.herokuapp.com/q16.mp4"},
    // {"reciter": "quran1", "url": "https://survey-king.herokuapp.com/q17.mp4"},
  ];
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _liked = false;
  void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success,
      {int? currentIndex}) async {
    _videoPlayerController =
        VideoPlayerController.network(videos[currentIndex!]["url"]);
    await Future.wait([_videoPlayerController.initialize()]);
    setState(() {});
    print(
        "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
  }

  downloadVideo(index) async {
   Flushbar(textDirection: TextDirection.ltr,
  message: "Downloading Now...",
  icon: Icon(
    Icons.info_outline,
    size: 28.0,
    color: Colors.blue[300],
    ),
  duration: const Duration(seconds: 3), margin: const EdgeInsets.all(8),
  borderRadius: BorderRadius.circular(8),
  // leftBarIndicatorColor: Colors.blue[300],
).show(context);

    // Fluttertoast.showToast(msg: "downloading..");
    final dio = Dio();
    final appDir = Directory("/storage/emulated/0/Download/");
    // final ffmpeg = FlutterFFmpeg();
    PermissionStatus status = await Permission.storage.request();
    //PermissionStatus status1 = await Permission.accessMediaLocation.request();
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    print('status $status   -> $status2');
    if (status.isGranted && status2.isGranted) {
      print(true);
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
    final fullSuraFilePath = "${appDir.path}${videos[index]["reciter"]}.mp4";

    // Check if the full sura file already exists
    if (File(fullSuraFilePath).existsSync()) {
     
   Flushbar(textDirection: TextDirection.ltr,
  message: "Already Downloaded under Downloads folder $fullSuraFilePath",
  icon: Icon(
    Icons.info_outline,
    size: 28.0,
    color: Colors.blue[300],
    ),
  duration: const Duration(seconds: 3), margin: const EdgeInsets.all(8),
  borderRadius: BorderRadius.circular(8),
  // leftBarIndicatorColor: Colors.blue[300],
).show(context);

      print('Full sura audio file already cached: $fullSuraFilePath');
    } else {
      try {
        await dio.download(videos[index]["url"], fullSuraFilePath);
    Flushbar(textDirection: TextDirection.ltr,
  message: "Downloaded under Downloads folder $fullSuraFilePath",
  icon: Icon(
    Icons.info_outline,
    size: 28.0,
    color: Colors.blue[300],
    ), margin: const EdgeInsets.all(8),
  borderRadius: BorderRadius.circular(8),
  duration: const Duration(seconds: 3),
  // leftBarIndicatorColor: Colors.blue[300],
).show(context);
   
      } catch (e) {
        print(e);
      } // updateValue(
      //     "downloadedSurahs",
      //     json.decode(getValue("downloadedSurahs").add(
      //         "${event.suraName}-${event.moshafId}-${event.reciterName}")));
    }
  }

  int index = 0;
  @override
  void initState() {
    controller.addListener((event) {
      if (event.direction == ScrollDirection.FORWARD) {
        if (index != videos.length) index = index + 1;
      } else {
        if (index != 0) {
          index = index - 1;
        }
      }
      setState(() {});
      initializePlayer();
    });
    super.initState();
    initializePlayer();
  }

  Future initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.network(videos[index]["url"]);
    await Future.wait([_videoPlayerController.initialize()]);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        showControls: true,
        allowMuting: true,
        allowFullScreen: true,
        showOptions: true,
        overlay: Container(),
        customControls: const CupertinoControls(
            backgroundColor: Colors.black12, iconColor: Colors.white),
        looping: true,
        additionalOptions: (d) => [
              OptionItem(
                  onTap: () {
                    downloadVideo(index);
                  },
                  iconData: Icons.download,
                  title: "Download to Device")
            ]);
    setState(() {});
  }

  Controller controller = Controller();
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TikTokStyleFullPageScroller(
          contentSize: videos.length,
          swipePositionThreshold: 0.2,
          // ^ the fraction of the screen needed to scroll
          swipeVelocityThreshold: 2000,
          // ^ the velocity threshold for smaller scrolls
          animationDuration: const Duration(milliseconds: 400),
          // ^ how long the animation will take
          controller: controller,
          // ^ registering our own function to listen to page changes
          builder: (BuildContext context, int index) {
            return _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _liked = !_liked;
                      });
                    },
                    child: Chewie(
                      controller: _chewieController!,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Loading...')
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class LikeIcon extends StatelessWidget {
  const LikeIcon({super.key});

  Future<int> tempFuture() async {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: tempFuture(),
        builder: (context, snapshot) =>
            snapshot.connectionState != ConnectionState.done
                ? const Icon(Icons.favorite, size: 110)
                : const SizedBox(),
      ),
    );
  }
}
