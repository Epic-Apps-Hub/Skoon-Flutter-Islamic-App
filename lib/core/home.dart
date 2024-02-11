import 'dart:async';
import 'dart:convert';

// import 'package:alert_system/alert_overlay_plugin.dart';
// import 'package:alert_system/systems/initializer.dart';
import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:nabd/blocs/bloc/hadith_bloc.dart';
import 'package:nabd/blocs/bloc/player_bloc_bloc.dart';
import 'package:nabd/blocs/bloc/quran_page_player_bloc.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/initializeData.dart';
import 'package:nabd/core/QuranPages/views/quran_sura_list.dart';
import 'package:nabd/core/allah_names/allah_names_page.dart';
import 'package:nabd/core/audiopage/views/audio_home_page.dart';
import 'package:nabd/core/azkar/views/azkar_homepage.dart';

import 'package:nabd/core/hadith/views/hadithbookspage.dart';
import 'package:nabd/core/live_tv/live_tv_page.dart';
import 'package:nabd/core/notifications/views/all_notification_page.dart';
import 'package:nabd/core/qibla/q_compass.dart';
import 'package:nabd/core/qibla/qibla_page.dart';
import 'package:nabd/core/radio_page/radio_page.dart';
import 'package:nabd/core/sibha/sibha_page.dart';
import 'package:nabd/core/support/support_page.dart';
import 'package:periodic_alarm/model/alarms_model.dart';
import 'package:periodic_alarm/periodic_alarm.dart';
import 'package:periodic_alarm/services/alarm_notification.dart';
import 'package:periodic_alarm/services/alarm_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:after_layout/after_layout.dart';
import 'package:workmanager/workmanager.dart';
import 'package:periodic_alarm/src/android_alarm.dart';
import 'package:flutter/material.dart';

final qurapPagePlayerBloc = QuranPagePlayerBloc();
final playerPageBloc = PlayerBlocBloc();
final hadithPageBloc = HadithBloc();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with
        AfterLayoutMixin,
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  var widgejsonData;
  var quarterjsonData;
  // BoxController boxController = BoxController();
  // StreamController<AlarmSettings> alarmStream = Alarm.ringStream;
  getAndStoreRadioData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response response;

    try {
      if (context.locale.languageCode == "ms") {
        response =
            await Dio().get('http://mp3quran.net/api/v3/radios?language=eng');
      } else {
        response = await Dio().get(
            'http://mp3quran.net/api/v3/radios?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
      }
      if (response.data != null) {
        final jsonData = json.encode(response.data['radios']);
        prefs.setString(
            "radios-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
            jsonData);
      }
    } catch (error) {
      print('Error while storing data: $error');
    }
  }

  StreamSubscription? _subscription;
  StreamSubscription? _subscription2;
  bool alarm = false;
  bool alarm1 = false;
  int? id;

  Future<void> loadJsonAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/surahs.json');
    var data = jsonDecode(jsonString);
    setState(() {
      widgejsonData = data;
    });
    final String jsonString2 =
        await rootBundle.loadString('assets/json/quarters.json');
    var data2 = jsonDecode(jsonString2);
    setState(() {
      quarterjsonData = data2;
    });

    //print(widgejsonData);
  }

  checkSalahNotification() {
    if (getValue("shouldShowSallyNotification") == true) {
      Workmanager().registerOneOffTask("sallahEnable", "sallahEnable");
    } else {
      Workmanager().registerOneOffTask("sallahDisable", "sallahDisable");
    }
  }

  late Timer _timer;
  // static StreamSubscription<AlarmSettings>? subscription;
  configureSelectNotificationSubject() {
    _subscription2 ??= AlarmNotification.selectNotificationStream.stream
        .listen((String? payload) async {
      print("payload");
      print(payload);
      List<String> payloads = [];
      AlarmModel? alarmModel;
      payloads.add(payload!);
      for (var element in payloads) {
        if (int.tryParse(element) != null) {
          id = int.tryParse(element);
          alarmModel = PeriodicAlarm.getAlarmWithId(id!);
          print(id);

          setState(() {});
        } else if (element == 'Stop') {
          print(id);

          PeriodicAlarm.stop(id!);
        } else if (element == "") {
          print("------------------ ERROR");
          openAlarmScreen();
        }
      }
    });
  }

  Future<void> setAlarm(int id, DateTime dt, String azan, String locale) async {
    AlarmModel alarmModel = AlarmModel(
        id: id,
        dateTime: dt,
        assetAudioPath: 'assets/audio/azan.mp3',
        notificationTitle: locale == "ar" ? "المؤزن" : "Prayer Alarm",
        notificationBody: locale == "ar"
            ? "حان الأن موعد أذان ${prayers.where((element) => element[0] == azan).first[1]}"
            : 'Now is $azan time',
        // monday: true,
        // tuesday: true,
        // wednesday: true,
        // thursday: true,
        // friday: true,
        active: false,
        musicTime: 0,
        loopAudio: false,
        incMusicTime: 0,
        musicVolume: .5,
        incMusicVolume: .5);

    if (alarmModel.days.contains(true)) {
      PeriodicAlarm.setPeriodicAlarm(alarmModel: alarmModel);
    } else {
      PeriodicAlarm.setOneAlarm(alarmModel: alarmModel);
    }
  }

  openAlarmScreen() async {
    Future.delayed(const Duration(seconds: 1), () async {
      var alarms = await AlarmStorage.getAlarmRinging();
      if (alarms.isNotEmpty) {
        Navigator.of(context).push(
            CupertinoPageRoute(builder: (builder) => const AlarmScreen()));
      }
    });
  }

  onRingingControl() {
    _subscription = PeriodicAlarm.ringStream.stream.listen(
      (alarmModel) async {
        print("start listening for");
        openAlarmScreen();
        // if (alarmModel.days.contains(true)) {
        //   alarmModel.setDateTime = alarmModel.dateTime.add(Duration(days: 1));
        //   PeriodicAlarm.setPeriodicAlarm(alarmModel: alarmModel);
        // }
      },
    );

    setState(() {});
  }

  @override
  void initState() {
    //checkAzanRinging() ;
    checkSalahNotification();
    downloadAndStoreHadithData();
    getAndStoreRecitersData();
    getAndStoreRadioData();
    //boxController.hideBox();
    initHiveValues(); // TODO: implement initState
    super.initState();
    // boxController.hideBox();
    // AlertWindowHelper.requestPermission();
    loadJsonAsset();
    // subscription = Alarm.ringStream.stream.listen((event) {
    //   print(event.notificationBody);
    // });
    // subscription!.onData((data) {
    //   print(data.notificationTitle);
    // });
    // getPrayerTimesData();

    // _timeLeftController = StreamController<Duration>();
    // _timeLeftStream = _timeLeftController.stream.asBroadcastStream();

    // // Update the time left every second
    // _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   _updateTimeLeft();
    // });
    // configureSelectNotificationSubject();
    // onRingingControl();
  }

  @override
  void dispose() {
    // AndroidAlarm.audioPlayer.dispose();

    // subscription!.cancel();
    // alarmStream.close();
    // _timeLeftController.close();
    // _timer.cancel(); // Cancel the timer

    super.dispose();
  }

  String getNativeLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'am':
        return 'አማርኛ';
      case 'jp':
        return '日本語';
      case 'ms':
        return 'Melayu';
      case 'pt':
        return 'Português';
      case 'tr':
        return 'Türkçe';
      case 'ru':
        return 'Русский';
      default:
        return languageCode; // Return the language code if not found
    }
  }

  late StreamController<Duration> _timeLeftController;
  late Stream<Duration> _timeLeftStream;
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

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("working");
    Response response;
    Response response2;
    Response response3;
    try {
      if (context.locale.languageCode == "ms") {
        response =
            await Dio().get('http://mp3quran.net/api/v3/reciters?language=eng');
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
      print("worked");
    } catch (error) {
      print('Error while storing data: $error');
    }

    prefs.setInt("zikrNotificationindex", 0);
  }

  DateTime dateTime = DateTime.now();

  var prayerTimes;
  bool isLoading = true;
  bool reload = false;
  getPrayerTimesData() async {
    DateTime dateTime = DateTime.now();
    if (getValue("prayerTimes/${dateTime.year}/${dateTime.month}") == null ||
        reload) {
      await Geolocator.requestPermission();
      Position geolocation = await Geolocator.getCurrentPosition();
      await placemarkFromCoordinates(
              geolocation.latitude, geolocation.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        updateValue("currentCity", place.subAdministrativeArea!);
        updateValue("currentCountry", place.country!);
      });
      Response response = await Dio().get(
          "https://api.aladhan.com/v1/calendar/${dateTime.year}/${dateTime.month}?latitude=${geolocation.latitude}&longitude=${geolocation.longitude}");
      updateValue(
          "prayerTimes/${dateTime.year}/${dateTime.month}", response.data);
    }
    prayerTimes = getValue("prayerTimes/${dateTime.year}/${dateTime.month}");
    final currentDateTime = DateTime.now();
    final currentFormattedTime =
        DateFormat('HH:mm').format(currentDateTime.toUtc());
    // setAllarmsForTheMonth();
    var prayerTimings = prayerTimes["data"][dateTime.day]["timings"];
    for (var prayer in prayerTimings.keys) {
      if (currentFormattedTime.compareTo(prayerTimings[prayer]!) < 0) {
        nextPrayer = prayer;
        nextPrayerTime = prayerTimings[prayer]!;
        break;
      }
    }

    if (nextPrayer.isEmpty ||
        nextPrayer == "Imsak" ||
        nextPrayer == "Firstthird" ||
        nextPrayer == "Midnight" ||
        nextPrayer == "Lastthird") {
      nextPrayer = 'Fajr';
      nextPrayerTime = prayerTimings['Fajr']!;
    }
    print("nextPrayer: $nextPrayer");
    print("nextPrayerTime: $nextPrayerTime");

    setState(() {
      isLoading = false;
    });
    setAllarmsForTheMonth();
    print(nextPrayer);
  }

  setAllarmsForTheMonth() async {
    await Future.delayed(const Duration(seconds: 1));
    // Loop through each data entry
    for (var entry in prayerTimes["data"]) {
      var dateInfo = entry["date"];
      var gregorianDate = dateInfo["gregorian"];
      var timings = entry["timings"];

      // Specify the prayer times you want to use
      var prayerTimesToUse = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

      // Filter out unwanted prayer times
      var filteredTimings = timings.entries
          .where((entry) => prayerTimesToUse.contains(entry.key));

      // Loop through each filtered prayer time
      for (var prayerEntry in filteredTimings) {
        var prayer = prayerEntry.key;
        var time = prayerEntry.value;
        print("prayer time: " + time);
        print("prayer" + prayer);
        // Parse the time string
        var timeComponents = time.split(' ')[0].split(':');
        var hour = int.parse(timeComponents[0]);
        var minute = int.parse(timeComponents[1].split(' ')[0]);

        // Create the DateTime object using the date and time information
        var prayerDateTime = DateTime.utc(
          int.parse(gregorianDate["year"]),
          gregorianDate["month"]["number"],
          int.parse(gregorianDate["day"]),
          hour,
          minute,
        );

        if (prayerDateTime.isBefore(DateTime.now())) {
        } else {
          // setAlarm(dateTime.month * 100 + dateTime.day+prayers.indexOf((element) => element[0]==prayer), prayerDateTime,prayer, context.locale.languageCode);
          setAlarm(
              (prayerDateTime.month * prayerDateTime.month) * 10 +
                  (prayerDateTime.day * prayerDateTime.day) * 10 +
                  (prayers.indexWhere((element) => element[0] == prayer) + 1) *
                      10,
              prayerDateTime,
              prayer,
              context.locale.languageCode);
        }

        // var alarmSettings = AlarmSettings(
        //   id: dateTime.month * 100 + dateTime.day,
        //   dateTime: prayerDateTime,
        //   assetAudioPath: 'assets/images/azan.mp3',
        //   loopAudio: false,
        //   vibrate: false,
        //   volume: 0.8,
        //   fadeDuration: 3.0,
        //   notificationTitle: 'المؤزن',
        //   notificationBody:
        //       '${prayers.where((element) => element[0] == prayer).first[1]} حان الان موعد اذان',
        //   enableNotificationOnKill: false,
        // );
        // await Alarm.set(alarmSettings: alarmSettings);
        // Print or use the prayerDateTime as needed
        // print('$prayer: $prayerDateTime');
      }
    }
    getAlarms();
    final currentDateTime = DateTime.now();
    final nextPrayerTim = DateTime.parse(
        "${DateFormat('yyyy-MM-dd').format(currentDateTime)} ${nextPrayerTime.split(' ')[0]}");

    prayerTimes = getValue("prayerTimes/${dateTime.year}/${dateTime.month}");
    for (var i = dateTime.day; i < prayerTimes["data"].length; i++) {
      var prayerTimings = prayerTimes["data"][i]["timings"];
    }
  }

  String nextPrayer = '';
  String nextPrayerTime = '';
  int index = 1;
  void _updateTimeLeft() {
    final currentDateTime = DateTime.now();
    final nextPrayerTim = DateTime.parse(
        "${DateFormat('yyyy-MM-dd').format(currentDateTime)} ${nextPrayerTime.split(' ')[0]}");
    if (nextPrayer == "Fajr") {
      if (currentDateTime.isAfter(nextPrayerTim)) {
        final currentDateTime2 = DateTime.now();
        final nextPrayerTim2 = DateTime.parse(
                "${DateFormat('yyyy-MM-dd').format(currentDateTime)} ${nextPrayerTime.split(' ')[0]}")
            .add(const Duration(days: 1));
        final timeLeft = nextPrayerTim2.difference(currentDateTime2);
        _timeLeftController.add(timeLeft);
      } else {
        if (currentDateTime.isBefore(nextPrayerTim)) {
          final timeLeft = nextPrayerTim.difference(currentDateTime);
          _timeLeftController.add(timeLeft);
        }
      }
    } else {
      if (currentDateTime.isBefore(nextPrayerTim)) {
        final timeLeft = nextPrayerTim.difference(currentDateTime);
        _timeLeftController.add(timeLeft);
      }
    }
  }

  List prayers = [
    ["Fajr", "الفجر"],
    ["Sunrise", "الشروق"],
    ["Dhuhr", "الظهر"],
    ["Asr", "العصر"],
    ["Maghrib", "المغرب"],
    ["Isha", "العشاء"]
  ];
  getLocationData() {}
  String currentCity = "";

  String currentCountry = "";
  getAlarms() async {
    List<AlarmModel> alarms = AlarmStorage.getSavedAlarms();
    print("alarms.length");
    print(alarms.length);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // print(screenSize.height);
    // print(screenSize.width);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            height: screenSize.height,
            decoration: BoxDecoration(
                color: index == 1 ? quranPagesColor : darkPrimaryColor,
                image: index == 1
                    ? const DecorationImage(
                        image: AssetImage("assets/images/homebackground.png"),
                        alignment: Alignment.topCenter,
                        opacity: .2)
                    : DecorationImage(
                        image: AssetImage((DateTime.now().hour < 17 &&
                                DateTime.now().hour > 6)
                            ? "assets/images/daytimetry2.png"
                            : "assets/images/prayerbackgroundnight.png"),
                        alignment: Alignment.topCenter,
                        fit: (DateTime.now().hour < 17 &&
                                DateTime.now().hour > 6)
                            ? BoxFit.fill
                            : BoxFit.scaleDown,
                        opacity: .2)),
            child: Container(
              width: screenSize.width,
              // height: screenSize.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: const AssetImage("assets/images/try2.png"),
                      alignment: Alignment.bottomCenter,
                      opacity: index == 1 ? .2 : 0)),
              child: PageTransitionSwitcher(
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return FadeThroughTransition(
                    fillColor: Colors.transparent,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                child: [
                  Container(),
                  // SingleChildScrollView(
                  //   child: Column(
                  //     children: [
                  //       SizedBox(
                  //         height: 45.h,
                  //       ),
                  //       SizedBox(
                  //         height: 40.h,
                  //         child: Padding(
                  //           padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               EasyContainer(
                  //                   padding: 0,
                  //                   customPadding:
                  //                       EdgeInsets.symmetric(horizontal: 3.w),
                  //                   borderRadius: 99.r,
                  //                   color: Colors.redAccent,
                  //                   onTap: () {
                  //                     setState(() {
                  //                       index = 1;
                  //                     });
                  //                   },
                  //                   child: Padding(
                  //                     padding: EdgeInsets.symmetric(
                  //                         horizontal: 14.0.w),
                  //                     child: Center(
                  //                         child: Row(
                  //                       children: [
                  //                         Icon(
                  //                           Icons.arrow_back_ios,
                  //                           size: 24.sp,
                  //                           color: Colors.white,
                  //                         ),
                  //                         Icon(
                  //                           Icons.home_filled,
                  //                           size: 24.sp,
                  //                           color: Colors.white,
                  //                         ),
                  //                       ],
                  //                     )),
                  //                   )),
                  //               Row(
                  //                 children: [
                  //                   EasyContainer(
                  //                       padding: 0,
                  //                       customPadding: EdgeInsets.symmetric(
                  //                           horizontal: 3.w),
                  //                       borderRadius: 99,
                  //                       color: Colors.redAccent,
                  //                       onTap: () {
                  //                         setState(() {
                  //                           index = 1;
                  //                         });
                  //                       },
                  //                       child: Padding(
                  //                         padding: EdgeInsets.symmetric(
                  //                             horizontal: 8.0.w),
                  //                         child: Center(
                  //                             child: Row(
                  //                           children: [
                  //                             Switch(
                  //                                 value: getValue(
                  //                                     "shouldUsePrayerTimes"),
                  //                                 onChanged: (value) {
                  //                                   updateValue(
                  //                                       "shouldUsePrayerTimes",
                  //                                       value);
                  //                                   setState(() {});
                  //                                 }),
                  //                             const Icon(
                  //                               Icons.alarm,
                  //                               color: Colors.white,
                  //                             ),
                  //                           ],
                  //                         )),
                  //                       )),
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 25.h,
                  //       ),
                  //       Container(
                  //         width: screenSize.width * .6,
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(22),
                  //             color: (DateTime.now().hour < 17 &&
                  //                     DateTime.now().hour > 6)
                  //                 ? darkPrimaryColor.withOpacity(.4)
                  //                 : Colors.grey.withOpacity(.4)),
                  //         child: Padding(
                  //           padding: EdgeInsets.symmetric(horizontal: 3.0.w),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               if (getValue("currentCity") != null &&
                  //                   getValue("currentCountry") != null)
                  //                 Padding(
                  //                   padding:
                  //                       EdgeInsets.symmetric(horizontal: 8.0.w),
                  //                   child: SizedBox(
                  //                     width: screenSize.width * .4,
                  //                     child: Text(
                  //                       "${getValue("currentCity")}, ${getValue("currentCountry")}",
                  //                       overflow: TextOverflow.ellipsis,
                  //                       style: TextStyle(
                  //                         color: Colors.white,
                  //                         fontSize: 14.sp,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               EasyContainer(
                  //                 onTap: () {
                  //                   setState(() {
                  //                     reload = true;
                  //                   });
                  //                   getPrayerTimesData();
                  //                 },
                  //                 height: 43.h,
                  //                 borderRadius: 99.r,
                  //                 padding: 0,
                  //                 customPadding:
                  //                     EdgeInsets.symmetric(horizontal: 15.w),
                  //                 color: Colors.redAccent,
                  //                 child: Icon(
                  //                   Entypo.arrows_ccw,
                  //                   size: 12.sp,
                  //                   color: Colors.white,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  // if(prayerTimes!=null)      Center(
                  //         child: Text(
                  //           prayerTimes["data"][dateTime.day - 1]["date"]
                  //               ["hijri"]["weekday"]["ar"],
                  //           style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 22.sp,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //       ),
                  //       if(prayerTimes!=null)      Center(
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text(
                  //               prayerTimes["data"][dateTime.day - 1]["date"]
                  //                   ["hijri"]["day"],
                  //               style: TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 18.sp,
                  //                   fontWeight: FontWeight.bold),
                  //             ),
                  //             const Text(" "),
                  //             Text(
                  //               prayerTimes["data"][dateTime.day - 1]["date"]
                  //                   ["hijri"]["month"]["ar"],
                  //               style: TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 18.sp,
                  //                   fontWeight: FontWeight.bold),
                  //             ),
                  //             const Text(" "),
                  //             Text(
                  //               prayerTimes["data"][dateTime.day - 1]["date"]
                  //                   ["hijri"]["year"],
                  //               style: TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 18.sp,
                  //                   fontWeight: FontWeight.bold),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //        if(prayerTimes!=null)     Text(
                  //         prayerTimes["data"][dateTime.day - 1]["date"]
                  //             ["readable"],
                  //         style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 16.sp,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //       SizedBox(
                  //         height: 10.h,
                  //       ),
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: CircleAvatar(
                  //           backgroundColor: Colors.redAccent,
                  //           radius: 75,
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               Text(
                  //                 "بقي علي",
                  //                 style: TextStyle(
                  //                     color: Colors.white.withOpacity(.5),
                  //                     fontSize: 12.sp,
                  //                     fontWeight: FontWeight.bold),
                  //               ),
                  //              if(  prayers
                  //                         .where((element) =>
                  //                             element[0] == nextPrayer).isNotEmpty) Text(
                  //                 prayers
                  //                         .where((element) =>
                  //                             element[0] == nextPrayer)
                  //                         .first[0] +
                  //                     " - " +
                  //                     prayers
                  //                         .where((element) =>
                  //                             element[0] == nextPrayer)
                  //                         .first[1],
                  //                 style: TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 16.sp,
                  //                 ),
                  //               ),
                  //               StreamBuilder<Duration>(
                  //                 stream: _timeLeftStream,
                  //                 builder: (context, snapshot) {
                  //                   if (snapshot.hasData) {
                  //                     print(snapshot.data!.inHours);
                  //                     final hoursLeft = snapshot.data!
                  //                         .inHours; //final formattedHours = hoursLeft == 0 ? '00' : hoursLeft.toString();

                  //                     final minutesLeft = snapshot
                  //                         .data!.inMinutes
                  //                         .remainder(60);
                  //                     // Format hours and minutes as "00" if less than 10
                  //                     final formattedHours =
                  //                         hoursLeft.toString().padLeft(2, '0');
                  //                     final formattedMinutes = minutesLeft
                  //                         .toString()
                  //                         .padLeft(2, '0');

                  //                     return Text(
                  //                       '$formattedHours :$formattedMinutes',
                  //                       textDirection: m.TextDirection.ltr,
                  //                       style: TextStyle(
                  //                           fontSize: 20.sp,
                  //                           color: Colors.white),
                  //                     );
                  //                   } else {
                  //                     return const Text(
                  //                       '...',
                  //                       // style: TextStyle(fontSize: 20),
                  //                     );
                  //                   }
                  //                 },
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 30.h,
                  //       ),
                  //       isLoading
                  //           ? const CircularProgressIndicator()
                  //           : Container(
                  //               child: Column(
                  //                   children: prayers
                  //                       .map((e) => Column(
                  //                             children: [
                  //                               Row(
                  //                                 mainAxisAlignment:
                  //                                     MainAxisAlignment
                  //                                         .spaceAround,
                  //                                 children: [
                  //                                   Column(
                  //                                     children: [
                  //                                       Text(
                  //                                         e[1],
                  //                                         style: TextStyle(
                  //                                             color: e[0] ==
                  //                                                     nextPrayer
                  //                                                 ? Colors
                  //                                                     .redAccent
                  //                                                 : Colors
                  //                                                     .white,
                  //                                             fontSize: 16.sp),
                  //                                       ),
                  //                                       Text(
                  //                                         e[0],
                  //                                         style: TextStyle(
                  //                                             color: e[0] ==
                  //                                                     nextPrayer
                  //                                                 ? Colors
                  //                                                     .redAccent
                  //                                                     .withOpacity(
                  //                                                         .8)
                  //                                                 : Colors.white
                  //                                                     .withOpacity(
                  //                                                         .8),
                  //                                             fontSize: 12.sp),
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                   Text(
                  //                                     prayerTimes["data"]
                  //                                                 [dateTime.day]
                  //                                             ["timings"][e[0]]
                  //                                         .split(" ")[0],
                  //                                     style: TextStyle(
                  //                                         color: e[0] ==
                  //                                                 nextPrayer
                  //                                             ? Colors.redAccent
                  //                                             : Colors.white,
                  //                                         fontSize: 16.sp),
                  //                                   ),
                  //                                 ],
                  //                               ),
                  //                               SizedBox(
                  //                                 height: 12.h,
                  //                               ),
                  //                               Padding(
                  //                                 padding: const EdgeInsets
                  //                                     .symmetric(
                  //                                     horizontal: 60.0),
                  //                                 child: Divider(
                  //                                   color: Colors.white
                  //                                       .withOpacity(.6),
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ))
                  //                       .toList()),
                  //             ),
                  //       // StreamBuilder<AlarmSettings>(
                  //       //   stream: alarmStream.stream,
                  //       //   builder: (BuildContext context, snapshot) {
                  //       //     if (snapshot.hasData) {
                  //       //       return EasyContainer(
                  //       //           onTap: () async {
                  //       //             await Alarm.stop(snapshot.data!.id);
                  //       //           },
                  //       //           child: Text(
                  //       //             snapshot.data!.notificationBody,
                  //       //             style: const TextStyle(color: Colors.red),
                  //       //           ));
                  //       //     }
                  //       //     return Container();
                  //       //   },
                  //       // ),
                  //     ],
                  //   ),
                  // ),

                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height,
                    child: ListView(shrinkWrap: true,//physics: const NeverScrollableScrollPhysics(),
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width.w,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'main'.tr(),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "cairo",
                                      fontSize: 32.sp),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: DropdownButton<Locale>(
                                      value: context.locale,
                                      onChanged: (Locale? newValue) {
                                        context.setLocale(newValue!);
                                        getAndStoreRecitersData();
                                        getAndStoreRadioData();
                                        downloadAndStoreHadithData();
                                      },
                                      items: [
                                        const Locale("ar"),
                                        const Locale('en'),
                                        const Locale('de'),
                                        const Locale("am"),
                                        // const Locale("jp"),
                                        const Locale("ms"),
                                        const Locale("pt"),
                                        const Locale("tr"),
                                        const Locale("ru")
                                      ].map<DropdownMenuItem<Locale>>(
                                          (Locale locale) {
                                        return DropdownMenuItem<Locale>(
                                          value: locale,
                                          child: Text(getNativeLanguageName(
                                              locale.languageCode)),
                                        );
                                      }).toList(),
                                    )),
                                // GestureDetector(
                                //     onTap: () {
                                //       setState(() {
                                //         index = 0;
                                //       });
                                //     },
                                //     child: const CircleAvatar(
                                //       backgroundImage:
                                //           AssetImage("assets/images/azan.jpg"),
                                //     ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 55.h),
                        // Image.asset(
                        //   "assets/images/iconlauncher.png",
                        //   height: 120.h,
                        //   // color: Colors.white,
                        // ),
                        // Center(
                        //     child: Text(
                        //   "skoon".tr(),
                        //   style: TextStyle(
                        //       color: Colors.white,
                        //       fontFamily: "cairo",
                        //       fontSize: 14.sp),
                        // )),
                        SizedBox(height: 10.h),
                        // Image.asset(
                        //   'assets/quranverse-logo.png', // Make sure to place your logo image in the 'assets' folder
                        //   width: 150,
                        //   height: 150,
                        // ),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.0.w),
                          child: SizedBox(
                            // height: screenSize.height * .5,
                            child: ListView(shrinkWrap: true,physics: const NeverScrollableScrollPhysics(),
                              children: [   SuperellipseButton(
                                    text: "quran".tr(),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (builder) =>
                                                  SurahListPage(
                                                    jsonData: widgejsonData,
                                                    quarterjsonData:
                                                        quarterjsonData,
                                                  )));
                                    },
                                    imagePath: "assets/images/qlogo.png"),
                               
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 1,
                                  crossAxisCount: 2,
                                  children: <Widget>[
                                  SuperellipseButton(
                                        text: "audios".tr(),
                                        onPressed: () {
                                          // SystemChrome.setEnabledSystemUIMode(
                                          //     SystemUiMode.immersiveSticky);
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      BlocProvider(
                                                        create: (create) =>
                                                            playerPageBloc,
                                                        child: RecitersPage(
                                                          jsonData: widgejsonData,
                                                        ),
                                                      )));
                                        },
                                        imagePath: "assets/images/quranlogo.png"),
                                    SuperellipseButton(
                                        text: "Hadith".tr(),
                                        onPressed: () {
                                          // SystemChrome.setEnabledSystemUIMode(
                                          //     SystemUiMode.immersiveSticky);
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      BlocProvider(
                                                        create: (context) =>
                                                            hadithPageBloc,
                                                        child: HadithBooksPage(
                                                            locale: context.locale
                                                                .languageCode),
                                                      )));
                                        },
                                        imagePath: "assets/images/muhammed.png"),
                                    SuperellipseButton(
                                        text: "livetv".tr(),
                                        onPressed: () async {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      const LiveTvPage()));
                                        },
                                        imagePath: "assets/images/tv.png"),
                                    SuperellipseButton(
                                        text: "radios".tr(),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      const RadioPage()));
                                        },
                                        imagePath: "assets/images/radio.png"),
                                    SuperellipseButton(
                                        text: "qibla".tr(),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      const CompassWithQibla()));
                                        },
                                        imagePath: "assets/images/qaaba.png"),
                                    SuperellipseButton(
                                        text: "asmaa".tr(),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (c) =>
                                                      const AllahNamesPage()));
                                        },
                                        imagePath: "assets/images/names.svg"),
                                    SuperellipseButton(
                                        text: "azkar".tr(),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: ((context) =>
                                                      const AzkarHomePage())));
                                          //boxController.openBox();
                                        },
                                        imagePath: "assets/images/azkar.png"),
                                    SuperellipseButton(
                                        text: "notifications".tr(),
                                        onPressed: () async {
                                          // await FlutterOverlayWindow.requestPermission();
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      const NotificationsPage()));
                                        },
                                        imagePath:
                                            "assets/images/notifications.png"),
                                    SuperellipseButton(
                                        text: "sibha".tr(),
                                        onPressed: () async {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      const SibhaPage()));
                                        },
                                        imagePath:
                                            "assets/images/sibha.png"), // Add more buttons for other features
                                    SuperellipseButton(
                                        text: "support".tr(),
                                        onPressed: () async {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (builder) =>
                                                      const SupportPage()));
                                        },
                                        imagePath:
                                            "assets/images/support.png"), // Add more buttons for other features
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 85.h),
                      ],
                    ),
                  ),
                ][index],
              ),
            )));
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    // boxController.hideBox();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class SuperellipseButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String imagePath;

  const SuperellipseButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0.w, vertical: 6.h),
      child: Material(
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(.2),
        shape: SuperellipseShape(
          borderRadius: BorderRadius.circular(34.0.r),
        ),
        child:
            // AnimatedOpacity(
            // duration: const Duration(milliseconds: 500),
            // opacity: dominantColor != null ? 1.0 : 0,
            // child:
            InkWell(
          onTap: onPressed,
          splashColor: quranPagesColor,
          borderRadius: BorderRadius.circular(17.0.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: text == "الأذكار والأدعية" ? 12.h : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(text=="quran".tr())
                SizedBox(height: 24.h,),
                if (imagePath.contains("svg"))
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: SvgPicture.asset(
                      color: Colors.white,
                      imagePath,
                      height: (MediaQuery.of(context).size.height * .075),
                    ),
                  ),
                if (imagePath.contains("svg") == false)
                  Image.asset(
                    imagePath,
                    height: (MediaQuery.of(context).size.height * .075),
                    color: Colors.white,
                  ),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontFamily: "cairo"),
                ), if(text=="quran".tr())
                SizedBox(height: 24.h,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  StreamSubscription? _subscription2;
  AlarmModel? alarmModel;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getAlarm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getAlarm() async {
    List<String> alarms = await AlarmStorage.getAlarmRinging();
    AlarmModel? alarm = AlarmStorage.getAlarm(int.parse(alarms.last));

    alarmModel = alarm;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final alarmModel = ModalRoute.of(context)!.settings.arguments as AlarmModel;
    return Scaffold(
      body: Container(
        child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/praying.png"))),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              alarmModel!.notificationTitle!,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.sp),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              alarmModel!.notificationBody!,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.sp),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EasyContainer(
                                borderRadius: 25,
                                customPadding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                onTap: () {
                                  PeriodicAlarm.stop(alarmModel!.id);
                                  Navigator.of(context)
                                      .popUntil(ModalRoute.withName('/'));
                                },
                                child: const Text('Stop the Azan')),
                          ],
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }
}
