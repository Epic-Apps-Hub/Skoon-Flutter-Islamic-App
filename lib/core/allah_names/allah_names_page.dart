import 'package:adhan/adhan.dart';
import 'package:animate_do/animate_do.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:nabd/core/allah_names/data/allah_names.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart' as m;

class AllahNamesPage extends StatefulWidget {
  const AllahNamesPage({super.key});

  @override
  State<AllahNamesPage> createState() => _AllahNamesPageState();
}

class _AllahNamesPageState extends State<AllahNamesPage> {
  bool isGrid = true;

  testPrayer() {
    print('My Prayer Times');
    final myCoordinates = Coordinates(
        30.044420, 31.235712); // Replace with your own location lat, lng.
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    print(
        "---Today's Prayer Times in Your Local Timezone(${prayerTimes.fajr.timeZoneName})---");
    print(DateFormat.jm().format(prayerTimes.fajr));
    print(DateFormat.jm().format(prayerTimes.sunrise));
    print(DateFormat.jm().format(prayerTimes.dhuhr));
    print(DateFormat.jm().format(prayerTimes.asr));
    print(DateFormat.jm().format(prayerTimes.maghrib));
    print(DateFormat.jm().format(prayerTimes.isha));

    print('---');

    // // Custom Timezone Usage. (Most of you won't need this).
    // print('NewYork Prayer Times');
    // final newYork = Coordinates(35.7750, -78.6336);
    // const nyUtcOffset = Duration(hours: -4);
    // final nyDate = DateComponents(2015, 7, 12);
    // final nyParams = CalculationMethod.dubai.getParameters();
    // nyParams.madhab = Madhab.hanafi;
    // final nyPrayerTimes = PrayerTimes(newYork, nyDate, nyParams, utcOffset: nyUtcOffset);

    // print(nyPrayerTimes.fajr.timeZoneName);
    // print(DateFormat.jm().format(nyPrayerTimes.fajr));
    // print(DateFormat.jm().format(nyPrayerTimes.sunrise));
    // print(DateFormat.jm().format(nyPrayerTimes.dhuhr));
    // print(DateFormat.jm().format(nyPrayerTimes.asr));
    // print(DateFormat.jm().format(nyPrayerTimes.maghrib));
    // print(DateFormat.jm().format(nyPrayerTimes.isha));
  }

  @override
  void initState() {
    testPrayer();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);

    pageController = PageController(initialPage: indexx);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isGrid) {
      return false;
    } else {
      setState(() {
        isGrid = true;
      });
    }
    return true;
  }

  int indexx = 0;
  late PageController pageController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPrimaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkPrimaryColor,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isGrid = !isGrid;
                });
              },
              icon: Icon(isGrid == false
                  ? ModernPictograms.th
                  : ModernPictograms.th_list))
        ],
        title: Text(
          "asmaa".tr(),
          style: const TextStyle(fontFamily: 'cairo'),
        ),
        centerTitle: true,
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    "assets/images/try6.png",
                  ),
                  alignment: Alignment.center,
                  opacity: .24)),
          child: isGrid
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          isGrid = false;
                          indexx = index;
                        });
                        await Future.delayed(const Duration(milliseconds: 200));
                        pageController.animateToPage(index,
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            curve: Curves.easeIn);
                      },
                      child: Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: darkPrimaryColor.withOpacity(.5),
                            image: const DecorationImage(
                                image: AssetImage(
                                    "assets/images/nameborder.png"))),
                        child: Center(
                          child: Text(
                            allahNamesAr[index]["name"],
                            style: TextStyle(
                                color: const Color(0xffe0cb8a),
                                fontSize: 14.sp),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  child: PageView.builder(
                    itemBuilder: (context, int index) {
                      return Container(
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FadeIn(
                                  // tag: index.toString(),
                                  duration: const Duration(milliseconds: 1000),
                                  child: Container(
                                    height: 200.h,
                                    width: 200.w,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: darkPrimaryColor.withOpacity(.5),
                                        image: const DecorationImage(
                                            fit: BoxFit.contain,
                                            image: AssetImage(
                                              "assets/images/nameborder.png",
                                            ))),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FadeIn(
                                            duration: const Duration(
                                                milliseconds: 1100),
                                            child: Text(
                                              allahNamesAr[index]["name"],
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xffe0cb8a),
                                                  fontSize: 26.sp),
                                            ),
                                          ),
                                          FadeIn(
                                              duration: const Duration(
                                                  milliseconds: 1100),
                                              child: Text(
                                                allahNamesEnglish[index]
                                                    ["transliteration"],
                                                style: TextStyle(
                                                    color:
                                                        const Color(0xffe0cb8a),
                                                    fontSize: 17.sp),
                                              )),
                                          FadeIn(
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            child: Text(
                                              allahNamesEnglish[index]["en"]
                                                  ["meaning"],
                                              // textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xffe0cb8a),
                                                fontFamily: "cairo",
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          ),
                                          FadeIn(
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            child: Text(
                                              allahNamesEnglish[index]["fr"]
                                                  ["meaning"],
                                              // textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xffe0cb8a),
                                                fontFamily: "cairo",
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),

                            FadeIn(
                              duration: const Duration(milliseconds: 1500),
                              child: Text(
                                allahNamesAr[index]["text"],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "cairo",
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                            // SizedBox(height: 15.h),
                            // Image.asset(
                            //   "assets/images/divider.png",
                            //   color: const Color(0xffe0cb8a),
                            // ),
                            SizedBox(height: 15.h),
                            FadeIn(
                                duration: const Duration(milliseconds: 1500),
                                child: Text(
                                  allahNamesEnglish[index]["en"]["desc"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "cairo",
                                    fontSize: 18.sp,
                                  ),
                                )),
                            // SizedBox(height: 15.h),
                            // Image.asset(
                            //   "assets/images/divider.png",
                            //   color: const Color(0xffe0cb8a)
                            // ),
                            SizedBox(height: 15.h),
                            FadeIn(
                                duration: const Duration(milliseconds: 1500),
                                child: Text(
                                  decodeUnicode(
                                      allahNamesEnglish[index]["fr"]["desc"]),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "cairo",
                                    fontSize: 18.sp,
                                  ),
                                )),
                          ],
                        ),
                      );
                    },
                    itemCount: 100,
                    controller: pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (i) {
                      setState(() {
                        indexx = i;
                      });
                    },
                  ),
                )),
    );
  }

  String decodeUnicode(String text) {
    return text.replaceAllMapped(
      RegExp(r'\\u(\w{4})'),
      (match) {
        final charCode = int.parse(match.group(1)!, radix: 16);
        return String.fromCharCode(charCode);
      },
    );
  }
}
