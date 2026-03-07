import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/features/QuranPages/helpers/quran_page_utils.dart';
import 'package:quran/quran.dart';

class QuranPageHeader extends StatelessWidget {
  final int index;
  final dynamic jsonData;
  final dynamic quarterJsonData;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const QuranPageHeader({
    Key? key,
    required this.index,
    required this.jsonData,
    required this.quarterJsonData,
    required this.onBack,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final pageData = getPageData(index);
    final surahNumber = pageData[0]["surah"];
    final surahName = jsonData[surahNumber - 1]["name"];

    return SizedBox(
      width: screenSize.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: (screenSize.width * .27).w,
            child: Row(
              children: [
                IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 24.sp,
                      color: secondaryColors[getValue("quranPageolorsIndex")],
                    )),
                Text(surahName,
                    style: TextStyle(
                        color: secondaryColors[getValue("quranPageolorsIndex")],
                        fontFamily: "Taha",
                        fontSize: 14.sp)),
              ],
            ),
          ),
          SizedBox(
            width: (screenSize.width * .32).w,
            child: Center(
              child: Stack(
                children: [
                  _buildPageInfoChunk(index, pageData),
                ],
              ),
            ),
          ),
          SizedBox(
            width: (screenSize.width * .27).w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: onSettings,
                    icon: Icon(
                      Icons.settings,
                      size: 24.sp,
                      color: secondaryColors[getValue("quranPageolorsIndex")],
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPageInfoChunk(int index, dynamic pageData) {
    final result = QuranPageUtils.checkIfPageIncludesQuarterAndQuarterIndex(
        quarterJsonData, pageData, indexes);

    if (result.includesQuarter) {
      return EasyContainer(
        borderRadius: 12.r,
        color: secondaryColors[getValue("quranPageolorsIndex")]
            .withValues(alpha: .5),
        borderColor: primaryColors[getValue("quranPageolorsIndex")],
        showBorder: true,
        height: 20.h,
        width: 160.w,
        padding: 0,
        margin: 0,
        child: Text(
          result.includesQuarter == true
              ? "${"page".tr()} ${(index).toString()} | ${(result.quarterIndex + 1) == 1 ? "" : "${(result.quarterIndex).toString()}/${4.toString()}"} ${"hizb".tr()} ${(result.hizbIndex + 1).toString()} | ${"juz".tr()} ${getJuzNumber(pageData[0]["surah"], pageData[0]["start"])} "
              : "${"page".tr()} $index | ${"juz".tr()} ${getJuzNumber(pageData[0]["surah"], pageData[0]["start"])}",
          style: TextStyle(
            fontFamily: 'aldahabi',
            fontSize: 10.sp,
            color: backgroundColors[getValue("quranPageolorsIndex")],
          ),
        ),
      );
    } else {
      return EasyContainer(
        borderRadius: 12.r,
        color: secondaryColors[getValue("quranPageolorsIndex")]
            .withValues(alpha: .5),
        borderColor: backgroundColors[getValue("quranPageolorsIndex")],
        showBorder: true,
        height: 20.h,
        width: 120.w,
        padding: 0,
        margin: 0,
        child: Center(
          child: Text(
            "${"page".tr()} $index | ${"juz".tr()} ${getJuzNumber(pageData[0]["surah"], pageData[0]["start"])}",
            style: TextStyle(
              fontFamily: 'aldahabi',
              fontSize: 12.sp,
              color: backgroundColors[getValue("quranPageolorsIndex")],
            ),
          ),
        ),
      );
    }
  }
}
