import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nabd/blocs/bloc/quran_page_player_bloc.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/QuranPages/views/quranDetailsPage.dart';
import 'package:nabd/core/widgets/hizb_quarter_circle.dart';
import 'package:nabd/models/surah.dart';

import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:flutter/material.dart' as m;
import '../helpers/convertNumberToAr.dart';

class SurahListPage extends StatefulWidget {
  var jsonData;
  var quarterjsonData;
  SurahListPage(
      {Key? key, required this.jsonData, required this.quarterjsonData})
      : super(key: key);

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  bool isLoading = true;
  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    // overlays: SystemUiOverlay.values); // TODO: implement dispose
    super.dispose();
  }

  TextEditingController textEditingController = TextEditingController();
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10, // Choose a suitable number of shimmering items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(.5),
          highlightColor: quranPagesColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                color: backgroundColor, // Shimmer effect
              ),
              title: Container(
                height: 15,
                color: backgroundColor, // Shimmer effect
              ),
              subtitle: Container(
                height: 12,
                color: backgroundColor, // Shimmer effect
              ),
            ),
          ),
        );
      },
    );
  }

  getCircleWidget(index, hizbNumber) {
    if (index == 0) {
      return Container(
        width: 33.sp,
        height: 33.sp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: quranPagesColor.withOpacity(.1), // Replace with your logic
        ),
        child: Center(
          child: Text(
            hizbNumber.toString(),
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    } else if (index == 1) {
      return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: quranPagesColor.withOpacity(.1), // Replace with your logic
          ),
          child: QuarterCircle(color: quranPagesColor, size: 20.sp));
    } else if (index == 2) {
      return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: quranPagesColor.withOpacity(.1), // Replace with your logic
          ),
          child: HalfCircle(color: quranPagesColor, size: 20.sp));
    } else if (index == 3) {
      return Container(
          width: 20.sp,
          height: 20.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: quranPagesColor.withOpacity(.1), // Replace with your logic
          ),
          child: ThreeQuartersCircle(color: quranPagesColor, size: 20.sp));
    }
  }

  var searchQuery = "";
  var filteredData;
  @override
  void initState() {
    getStarredVerse();
    getValue("lastRead") != "non" ?? getJuzNumber();
    // getJuzNumber();
    addFilteredData(); // TODO: implement initState
    super.initState();
  }

  int juzNumberLastRead = 0;
  getJuzNumber() async {
    juzNumberLastRead = quran.getJuzNumber(
        quran.getPageData(getValue("lastRead"))[0]["surah"],
        quran.getPageData(getValue("lastRead"))[0]["start"]);
    print(juzNumberLastRead);
    setState(() {});
    // await Future.delayed(const Duration(milliseconds: 300));
    // _juzScrollController.scrollTo(
    //     index: juzNumberLastRead-1, duration: const Duration(milliseconds: 500));
  }

  List bookmarks = [
    getValue("greenBookmark"),
    getValue("redBookmark"),
    getValue("blueBookmark"),
  ];

  reloadBookmarks() {
    setState(() {
      bookmarks = [
        getValue("greenBookmark"),
        getValue("redBookmark"),
        getValue("blueBookmark"),
      ];
    });
  }

  int quarterNumberLastRead = 0;
  getJquarterNumber() async {
    juzNumberLastRead = quran.getJuzNumber(
        quran.getPageData(getValue("lastRead"))[0]["surah"],
        quran.getPageData(getValue("lastRead"))[0]["start"]);
    print(juzNumberLastRead);
    setState(() {});
    // await Future.delayed(const Duration(milliseconds: 300));
    // _juzScrollController.scrollTo(
    //     index: juzNumberLastRead-1, duration: const Duration(milliseconds: 500));
  }

  final ItemScrollController _juzScrollController = ItemScrollController();

  addFilteredData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      filteredData = widget.jsonData;
      isLoading = false;
    });
  }

  List<Surah> surahList = [];
  int _currentIndex = 0;

  // Define the tabs
  final List<Tab> tabs = <Tab>[
    Tab(text: 'surah'.tr()),
    Tab(text: 'juz'.tr()),
    Tab(text: 'quarter'.tr()),
  ];
  var ayatFiltered;
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  Set<String> starredVerses = {};

  getStarredVerse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: Container(
          decoration: const BoxDecoration(
              // image: DecorationImage(
              //     image: AssetImage("assets/images/homebackground.png"),
              //     alignment: Alignment.topCenter,
              //     opacity: .256),
              color: quranPagesColor),
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              endDrawer: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * .7,
                  color: const Color.fromARGB(255, 255, 251, 248),
                  child: ListView(
                      shrinkWrap: true,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            EasyContainer(
                              color: primaryColors[0].withOpacity(.05),
                              onTap: () async {
                                if (getValue("greenBookmark") != null) {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => BlocProvider(
                                                create: (context) =>
                                                    QuranPagePlayerBloc(),
                                                child: QuranDetailsPage(
                                                    shouldHighlightSura: false,
                                                    pageNumber: quran.getPageNumber(
                                                        int.parse(
                                                            getValue("greenBookmark")
                                                                .split("-")[0]),
                                                        int.parse(getValue(
                                                                "greenBookmark")
                                                            .split("-")[1])),
                                                    jsonData: widget.jsonData,
                                                    shouldHighlightText: true,
                                                    highlightVerse: quran.getVerse(
                                                        int.parse(
                                                            getValue("greenBookmark")
                                                                .split("-")[0]),
                                                        int.parse(getValue("greenBookmark").split("-")[1])),
                                                    quarterJsonData: widget.quarterjsonData),
                                              )));
                                }
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.bookmark,
                                          color: Colors.greenAccent,
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Text("greenbookmark".tr(),
                                            style: TextStyle(
                                                fontFamily: "cairo",
                                                fontSize: 14.sp,
                                                color: primaryColors[0])),
                                      ],
                                    ),
                                    const Divider(),
                                    if (getValue("greenBookmark") != null)
                                      SizedBox(
                                        // width: MediaQuery.of(context).size.width * .4,
                                        child: Text(
                                            quran.getVerse(
                                              int.parse(
                                                  getValue("greenBookmark")
                                                      .toString()
                                                      .split('-')[0]),
                                              int.parse(
                                                  getValue("greenBookmark")
                                                      .toString()
                                                      .split('-')[1]),
                                            ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: fontFamilies[0],
                                              fontSize: 18.sp,
                                              color: primaryColors[0],
                                            )),
                                      ),
                                    if (getValue("greenBookmark") != null)
                                      const Divider(),
                                    if (getValue("greenBookmark") != null)
                                      Text(
                                        context.locale.languageCode == "ar"
                                            ? quran.getSurahNameArabic(
                                                int.parse(
                                                    getValue("greenBookmark")
                                                        .toString()
                                                        .split('-')[0]))
                                            : quran.getSurahNameEnglish(
                                                int.parse(
                                                    getValue("greenBookmark")
                                                        .toString()
                                                        .split('-')[0])),
                                        style: const TextStyle(),
                                      ),
                                    if (getValue("greenBookmark") != null)
                                      Text(
                                          "${convertToArabicNumber((int.parse(getValue("greenBookmark").split("-")[1]).toString()))} " //               quran.getVerseEndSymbol()
                                          ,
                                          style: TextStyle(
                                              fontSize: 24.sp,
                                              color: Colors.blueAccent,
                                              fontFamily:
                                                  "KFGQPC Uthmanic Script HAFS Regular"))
                                  ],
                                ),
                              ),
                            ),
                            EasyContainer(
                              color: primaryColors[0].withOpacity(.05),
                              onTap: () async {
                                if (getValue("redBookmark") != null) {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => BlocProvider(
                                                create: (context) =>
                                                    QuranPagePlayerBloc(),
                                                child: QuranDetailsPage(
                                                    shouldHighlightSura: false,
                                                    pageNumber: quran.getPageNumber(
                                                        int.parse(
                                                            getValue("redBookmark")
                                                                .split("-")[0]),
                                                        int.parse(getValue(
                                                                "redBookmark")
                                                            .split("-")[1])),
                                                    jsonData: widget.jsonData,
                                                    shouldHighlightText: true,
                                                    highlightVerse: quran.getVerse(
                                                        int.parse(
                                                            getValue("redBookmark")
                                                                .split("-")[0]),
                                                        int.parse(getValue("redBookmark").split("-")[1])),
                                                    quarterJsonData: widget.quarterjsonData),
                                              )));
                                }
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.bookmark,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Text("redbookamrk".tr(),
                                            style: TextStyle(
                                                fontFamily: "cairo",
                                                fontSize: 14.sp,
                                                color: primaryColors[0])),
                                      ],
                                    ),
                                    const Divider(),
                                    if (getValue("redBookmark") != null)
                                      SizedBox(
                                        // width: MediaQuery.of(context).size.width * .4,
                                        child: Text(
                                            quran.getVerse(
                                              int.parse(getValue("redBookmark")
                                                  .toString()
                                                  .split('-')[0]),
                                              int.parse(getValue("redBookmark")
                                                  .toString()
                                                  .split('-')[1]),
                                            ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: fontFamilies[0],
                                              fontSize: 18.sp,
                                              color: primaryColors[0],
                                            )),
                                      ),
                                    if (getValue("redBookmark") != null)
                                      const Divider(),
                                    if (getValue("redBookmark") != null)
                                      Text(
                                        context.locale.languageCode == "ar"
                                            ? quran.getSurahNameArabic(
                                                int.parse(
                                                    getValue("redBookmark")
                                                        .toString()
                                                        .split('-')[0]))
                                            : quran.getSurahNameEnglish(
                                                int.parse(
                                                    getValue("redBookmark")
                                                        .toString()
                                                        .split('-')[0])),
                                        style: const TextStyle(),
                                      ),
                                    if (getValue("redBookmark") != null)
                                      Text(
                                          "${convertToArabicNumber((int.parse(getValue("redBookmark").split("-")[1]).toString()))} " //               quran.getVerseEndSymbol()
                                          ,
                                          style: TextStyle(
                                              fontSize: 24.sp,
                                              color: Colors.blueAccent,
                                              fontFamily:
                                                  "KFGQPC Uthmanic Script HAFS Regular"))
                                  ],
                                ),
                              ),
                            ),
                            EasyContainer(
                              color: primaryColors[0].withOpacity(.05),
                              onTap: () async {
                                if (getValue("blueBookmark") != null) {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => BlocProvider(
                                                create: (context) =>
                                                    QuranPagePlayerBloc(),
                                                child: QuranDetailsPage(
                                                    shouldHighlightSura: false,
                                                    pageNumber: quran.getPageNumber(
                                                        int.parse(
                                                            getValue("blueBookmark")
                                                                .split("-")[0]),
                                                        int.parse(getValue(
                                                                "blueBookmark")
                                                            .split("-")[1])),
                                                    jsonData: widget.jsonData,
                                                    shouldHighlightText: true,
                                                    highlightVerse: quran.getVerse(
                                                        int.parse(
                                                            getValue("blueBookmark")
                                                                .split("-")[0]),
                                                        int.parse(getValue("blueBookmark").split("-")[1])),
                                                    quarterJsonData: widget.quarterjsonData),
                                              )));
                                }
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.bookmark,
                                          color: Colors.blueAccent,
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        Text("bluebookamrk".tr(),
                                            style: TextStyle(
                                                fontFamily: "cairo",
                                                fontSize: 14.sp,
                                                color: primaryColors[0])),
                                      ],
                                    ),
                                    const Divider(),
                                    if (getValue("blueBookmark") != null)
                                      SizedBox(
                                        // width: MediaQuery.of(context).size.width * .4,
                                        child: Text(
                                            quran.getVerse(
                                              int.parse(getValue("blueBookmark")
                                                  .toString()
                                                  .split('-')[0]),
                                              int.parse(getValue("blueBookmark")
                                                  .toString()
                                                  .split('-')[1]),
                                            ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: fontFamilies[0],
                                              fontSize: 18.sp,
                                              color: primaryColors[0],
                                            )),
                                      ),
                                    if (getValue("blueBookmark") != null)
                                      const Divider(),
                                    if (getValue("blueBookmark") != null)
                                      Text(
                                        context.locale.languageCode == "ar"
                                            ? quran.getSurahNameArabic(
                                                int.parse(
                                                    getValue("blueBookmark")
                                                        .toString()
                                                        .split('-')[0]))
                                            : quran.getSurahNameEnglish(
                                                int.parse(
                                                    getValue("blueBookmark")
                                                        .toString()
                                                        .split('-')[0])),
                                        style: const TextStyle(),
                                      ),
                                    if (getValue("blueBookmark") != null)
                                      Text(
                                          "${convertToArabicNumber((int.parse(getValue("blueBookmark").split("-")[1]).toString()))} " //               quran.getVerseEndSymbol()
                                          ,
                                          style: TextStyle(
                                              fontSize: 24.sp,
                                              color: Colors.blueAccent,
                                              fontFamily:
                                                  "KFGQPC Uthmanic Script HAFS Regular"))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 8.0.h),
                          child: Text(
                            "starredverses".tr(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                            ),
                          ),
                        )),
                        Center(
                          child: Icon(Icons.keyboard_arrow_down, size: 18.sp),
                        ),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: starredVerses
                              .map((e) => EasyContainer(
                                  color: primaryColors[0].withOpacity(.05),
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => BlocProvider(
                                                  create: (context) =>
                                                      QuranPagePlayerBloc(),
                                                  child: QuranDetailsPage(
                                                      shouldHighlightSura:
                                                          false,
                                                      pageNumber:
                                                          quran.getPageNumber(
                                                              int.parse(e.split(
                                                                  "-")[0]),
                                                              int.parse(e.split(
                                                                  "-")[1])),
                                                      jsonData: widget.jsonData,
                                                      shouldHighlightText: true,
                                                      highlightVerse: quran.getVerse(
                                                          int.parse(
                                                              e.split("-")[0]),
                                                          int.parse(
                                                              e.split("-")[1])),
                                                      quarterJsonData: widget
                                                          .quarterjsonData),
                                                )));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                          quran.getVerse(
                                              int.parse(e.split("-")[0]),
                                              int.parse(e.split("-")[1])),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: fontFamilies[0],
                                            fontSize: 18.sp,
                                            color: primaryColors[0],
                                          )),
                                      Text(
                                        context.locale.languageCode == "ar"
                                            ? quran.getSurahNameArabic(
                                                int.parse(e.split("-")[0]))
                                            : quran.getSurahNameEnglish(
                                                int.parse(e.split("-")[0])),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                          "${convertToArabicNumber((int.parse(e.split("-")[1]).toString()))} " //               quran.getVerseEndSymbol()
                                          ,
                                          style: TextStyle(
                                              fontSize: 24.sp,
                                              color: Colors.blueAccent,
                                              fontFamily:
                                                  "KFGQPC Uthmanic Script HAFS Regular"))
                                    ],
                                  )))
                              .toList(),
                        )
                      ]),
                ),
              ),
              key: scaffoldKey,
              appBar: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width.w, 80.h),
                child: AppBar(
                  actions: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.0.w, vertical: 8.h),
                      child: Builder(builder: (context) {
                        return IconButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            icon: const Icon(
                              Iconsax.bookmark,
                              color: backgroundColor,
                            ));
                      }),
                    )
                  ],
                  leading: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height * 0.04,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.04,
                      decoration: BoxDecoration(
                        color: Colors
                            .transparent, // Change this to your desired color
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 20.w),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Colors.white,
                        indicatorWeight: 4,
                        tabs: tabs,
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                          // if(index==1)getJuzNumber();
                        },
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r))),
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: quranPagesColor,
                  title: Text(
                    "alQuran".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  SafeArea(
                    child: Container(
                      color: backgroundColor,
                      child: Column(
                        children: [
                          if (getValue("lastRead") != "non")
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: EasyContainer(
                                  color: quranPagesColor,
                                  height: 60.h,
                                  padding: 0,
                                  margin: 0,
                                  borderRadius: 15.r,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "lastRead".tr(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Text(
                                            "${context.locale.languageCode == "ar" ? (quran.getSurahNameArabic(quran.getPageData(getValue("lastRead"))[0]["surah"])) : (quran.getSurahName(quran.getPageData(getValue("lastRead"))[0]["surah"]))} - ${getValue("lastRead")}",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => BlocProvider(
                                                  create: (context) =>
                                                      QuranPagePlayerBloc(),
                                                  child: QuranDetailsPage(
                                                      shouldHighlightSura:
                                                          false,
                                                      pageNumber:
                                                          getValue("lastRead"),
                                                      jsonData: widget.jsonData,
                                                      shouldHighlightText:
                                                          false,
                                                      highlightVerse: "",
                                                      quarterJsonData: widget
                                                          .quarterjsonData),
                                                )));
                                    setState(() {});
                                  }),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0.w),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffF6F6F6),
                                          borderRadius:
                                              BorderRadius.circular(5.r)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0.w),
                                              child: TextField(
                                                controller:
                                                    textEditingController,
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchQuery = value;
                                                  });
                                                  if (value == "") {
                                                    filteredData =
                                                        widget.jsonData;
                                                    setState(() {});
                                                  } /*https://api.alquran.cloud/v1/search/%D8%A7%D8%A8%D8%B1%D8%A7%D9%87%D9%8A%D9%85/all/ar*/
                                                  if (searchQuery.length > 3 ||
                                                      searchQuery
                                                          .toString()
                                                          .contains(" ")) {
                                                    setState(() {
                                                      ayatFiltered = [];
                                                      searchQuery = value;

                                                      ayatFiltered =
                                                          quran.searchWords(
                                                              searchQuery);
                                                      filteredData = widget
                                                          .jsonData
                                                          .where((sura) {
                                                        final suraName =
                                                            sura['englishName']
                                                                .toLowerCase();
                                                        // final suraNameTranslated =
                                                        //     sura['name']
                                                        //         .toString()
                                                        //         .toLowerCase();
                                                        final suraNameTranslated =
                                                            quran.getSurahNameArabic(
                                                                sura["number"]);

                                                        return suraName.contains(
                                                                searchQuery
                                                                    .toLowerCase()) ||
                                                            suraNameTranslated
                                                                .contains(
                                                                    searchQuery
                                                                        .toLowerCase());
                                                      }).toList();
                                                    });
                                                  }
                                                },
                                                cursorColor: quranPagesColor,
                                                decoration: InputDecoration(
                                                  hintText: 'searchQuran'.tr(),
                                                  hintStyle: const TextStyle(
                                                      fontFamily: "aldahabi",
                                                      color: Color.fromARGB(
                                                          73, 0, 0, 0)),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (searchQuery.isNotEmpty) {
                                                filteredData = widget.jsonData;
                                                textEditingController.clear();
                                                setState(() {
                                                  searchQuery = "";
                                                });
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: searchQuery.isNotEmpty
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(Icons.close,
                                                          color: Color.fromARGB(
                                                              73, 0, 0, 0)),
                                                    )
                                                  : const Icon(
                                                      FontAwesome.search,
                                                      color: Color.fromARGB(
                                                          73, 0, 0, 0)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: isLoading
                                ? _buildShimmerLoading()
                                : ListView(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    children: [
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (context, index) =>
                                            Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0.w),
                                          child: Divider(
                                            color: Colors.grey.withOpacity(.5),
                                          ),
                                        ),
                                        itemCount: filteredData.length,
                                        itemBuilder: (context, index) {
                                          int suraNumber = index + 1;
                                          String suraName = filteredData[index]
                                              ["englishName"];
                                          String suraNameEnglishTranslated =
                                              filteredData[index]
                                                  ["englishNameTranslation"];
                                          int suraNumberInQuran =
                                              filteredData[index]["number"];
                                          String suraNameTranslated =
                                              filteredData[index]["name"]
                                                  .toString();
                                          int ayahCount =
                                              quran.getVerseCount(suraNumber);

                                          return Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: ListTile(
                                              leading: Container(
                                                width: 45,
                                                height: 45,
                                                decoration: const BoxDecoration(
                                                    image: DecorationImage(
                                                  image: AssetImage(
                                                    "assets/images/sura_frame.png",
                                                  ),
                                                )),
                                                child: Center(
                                                  child: Text(
                                                    suraNumberInQuran
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: quranPagesColor,
                                                        fontSize: 14.sp),
                                                  ),
                                                ),
                                              ) //  Material(

                                              ,
                                              minVerticalPadding: 0,
                                              title: SizedBox(
                                                width: 90.w,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      suraName,
                                                      style: TextStyle(
                                                          // fontWeight: FontWeight.bold,
                                                          color:
                                                              quranPagesColor,
                                                          fontSize: 14.sp,
                                                          fontWeight: FontWeight
                                                              .w700, // Text color
                                                          fontFamily:
                                                              "uthmanic"),
                                                    ),
                                                    if (bookmarks.any((a) {
                                                      return a
                                                          .toString()
                                                          .startsWith(
                                                              "$suraNumberInQuran");
                                                    }))
                                                      Icon(Icons.bookmark,
                                                          size: 16.sp,
                                                          color: colorsOfBookmarks2[
                                                                  bookmarks
                                                                      .indexWhere(
                                                                          (a) {
                                                            return a
                                                                .toString()
                                                                .startsWith(
                                                                    "$suraNumberInQuran");
                                                          })]
                                                              .withOpacity(.7))
                                                  ],
                                                ),
                                              ),
                                              subtitle: Text(
                                                "$suraNameEnglishTranslated ($ayahCount)",
                                                style: TextStyle(
                                                    fontFamily: "uthmanic",
                                                    fontSize: 14.sp,
                                                    color: Colors.grey
                                                        .withOpacity(.8)),
                                              ),
                                              trailing: Text(
                                                suraNameTranslated,
                                                style: TextStyle(
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.black54,
                                                    fontSize:
                                                        18.sp, // Text color
                                                    fontFamily: "me"),
                                              ),
                                              onTap: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (builder) =>
                                                            BlocProvider(
                                                              create: (context) =>
                                                                  QuranPagePlayerBloc(),
                                                              child: QuranDetailsPage(
                                                                  shouldHighlightSura:
                                                                      true,
                                                                  shouldHighlightText:
                                                                      false,
                                                                  highlightVerse:
                                                                      "",
                                                                  jsonData: widget
                                                                      .jsonData,
                                                                  quarterJsonData:
                                                                      widget
                                                                          .quarterjsonData,
                                                                  pageNumber: quran
                                                                      .getPageNumber(
                                                                          suraNumberInQuran,
                                                                          1)),
                                                            )));
                                                // Handle tapping on a sura item here
                                                // You can navigate to the sura details page or perform any other action.
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      if (ayatFiltered != null) const Divider(),
                                      if (ayatFiltered != null)
                                        ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                    
                                          itemCount:
                                              ayatFiltered["occurences"] > 10
                                                  ? 10
                                                  : ayatFiltered["occurences"],
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: EasyContainer( borderRadius: 14,

                                                onTap: () async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (builder) =>
                                                                  BlocProvider(
                                                                    create: (context) =>
                                                                        QuranPagePlayerBloc(),
                                                                    child: QuranDetailsPage(
                                                                        shouldHighlightSura:
                                                                            false,
                                                                        pageNumber: quran.getPageNumber(
                                                                            ayatFiltered["result"][index][
                                                                                "surah"],
                                                                            ayatFiltered["result"][index][
                                                                                "verse"]),
                                                                        jsonData:
                                                                            widget
                                                                                .jsonData,
                                                                        shouldHighlightText:
                                                                            true,
                                                                        highlightVerse: quran.getVerse(
                                                                            ayatFiltered["result"][index]["surah"],
                                                                            ayatFiltered["result"][index]["verse"]),
                                                                        quarterJsonData: widget.quarterjsonData),
                                                                  )));
                                                },
                                                child:  Text(
                                                    "سورة ${quran.getSurahNameArabic(ayatFiltered["result"][index]["surah"])} - ${quran.getVerse(ayatFiltered["result"][index]["surah"], ayatFiltered["result"][index]["verse"], verseEndSymbol: true)}",
                                                 textDirection: m.TextDirection.rtl,   style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "uthmanic",
                                                        fontSize: 17.sp),
                                                  
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const Text("data"),
                  ScrollablePositionedList.builder(
                    itemCount: 30,
                    itemScrollController: _juzScrollController,
                    itemBuilder: (BuildContext context, index) {
                      return Card(
                        color: backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              title: Text(quran.getSurahNameArabic(quran
                                  .getSurahAndVersesFromJuz(index + 1)
                                  .keys
                                  .first)),
                              subtitle: Text(
                                quran.getVerse(
                                    quran
                                        .getSurahAndVersesFromJuz(index + 1)
                                        .keys
                                        .first,
                                    quran
                                        .getSurahAndVersesFromJuz(index + 1)
                                        .values
                                        .first[0]),
                                style: TextStyle(
                                  fontFamily: "UthmanicHafs13",
                                  fontSize: 18.sp,
                                  // fontWeight: FontWeight.w600
                                ),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => BlocProvider(
                                              create: (context) =>
                                                  QuranPagePlayerBloc(),
                                              child: QuranDetailsPage(
                                                  shouldHighlightSura: false,
                                                  quarterJsonData:
                                                      widget.quarterjsonData,
                                                  shouldHighlightText: true,
                                                  highlightVerse: quran.getVerse(
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .keys
                                                          .first,
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .values
                                                          .first[0]),
                                                  pageNumber: quran.getPageNumber(
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .keys
                                                          .first,
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .values
                                                          .first[0]),
                                                  jsonData: widget.jsonData),
                                            )));
                                getJuzNumber();
                                setState(() {});
                              },
                              leading: Container(
                                width: 33.sp,
                                height: 33.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: juzNumberLastRead == index + 1
                                      ? quranPagesColor
                                      : quranPagesColor.withOpacity(
                                          .1), // Replace with your logic
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                              )),
                        ),
                      );
                    },
                  ),

                  GroupListView(
                    sectionsCount: 60,
                    countOfItemInSection: (int section) {
                      return 4;
                    },
                    itemBuilder: (BuildContext context, IndexPath index) {
                      return Card(
                        color: backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(quran.getSurahNameArabic(
                                widget.quarterjsonData[
                                        indexes[index.section][index.index] - 1]
                                    ["surah"])),
                            subtitle: Text(
                              quran.getVerse(
                                  widget.quarterjsonData[indexes[index.section]
                                          [index.index] -
                                      1]["surah"],
                                  widget.quarterjsonData[indexes[index.section]
                                          [index.index] -
                                      1]["ayah"]),
                              style: TextStyle(
                                fontFamily: "UthmanicHafs13",
                                fontSize: 18.sp,
                                // fontWeight: FontWeight.w600
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => BlocProvider(
                                            create: (context) =>
                                                QuranPagePlayerBloc(),
                                            child: QuranDetailsPage(
                                                shouldHighlightSura: false,
                                                quarterJsonData:
                                                    widget.quarterjsonData,
                                                shouldHighlightText: true,
                                                highlightVerse: quran.getVerse(
                                                    widget.quarterjsonData[indexes[index.section][index.index] - 1]
                                                        ["surah"],
                                                    widget.quarterjsonData[indexes[index.section][index.index] - 1]
                                                        ["ayah"]),
                                                pageNumber: quran.getPageNumber(
                                                    widget.quarterjsonData[indexes[index.section][index.index] - 1]
                                                        ["surah"],
                                                    widget.quarterjsonData[
                                                        indexes[index.section]
                                                                [index.index] -
                                                            1]["ayah"]),
                                                jsonData: widget.jsonData),
                                          )));

                              setState(() {});
                            },
                            leading:
                                getCircleWidget(index.index, index.section + 1),
                          ),
                        ),
                      );
                    },
                    groupHeaderBuilder: (BuildContext context, int section) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Text(
                          "${"hizb".tr()} ${section + 1}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    sectionSeparatorBuilder: (context, section) =>
                        const SizedBox(height: 10),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
