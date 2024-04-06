import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lottie/lottie.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/initializeData.dart';
import 'package:nabd/GlobalHelpers/messaging_helper.dart';
import 'package:nabd/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:nabd/core/audiopage/player/player_bar.dart';
import 'package:nabd/core/home.dart';
import 'package:nabd/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart' as ez;

final mediaStorePlugin = MediaStore();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    //PermissionStatus status1 = await Permission.accessMediaLocation.request();
    // PermissionStatus status2 =
    //     await Permission.locationWhenInUse.request();
    print('status $status ');
    if (status.isGranted) {
      print(true);
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
  }

  navigateToHome(context) async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
            builder: (builder) => BlocProvider(
                  create: (xc) => playerPageBloc,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Home(),
                      MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (create) =>
                                  BlocProvider.of<PlayerBarBloc>(context)),
                          BlocProvider(create: (create) => playerPageBloc),
                        ],
                        child: const PlayerBar(),
                      )
                      // Container(height: 100,width: 100,color: Colors.amber,)
                    ],
                  ),
                )),
        (route) => false);
  }

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );

    Response response;
    Response response2;
    Response response3;
    if (prefs.getString("reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") == null ||
        prefs.getString(
                "moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
            null ||
        prefs.getString(
                "suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
            null) {
      try {
        if (context.locale.languageCode == "ms") {
          response = await Dio()
              .get('http://mp3quran.net/api/v3/reciters?language=eng');
          response2 =
              await Dio().get('http://mp3quran.net/api/v3/moshaf?language=eng');
          response3 =
              await Dio().get('http://mp3quran.net/api/v3/suwar?language=eng');
        } else {
          response = await Dio().get(
              'http://mp3quran.net/api/v3/reciters?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
          response2 = await Dio().get(
              'http://mp3quran.net/api/v3/moshaf?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
          response3 = await Dio().get(
              'http://mp3quran.net/api/v3/suwar?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
        }
        if (response.data != null) {
          final jsonData = json.encode(response.data['reciters']);
          prefs.setString(
              "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
              jsonData);
        }
        if (response2.data != null) {
          final jsonData2 = json.encode(response2.data);
          prefs.setString(
              "moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
              jsonData2);
        }
        if (response3.data != null) {
          final jsonData3 = json.encode(response3.data['suwar']);
          prefs.setString(
              "suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
              jsonData3);
        }
      } catch (error) {
        print('Error while storing data: $error');
      }
    }

    prefs.setInt("zikrNotificationindex", 0);
  }

  downloadAndStoreHadithData() async {
    await Future.delayed(const Duration(seconds: 1));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("hadithlist-100000-${context.locale.languageCode}") ==
        null) {
      Response response = await Dio().get(
          "https://hadeethenc.com/api/v1/categories/roots/?language=${context.locale.languageCode}");

      if (response.data != null) {
        final jsonData = json.encode(response.data);
        prefs.setString("categories-${context.locale.languageCode}", jsonData);

        response.data.forEach((category) async {
          Response response2 = await Dio().get(
              "https://hadeethenc.com/api/v1/hadeeths/list/?language=${context.locale.languageCode}&category_id=${category["id"]}&per_page=699999");

          if (response2.data != null) {
            final jsonData = json.encode(response2.data["data"]);
            prefs.setString(
                "hadithlist-${category["id"]}-${context.locale.languageCode}",
                jsonData);

            ///add to category of all hadithlist
            if (prefs.getString(
                    "hadithlist-100000-${context.locale.languageCode}") ==
                null) {
              prefs.setString(
                  "hadithlist-100000-${context.locale.languageCode}", jsonData);
            } else {
              final dataOfOldHadithlist = json.decode(prefs.getString(
                      "hadithlist-100000-${context.locale.languageCode}")!)
                  as List<dynamic>;
              dataOfOldHadithlist.addAll(json.decode(jsonData));
              prefs.setString(
                  "hadithlist-100000-${context.locale.languageCode}",
                  json.encode(dataOfOldHadithlist));
            }
          }
        });
      }
    }

    //  if (response.data != null) {
    //       final jsonData = json.encode(response.data['reciters']);
    //       prefs.setString(
    //           "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
    //           jsonData);
    //     }
  }

  initStoragePermission() async {
    List<Permission> permissions = [
      Permission.storage,
    ];

    if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
      permissions.add(Permission.photos);
      permissions.add(Permission.audio);
      permissions.add(Permission.location);

      // permissions.add(Permission.videos);
    }

    await permissions.request();
    MediaStore.appFolder = "Skoon";
    initMessaging();
    setOptimalDisplayMode();
  }

  @override
  void initState() {
    super.initState();
    initHiveValues();
    checkNotificationPermission();
    downloadAndStoreHadithData();
    getAndStoreRecitersData();
    initStoragePermission();
    navigateToHome(context);
  }

  List zikrNotifs = [
    "ﷺ  صلي علي محمد",
    "اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي",
    "لا حول ولا قوة الا بالله",
    "لا اله الا الله, محمد رسول الله",
    "لا اله الا انت سبحانك اني كنت من الظالمين",
    "استغفر الله",
    "سبحان الله",
    "الحمدلله",
    "لا اله الا الله",
    "الله اكبر"
  ];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xfffff9de),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    zikrNotifs[Random().nextInt(zikrNotifs.length)],
                    style: TextStyle(
                        color: Colors.black,fontSize: 22.sp, fontFamily: fontFamilies[Random().nextInt(fontFamilies.length)]),
                  ),
                  Image.asset(
                    "assets/images/skoon.png",
                    height: 160.h,
                  ),
                  LottieBuilder.asset(
                    "assets/images/loading.json",
                    repeat: true,
                    height: 80.h,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  "assets/images/splash_top.json",
                  width: MediaQuery.of(context).size.width * .8,
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
