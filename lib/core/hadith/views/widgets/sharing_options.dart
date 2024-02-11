import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/core/hadith/models/hadith.dart';
import 'package:nabd/core/hadith/views/widgets/screenshot_preview.dart';
import 'package:share_plus/share_plus.dart';

class SharingOptions extends StatefulWidget {
  final data;
  final bool isImage;
  const SharingOptions({super.key, required this.data, required this.isImage});

  @override
  State<SharingOptions> createState() => _SharingOptionsState();
}

class _SharingOptionsState extends State<SharingOptions> {
  bool val1 = false;
  bool val2 = false;
  bool val3 = false;
  bool val4 = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top:16.0),
            child: Text(widget.isImage ? "asimage".tr() : "astext".tr(),style: TextStyle(
              fontSize: 18.sp
            ),),
          ),
          // if (context.locale.languageCode != "ar")
          //   SwitchListTile(
          //       title: const Text("Share Arabic"),
          //       value: val4,
          //       onChanged: (v) {
          //         setState(() {
          //           val4 = v;
          //         });
          //       }),
          SwitchListTile(
              title:  Text("explanation".tr()),
              value: val1,
              onChanged: (v) {
                setState(() {
                  val1 = v;
                });
              }),
          SwitchListTile(
              title:  Text("meanings".tr()),
              value: val2,
              onChanged: (v) {
                setState(() {
                  val2 = v;
                });
              }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: EasyContainer(
                onTap: (() {
                  String textAr = "";
                  String textOtherLanguage = "";
                  var hadithOtherLanguage = widget.data["hadithOtherLanguage"];
                  Hadith hadithAr = widget.data["hadithAr"];
                  if (val4) {
                    textAr = hadithAr.hadeeth +
                        "\n" +
                        '[${hadithAr.attribution}] - [${hadithAr.grade}]';
                    if (context.locale.languageCode != "ar") {
                      textOtherLanguage = hadithOtherLanguage["hadeeth"] +
                          "\n" +
                          '${hadithOtherLanguage["attribution"]} - [${hadithOtherLanguage["grade"]}]';
                    }
                  }
                  if (val1) {
                    textAr = "$textAr\n\nشرح الحديث: \n${hadithAr.explanation}";
                    if (context.locale.languageCode != "ar") {
                      textOtherLanguage =
                          "$textOtherLanguage/n Explanation :${hadithOtherLanguage["explanation"]}";
                    }
                  }

                  if (val2 && hadithAr.wordsMeanings.isNotEmpty) {
                    textAr = "$textAr\nمعاني الكلمات :\n";
                    for (var i = 0; i < hadithAr.wordsMeanings.length; i++) {
                      textAr =
                          "$textAr${"- ${hadithAr.wordsMeanings[i].word}:${hadithAr.wordsMeanings[i].meaning}"}";
                    }
                  }

                   widget.isImage? Navigator.push(context, CupertinoPageRoute(builder: (builder)=>HadithScreenShotPreviewPage(hadithAr: hadithAr
                   ,addExplanation: val1,addMeanings: val2,hadithOtherLanguage: hadithOtherLanguage,
                   ))):    Share.share("$textAr\n$textOtherLanguage");
                }),
                borderRadius: 22,
                color: Colors.blueAccent,
                child: Text(
                widget.isImage?"preview".tr():  "share".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
