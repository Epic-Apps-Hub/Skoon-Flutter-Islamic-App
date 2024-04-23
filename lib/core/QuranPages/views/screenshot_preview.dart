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
import 'package:nabd/models/TranslationInfo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/share_image.dart';
import 'package:quran/quran.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart' as m;
import '../helpers/translation/get_translation_data.dart'
    as get_translation_data;

class ScreenShotPreviewPage extends StatefulWidget {
  ScreenShotPreviewPage(
      {super.key,
      required this.index,
      required this.surahNumber,
      required this.jsonData,
      required this.firstVerse,
      required this.lastVerse,
      required this.isQCF
      });

  var firstVerse;
  var index;
  var jsonData;
  var lastVerse;
  var surahNumber;
bool isQCF;
  @override
  State<ScreenShotPreviewPage> createState() => _ScreenShotPreviewPageState();
}

class _ScreenShotPreviewPageState extends State<ScreenShotPreviewPage> {
  TextAlign alignment = TextAlign.center;
  Directory? appDir;
  var dataOfCurrentTranslation;
  int indexOfTheme = getValue("quranPageolorsIndex");
  var isDownloading = "";
  bool isShooting = false;
  ScreenshotController screenshotController = ScreenshotController();
  double textSize = 22;late
bool isQCF;
  @override
  void initState() {updateData();
    initialize();
    getTranslationData();
    
    // TODO: implement initState
    super.initState();
  }
updateData(){
  setState(() {
    isQCF=widget.isQCF;
    textSize=widget.isQCF?19:22;

  });
}
  initialize() async {

    appDir = await getTemporaryDirectory();
    getTranslationData();
    if (mounted) {
      setState(() {});
    }
  }

  getTranslationData() async {
    if (getValue("addTafseerValue") > 1) {
      File file = File(
          "${appDir!.path}/${translationDataList[getValue("addTafseerValue")].typeText}.json");

      String jsonData = await file.readAsString();
      dataOfCurrentTranslation = json.decode(jsonData);
    }
    setState(() {});
  }

  List<InlineSpan> buildVerseSpans(
      int surahNumber, int firstVerseNumber, int lastVerseNumber) {
    List<InlineSpan> verseSpans = [];

    for (int verseNumber = firstVerseNumber;
        verseNumber <= lastVerseNumber;
        verseNumber++) {
      String centeredSubstringFromV1 = "";
      String verseText =isQCF? getVerseQCF(surahNumber, verseNumber):getVerse(surahNumber, verseNumber);
      if (verseNumber == firstVerseNumber) {
        // print("true");
        // verseText.replaceFirst(" ", "\n");
        if (verseText.length > 15 ||
            firstVerseNumber != lastVerseNumber && verseText.length > 4) {
          centeredSubstringFromV1 = isQCF? "${verseText.substring(0, 4)}\n":"";
          verseText =isQCF? verseText.substring(3, verseText.length):alignment==TextAlign.justify?verseText:  verseText.replaceFirst(" ", "\n");
          print(verseText);
          print(centeredSubstringFromV1);
        }
      }

      int pageNumber = getPageNumber(surahNumber, verseNumber);
      // print("QCF_P${pageNumber.toString().padLeft(3, "0")}");
      if (verseText.length > 15 || firstVerseNumber != lastVerseNumber ) {
        TextSpan centeredSubstringFromV1Span = TextSpan(
            text: centeredSubstringFromV1,
            style: TextStyle(
              color: primaryColors[indexOfTheme],
              fontSize: textSize.sp,
              wordSpacing: 0,
              height: 2,
              letterSpacing:isQCF? -1:0,
              fontFamily:isQCF? "QCF_P${pageNumber.toString().padLeft(3, "0")}":getValue("selectedFontFamily"),
            ),
            children: const [
              WidgetSpan(
                  child: Text(
                "",
                textAlign: TextAlign.center,
              ))
            ]);
        verseSpans.add(centeredSubstringFromV1Span);
      }
      TextSpan verseSpan = TextSpan(
        text: verseText+ (isQCF?" ":"") //.replaceAll(' ', ''),
        // recognizer: LongPressGestureRecognizer()..onLongPress = () {},
        ,
        style: TextStyle(
          color: primaryColors[indexOfTheme],
          fontSize: textSize.sp,
          wordSpacing: 0,
          height: 2,
          letterSpacing:isQCF? -1:0,
              fontFamily:isQCF? "QCF_P${pageNumber.toString().padLeft(3, "0")}":getValue("selectedFontFamily"),
        ),
      );

      verseSpans.add(verseSpan);

if(isQCF==false) {
  verseSpans.add(
        TextSpan(
            locale: const Locale("ar"),
            text:
                " ${convertToArabicNumber((verseNumber).toString())} " //               quran.getVerseEndSymbol()
            ,
            style: TextStyle(
                color: secondaryColors[indexOfTheme],
                fontSize: textSize.sp,
                fontFamily: "KFGQPC Uthmanic Script HAFS Regular")),
      );
}
    }

    return verseSpans;
  }

  Future<List<InlineSpan>> buildTafseerSpans(int surahNumber,
      int firstVerseNumber, int lastVerseNumber, translatee) async {
    List<InlineSpan> tafseerSpans = [];
    tafseerSpans.add(TextSpan(
      text: translatee.typeTextInRelatedLanguage + ": ",
      // recognizer: LongPressGestureRecognizer()..onLongPress = () {},
      style: TextStyle(
          color: primaryColors[indexOfTheme],
          fontSize: ((textSize + 6.5) / 2).sp,
          wordSpacing: .2,
          letterSpacing: .2,
          fontFamily: "cairo"
          // fontFamily: getValue("selectedFontFamily"),
          ),
    ));
    for (int verseNumber = firstVerseNumber;
        verseNumber <= lastVerseNumber;
        verseNumber++) {
      String verseText = getVerse(surahNumber, verseNumber);
      String text = await get_translation_data.getVerseTranslation(
          surahNumber, verseNumber, translatee);
      text = text.replaceAll("<p>", "\n").replaceAll("</p>", "");
      TextSpan translateSpan = TextSpan(
        text: "$text (${convertToArabicNumber(verseNumber.toString())}) ",
        // recognizer: LongPressGestureRecognizer()..onLongPress = () {},
        style: TextStyle(
            color: primaryColors[indexOfTheme],
            fontSize: ((textSize + 6) / 2).sp,
            wordSpacing: .2,
            letterSpacing: .2,
            fontFamily: "cairo"
            // fontFamily: getValue("selectedFontFamily"),
            ),
      );

      tafseerSpans.add(translateSpan);
      // tafseerSpans.add(
      //   TextSpan(
      //       locale: const Locale("ar"),
      //       text:
      //           " ${convertToArabicNumber((verseNumber).toString())} " //               quran.getVerseEndSymbol()
      //       ,
      //       style: const TextStyle(
      //         color: secondaryColors[indexOfTheme],
      //       )),
      // );
    }

    return tafseerSpans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
        backgroundColor:
            getValue("darkMode") ? darkModeSecondaryColor : blueColor,
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
                  value: getValue("showSuraHeader"),
                  onChanged: (newValue) {
                    updateValue("showSuraHeader", newValue);
                    setState(() {});
                  },
                ),
                Text(
                  'showsuraheader'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  fillColor: MaterialStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  checkColor: backgroundColors[getValue("quranPageolorsIndex")],
                  value: getValue("showBottomBar"),
                  onChanged: (newValue) {
                    updateValue("showBottomBar", newValue);
                    setState(() {});
                  },
                ),
                Text(
                  'showbottombar'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),    Row(
              children: [
                Checkbox(
                  fillColor: MaterialStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  checkColor: backgroundColors[getValue("quranPageolorsIndex")],
                  value: isQCF,
                  onChanged: (newValue) {
                    isQCF=newValue!;
                    setState(() {});
                  },
                ),
                Text(
                  'IsQCF Font'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  fillColor: MaterialStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  checkColor: backgroundColors[getValue("quranPageolorsIndex")],
                  value: getValue("addTafseer"),
                  onChanged: (newValue) {
                    updateValue("addTafseer", newValue);

                    setState(() {});
                  },
                ),
                Text(
                  'addtafseer'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
                if (getValue("addTafseer") == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20.w,
                      ),

                      // DropdownButton<String>(
                      //   value: translationDataList
                      //       [getValue("addTafseerValue")]
                      //       .typeText,
                      //   onChanged: (String? newValue) {
                      //     updateValue("addTafseerValue", newValue);
                      //     setState(() {});
                      //     // setStatee(() {});
                      //   },
                      //   items:
                      //       translationDataList.map(( translation) {
                      //     return DropdownMenuItem<String>(
                      //       value: translation.typeText,
                      //       child: Text(translation
                      //           .typeTextInRelatedLanguage), // Display the native language name
                      //     );
                      //   }).toList(),
                      // ),
                    ],
                  ),
              ],
            ),
            if (getValue("addTafseer") == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20.w,
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
                              duration: const Duration(milliseconds: 200),
                              backgroundColor: backgroundColor,
                              context: context,
                              builder: (builder) {
                                return Directionality(
                                  textDirection: m.TextDirection.rtl,
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * .8,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "choosetranslation".tr(),
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 22.sp,
                                                fontFamily: context.locale
                                                            .languageCode ==
                                                        "ar"
                                                    ? "cairo"
                                                    : "roboto"),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.separated(
                                              separatorBuilder:
                                                  ((context, index) {
                                                return const Divider();
                                              }),
                                              itemCount:
                                                  translationDataList.length,
                                              itemBuilder: (c, i) {
                                                return Container(
                                                  color: i ==
                                                          getValue(
                                                              "addTafseerValue")
                                                      ? Colors.blueGrey
                                                          .withOpacity(.1)
                                                      : Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (isDownloading !=
                                                          translationDataList[i]
                                                              .url) {
                                                        if (File("${appDir!.path}/${translationDataList[i].typeText}.json")
                                                                .existsSync() ||
                                                            i == 0 ||
                                                            i == 1) {
                                                          updateValue(
                                                              "addTafseerValue",
                                                              i);
                                                          setState(() {});
                                                        } else {
                                                          PermissionStatus
                                                              status =
                                                              await Permission
                                                                  .storage
                                                                  .request();
                                                          //PermissionStatus status1 = await Permission.accessMediaLocation.request();
                                                          PermissionStatus
                                                              status2 =
                                                              await Permission
                                                                  .manageExternalStorage
                                                                  .request();
                                                          print(
                                                              'status $status   -> $status2');
                                                          if (status
                                                                  .isGranted &&
                                                              status2
                                                                  .isGranted) {
                                                            print(true);
                                                          } else if (status
                                                                  .isPermanentlyDenied ||
                                                              status2
                                                                  .isPermanentlyDenied) {
                                                            await openAppSettings();
                                                          } else if (status
                                                              .isDenied) {
                                                            print(
                                                                'Permission Denied');
                                                          }

                                                          await Dio().download(
                                                              translationDataList[
                                                                      i]
                                                                  .url,
                                                              "${appDir!.path}/${translationDataList[i].typeText}.json");
                                                          updateValue(
                                                              "addTafseerValue",
                                                              i);
                                                        }
                                                        setState(() {});
                                                      }
                                                      getTranslationData();

                                                      setState(() {});

                                                      // setStatee(() {});
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  18.0.w,
                                                              vertical: 2.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            translationDataList[
                                                                    i]
                                                                .typeTextInRelatedLanguage,
                                                            style: TextStyle(
                                                                color: primaryColor
                                                                    .withOpacity(
                                                                        .9),
                                                                fontSize:
                                                                    14.sp),
                                                          ),
                                                          isDownloading !=
                                                                  translationDataList[
                                                                          i]
                                                                      .url
                                                              ? Icon(
                                                                  i == 0 ||
                                                                          i == 1
                                                                      ? MfgLabs
                                                                          .hdd
                                                                      : File("${appDir!.path}/${translationDataList[i].typeText}.json")
                                                                              .existsSync()
                                                                          ? Icons
                                                                              .done
                                                                          : Icons
                                                                              .cloud_download,
                                                                  color: secondaryColors[
                                                                      indexOfTheme],
                                                                  size: 18.sp,
                                                                )
                                                              : CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: secondaryColors[
                                                                      indexOfTheme],
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
                          width: MediaQuery.of(context).size.width * .9,
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
                                          getValue("addTafseerValue") ?? 0]
                                      .typeTextInRelatedLanguage,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: translationDataList[getValue(
                                                          "addTafseerValue") ??
                                                      0]
                                                  .typeInNativeLanguage ==
                                              "العربية"
                                          ? "cairo"
                                          : "roboto"),
                                ),
                                Icon(
                                  FontAwesome.ellipsis,
                                  size: 24.sp,
                                  color: secondaryColors[indexOfTheme],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            RadioListTile(
              title: Text("centerText".tr()),
              value: TextAlign.center,
              groupValue: alignment,
              onChanged: (value) {
                setState(() {
                  alignment = value!;
                });
              },
            ),
            RadioListTile(
              title: Text("justifyText".tr()),
              value: TextAlign.justify,
              groupValue: alignment,
              onChanged: (value) {
                setState(() {
                  alignment = value!;
                });
              },
            ),
            Slider(
              label: textSize.toString(),
              divisions: 30,
              value: textSize,
              min: 15.0, // Minimum font size
              max: 45.0, // Maximum font size
              onChanged: (newSize) {
                textSize = newSize;
                // Call the function to update font size
                setState(() {});
              },
            ),
            SizedBox(
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: primaryColors.length,
                  itemBuilder: (a, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            indexOfTheme = i;
                          });
                        },
                        child: SizedBox(
                          width: 90,
                          height: 40,
                          child: Stack(
                            children: [
                              // First Color
                              Center(
                                child: Container(
                                  width: 90,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 1,
                                          color: Colors.grey.withOpacity(.5))
                                    ],
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    color: backgroundColors[i],
                                  ),
                                ),
                              ),

                              // Second Color (Overlay)
                              Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColors[i],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 30.h,
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
                        decoration: BoxDecoration(
                          // color: const Color(0xffFFFCE7),
                          color: backgroundColors[indexOfTheme],
                          //  gradient: const RadialGradient(
                          //       center: Alignment.center,
                          //       radius: 0.5, // Adjust this value to control the circle size
                          //       colors: [
                          //         Color.fromARGB(255, 13, 43, 85), // Dark blue color
                          //         Color.fromARGB(255, 10, 31, 55), // Slightly lighter blue color
                          //         Color.fromARGB(255, 6, 20, 35), // Even lighter blue color
                          //       ],
                          //       stops: [0.0, 0.7, 1.0], // Stops for each color in the gradient
                          //     ),
                        ),
                        // padding: const EdgeInsets.all(30.0),

                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            if (getValue("showSuraHeader") == true)
                              HeaderWidget(
                                e: {"surah": widget.surahNumber},
                                jsonData: widget.jsonData,
                                indexOfTheme: indexOfTheme,
                              ),
                            SizedBox(
                              height: widget.firstVerse == 1 ? 5.h : 10.h,
                            ),
                            if ((widget.firstVerse == 1 &&
                                widget.index != 1 &&
                                widget.index != 187))
                              Basmallah(index: indexOfTheme),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: RichText(
                                  textAlign: //getValue("textAlignIndex")==0?
                                      alignment //:TextAlign.justify

                                  ,
                                  textWidthBasis: TextWidthBasis.longestLine,
                                  locale: const Locale("ar"),
                                  textDirection: m.TextDirection.rtl,
                                  text: TextSpan(
                                    text: '', // Initialize with an empty string
                                    style: TextStyle(
                                      color: primaryColors[indexOfTheme],
                                      fontSize: (20).sp,
                                      fontFamily:
                                          getValue("selectedFontFamily"),
                                    ),
                                    children: buildVerseSpans(
                                        widget.surahNumber,
                                        widget.firstVerse,
                                        widget.lastVerse),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            if (getValue("addTafseer") == true) const Divider(),
                            if (getValue("addTafseer") == true)
                              FutureBuilder(
                                future: buildTafseerSpans(
                                    widget.surahNumber,
                                    widget.firstVerse,
                                    widget.lastVerse,
                                    translationDataList[
                                        getValue("addTafseerValue")]),
                                initialData: const [],
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  return Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: RichText(
                                        textDirection: translationDataList[
                                                        getValue(
                                                            "addTafseerValue")]
                                                    .typeInNativeLanguage
                                                    .toString() ==
                                                "العربية"
                                            ? m.TextDirection.rtl
                                            : m.TextDirection.ltr,
                                        text: TextSpan(
                                            children: snapshot.hasData
                                                ? snapshot.data
                                                : null)),
                                  );
                                },
                              ),
                            if (getValue("addAppSlogan") == true)
                              SizedBox(
                                height: 15.h,
                              ),
                            if (getValue("addAppSlogan") == true)
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
                                        color: primaryColors[indexOfTheme]),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 15.h,
                            ),
                            if (getValue("showBottomBar") == true)
                              Container(
                                color: secondaryColors[indexOfTheme]
                                    .withOpacity(.45),
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 77.0.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "[${widget.firstVerse} - ${widget.lastVerse}]",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                backgroundColors[indexOfTheme]
                                                    .withOpacity(.6)),
                                      ),
                                      Text(
                                        widget.jsonData[widget.surahNumber - 1]
                                            ["name"],
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamilies[0],
                                            color:
                                                backgroundColors[indexOfTheme]
                                                    .withOpacity(.6)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        )),
                  )),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: getValue("darkMode")
              ? darkModeSecondaryColor
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 0),
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
                    color: orangeColor,
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
                    color: orangeColor,
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
