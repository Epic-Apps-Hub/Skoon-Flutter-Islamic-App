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
          Center(
            child: Image.asset(
              "assets/images/888-02.png",
              width: MediaQuery.of(context).size.width.w,
              height: 50.h,
              color: indexOfTheme != null
                  ? indexOfTheme != 1 &&indexOfTheme != 2 &&
                          indexOfTheme != 0 &&
                          indexOfTheme != 6 &&
                          indexOfTheme != 13 &&
                          indexOfTheme != 15
                      ? secondaryColors[indexOfTheme]
                      : null
                  : getValue("quranPageolorsIndex") != 1 &&getValue("quranPageolorsIndex") != 2 &&
                          getValue("quranPageolorsIndex") != 0&&
                          getValue("quranPageolorsIndex") != 6 &&
                          getValue("quranPageolorsIndex") != 13 &&
                          getValue("quranPageolorsIndex") != 15
                      ? secondaryColors[getValue("quranPageolorsIndex")]
                      : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19.7.w, vertical: 10.h),
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
                    child: RichText(
                      text: TextSpan(
text:    "${e["surah"]}",
                  style: TextStyle(
                    fontFamily: "arsura",
                    fontSize: 25.sp,
                    color: indexOfTheme == null
                        ? primaryColors[getValue("quranPageolorsIndex")]
                            .withOpacity(.9)
                        : primaryColors[indexOfTheme].withOpacity(.9),
                  ),

                      ),
                  textAlign: TextAlign.center,
               
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
