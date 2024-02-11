import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notificationPlugin;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nabd/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:nabd/blocs/bloc/observer.dart';
import 'package:nabd/blocs/bloc/player_bloc_bloc.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:nabd/core/audiopage/player/player_bar.dart';
import 'package:nabd/core/home.dart';
import 'package:nabd/core/notifications/data/40hadith.dart';
import 'package:nabd/core/notifications/views/small_notification_popup.dart';
// import 'package:nabd/views/notifications/alert_window_notifcations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:periodic_alarm/periodic_alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:workmanager/workmanager.dart';
import 'GlobalHelpers/messaging_helper.dart';
import 'package:media_store_plus/media_store_plus.dart';
// import 'package:alarm/alarm.dart';

final mediaStorePlugin = MediaStore();

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ez.EasyLocalization.ensureInitialized();
  List<Permission> permissions = [
    Permission.storage,
  ];
  await PeriodicAlarm.init();

  if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
    permissions.add(Permission.photos);
    permissions.add(Permission.audio);
    permissions.add(Permission.location);

    // permissions.add(Permission.videos);
  }

  await permissions.request();
  // we are not checking the status as it is an example app. You should (must) check it in a production app

  // You have set this otherwise it throws AppFolderNotSetException
  MediaStore.appFolder = "Skoon";

  // HydratedBloc.storage = await HydratedStorage.build(
  //   storageDirectory: await getApplicationDocumentsDirectory(),
  // );
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  // await AndroidAlarmManager.initialize();
  await initializeHive();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  initMessaging();
  setOptimalDisplayMode();
  Bloc.observer = SimpleBlocObserver();
  runApp(ez.EasyLocalization(
      //startLocale: const Locale("ar"),
      supportedLocales: const [
        Locale("ar"),
        Locale('en'),
        Locale('de'),
        Locale("am"),
        // Locale("jp"),
        Locale("ms"),
        Locale("pt"),
        Locale("tr"),
        Locale("ru")
      ],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('ar'),
      child: MultiBlocProvider(providers: [
        BlocProvider(create: (create) => PlayerBarBloc()),
      ], child: const MyApp())));
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ZikrNotificationPopub(),
  );
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (task == "zikrNotification") {
      if (await FlutterOverlayWindow.isActive()) {
        FlutterOverlayWindow.closeOverlay();
        // return;
      }
      //300/700 ان الله وملائكته
      //سبحان الله      //  height: 150,
      // width: 240,
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      int? index = prefs.getInt("zikrNotificationindex") ?? 0;
// Calculate the text size
      // print(ayahNotfications[index].trim().length *3);
      // print(ayahNotfications[index].trim().length *3);

      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        overlayTitle: "",
        overlayContent: 'Skoon',
        alignment: OverlayAlignment.centerRight,
        flag: OverlayFlag.focusPointer,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.right,
        height: 180,
        width: index < 5 ? 300 : 500,
      );
    } else if (task == "zikrNotificationTest") {
      if (await FlutterOverlayWindow.isActive()) {
        FlutterOverlayWindow.closeOverlay();
        // return;
      }
      //300/700 ان الله وملائكته
      //سبحان الله      //  height: 150,
      // width: 240,
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      int? index = prefs.getInt("zikrNotificationindex") ?? 0;
// Calculate the text size
      // print(ayahNotfications[index].trim().length *3);
      // print(ayahNotfications[index].trim().length *3);

      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        overlayTitle: "",
        overlayContent: 'Skoon',
        alignment: OverlayAlignment.centerRight,
        flag: OverlayFlag.focusPointer,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.right,
        height: 180,
        width: index < 8 ? 300 : 500,
      );
    } else if (task == "zikrNotification2") {
//  final SharedPreferences prefs = await SharedPreferences.getInstance();

      int? index = Random().nextInt(zikrNotfications.length);

      flutterLocalNotificationsPlugin.show(
          2,
          zikrNotfications[index],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    zikrNotfications[index], contentTitle: "Zikr",
                    htmlFormatBigText: true,

                    // htmlFormatBigText: true
                  ),
                  "channelId2",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "zikr,",
                  "Zikr")));

      ///show local notification
      ///
    } else if (task == "zikrNotificationTest2") {
      int? index = Random().nextInt(zikrNotfications.length);

      flutterLocalNotificationsPlugin.show(
          2,
          zikrNotfications[index],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  colorized: true,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    zikrNotfications[index], contentTitle: "Zikr",
                    htmlFormatBigText: true,

                    // htmlFormatBigText: true
                  ),
                  "channelId2",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "zikr,",
                  "Zikr" //,ongoing: true
                  )));

      ///show local notification
      ///
    } else if (task == "ayahNot") {
      int suraNumber = Random().nextInt(114) + 1;
      int verseNumber = Random().nextInt(getVerseCount(suraNumber)) + 1;
      flutterLocalNotificationsPlugin.show(
          1,
          getVerse(suraNumber, verseNumber),
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    getVerse(suraNumber, verseNumber), contentTitle: "Ayah",
                    htmlFormatBigText: true,

                    // htmlFormatBigText: true
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "verses,",
                  "verses")));

      ///show local notification
      ///
    } else if (task == "ayahNotTest") {
      int suraNumber = Random().nextInt(114) + 1;
      int verseNumber = Random().nextInt(getVerseCount(suraNumber)) + 1;
      flutterLocalNotificationsPlugin.show(
          1,
          getVerse(suraNumber, verseNumber),
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    getVerse(suraNumber, verseNumber),
                    contentTitle: "Ayah",
                    htmlFormatBigText: true,
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "verses,",
                  "verses")));

      ///show local notification
      ///
    } else if (task == "hadithNot") {
      int suraNumber = Random().nextInt(42);
      flutterLocalNotificationsPlugin.show(
          1,
          hadithes[suraNumber]["hadith"],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    hadithes[suraNumber]["hadith"],
                    contentTitle: "Hadith",
                    htmlFormatBigText: true,
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "vehadith,",
                  "hadith")));
    } else if (task == "hadithNotTest") {
      int suraNumber = Random().nextInt(42);
      flutterLocalNotificationsPlugin.show(
          1,
          hadithes[suraNumber]["hadith"],
          "",
          notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  styleInformation: notificationPlugin.BigTextStyleInformation(
                    hadithes[suraNumber]["hadith"],
                    contentTitle: "Hadith",
                    htmlFormatBigText: true,
                  ),
                  "channelId",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "vehadith,",
                  "hadith")));

      ///show local notification
      ///
    } else if (task == "sallahEnable") {
      flutterLocalNotificationsPlugin.show(
          3,
          "صلِّ على النبي ﷺ",
          "",
          const notificationPlugin.NotificationDetails(
              android: notificationPlugin.AndroidNotificationDetails(
                  color: Colors.white,
                  "channelId3",
                  importance: notificationPlugin.Importance.max,
                  groupKey: "sallah",
                  "Sally",
                  ongoing: true)));
    } else if (task == "sallahDisable") {
      flutterLocalNotificationsPlugin.cancel(3);
    }
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;
// print(supported);
// print(active.refreshRate);

  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
// print(mostOptimalMode.refreshRate);
  /// This setting is per session.
  /// Please ensure this was placed with `initState` of your root widget.
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  //  final activee = await FlutterDisplayMode.active;
  //   print(mostOptimalMode.refreshRate);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  setup() async {
    // await    setupServiceLocator();
  }
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    downloadAndStoreHadithData();
    getAndStoreRecitersData();
    // checkNotificationPermission();
    // TODO: implement initState
    super.initState();
  }

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

  // BoxController boxController = BoxController();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //print(context.locale.toLanguageTag());
    return ScreenUtilInit(
        designSize: const Size(392.72727272727275, 800.7272727272727),
        builder: (context, child) => BlocProvider(
              create: (xc) => playerPageBloc,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'Skoon',
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      theme: ThemeData(
                        fontFamily: context.locale.languageCode == "ar"
                            ? "cairo"
                            : "roboto",
                        primarySwatch: Colors.blue,
                      ),
                      home: const Home()),
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
            ));
  }
}
