import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/hadith/models/hadith.dart';
import 'package:nabd/core/hadith/views/widgets/sharing_options.dart';

class HadithDetailsPage extends StatefulWidget {
  String id;
  String locale;
  String title;

  HadithDetailsPage(
      {super.key, required this.locale, required this.id, required this.title});

  @override
  State<HadithDetailsPage> createState() => _HadithDetailsPageState();
}

class _HadithDetailsPageState extends State<HadithDetailsPage> {
  bool isLoading = true;
  late Hadith hadithAr;
  var hadithOtherLanguage;
  getHadithData() async {
    Response responsee = await Dio().get(
        "https://hadeethenc.com/api/v1/hadeeths/one/?language=${widget.locale}&id=${widget.id}");
    print("response.data");
    Response response = await Dio().get(
        "https://hadeethenc.com/api/v1/hadeeths/one/?language=ar&id=${widget.id}");
    print(response.data);
    hadithOtherLanguage = responsee.data;
    hadithAr = Hadith.fromJson(response.data);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getHadithData(); // TODO: implement initState
    super.initState();
  }

  bool isExpanded = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;
  bool isExpanded4 = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: getValue("darkMode")
              ? Colors.black.withOpacity(.87)
              : Colors.white,
          image: const DecorationImage(
              image: AssetImage("assets/images/mosquepnggold.png"),
              opacity: .3,
              alignment: Alignment.bottomCenter)),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill,
                opacity: .2)),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme:  IconThemeData(color:getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors.black87),
            elevation: 0,
            title: SizedBox(
              width: MediaQuery.of(context).size.width * .4,
              child: Text(widget.title,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(color:getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : const Color(0xffA28858))),
            ),
          ),
          // backgroundColor: darkPrimaryColor,
          body: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Container(
                    child: ListView(
                    physics: const BouncingScrollPhysics(),
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12),
                        child: Text(
                          hadithAr.hadeeth,
                          textDirection: m.TextDirection.rtl,
                          locale: const Locale("ar"),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color:getValue("darkMode")
              ? Colors.white
              : Colors.black87,
                            fontFamily: 'Taha',
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0, right: 12),
                        child: Text(
                          '[${hadithAr.attribution}] - [${hadithAr.grade}]',
                          textDirection: m.TextDirection.rtl,
                          locale: const Locale("ar"),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            //fontFamily: 'roboto',
                            color:getValue("darkMode")
              ? Colors.white.withOpacity(.45)
              : Colors.black45, //fontFamily: 'Taha',
                            fontSize: 16.sp, fontFamily: 'Taha',
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 12),
                          child: FadeIn(
                            child: Text(
                              isExpanded == false
                                  ? 'شرح الحديث...'
                                  : "الشرح: \n${hadithAr.explanation}",
                              textDirection: m.TextDirection.rtl,
                              locale: const Locale("ar"),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                //fontFamily: 'roboto',
                                color: isExpanded == false
                                    ?getValue("darkMode")
              ? orangeColor
              : const Color(0xffA28858)
                                    :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors.black87, //fontFamily: 'Taha',
                                fontSize: 16.sp, fontFamily: 'Taha',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded2 = !isExpanded2;
                          });
                        },
                        child: isExpanded2 == false
                            ? FadeIn(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, right: 12),
                                  child: Text(
                                    'معاني الكلمات...',
                                    textDirection: m.TextDirection.rtl,
                                    locale: const Locale("ar"),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      //fontFamily: 'roboto',
                                      color: isExpanded2 == false
                                          ? getValue("darkMode")
              ? orangeColor
              :const Color(0xffA28858)
                                          : getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              :Colors
                                              .black87, //fontFamily: 'Taha',
                                      fontSize: 16.sp, fontFamily: 'Taha',
                                    ),
                                  ),
                                ),
                              )
                            : FadeIn(
                                child: Column(
                                  children: [
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
                                                color: isExpanded2 == false
                                                    ? getValue("darkMode")
              ? orangeColor
              :const Color(0xffA28858)
                                                    :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors
                                                        .black87, //fontFamily: 'Taha',
                                                fontSize: 16.sp,
                                                fontFamily: 'Taha',
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
                                          itemCount:
                                              hadithAr.wordsMeanings.length,
                                          itemBuilder: (c, i) => Text(
                                            "- ${hadithAr.wordsMeanings[i].word}:${hadithAr.wordsMeanings[i].meaning}",
                                            textDirection: m.TextDirection.rtl,
                                            locale: const Locale("ar"),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              //fontFamily: 'roboto',
                                              color: isExpanded2 == false
                                                  ?getValue("darkMode")
              ? orangeColor
              : const Color(0xffA28858)
                                                  :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors
                                                      .black87, //fontFamily: 'Taha',
                                              fontSize: 16.sp,
                                              fontFamily: 'Taha',
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded4 = !isExpanded4;
                          });
                        },
                        child: isExpanded4 == false
                            ? FadeIn(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, right: 12),
                                  child: Text(
                                    'الفوائد من الحديث...',
                                    textDirection: m.TextDirection.rtl,
                                    locale: const Locale("ar"),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      //fontFamily: 'roboto',
                                      color: isExpanded4 == false
                                         ?getValue("darkMode")
              ? orangeColor
              : const Color(0xffA28858)
                                                  :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors
                                                      .black87, //fontFamily: 'Taha',
                                      fontSize: 16.sp, fontFamily: 'Taha',
                                    ),
                                  ),
                                ),
                              )
                            : FadeIn(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4.0, right: 12),
                                      child: Directionality(
                                        textDirection: m.TextDirection.rtl,
                                        child: Row(
                                          children: [
                                            Text(
                                              'الفوائد:',
                                              textDirection:
                                                  m.TextDirection.rtl,
                                              locale: const Locale("ar"),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                //fontFamily: 'roboto',
                                                color: isExpanded4 == false
                                                 ?getValue("darkMode")
              ? orangeColor
              : const Color(0xffA28858)
                                                  :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors
                                                      .black87,//fontFamily: 'Taha',
                                                fontSize: 16.sp,
                                                fontFamily: 'Taha',
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
                                          itemCount:
                                              hadithAr.wordsMeanings.length,
                                          itemBuilder: (c, i) => Text(
                                            "${i + 1}- ${hadithAr.hints[i]}",
                                            textDirection: m.TextDirection.rtl,
                                            locale: const Locale("ar"),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              //fontFamily: 'roboto',
                                              color: isExpanded4 == false
                                               ?getValue("darkMode")
              ? orangeColor
              : const Color(0xffA28858)
                                                  :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors
                                                      .black87, //fontFamily: 'Taha',
                                              fontSize: 16.sp,
                                              fontFamily: 'Taha',
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded3 = !isExpanded3;
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 12),
                          child: Text(
                            isExpanded3 == false
                                ? 'الإسناد...'
                                : "إسناده: \n${hadithAr.reference}",
                            textDirection: m.TextDirection.rtl,
                            locale: const Locale("ar"),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              //fontFamily: 'roboto',
                              color: isExpanded3 == false
                                ?getValue("darkMode")
              ? orangeColor
              : const Color(0xffA28858)
                                                  :getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors
                                                      .black87, //fontFamily: 'Taha',
                              fontSize: 16.sp, fontFamily: 'Taha',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Padding(
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 12),
                          child: Directionality(
                            textDirection: m.TextDirection.rtl,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (builder) => SharingOptions(
                                          isImage: false,
                                          data: {
                                            "hadithAr": hadithAr,
                                            "hadithOtherLanguage":
                                                hadithOtherLanguage
                                          }),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xffF5EFE8)
                                            .withOpacity(.9),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Icon(
                                          Icons.copy,
                                          color: Colors.black87,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (builder) => SharingOptions(
                                          isImage: true,
                                          data: {
                                            "hadithAr": hadithAr,
                                            "hadithOtherLanguage":
                                                hadithOtherLanguage
                                          }),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xffF5EFE8)
                                            .withOpacity(.9),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Icon(
                                          Icons.share,
                                          color: Colors.black87,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                              ],
                            ),
                          )),
                      if (context.locale.languageCode != "ar")
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12),
                          child: Text(
                            hadithOtherLanguage["hadeeth"],
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              color:getValue("darkMode")
              ? Colors.white.withOpacity(.87)
              : Colors.black87,
                              fontSize: 16.sp,
                              fontFamily: 'roboto',
                            ),
                          ),
                        ),
                      if (context.locale.languageCode != "ar")
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0, left: 12),
                          child: Text(
                            '${hadithOtherLanguage["attribution"]} - [${hadithOtherLanguage["grade"]}]',
                            // textDirection: m.TextDirection.rtl,locale: const Locale("ar"),textAlign: TextAlign.right,
                            style: TextStyle(
                              //fontFamily: 'roboto',
                              color:getValue("darkMode")
              ? Colors.white.withOpacity(.45)
              : Colors.black45, //fontFamily: 'Taha',
                              fontSize: 16.sp, fontFamily: 'roboto',
                            ),
                          ),
                        ),
                    ],
                  )),
          ),
        ),
      ),
    );
  }
}
