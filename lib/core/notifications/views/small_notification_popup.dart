import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZikrNotificationPopub extends StatefulWidget {
  const ZikrNotificationPopub({Key? key}) : super(key: key);

  @override
  State<ZikrNotificationPopub> createState() => _ZikrNotificationPopubState();
}

class _ZikrNotificationPopubState extends State<ZikrNotificationPopub> {
  Color color = const Color(0xFFFFFFFF);
  final BoxShape _currentShape = BoxShape.circle;
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String messageFromOverlay = "استغفر الله";
  int index = 0;

  late Timer timer;
  @override
  void initState() {
    // timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    //   print(":timer:${timer.tick}");
    //   Fluttertoast.showToast(msg: ":timer:${timer.tick}");
    // });
    super.initState();
    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameOverlay,
    );
    log("$res : HOME");
    _receivePort.listen((message) {
      log("message from UI: $message");
      setState(() {
        messageFromOverlay = '$message';
      });
    });
    perfss();
  }

  perfss() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      index = prefs.getInt("zikrNotificationindex")??0;
    });
  }

  // late SharedPreferences prefs;
  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18.0, right: 10),
          child: GestureDetector(
            onTap: () async {
              await FlutterOverlayWindow.closeOverlay();

              setState(() {
                prefs.setInt("zikrNotificationindex", index + 1);
                index = prefs.getInt("zikrNotificationindex")!;
                // prefs.setInt("zikrNotificationindex", index);
              });
              if (index == zikrNotfications.length) {
                setState(() {
                  prefs.setInt("zikrNotificationindex", 0);
                  index = prefs.getInt("zikrNotificationindex")!;
                });
              }
            },
            child: FadeInRight(
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                    // height: 30,
                    // width: 69,
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffE8DCB2)),
                        color: const Color(0xff293647),
                        borderRadius: BorderRadius.circular(25),
                        image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              "assets/images/try6.png",
                            ),
                            alignment: Alignment.center,
                            opacity: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Text(
                          zikrNotfications[index],
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'cairo'),
                        ),
                      ),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
