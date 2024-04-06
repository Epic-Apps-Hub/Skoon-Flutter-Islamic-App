import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/sibha/models/tasbeh.dart';
import 'package:nabd/core/sibha/widgets/add_tasbeeh_dialog.dart';

class SibhaPage extends StatefulWidget {
  const SibhaPage({super.key});

  @override
  State<SibhaPage> createState() => _SibhaPageState();
}

class _SibhaPageState extends State<SibhaPage> {
  List<Tasbeeh> tasbeehList = [
    Tasbeeh(
      id: 0,
      arabic: 'الحمد لله',
      translation: 'Praise be to Allah',
      pronunciation: 'Al-ham-du li-lah',
    ),
    Tasbeeh(
      id: 1,
      arabic: 'الله اكبر',
      translation: 'Allah is the Greatest',
      pronunciation: 'Al-lah-hu Ak-bar',
    ),
    Tasbeeh(
      id: 2,
      arabic: 'استغفر الله',
      translation: 'I seek forgiveness from Allah',
      pronunciation: 'As-tag-fir-ul-lah',
    ),
    Tasbeeh(
      id: 3,
      arabic: 'لا اله الا الله',
      translation: 'There is no god but Allah',
      pronunciation: 'La ila-ha ill-al-lah',
    ),
    Tasbeeh(
      id: 4,
      arabic: 'سبحان الله',
      translation: 'Glory be to Allah',
      pronunciation: 'Sub-han Allah',
    ),
    Tasbeeh(
      id: 5,
      arabic: 'سبحان الله وبحمده سبحان الله العظيم',
      translation:
          'Glory be to Allah, and praise is due to Him, glory be to Allah the Great',
      pronunciation: 'Sub-han Allah wa bi-ham-di-hi Sub-han Allah al-a-zeem',
    ),
    Tasbeeh(
      id: 6,
      arabic: 'سبحان الله والحمد لله ولا اله الا الله والله اكبر',
      translation:
          'Glory be to Allah, and praise is due to Allah, and there is no god but Allah, and Allah is the Greatest',
      pronunciation:
          'Sub-han Allah wa al-ham-du li-lah wa la ila-ha ill-al-lah wa Al-lah Ak-bar',
    ),
    Tasbeeh(
      id: 7,
      arabic: 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
      translation:
          'There is no god but You, glory be to You; surely I am of those who are unjust',
      pronunciation:
          'La ila-ha ill-a an-ta Sub-ha-na-ka in-ni ku-n-tu min az-zal-li-meen',
    ),
    Tasbeeh(
      id: 8,
      arabic: 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام',
      translation:
          'O Allah, You are the Peace, and from You comes peace; Blessed are You, O Possessor of Majesty and Honor',
      pronunciation:
          'Al-lah-ma an-ta as-Sa-laam wa min-ka as-Sa-laam ta-ba-ra-kat ya dha al-ja-la-li wal-i-kraam',
    ),
    Tasbeeh(
      id: 9,
      arabic: 'اللهم صل وسلم وبارك على سيدنا محمد',
      translation: 'O Allah, send peace and blessings upon our Master Muhammad',
      pronunciation:
          'Al-lah-ma sal-li wa sal-lim wa ba-rik ala sa-yi-di-na Mu-ham-mad',
    ),
    Tasbeeh(
      id: 10,
      arabic: 'الله أكبر كبيرا  والحمد لله كثيرا  وسبحان الله بكرة وأصيلا',
      translation:
          'Allah is the Greatest, greatly, and praise be to Allah abundantly, and glory be to Allah in the morning and the evening',
      pronunciation:
          'Al-lah Ak-bar kabee-ra wa al-ham-du li-lah ka-thee-ra wa Sub-han Al-lah bu-ka-ra wa a-shee-la',
    ),
    Tasbeeh(
      id: 11,
      arabic:
          'لا إله إلا الله وحده لا شريك له له الملك وله الحمد وهو على كل شيء قدير',
      translation:
          'There is no god but Allah alone, He has no partner, His is the sovereignty, and His is the praise, and He has power over everything',
      pronunciation:
          'La ila-ha ill-a al-lah wa-hda-hu la shar-ee-ka la-hu la-hu al-mul-ku wa la-hu al-ham-du wa hu-wa ala ku-l-lee shay-in qa-deer',
    ),
    Tasbeeh(
      id: 12,
      arabic: 'سبحان الله وبحمده  سبحان الله العظيم',
      translation:
          'Glory be to Allah, and praise be to Him; glory be to Allah the Great',
      pronunciation: 'Sub-han Al-lah wa bi-ham-di-hi  Sub-han Al-lah al-a-zeem',
    ),
  ];

  @override
  void initState() {
    customTasbeehFetcher();
    super.initState();
  }

  customTasbeehFetcher() {
    var customTasbeehs = getValue("customTasbeehs");
    print(customTasbeehs);
    if (customTasbeehs != null) {
      json.decode(customTasbeehs).forEach((t) {
        tasbeehList.add(Tasbeeh(
          id: t["id"],
          arabic: t["arabic"],
          translation: "",
          pronunciation: "",
        ));
      });
      setState(() {});
    }
  }

  addCustomTasbeeh(arabic) async{
    var customTasbeehs = getValue("customTasbeehs");
    if (customTasbeehs != null) {
      var tasbeehs = json.decode(customTasbeehs);
      tasbeehs.add({
        "id": Random().nextInt(665656),
        "arabic": arabic,
      });
      tasbeehList.add(Tasbeeh(
          id: tasbeehs[tasbeehs.length - 1]["id"],
          arabic: tasbeehs[tasbeehs.length - 1]["arabic"],
          translation: "",
          pronunciation: ""));
      updateValue("customTasbeehs", json.encode(tasbeehs));
    } else {
      List tasbeehs = [];
      tasbeehs.add({
        "id": Random().nextInt(665656),
        "arabic": arabic,
      });
      setState(() {});
      tasbeehList.add(Tasbeeh(
          id: tasbeehs[0]["id"],
          arabic: tasbeehs[0]["arabic"],
          translation: "",
          pronunciation: ""));
      setState(() {});
      updateValue("customTasbeehs", json.encode(tasbeehs));
    }
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 150));
    tasbeehScrollController.animateToPage(tasbeehList.length - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.bounceInOut);
  }

  // removeTasbeeh(arabic) {
  //   var customTasbeehs = getValue("customTasbeehs");
  //   if (customTasbeehs != null) {
  //     var tasbeehs = json.decode(customTasbeehs);
  //     tasbeehs.add({
  //       "id": Random().nextInt(665656),
  //       "arabic": arabic,
  //     });
  //     tasbeehList.add(
  //       Tasbeeh(id: tasbeehs[tasbeehs.length]["id"], arabic: tasbeehs[tasbeehs.length]["arabic"], translation: "", pronunciation: "")
  //     );
  //     updateValue("customTasbeehs", json.encode(tasbeehs));
  //   }

  // }
  PageController tasbeehScrollController =
      PageController(initialPage: getValue("tasbeehLastIndex") ?? 0);
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
          color: darkPrimaryColor,
          image: DecorationImage(
              image: AssetImage(
                "assets/images/tasbeehbackground.png",
              ),
              opacity: .03,
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () {
                  showAnimatedDialog(
                      alignment: Alignment.center,
                      // animationType: DialogTransitionType.,
                      context: context,
                      builder: (c) => AddTasbeehDialog(
                            function: addCustomTasbeeh,
                          ));
                },
                icon: const Icon(Icons.add))
          ],
          title: Text(
            "sibha".tr(),
            style: const TextStyle(fontFamily: 'cairo'),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(
              height: screenSize.height * .04,
            ),
            Expanded(
              // height: screenSize.height * .2,
              // width: screenSize.width,
              child: PageView.builder(
                onPageChanged: ((value) {
                  updateValue("tasbeehLastIndex", value);
                  setState(() {});
                }),
                itemBuilder: (itemBuilder, i) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor.withOpacity(.75),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tasbeehList[i].arabic,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "cairo",
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          if (tasbeehList[i].pronunciation != "")
                            const Divider(),
                          if (tasbeehList[i].pronunciation != "")
                            Text(tasbeehList[i].pronunciation,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.6),
                                    fontFamily: "roboto",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold)),
                          if (tasbeehList[i].translation != "") const Divider(),
                          if (tasbeehList[i].translation != "")
                            Text(tasbeehList[i].translation,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.5),
                                    fontFamily: "roboto",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  );
                },
                itemCount: tasbeehList.length,
                scrollDirection: Axis.horizontal,
                controller: tasbeehScrollController,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            SizedBox(
              width: screenSize.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      print("object");
                      if (getValue("tasbeehLastIndex") != 0) {
                        tasbeehScrollController.animateToPage(
                            getValue("tasbeehLastIndex") - 1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.decelerate);
                      }
                      setState(() {});
                    },
                    child: SizedBox(
                      width: screenSize.width * .3,
                      height: screenSize.height * .062,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 40.w),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white.withOpacity(.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      updateValue("${getValue("tasbeehLastIndex")}number", (0));
                      setState(() {});
                    },
                    child: SizedBox(
                      width: screenSize.width * .3,
                      height: screenSize.height * .062,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 0.w),
                          child: Icon(
                            Icons.replay_outlined,
                            color: Colors.white.withOpacity(.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (getValue("tasbeehLastIndex") !=
                          tasbeehList.length - 1) {
                        tasbeehScrollController.animateToPage(
                            getValue("tasbeehLastIndex") + 1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.decelerate);
                        setState(() {});
                      }
                    },
                    child: SizedBox(
                      height: screenSize.height * .062,
                      width: screenSize.width * .3,
                      child: Padding(
                        padding: EdgeInsets.only(right: 40.w),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InkWell(
                  overlayColor:
                      MaterialStatePropertyAll(Colors.white.withOpacity(.2)),
                  splashColor: Colors.white.withOpacity(.1),
                  focusColor: Colors.white.withOpacity(.1),
                  hoverColor: Colors.white.withOpacity(.1),
                  highlightColor: Colors.white.withOpacity(.1),
                  borderRadius: BorderRadius.circular(200),
                  onTap: () {
                    updateValue(
                        "${getValue("tasbeehLastIndex")}number",
                        (getValue("${getValue("tasbeehLastIndex")}number") ??
                                0) +
                            1);
                    setState(() {});
                  },
                  child: Center(
                    child: Text(
                        "${getValue("${getValue("tasbeehLastIndex")}number") ?? 0}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "roboto")),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
