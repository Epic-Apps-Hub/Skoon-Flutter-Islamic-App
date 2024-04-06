import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/QuranPages/helpers/convertNumberToAr.dart';
import 'package:nabd/core/QuranPages/helpers/remove_html_tags.dart';
import 'package:nabd/core/QuranPages/helpers/save_image.dart';
import 'package:nabd/core/QuranPages/helpers/translation/translation_info.dart';
import 'package:nabd/core/QuranPages/helpers/translation/translationdata.dart';
import 'package:nabd/core/QuranPages/widgets/bismallah.dart';
import 'package:nabd/core/QuranPages/widgets/header_widget.dart';
import 'package:nabd/core/hadith/models/hadith.dart';
import 'package:nabd/models/TranslationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:nabd/core/QuranPages/helpers/share_image.dart";
import 'package:quran/quran.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart' as m;

class HadithScreenShotPreviewPage extends StatefulWidget {
  Hadith hadithAr;
  var hadithOtherLanguage;
  bool addMeanings;
  bool addExplanation;

  HadithScreenShotPreviewPage(
      {super.key,
      required this.hadithAr,
      required this.addExplanation,
      required this.addMeanings,
      required this.hadithOtherLanguage});
  // var options;

  @override
  State<HadithScreenShotPreviewPage> createState() =>
      _ScreenShotPreviewPageState();
}

class _ScreenShotPreviewPageState extends State<HadithScreenShotPreviewPage> {
  TextAlign alignment = TextAlign.justify;
  ScreenshotController screenshotController = ScreenshotController();

  double textSize = 16;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool addAppSlogan = true;
  bool isShooting = false;
  int indexOfTheme = getValue("quranPageolorsIndex");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
        backgroundColor: quranPagesColorDark,
        elevation: 0,
        title: Text("preview".tr()),
      ),
      body: Center(
        child: ListView(
          children: [
            Row(
              children: [
                Checkbox(
                  fillColor: MaterialStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  checkColor: backgroundColors[getValue("quranPageolorsIndex")],
                  value: addAppSlogan,
                  onChanged: (newValue) {
                    addAppSlogan = !addAppSlogan;
                    setState(() {});
                  },
                ),
                Text(
                  'addappname'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Slider(
              label: textSize.toString(),
              divisions: 30,
              value: textSize,
              min: 10.0, // Minimum font size
              max: 45.0, // Maximum font size
              onChanged: (newSize) {
                textSize = newSize;
                // Call the function to update font size
                setState(() {});
              },
            ),
            SingleChildScrollView(
              child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: primaryColors[indexOfTheme].withOpacity(.2),
                      blurRadius: 4,
                      spreadRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]),
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/mosquepnggold.png"),
                                opacity: .1,
                                alignment: Alignment.bottomCenter)),

                        // padding: const EdgeInsets.all(30.0),

                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  image: AssetImage("assets/images/try6.png"),
                                  fit: BoxFit.fill,
                                  opacity: .25)),
                          child: Column(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12),
                                child: Text(
                                  widget.hadithAr.hadeeth,
                                  textDirection: m.TextDirection.rtl,
                                  locale: const Locale("ar"),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: const Color(0xff555555),
                                    fontFamily: 'Taha',
                                    fontSize: textSize.sp,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 4.0, right: 12),
                                child: Directionality(
                                  textDirection: m.TextDirection.rtl,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '[${widget.hadithAr.attribution}] - [${widget.hadithAr.grade}]',
                                        textDirection: m.TextDirection.rtl,
                                        locale: const Locale("ar"),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          //fontFamily: 'roboto',
                                          color: const Color(
                                              0xffAE8422), //fontFamily: 'Amiri',
                                          fontSize: textSize.sp,
                                          fontFamily: 'Taha',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.addExplanation)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, right: 12),
                                  child: Text(
                                    "الشرح: \n${widget.hadithAr.explanation}",
                                    textDirection: m.TextDirection.rtl,
                                    locale: const Locale("ar"),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      //fontFamily: 'roboto',
                                      color:
                                          Colors.black87, //fontFamily: 'Amiri',
                                      fontSize: textSize.sp, fontFamily: 'Taha',
                                    ),
                                  ),
                                ),
                              SizedBox(
                                height: 10.h,
                              ),
                              if (widget.addMeanings)
                                Column(
                                  children: [
                                    if (widget
                                        .hadithAr.wordsMeanings.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4.0, right: 12),
                                        child: Directionality(
                                          textDirection: m.TextDirection.rtl,
                                          child: Row(
                                            children: [
                                              Text(
                                                'معاني الكلمات:',
                                                textDirection:
                                                    m.TextDirection.rtl,
                                                locale: const Locale("ar"),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  //fontFamily: 'roboto',
                                                  color: Colors
                                                      .black87, //fontFamily: 'Amiri',
                                                  fontSize: textSize.sp,
                                                  fontFamily: 'Amiri',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4.0, right: 12),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: widget
                                              .hadithAr.wordsMeanings.length,
                                          itemBuilder: (c, i) => Text(
                                            "- ${widget.hadithAr.wordsMeanings[i].word}:${widget.hadithAr.wordsMeanings[i].meaning}",
                                            textDirection: m.TextDirection.rtl,
                                            locale: const Locale("ar"),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              //fontFamily: 'roboto',
                                              color: Colors
                                                  .black87, //fontFamily: 'Amiri',
                                              fontSize: textSize.sp,
                                              fontFamily: 'Amiri',
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              if (context.locale.languageCode != "ar")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12),
                                  child: Text(
                                    widget.hadithOtherLanguage["hadeeth"],
                                    // textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff555555),
                                      fontSize: 16.sp,
                                      fontFamily: 'roboto',
                                    ),
                                  ),
                                ),
                              if (context.locale.languageCode != "ar")
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, left: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${widget.hadithOtherLanguage["attribution"]} - [${widget.hadithOtherLanguage["grade"]}]',
                                        // textDirection: m.TextDirection.rtl,locale: const Locale("ar"),textAlign: TextAlign.right,
                                        style: TextStyle(
                                          //fontFamily: 'roboto',
                                          color: const Color(
                                              0xffAE8422), //fontFamily: 'Taha',
                                          fontSize: 16.sp, fontFamily: 'roboto',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 5.h,
                              ),
                              if (addAppSlogan)
                                SizedBox(
                                  height: 15.h,
                                ),
                              if (addAppSlogan)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      image: const AssetImage(
                                          "assets/images/iconlauncher2.png"),
                                      height: 25.h,
                                    ),
                                    SizedBox(
                                      width: 6.w,
                                    ),
                                    Text(
                                      "Shared with skoon",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: const Color(0xffA28858),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              SizedBox(
                                height: 15.h,
                              ),
                            ],
                          ),
                        )),
                  )),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color:
                primaryColors[getValue("quranPageolorsIndex")].withOpacity(.4),
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(1, 0),
          )
        ]),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 25.0, right: 25, bottom: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: EasyContainer(
                    height: 50,
                    width: MediaQuery.of(context).size.width * .3,
                    onTap: () async {
                      // setState(() {
                      //   isShooting = true;
                      // });
                      await screenshotController
                          .capture()
                          .then((capturedImage) => shareImage(capturedImage!));

                      // setState(() {
                      //   isShooting = false;
                      // });
                    },
                    color: quranPagesColorDark,
                    child: Text(
                      "shareexternal".tr(),
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: EasyContainer(
                    height: 50,
                    width: MediaQuery.of(context).size.width * .3,
                    onTap: () async {
                      // setState(() {
                      //   isShooting = true;
                      // });

                      await screenshotController.capture().then(
                          (capturedImage) =>
                              saveImageToGallery(capturedImage!));
                      // setState(() {
                      //   isShooting = false;
                      // });
                    },
                    color:  quranPagesColorDark,
                    child: Text(
                      "savetogallery".tr(),
                      style: TextStyle(
                          fontSize: context.locale.languageCode == "ar"
                              ? 12.sp
                              : 15.sp,
                          color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
