import 'package:flutter/material.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:quran/quran.dart';
class HeaderWidget extends StatelessWidget {
  var e;
  var jsonData;
  var indexOfTheme;

  HeaderWidget(
      {super.key, required this.e, required this.jsonData, this.indexOfTheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Stack(
        children: [
          if (indexOfTheme != null)
            Center(
              child: Image.asset(
                headerPaths[indexOfTheme],
                width: MediaQuery.of(context).size.width.w,
                height: 50.h,
                color: indexOfTheme == 4 ? primaryColors[indexOfTheme] : null,
              ),
            ),
          if (indexOfTheme == null)
            Center(
              child: Image.asset(
                headerPaths[getValue("quranPageolorsIndex")],
                width: MediaQuery.of(context).size.width.w,
                height: 50.h,
                color: getValue("quranPageolorsIndex") == 4
                    ? primaryColors[getValue("quranPageolorsIndex")]
                    : null,
              ),
            ), //888-02-Recovered.png
 Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: headerPaths[getValue("quranPageolorsIndex")] ==
                            "assets/images/888-02-Recovered.png"
                        ? 17.w
                        : 19.7.w,
                    vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "اياتها\n${getVerseCount(e["surah"])}",
                      style: TextStyle(
                          // color: accentColor,
                          color: indexOfTheme == null
                              ? primaryColors[getValue("quranPageolorsIndex")]
                                  .withOpacity(.9)
                              : primaryColors[indexOfTheme].withOpacity(.92),
                          fontSize: 5.sp,
                          fontFamily: "UthmanicHafs13"),
                    ),
                    Center(
                        child: Text(
                      textAlign: TextAlign.center,
                      "${e["surah"]}",
                      style: TextStyle(
                        fontFamily: "arsura",
                        fontSize: 29.sp,
                        color: indexOfTheme == null
                            ? primaryColors[getValue("quranPageolorsIndex")]
                                .withOpacity(.9)
                            : primaryColors[indexOfTheme].withOpacity(.9),
                      ),
                    )),
                    Text(
                      "ترتيبها\n${e["surah"]}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          //color: accentColor,//
                          color: indexOfTheme == null
                              ? primaryColors[getValue("quranPageolorsIndex")]
                                  .withOpacity(.9)
                              : primaryColors[indexOfTheme].withOpacity(.9),
                          fontSize: 5.sp,
                          fontFamily: "UthmanicHafs13"),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
