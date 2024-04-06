import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/hadith/models/hadith_min.dart';
import 'package:nabd/core/hadith/views/hadithdetailspage.dart';
import 'package:quran/quran.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithList extends StatefulWidget {
  String locale;
  String id;
  String count;
  String title;
  HadithList(
      {super.key,
      required this.locale,
      required this.id,
      required this.title,
      required this.count});

  @override
  State<HadithList> createState() => _HadithListState();
}

class _HadithListState extends State<HadithList> {
  bool isLoading = true;
  List<HadithMin> hadithes = [];

  getHadithList() async {
    hadithes = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonData =
        prefs.getString("hadithlist-${widget.id}-${widget.locale}");
    if (widget.id == "100000"&&prefs.getString("hadithlist-100000-${widget.locale}")!=null) {
      final jsonData = prefs.getString("hadithlist-100000-${widget.locale}");
      final data = json.decode(jsonData!) as List<dynamic>;
      for (var hadith in data) {
        if (hadithes
                .indexWhere((element) => element.title == hadith["title"]) ==
            -1) {
          hadithes.add(HadithMin.fromJson(hadith));
        } else {}
      }

      // starredRadios = json.decode(getValue("starredRadios"));
      setState(() {
        // radiosData = data;
        isLoading = false;
      });
    }
    if (jsonData != null) {
      print("notnull");

      final data = json.decode(jsonData) as List<dynamic>;
      for (var hadith in data) {
        hadithes.add(HadithMin.fromJson(hadith));
      }

      // starredRadios = json.decode(getValue("starredRadios"));
      setState(() {
        // radiosData = data;
        isLoading = false;
      });
    } else {
      Response response = await Dio().get(
          "https://hadeethenc.com/api/v1/hadeeths/list/?language=${widget.locale}&category_id=${widget.id}&per_page=699999");
      print("response.datlength");
      print(response.data["data"].length);
      await response.data["data"]
          .forEach((hadith) => hadithes.add(HadithMin.fromJson(hadith)));
      setState(() {
        isLoading = false;
      });
    }
    tempHadithes = hadithes;
    print(hadithes.length);
  }

  @override
  void initState() {
    getHadithList(); // TODO: implement initState
    super.initState();
  }

  List<HadithMin> filteredHadithes = []; // TOD
  List<HadithMin> tempHadithes = []; // TOD
  searchFunction(searchwords) {
    filteredHadithes = tempHadithes
        .where(
            (element) => removeDiacritics(element.title).contains(searchwords))
        .toList();

    hadithes = filteredHadithes;
    if (searchwords == "") {
      hadithes = tempHadithes;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    iconTheme:  IconThemeData(color: getValue("darkMode")?Colors.white.withOpacity(.87): Colors.black87),
                    backgroundColor: getValue("darkMode")?darkModeSecondaryColor: quranPagesColorLight,
                    elevation: 0, // No shadow
                    title: Text(
                      "${widget.title}- ${widget.count}",
                      style: TextStyle(color: getValue("darkMode")?Colors.white.withOpacity(.87): Colors.black87, fontSize: 16.sp),
                    ),
                    expandedHeight: 100.h,
                    collapsedHeight: kToolbarHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: getValue("darkMode")?darkModeSecondaryColor: const Color(0xffF5EFE8).withOpacity(.3),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                             Icon(Icons.search, color: getValue("darkMode")?Colors.white60: Colors.black54),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(style: TextStyle(
                              color:   getValue("darkMode")?Colors.white:Colors.black
                              ),
                                onChanged: (val) {
                                  searchFunction(val);
                                },
                                decoration:  InputDecoration(
                                  hintText: 'SearchHadith'.tr(),
                                  border: InputBorder.none,hintStyle:  TextStyle(
                              color:   getValue("darkMode")?Colors.white:Colors.black
                              ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: hadithes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OpenContainer(
                          closedElevation: 0,closedColor: Colors.transparent,middleColor: getValue("darkMode")
              ? darkModeSecondaryColor
              :Colors.white,
                          transitionType: ContainerTransitionType.fadeThrough,
                          transitionDuration: const Duration(milliseconds: 500),
                          openBuilder: (context, action) => HadithDetailsPage(
                              title: hadithes[index].title,
                              locale: context.locale.languageCode,
                              id: hadithes[index].id),
                          closedBuilder: (context, action) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color:getValue("darkMode")?darkModeSecondaryColor: const Color(0xffF5EFE8).withOpacity(.4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      hadithes[index].title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16.sp,fontFamily: "Taha",color: getValue("darkMode")?Colors.white.withOpacity(.87):Colors.black87),
                                    ),
                                     Icon(Entypo.down_open_mini,color: getValue("darkMode")?Colors.white.withOpacity(.87):Colors.black87)
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  )
                ],
              ));
  }
}
