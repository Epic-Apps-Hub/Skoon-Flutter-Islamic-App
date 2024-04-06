import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/QuranPages/helpers/convertNumberToAr.dart';
import 'package:nabd/core/QuranPages/helpers/translation/get_translation_data.dart';
import 'package:nabd/core/QuranPages/helpers/translation/translationdata.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:quran/quran.dart' as quran;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TafseerAndTranslateSheet extends StatefulWidget {
  int surahNumber;
  int verseNumber;
  bool isVerseByVerseSelection;
  TafseerAndTranslateSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,required this.isVerseByVerseSelection
  });

  @override
  State<TafseerAndTranslateSheet> createState() =>
      _TafseerAndTranslateSheetState();
}

class _TafseerAndTranslateSheetState extends State<TafseerAndTranslateSheet> {
  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
  String data = "";

  int verseNumber = 0;
  Directory? appDir;
  initialize() async {
    appDir = await getTemporaryDirectory();

    if (mounted) {
      setState(() {});
    }
  }

  getData() async {
    data = await getVerseTranslation(
        widget.surahNumber,
        widget.verseNumber + verseNumber,
        translationDataList[getValue("indexOfTranslation") ?? 0]);
    setState(() {});
  }

  @override
  void initState() {
    getData();
    initialize();
    super.initState();
  }

  String isDownloading = "";
  @override
  Widget build(BuildContext context) {
    // print(widget.surahNumber);
    // print(widget.verseNumber);
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .9,
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      if ((widget.verseNumber + verseNumber) > 1) {
                        setState(() {
                          verseNumber = verseNumber - 1;
                        });
                      }getData();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 16.sp,
                      color: (widget.verseNumber + verseNumber > 1)
                          ? getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                          : Colors.grey.withOpacity(.4),
                    )),
                SizedBox(
                  width: 5.w,
                ),
                Center(
                  child: Text(
                    convertToArabicNumber(
                        (widget.verseNumber + verseNumber).toString()),
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 32.sp,
                        fontFamily: "KFGQPC Uthmanic Script HAFS Regular"),
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                IconButton(
                    onPressed: () {
                      if (widget.verseNumber + verseNumber !=
                          quran.getVerseCount(widget.surahNumber)) {
                        setState(() {
                          verseNumber = verseNumber + 1;
                        });getData();
                      }
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: (widget.verseNumber + verseNumber !=
                              quran.getVerseCount(widget.surahNumber))
                          ? getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                          : Colors.grey.withOpacity(.4),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                locale: const Locale("ar"),
                textAlign: TextAlign.center,
                quran.getVerse(
                  widget.surahNumber,
                  widget.verseNumber + verseNumber,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  // wordSpacing: -1.4,
                  fontFamily: getValue("selectedFontFamily"),
                ),
              ),
            ),

            SizedBox(
              height: 15.h,
            ),

            Directionality(
              textDirection: m.TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    showMaterialModalBottomSheet(
                        enableDrag: true,
                        animationCurve: Curves.easeInOutQuart,
                        elevation: 0,
                        bounce: true,
                        duration: const Duration(milliseconds: 400),
                        backgroundColor: backgroundColor,
                        context: context,
                        builder: (builder) {
                          return Directionality(
                            textDirection: m.TextDirection.rtl,
                            child: SizedBox(
                              height: screenSize.height * .8,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "choosetranslation".tr(),
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 22.sp,
                                          fontFamily:
                                              context.locale.languageCode ==
                                                      "ar"
                                                  ? "cairo"
                                                  : "roboto"),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.separated(
                                        separatorBuilder: ((context, index) {
                                          return const Divider();
                                        }),
                                        itemCount: translationDataList.length,
                                        itemBuilder: (c, i) {
                                          return Container(
                                            color:
                                      i==getValue("indexOfTranslation")?          Colors.blueGrey.withOpacity(.1):Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                if (isDownloading !=
                                                    translationDataList[i]
                                                        .url) {
                                                  if (File("${appDir!.path}/${translationDataList[i].typeText}.json")
                                                          .existsSync() ||
                                                                                                               i == 0||i==1
) {
                                                    updateValue(
                                                        "indexOfTranslation",
                                                        i);
                                                    setState(() {});
                                                    getData();
                                                    Navigator.pop(context);
                                                  } else {
                                                    PermissionStatus status =
                                                        await Permission.storage
                                                            .request();
                                                    //PermissionStatus status1 = await Permission.accessMediaLocation.request();
                                                    PermissionStatus status2 =
                                                        await Permission
                                                            .manageExternalStorage
                                                            .request();
                                                    // print(
                                                    //     'status $status   -> $status2');
                                                    if (status.isGranted &&
                                                        status2.isGranted) {
                                                      // print(true);
                                                    } else if (status
                                                            .isPermanentlyDenied ||
                                                        status2
                                                            .isPermanentlyDenied) {
                                                      await openAppSettings();
                                                    } else if (status
                                                        .isDenied) {
                                                      // print(
                                                      //     'Permission Denied');
                                                    }
                                                    setState(() {
                                                      isDownloading =
                                                          translationDataList[i]
                                                              .url;
                                                    });
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500));
                                                    if (mounted) {
                                                      setState(() {});
                                                    }
                                                    await Dio().download(
                                                        translationDataList[i]
                                                            .url,
                                                        "${appDir!.path}/${translationDataList[i].typeText}.json");
                                                    if (mounted) {
                                                      setState(() {});
                                                    }

                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500));
                                                    setState(() {
                                                      isDownloading = "";
                                                    });
                                                  }
                                                  setState(() {});
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 18.0.w,
                                                    vertical: 2.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      translationDataList[i]
                                                          .typeTextInRelatedLanguage,
                                                      style: TextStyle(
                                                          color: primaryColor
                                                              .withOpacity(.9),
                                                          fontSize: 14.sp),
                                                    ),
                                                    isDownloading !=
                                                            translationDataList[
                                                                    i]
                                                                .url
                                                        ? Icon(
                                                            i == 0||i==1
                                                                ? MfgLabs.hdd
                                                                : File("${appDir!.path}/${translationDataList[i].typeText}.json")
                                                                        .existsSync()
                                                                    ? Icons.done
                                                                    : Icons
                                                                        .cloud_download,
                                                            color: Colors
                                                                .blueAccent,
                                                            size: 18.sp,
                                                          )
                                                        : const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors
                                                                .blueAccent,
                                                          )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Container(
                    width: screenSize.width,
                    height: 40.h,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            translationDataList[
                                    getValue("indexOfTranslation") ?? 0]
                                .typeTextInRelatedLanguage,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: translationDataList[getValue(
                                                    "indexOfTranslation") ??
                                                0]
                                            .typeInNativeLanguage ==
                                        "العربية"
                                    ? "cairo"
                                    : "roboto"),
                          ),
                          Icon(
                            FontAwesome.ellipsis,
                            size: 24.sp,
                            color: Colors.blueAccent,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Text(quran.getAudioURLByVerseNumber(1)),
            Divider(
                height: 30.h,
                color: Colors.black
                    .withOpacity(.2)),

            // if (verseNumber != 0 && surahNumber != 0)
            Directionality(
              textDirection: translationDataList[getValue("indexOfTranslation")]
                          .typeInNativeLanguage ==
                      "العربية"
                  ? m.TextDirection.rtl
                  : m.TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: data.contains(">")
                    ? Html(
                        data: data,
                        style: {
                          '*': Style(
                            fontFamily: 'cairo', // Set your custom font family
                            fontSize: FontSize(18.sp),
                            lineHeight:LineHeight(1.7.sp) ,
                            
                            // color: primaryColors[getValue("quranPageolorsIndex")]
                            //     .withOpacity(.9),
                          ),
                        },
                      )
                    : Text(
                        data,
                        style: TextStyle(
                            color:
                              Colors.black,
                            fontFamily: translationDataList[
                                            getValue("indexOfTranslation") ?? 0]
                                        .typeInNativeLanguage ==
                                    "العربية"
                                ? "cairo"
                                : "roboto",
                            fontSize: 16.sp),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
