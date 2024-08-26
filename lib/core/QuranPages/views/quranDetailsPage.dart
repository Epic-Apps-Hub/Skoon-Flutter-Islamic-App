import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:nabd/core/QuranPages/helpers/remove_html_tags.dart';
import 'package:nabd/core/QuranPages/widgets/bookmark_dialog.dart';

import '../helpers/translation/get_translation_data.dart'
    as get_translation_data;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nabd/blocs/bloc/player_bloc_bloc.dart';
import 'package:nabd/blocs/bloc/quran_page_player_bloc.dart';
import 'package:nabd/GlobalHelpers/printYellow.dart';
import 'package:nabd/core/QuranPages/helpers/translation/translationdata.dart';
import 'package:nabd/models/TranslationInfo.dart';
import 'package:nabd/models/reciter.dart';
import 'package:nabd/core/QuranPages/helpers/convertNumberToAr.dart';
import 'package:nabd/core/QuranPages/views/screenshot_preview.dart';
import 'package:nabd/core/QuranPages/widgets/bismallah.dart';
import 'package:nabd/core/QuranPages/widgets/header_widget.dart';
import 'package:nabd/core/QuranPages/widgets/tafseer_and_translation_sheet.dart';
import 'package:nabd/core/home.dart';
import 'package:nabd/core/QuranPages/helpers/convertNumberToAr.dart';
import 'package:nabd/core/QuranPages/widgets/bismallah.dart';
import 'package:nabd/core/QuranPages/widgets/header_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
// import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:easy_container/easy_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:quran/quran.dart' as quran;
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
// import 'package:tiktoklikescroller/tiktoklikescroller.dart' as verticalScroll;
import 'package:wakelock/wakelock.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:intl/intl.dart';
import 'package:arabic_roman_conv/arabic_roman_conv.dart';
import '../helpers/translation/get_translation_data.dart' as translate;
import 'package:syncfusion_flutter_sliders/sliders.dart';

class QuranReadingPage extends StatefulWidget {
  const QuranReadingPage({super.key});

  @override
  State<QuranReadingPage> createState() => _QuranReadingPageState();
}

class _QuranReadingPageState extends State<QuranReadingPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class QuranDetailsPage extends StatefulWidget {
  int pageNumber;
  var jsonData;
  var quarterJsonData;
  var shouldHighlightText;
  var highlightVerse;
  var shouldHighlightSura;
  // var highlighSurah;
  QuranDetailsPage(
      {super.key,
      required this.pageNumber,
      required this.jsonData,
      required this.shouldHighlightText,
      required this.highlightVerse,
      required this.quarterJsonData,
      required this.shouldHighlightSura});

  @override
  State<QuranDetailsPage> createState() => QuranDetailsPageState();
}

class QuranDetailsPageState extends State<QuranDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  // var controller;
  final ItemScrollController itemScrollController = ItemScrollController();
// final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
// final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create()

  // final bool _isScrolling = false;

  // List bookmarks = [
  //   getValue("greenBookmark"),
  //   getValue("redBookmark"),
  //   getValue("blueBookmark"),
  // ];

  // reloadBookmarks() {
  //   setState(() {
  //     bookmarks = [
  //       getValue("greenBookmark"),
  //       getValue("redBookmark"),
  //       getValue("blueBookmark"),
  //     ];
  //   });
  // }
  List bookmarks = [];
  fetchBookmarks() {
    bookmarks = json.decode(getValue("bookmarks"));
    setState(() {});
    // print(bookmarks);
  }

  var dataOfCurrentTranslation;
  getTranslationData() async {
    if (getValue("indexOfTranslationInVerseByVerse") > 1) {
      File file = File(
          "${appDir!.path}/${translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeText}.json");

      String jsonData = await file.readAsString();
      dataOfCurrentTranslation = json.decode(jsonData);
    }
    setState(() {});
  }

  var currentVersePlaying;
  // late final ScrollController _controller;
  int index = 0;
  setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  double valueOfSlider = 0;

  late Timer timer;
  Directory? appDir;
  initialize() async {
    appDir = await getTemporaryDirectory();
    getTranslationData();
    if (mounted) {
      setState(() {});
    }
  }

  checkIfSelectHighlight() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (selectedSpan != "") {
        setState(() {
          selectedSpan = "";
        });
      }
    });
  }

  int playIndexPage = 0;

  @override
  void initState() {
    fetchBookmarks();
    //var formatter = NumberFormat('', 'ar');print("ننتاا");
    initialize();
    getTranslationData();
    // reloadBookmarks();
    // verticalScrollController.addListener((event) {
    //   _handleCallbackEvent(event.direction, event.success);
    // });
    checkIfSelectHighlight();
    setIndex();

    changeHighlightSurah();
    // _model = ScrollListener.initialise(controller);

    highlightVerseFunction();
    _scrollController.addListener(_scrollListener);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pageController = PageController(initialPage: index);
    _pageController.addListener(_pagecontroller_scrollListner);
    // assignPageNumberToIndex+1();
    // addTextSpans(); // TODO: implement initState
    Wakelock.enable();
    updateValue("lastRead", widget.pageNumber);
    addReciters(); // addValueToFontSize();
    // updateValue("quranPageolorsIndex", 0);
    super.initState();
  }

  List<QuranPageReciter> reciters = [];
  addReciters() {
    quran.getReciters().forEach((element) {
      // if(element.reciterName.contains(quran.getVerse(surahNumber, verseNumber).reciterName)){
      reciters.add(QuranPageReciter(
        identifier: element["identifier"],
        language: element["language"],
        name: element["name"],
        englishName: element["englishName"],
        format: element["format"],
        type: element["type"],
        direction: element["direction"],
      ));
    });
  }

  void _scrollListener() {
    if (_scrollController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    } else {}
  }

  void _pagecontroller_scrollListner() {
    if (_pageController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    } else {}
  }

  var highlightVerse;
  var shouldHighlightText;
  changeHighlightSurah() async {
    await Future.delayed(const Duration(seconds: 2));
    widget.shouldHighlightSura = false;
  }

  highlightVerseFunction() {
    setState(() {
      shouldHighlightText = widget.shouldHighlightText;
    });
    if (widget.shouldHighlightText) {
      setState(() {
        highlightVerse = widget.highlightVerse;
      });

      Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (mounted) {
          setState(() {
            shouldHighlightText = false;
          });
        }
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              shouldHighlightText = true;
            });
          }
          if (timer.tick == 4) {
            if (mounted) {
              setState(() {
                highlightVerse = "";

                shouldHighlightText = false;
              });
            }
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Wakelock.disable();
    getTotalCharacters(quran.getVersesTextByPage(widget.pageNumber));
    super.dispose();
  }

  int total = 0;
  int total1 = 0;
  int total3 = 0;
  int getTotalCharacters(List<String> stringList) {
    total = 0;
    for (String str in stringList) {
      total += str.length;
    }
    // print(total);
    return total;
  }

  checkIfAyahIsAStartOfSura() {}
  String? swipeDirection;
  late PageController _pageController;

  var english = RegExp(r'[a-zA-Z]');

  String selectedSpan = "";

  late Uint8List _imageFile;
  Result checkIfPageIncludesQuarterAndQuarterIndex(array, pageData, indexes) {
    for (int i = 0; i < array.length; i++) {
      int surah = array[i]['surah'];
      int ayah = array[i]['ayah'];
      for (int j = 0; j < pageData.length; j++) {
        int pageSurah = pageData[j]['surah'];
        int start = pageData[j]['start'];
        int end = pageData[j]['end'];
        if ((surah == pageSurah) && (ayah >= start) && (ayah <= end)) {
          int targetIndex = i + 1;
          for (int hizbIndex = 0; hizbIndex < indexes.length; hizbIndex++) {
            List<int> hizb = indexes[hizbIndex];
            for (int quarterIndex = 0;
                quarterIndex < hizb.length;
                quarterIndex++) {
              if (hizb[quarterIndex] == targetIndex) {
                return Result(true, i, hizbIndex, quarterIndex);
              }
            }
          }
        }
      }
    }
    return Result(false, -1, -1, -1);
  } //Create an instance of ScreenshotController

  ScreenshotController screenshotController = ScreenshotController();

  double currentHeight = 2.0;
  // double currentWordSpacing = 0.0;
  double currentLetterSpacing = 0.0;
  final bool _isVisible = true;

  List<GlobalKey> richTextKeys = List.generate(
    604, // Replace with the number of pages in your PageView
    (_) => GlobalKey(),
  );
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldKey,
      endDrawer: SizedBox(
        height: screenSize.height,
        width: screenSize.width * .5,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Builder(
            builder: (context2) {
              if (getValue("alignmentType") == "pageview") {
                return PageView.builder(
                  physics: const CustomPageViewScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (a) {
                    setState(() {
                      selectedSpan = "";
                    });
                    index = a;
                    updateValue("lastRead", a);
                  },
                  controller: _pageController,
                  // onPageChanged: _onPageChanged,
                  reverse: context.locale.languageCode == "ar" ? false : true,
                  itemCount: quran.totalPagesCount +
                      1 /* specify the total number of pages */,
                  itemBuilder: (context, index) {
                    bool isEvenPage = index.isEven;

                    if (index == 0) {
                      return Container(
                        color: const Color(0xffFFFCE7),
                        child: Image.asset(
                          "assets/images/quran.jpg",
                          fit: BoxFit.fill,
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                          color:
                              backgroundColors[getValue("quranPageolorsIndex")],
                          boxShadow: [
                            if (isEvenPage) // Add shadow only for even-numbered pages
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius:
                                    5, // Controls the spread of the shadow
                                blurRadius: 10, // Controls the blur effect
                                offset: const Offset(
                                    -5, 0), // Left side shadow for even numbers
                              ),
                          ],
                          //index % 2 == 0
                          border: Border.fromBorderSide(BorderSide(
                              color:
                                  primaryColors[getValue("quranPageolorsIndex")]
                                      .withOpacity(.05)))),
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: Colors.transparent,
                        body: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(right: 12.0.w, left: 12.w),
                            child: SingleChildScrollView(
                              // physics: const ClampingScrollPhysics(),
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: screenSize.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: (screenSize.width * .27).w,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(
                                                    Icons.arrow_back_ios,
                                                    size: 24.sp,
                                                    color: secondaryColors[getValue(
                                                        "quranPageolorsIndex")],
                                                  )),
                                              Text(
                                                  widget.jsonData[
                                                      quran.getPageData(
                                                                  index)[0]
                                                              ["surah"] -
                                                          1]["name"],
                                                  style: TextStyle(
                                                      color: secondaryColors[
                                                          getValue(
                                                              "quranPageolorsIndex")],
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
                                                if (checkIfPageIncludesQuarterAndQuarterIndex(
                                                        widget.quarterJsonData,
                                                        quran
                                                            .getPageData(index),
                                                        indexes)
                                                    .includesQuarter)
                                                  if (checkIfPageIncludesQuarterAndQuarterIndex(
                                                          widget
                                                              .quarterJsonData,
                                                          quran.getPageData(
                                                              index),
                                                          indexes)
                                                      .includesQuarter)
                                                    EasyContainer(
                                                      borderRadius: 12.r,
                                                      color: secondaryColors[
                                                              getValue(
                                                                  "quranPageolorsIndex")]
                                                          .withOpacity(.5),
                                                      borderColor: primaryColors[
                                                          getValue(
                                                              "quranPageolorsIndex")],
                                                      showBorder: true,
                                                      height: 20.h,
                                                      width: 160.w,
                                                      padding: 0,
                                                      margin: 0,
                                                      child: Text(
                                                        checkIfPageIncludesQuarterAndQuarterIndex(
                                                                        widget
                                                                            .quarterJsonData,
                                                                        quran.getPageData(
                                                                            index),
                                                                        indexes)
                                                                    .includesQuarter ==
                                                                true
                                                            ? "${"page".tr()} ${(index).toString()} | ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex + 1) == 1 ? "" : "${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex).toString()}/${4.toString()}"} ${"hizb".tr()} ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).hizbIndex + 1).toString()} | ${"juz".tr()} ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])} "
                                                            : "${"page".tr()} $index | ${"juz".tr()} ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])}",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'aldahabi',
                                                          fontSize: 10.sp,
                                                          color: backgroundColors[
                                                              getValue(
                                                                  "quranPageolorsIndex")],
                                                        ),
                                                      ),
                                                    ),
                                                if (checkIfPageIncludesQuarterAndQuarterIndex(
                                                            widget
                                                                .quarterJsonData,
                                                            quran.getPageData(
                                                                index),
                                                            indexes)
                                                        .includesQuarter ==
                                                    false)
                                                  EasyContainer(
                                                    borderRadius: 12.r,
                                                    color: secondaryColors[getValue(
                                                            "quranPageolorsIndex")]
                                                        .withOpacity(.5),
                                                    borderColor: backgroundColors[
                                                        getValue(
                                                            "quranPageolorsIndex")],
                                                    showBorder: true,
                                                    height: 20.h,
                                                    width: 120.w,
                                                    padding: 0,
                                                    margin: 0,
                                                    child: Center(
                                                      child: Text(
                                                        "${"page".tr()} $index | ${"juz".tr()} ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])}",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'aldahabi',
                                                          fontSize: 12.sp,
                                                          color: backgroundColors[
                                                              getValue(
                                                                  "quranPageolorsIndex")],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: (screenSize.width * .27).w,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    showSettingsSheet(context);
                                                  },
                                                  icon: Icon(
                                                    Icons.settings,
                                                    size: 24.sp,
                                                    color: secondaryColors[getValue(
                                                        "quranPageolorsIndex")],
                                                  ))
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  if ((index == 1 || index == 2))
                                    SizedBox(
                                      height: (screenSize.height * .15),
                                    ),
                                  BlocBuilder<QuranPagePlayerBloc,
                                          QuranPagePlayerState>(
                                      bloc: qurapPagePlayerBloc,
                                      builder: (context, state) {
                                        if (state is QuranPagePlayerInitial ||
                                            state is QuranPagePlayerIdle) {
                                          return Directionality(
                                              textDirection:
                                                  m.TextDirection.rtl,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: RichText(
                                                    key:
                                                        richTextKeys[index - 1],
                                                    textDirection:
                                                        m.TextDirection.rtl,
                                                    textAlign: (index == 1 ||
                                                            index == 2 ||
                                                            index > 570)
                                                        ? TextAlign.center
                                                        : TextAlign.center,
                                                    softWrap: true,
                                                    locale: const Locale("ar"),
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        color: primaryColors[
                                                            getValue(
                                                                "quranPageolorsIndex")],
                                                        fontSize: getValue(
                                                                "pageViewFontSize")
                                                            .toDouble(),
                                                        fontFamily: getValue(
                                                            "selectedFontFamily"),
                                                      ),
                                                      children: quran
                                                          .getPageData(index)
                                                          .expand((e) {
                                                        List<InlineSpan> spans =
                                                            [];
                                                        for (var i = e["start"];
                                                            i <= e["end"];
                                                            i++) {
                                                          // Header
                                                          if (i == 1) {
                                                            spans
                                                                .add(WidgetSpan(
                                                              child: HeaderWidget(
                                                                  e: e,
                                                                  jsonData: widget
                                                                      .jsonData),
                                                            ));
                                                            if (index != 187 &&
                                                                index != 1) {
                                                              spans.add(
                                                                  WidgetSpan(
                                                                child: Basmallah(
                                                                    index: getValue(
                                                                        "quranPageolorsIndex")),
                                                              ));
                                                            }
                                                            if (index == 187) {
                                                              spans.add(
                                                                  WidgetSpan(
                                                                child:
                                                                    Container(
                                                                  height: 10.h,
                                                                ),
                                                              ));
                                                            }
                                                          }

                                                          // Verses
                                                          spans.add(TextSpan(
                                                            recognizer:
                                                                LongPressGestureRecognizer()
                                                                  ..onLongPress =
                                                                      () {
                                                                    showAyahOptionsSheet(
                                                                        index,
                                                                        e["surah"],
                                                                        i);
                                                                    print(
                                                                        "longpressed");
                                                                  }
                                                                  ..onLongPressDown =
                                                                      (details) {
                                                                    setState(
                                                                        () {
                                                                      selectedSpan =
                                                                          " ${e["surah"]}$i";
                                                                    });
                                                                  }
                                                                  ..onLongPressUp =
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      selectedSpan =
                                                                          "";
                                                                    });
                                                                    print(
                                                                        "finished long press");
                                                                  }
                                                                  ..onLongPressCancel =
                                                                      () =>
                                                                          setState(
                                                                              () {
                                                                            selectedSpan =
                                                                                "";
                                                                          }),
                                                            text: i ==
                                                                    e["start"]
                                                                ? "${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                                                                : quran
                                                                    .getVerseQCF(
                                                                        e[
                                                                            "surah"],
                                                                        i)
                                                                    .replaceAll(
                                                                        ' ',
                                                                        ''),
                                                            //  i == e["start"]
                                                            // ? "${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1).substring(0,  quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1).length - 1)}"
                                                            // :
                                                            // quran.getVerseQCF(e["surah"], i).replaceAll(' ', '').substring(0,  quran.getVerseQCF(e["surah"], i).replaceAll(' ', '').length - 1),
                                                            style: TextStyle(
                                                              color: bookmarks
                                                                      .where((element) =>
                                                                          element["suraNumber"] ==
                                                                              e[
                                                                                  "surah"] &&
                                                                          element["verseNumber"] ==
                                                                              i)
                                                                      .isNotEmpty
                                                                  ? Color(int.parse(
                                                                      "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                  : primaryColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")],
                                                              height: (index ==
                                                                          1 ||
                                                                      index ==
                                                                          2)
                                                                  ? 2.h
                                                                  : 1.95.h,
                                                              letterSpacing:
                                                                  0.w,
                                                              wordSpacing: 0,
                                                              fontFamily:
                                                                  "QCF_P${index.toString().padLeft(3, "0")}",
                                                              fontSize: index ==
                                                                          1 ||
                                                                      index == 2
                                                                  ? 28.sp
                                                                  : index == 145 ||
                                                                          index ==
                                                                              201
                                                                      ? index == 532 ||
                                                                              index ==
                                                                                  533
                                                                          ? 22.5
                                                                              .sp
                                                                          : 22.4
                                                                              .sp
                                                                      : 22.9.sp,
                                                              backgroundColor: shouldHighlightText
                                                                  ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                      : selectedSpan == " ${e["surah"]}$i"
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                          : Colors.transparent
                                                                  : selectedSpan == " ${e["surah"]}$i"
                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                      : Colors.transparent,
                                                            ),
                                                            children: const <TextSpan>[
                                                              // TextSpan(
                                                              //   text: quran.getVerseQCF(e["surah"], i).substring(quran.getVerseQCF(e["surah"], i).length - 1),
                                                              //   style:  TextStyle(
                                                              //     color: isVerseStarred(
                                                              //                                                     e[
                                                              //                                                         "surah"],
                                                              //                                                     i)
                                                              //                                                 ? Colors
                                                              //                                                     .amber
                                                              //                                                 : secondaryColors[getValue("quranPageolorsIndex")] // Change color here
                                                              //   ),
                                                              // ),
                                                            ],
                                                          ));
                                                        }
                                                        return spans;
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ));
                                        } else if (state
                                            is QuranPagePlayerPlaying) {
                                          // printYellow("playing");
                                          return Directionality(
                                            textDirection: m.TextDirection.rtl,
                                            child: StreamBuilder<Duration?>(
                                                stream: state.audioPlayerStream,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final currentDuration =
                                                        snapshot.data!
                                                            .inMilliseconds;
                                                    if (currentDuration !=
                                                        state.durations[state
                                                                .durations
                                                                .length -
                                                            1]["endDuration"]) {
                                                      currentVersePlaying =
                                                          state.durations
                                                              .where((element) {
                                                        return (element[
                                                                    "startDuration"] <=
                                                                currentDuration &&
                                                            currentDuration <=
                                                                element[
                                                                    "endDuration"]);
                                                      }).first;
                                                    }

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          // height: screenSize.height,
                                                          child: RichText(
                                                            //textWidthBasis: TextWidthBasis.parent,
                                                            key: richTextKeys[
                                                                index - 1],
                                                            textDirection: m
                                                                .TextDirection
                                                                .rtl,
                                                            textAlign: (index ==
                                                                        1 ||
                                                                    index ==
                                                                        2 ||
                                                                    index > 570)
                                                                ? TextAlign
                                                                    .center
                                                                : TextAlign
                                                                    .center,
                                                            softWrap:
                                                                true, //locale: const Locale("ar"),
                                                            locale:
                                                                const Locale(
                                                                    "ar"),
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                color: primaryColors[
                                                                    getValue(
                                                                        "quranPageolorsIndex")], //wordSpacing: -.3,
                                                                fontSize: getValue(
                                                                        "pageViewFontSize")
                                                                    .toDouble() //.sp
                                                                ,
                                                                //
                                                                fontFamily:
                                                                    getValue(
                                                                        "selectedFontFamily"),
                                                              ),
                                                              locale:
                                                                  const Locale(
                                                                      "ar"),
                                                              children: quran
                                                                  .getPageData(
                                                                      index)
                                                                  .expand((e) {
                                                                // print(e);
                                                                List<InlineSpan>
                                                                    spans = [];
                                                                for (var i = e[
                                                                        "start"];
                                                                    i <=
                                                                        e["end"];
                                                                    i++) {
                                                                  // Header
                                                                  if (i == 1) {
                                                                    spans.add(
                                                                        WidgetSpan(
                                                                      child: HeaderWidget(
                                                                          e: e,
                                                                          jsonData:
                                                                              widget.jsonData),
                                                                    ));

                                                                    if (index !=
                                                                            187 &&
                                                                        index !=
                                                                            1) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                              child: Basmallah(
                                                                        index: getValue(
                                                                            "quranPageolorsIndex"),
                                                                      )));
                                                                    }
                                                                    if (index ==
                                                                        187) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                              child: Container(
                                                                        height:
                                                                            10.h,
                                                                      )));
                                                                    }
                                                                  }

                                                                  // Verses
                                                                  spans.add(
                                                                      TextSpan(
                                                                    locale:
                                                                        const Locale(
                                                                            "ar"),
                                                                    recognizer:
                                                                        LongPressGestureRecognizer()
                                                                          ..onLongPress =
                                                                              () {
                                                                            // print(
                                                                            //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                            showAyahOptionsSheet(
                                                                                index,
                                                                                e["surah"],
                                                                                i);
                                                                            print("longpressed");
                                                                          }
                                                                          ..onLongPressDown =
                                                                              (details) {
                                                                            setState(() {
                                                                              selectedSpan = " ${e["surah"]}$i";
                                                                            });
                                                                          }
                                                                          ..onLongPressUp =
                                                                              () {
                                                                            setState(() {
                                                                              selectedSpan = "";
                                                                            });
                                                                            print("finished long press");
                                                                          }
                                                                          ..onLongPressCancel = () =>
                                                                              setState(() {
                                                                                selectedSpan = "";
                                                                              }),
                                                                    text: quran
                                                                        .getVerseQCF(
                                                                            e[
                                                                                "surah"],
                                                                            i)
                                                                        .replaceAll(
                                                                            ' ',
                                                                            ''),
                                                                    style:
                                                                        TextStyle(
                                                                      color: primaryColors[
                                                                          getValue(
                                                                              "quranPageolorsIndex")],
                                                                      // letterSpacing: .05,
                                                                      height: (index == 1 ||
                                                                              index ==
                                                                                  2)
                                                                          ? 2.h
                                                                          : 1.95
                                                                              .h,
                                                                      letterSpacing:
                                                                          0.w,
                                                                      // fontSize: 22.sp,
                                                                      // wordSpacing: -1.4,
                                                                      fontFamily:
                                                                          "QCF_P${index.toString().padLeft(3, "0")}"
                                                                      // getValue(
                                                                      //     "selectedFontFamily")
                                                                      ,
                                                                      fontSize:
                                                                          22.9.sp,
                                                                      backgroundColor: bookmarks
                                                                              .where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i)
                                                                              .isNotEmpty
                                                                          ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
                                                                          : (i == currentVersePlaying["verseNumber"] && e["surah"] == state.suraNumber)
                                                                              ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.28)
                                                                              : shouldHighlightText
                                                                                  ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                      : selectedSpan == " ${e["surah"]}$i"
                                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                          : Colors.transparent
                                                                                  : selectedSpan == " ${e["surah"]}$i"
                                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                      : Colors.transparent,
                                                                    ),
                                                                    children: const [
                                                                      // TextSpan(
                                                                      //     locale: const Locale(
                                                                      //         "ar"),
                                                                      //     text:
                                                                      //         " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                                      //     ,
                                                                      //     style: TextStyle(
                                                                      //         color: isVerseStarred(
                                                                      //                 e[
                                                                      //                     "surah"],
                                                                      //                 i)
                                                                      //             ? Colors.amber
                                                                      //             : secondaryColors[
                                                                      //                 getValue(
                                                                      //                     "quranPageolorsIndex")],
                                                                      //         fontFamily:
                                                                      //             "KFGQPC Uthmanic Script HAFS Regular")),

                                                                      //               ],
                                                                      //             ),
                                                                      //           ),
                                                                      //         ),
                                                                      //     ),
                                                                      //     ),
                                                                    ],
                                                                  ));
                                                                  if (bookmarks
                                                                      .where((element) =>
                                                                          element["suraNumber"] ==
                                                                              e[
                                                                                  "surah"] &&
                                                                          element["verseNumber"] ==
                                                                              i)
                                                                      .isNotEmpty) {
                                                                    spans.add(WidgetSpan(
                                                                        alignment: PlaceholderAlignment.middle,
                                                                        child: Icon(
                                                                          Icons
                                                                              .bookmark,
                                                                          color:
                                                                              Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                        )));
                                                                  }
                                                                }
                                                                return spans;
                                                              }).toList(),
                                                            ),
                                                          )),
                                                    );
                                                  } else {
                                                    return Directionality(
                                                      textDirection:
                                                          m.TextDirection.rtl,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            // height: screenSize.height,
                                                            child: RichText(
                                                              //textWidthBasis: TextWidthBasis.parent,
                                                              key: richTextKeys[
                                                                  index - 1],
                                                              textDirection: m
                                                                  .TextDirection
                                                                  .rtl,
                                                              textAlign: (index ==
                                                                          1 ||
                                                                      index ==
                                                                          2 ||
                                                                      index >
                                                                          570)
                                                                  ? TextAlign
                                                                      .center
                                                                  : TextAlign
                                                                      .center,
                                                              softWrap:
                                                                  true, //locale: const Locale("ar"),
                                                              locale:
                                                                  const Locale(
                                                                      "ar"),
                                                              text: TextSpan(
                                                                style:
                                                                    TextStyle(
                                                                  color: primaryColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")], //wordSpacing: -.3,
                                                                  fontSize: getValue(
                                                                          "pageViewFontSize")
                                                                      .toDouble() //.sp
                                                                  ,
//
                                                                  fontFamily:
                                                                      getValue(
                                                                          "selectedFontFamily"),
                                                                ),
                                                                locale:
                                                                    const Locale(
                                                                        "ar"),
                                                                children: quran
                                                                    .getPageData(
                                                                        index)
                                                                    .expand(
                                                                        (e) {
                                                                  // print(e);
                                                                  List<InlineSpan>
                                                                      spans =
                                                                      [];
                                                                  for (var i = e[
                                                                          "start"];
                                                                      i <=
                                                                          e["end"];
                                                                      i++) {
                                                                    // Header
                                                                    if (i ==
                                                                        1) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                        child: HeaderWidget(
                                                                            e: e,
                                                                            jsonData: widget.jsonData),
                                                                      ));

                                                                      if (index !=
                                                                              187 &&
                                                                          index !=
                                                                              1) {
                                                                        spans.add(WidgetSpan(
                                                                            child: Basmallah(
                                                                          index:
                                                                              getValue("quranPageolorsIndex"),
                                                                        )));
                                                                      }
                                                                      if (index ==
                                                                          187) {
                                                                        spans.add(WidgetSpan(
                                                                            child: Container(
                                                                          height:
                                                                              10.h,
                                                                        )));
                                                                      }
                                                                    }

                                                                    // Verses
                                                                    spans.add(
                                                                        TextSpan(
                                                                      locale: const Locale(
                                                                          "ar"),
                                                                      recognizer:
                                                                          LongPressGestureRecognizer()
                                                                            ..onLongPress =
                                                                                () {
                                                                              // print(
                                                                              //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                              showAyahOptionsSheet(index, e["surah"], i);
                                                                              print("longpressed");
                                                                            }
                                                                            ..onLongPressDown =
                                                                                (details) {
                                                                              setState(() {
                                                                                selectedSpan = " ${e["surah"]}$i";
                                                                              });
                                                                            }
                                                                            ..onLongPressUp =
                                                                                () {
                                                                              setState(() {
                                                                                selectedSpan = "";
                                                                              });
                                                                              print("finished long press");
                                                                            }
                                                                            ..onLongPressCancel = () =>
                                                                                setState(() {
                                                                                  selectedSpan = "";
                                                                                }),
                                                                      text: quran
                                                                          .getVerseQCF(
                                                                              e[
                                                                                  "surah"],
                                                                              i)
                                                                          .replaceAll(
                                                                              ' ',
                                                                              ''),
                                                                      style:
                                                                          TextStyle(
                                                                        color: primaryColors[
                                                                            getValue("quranPageolorsIndex")],
// letterSpacing: .05,
                                                                        height: (index == 1 ||
                                                                                index == 2)
                                                                            ? 2.h
                                                                            : 1.95.h,
                                                                        letterSpacing:
                                                                            0.w,
                                                                        // fontSize: 22.sp,
                                                                        // wordSpacing: -1.4,
                                                                        fontFamily:
                                                                            "QCF_P${index.toString().padLeft(3, "0")}"
                                                                        // getValue(
                                                                        //     "selectedFontFamily")
                                                                        ,
                                                                        fontSize:
                                                                            22.9.sp,
                                                                        backgroundColor: bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).isNotEmpty
                                                                            ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
                                                                            : shouldHighlightText
                                                                                ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                    ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                    : selectedSpan == " ${e["surah"]}$i"
                                                                                        ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                        : Colors.transparent
                                                                                : selectedSpan == " ${e["surah"]}$i"
                                                                                    ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                    : Colors.transparent,
                                                                      ),
                                                                      children: const [
                                                                        // TextSpan(
                                                                        //     locale: const Locale(
                                                                        //         "ar"),
                                                                        //     text:
                                                                        //         " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                                        //     ,
                                                                        //     style: TextStyle(
                                                                        //         color: isVerseStarred(
                                                                        //                 e[
                                                                        //                     "surah"],
                                                                        //                 i)
                                                                        //             ? Colors.amber
                                                                        //             : secondaryColors[
                                                                        //                 getValue(
                                                                        //                     "quranPageolorsIndex")],
                                                                        //         fontFamily:
                                                                        //             "KFGQPC Uthmanic Script HAFS Regular")),

                                                                        //               ],
                                                                        //             ),
                                                                        //           ),
                                                                        //         ),
                                                                        //     ),
                                                                        //     ),
                                                                      ],
                                                                    ));
                                                                    if (bookmarks
                                                                        .where((element) =>
                                                                            element["suraNumber"] == e["surah"] &&
                                                                            element["verseNumber"] ==
                                                                                i)
                                                                        .isNotEmpty) {
                                                                      spans.add(WidgetSpan(
                                                                          alignment: PlaceholderAlignment.middle,
                                                                          child: Icon(
                                                                            Icons.bookmark,
                                                                            color:
                                                                                Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                          )));
                                                                    }
                                                                  }
                                                                  return spans;
                                                                }).toList(),
                                                              ),
                                                            )),
                                                      ),
                                                    );
                                                  }
                                                }),
                                          );
                                        }
                                        return Container();
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ); /* Your page content */
                  },
                );
              } else if (getValue("alignmentType") == "verticalview") {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor:
                      backgroundColors[getValue("quranPageolorsIndex")],
                  body: Stack(
                    children: [
                      ScrollablePositionedList.separated(
                        // ph
                        // physics: const ClampingScrollPhysics(),

                        itemCount: quran.totalPagesCount + 1,
                        separatorBuilder: (context, index) {
                          if (index == 0) return Container();
                          return Container(
                            color:
                                secondaryColors[getValue("quranPageolorsIndex")]
                                    .withOpacity(.45),
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 77.0.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    checkIfPageIncludesQuarterAndQuarterIndex(
                                                    widget.quarterJsonData,
                                                    quran.getPageData(index),
                                                    indexes)
                                                .includesQuarter ==
                                            true
                                        ? "${"page".tr()} ${(index).toString()} | ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex + 1) == 1 ? "" : "${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex).toString()}/${4.toString()}"} ${"hizb".tr()} ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).hizbIndex + 1).toString()} | ${"juz".tr()}: ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])} "
                                        : "${"page".tr()} $index | ${"juz".tr()}: ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: backgroundColors[
                                            getValue("quranPageolorsIndex")]),
                                  ),
                                  Text(
                                    widget.jsonData[quran.getPageData(index)[0]
                                            ["surah"] -
                                        1]["name"],
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: "taha",
                                        fontWeight: FontWeight.bold,
                                        color: backgroundColors[
                                            getValue("quranPageolorsIndex")]),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        itemScrollController: itemScrollController,
                        initialScrollIndex: getValue("lastRead"),
                        itemPositionsListener: itemPositionsListener,
                        itemBuilder: (context, index) {
                          // updateValue("lastRead", index);
                          // bool isEvenPage = index.isEven;

                          if (index == 0) {
                            return Container(
                              color: const Color(0xffFFFCE7),
                              child: Image.asset(
                                "assets/images/quran.jpg",
                                fit: BoxFit.fill,
                              ),
                            );
                          }

                          return BlocBuilder<QuranPagePlayerBloc,
                              QuranPagePlayerState>(
                            bloc: qurapPagePlayerBloc,
                            builder: (context, state) {
                              if (state is QuranPagePlayerInitial ||
                                  state is QuranPagePlayerIdle) {
                                print("idle");
                                return VisibilityDetector(
                                  key: Key(index.toString()),
                                  onVisibilityChanged: (VisibilityInfo info) {
                                    if (info.visibleFraction == 1) {
                                      print(index);
                                      updateValue("lastRead", index);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Directionality(
                                        textDirection: m.TextDirection.rtl,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.0.w,
                                              vertical: 26.h),
                                          child: SizedBox(
                                              width: double.infinity,
                                              child: RichText(
                                                key: richTextKeys[index - 1],
                                                textDirection:
                                                    m.TextDirection.rtl,
                                                textAlign: TextAlign.center,
                                                softWrap:
                                                    true, //locale: const Locale("ar"),
                                                text: TextSpan(
                                                  locale: const Locale("ar"),
                                                  children: quran
                                                      .getPageData(index)
                                                      .expand((e) {
                                                    // print(e);
                                                    List<InlineSpan> spans = [];
                                                    for (var i = e["start"];
                                                        i <= e["end"];
                                                        i++) {
                                                      print(index);
                                                      // Header
                                                      if (i == 1) {
                                                        spans.add(WidgetSpan(
                                                          child: HeaderWidget(
                                                              e: e,
                                                              jsonData: widget
                                                                  .jsonData),
                                                        ));

                                                        if (index != 187 &&
                                                            index != 1) {
                                                          spans.add(WidgetSpan(
                                                              child: Basmallah(
                                                            index: getValue(
                                                                "quranPageolorsIndex"),
                                                          )));
                                                        }
                                                        if (index == 187 ||
                                                            index == 1) {
                                                          spans.add(WidgetSpan(
                                                              child: Container(
                                                            height: 10.h,
                                                          )));
                                                        }
                                                      }

                                                      // Verses
                                                      spans.add(TextSpan(
                                                        locale:
                                                            const Locale("ar"),
                                                        recognizer:
                                                            LongPressGestureRecognizer()
                                                              ..onLongPress =
                                                                  () {
                                                                // print(
                                                                //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                showAyahOptionsSheet(
                                                                    index,
                                                                    e["surah"],
                                                                    i);
                                                                print(
                                                                    "longpressed");
                                                              }
                                                              ..onLongPressDown =
                                                                  (details) {
                                                                setState(() {
                                                                  selectedSpan =
                                                                      " ${e["surah"]}$i";
                                                                });
                                                              }
                                                              ..onLongPressUp =
                                                                  () {
                                                                setState(() {
                                                                  selectedSpan =
                                                                      "";
                                                                });
                                                                print(
                                                                    "finished long press");
                                                              }
                                                              ..onLongPressCancel =
                                                                  () =>
                                                                      setState(
                                                                          () {
                                                                        selectedSpan =
                                                                            "";
                                                                      }),
                                                        text: quran.getVerse(
                                                            e["surah"], i),
                                                        style: TextStyle(
                                                          //wordSpacing: -7,
                                                          color: primaryColors[
                                                              getValue(
                                                                  "quranPageolorsIndex")],
                                                          fontSize: getValue(
                                                                  "verticalViewFontSize")
                                                              .toDouble(),
                                                          // wordSpacing: -1.4,
                                                          fontFamily: getValue(
                                                              "selectedFontFamily"),
                                                          // letterSpacing: 1,
                                                          //fontWeight: FontWeight.bold,
                                                          backgroundColor: bookmarks
                                                                  .where((element) =>
                                                                      element["suraNumber"] == e["surah"] &&
                                                                      element["verseNumber"] ==
                                                                          i)
                                                                  .isNotEmpty
                                                              ? Color(int.parse(
                                                                      "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                  .withOpacity(
                                                                      .19)
                                                              : shouldHighlightText
                                                                  ? quran.getVerse(e["surah"], i) ==
                                                                          widget
                                                                              .highlightVerse
                                                                      ? highlightColors[getValue("quranPageolorsIndex")]
                                                                          .withOpacity(
                                                                              .25)
                                                                      : selectedSpan ==
                                                                              " ${e["surah"]}$i"
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(
                                                                              .25)
                                                                          : Colors
                                                                              .transparent
                                                                  : selectedSpan ==
                                                                          " ${e["surah"]}$i"
                                                                      ? highlightColors[getValue("quranPageolorsIndex")]
                                                                          .withOpacity(
                                                                              .25)
                                                                      : Colors.transparent,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                              text:
                                                                  " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                              ,
                                                              style: TextStyle(
                                                                  //wordSpacing: -10,letterSpacing: -5,
                                                                  color: isVerseStarred(
                                                                          e[
                                                                              "surah"],
                                                                          i)
                                                                      ? Colors
                                                                          .amber
                                                                      : secondaryColors[
                                                                          getValue(
                                                                              "quranPageolorsIndex")],
                                                                  fontFamily:
                                                                      "KFGQPC Uthmanic Script HAFS Regular")),

                                                          //               ],
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //     ),
                                                          //     ),
                                                        ],
                                                      ));
                                                      // if (bookmarks.contains(
                                                      //     "${e["surah"]}-$i")) {
                                                      //   spans.add(WidgetSpan(
                                                      //       alignment:
                                                      //           PlaceholderAlignment
                                                      //               .middle,
                                                      //       child: Icon(
                                                      //         Icons.bookmark,
                                                      //         color: colorsOfBookmarks2[
                                                      //             bookmarks
                                                      //                 .indexOf(
                                                      //                     "${e["surah"]}-$i")],
                                                      //       )));
                                                      // }
                                                      if (bookmarks
                                                          .where((element) =>
                                                              element["suraNumber"] ==
                                                                  e["surah"] &&
                                                              element["verseNumber"] ==
                                                                  i)
                                                          .isNotEmpty) {
                                                        spans.add(WidgetSpan(
                                                            alignment:
                                                                PlaceholderAlignment
                                                                    .middle,
                                                            child: Icon(
                                                              Icons.bookmark,
                                                              color: Color(
                                                                  int.parse(
                                                                      "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                            )));
                                                      }
                                                    }
                                                    return spans;
                                                  }).toList(),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (state is QuranPagePlayerPlaying) {
                                // print("last read ${getValue("lastRead")}");
                                // printYellow("playing");
                                return Column(
                                  children: [
                                    StreamBuilder(
                                        stream: state.audioPlayerStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final currentDuration =
                                                snapshot.data!.inMilliseconds;
                                            if (currentDuration !=
                                                state.durations[
                                                    state.durations.length -
                                                        1]["endDuration"]) {
                                              currentVersePlaying = state
                                                  .durations
                                                  .where((element) {
                                                return (element[
                                                            "startDuration"] <=
                                                        currentDuration &&
                                                    currentDuration <=
                                                        element["endDuration"]);
                                              }).first;
                                            }

                                            // if( currentDuration ==
                                            //           state.durations[  state.durations.length-1]["endDuration"]){
                                            //             state.player.dispose();

                                            //           }
                                            // print(currentVersePlaying);
                                            return Directionality(
                                              textDirection:
                                                  m.TextDirection.rtl,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0.w,
                                                    vertical: 26.h),
                                                child: VisibilityDetector(
                                                  key: Key(index.toString()),
                                                  onVisibilityChanged:
                                                      (VisibilityInfo info) {
                                                    if (info.visibleFraction ==
                                                        1) {
                                                      updateValue(
                                                          "lastRead", index);
                                                    }
                                                  },
                                                  child: SizedBox(
                                                      width: double.infinity,
                                                      child: RichText(
                                                        key: richTextKeys[
                                                            index - 1],
                                                        textDirection:
                                                            m.TextDirection.rtl,
                                                        textAlign:
                                                            TextAlign.center,
                                                        softWrap:
                                                            true, //locale: const Locale("ar"),
                                                        text: TextSpan(
                                                          locale: const Locale(
                                                              "ar"),
                                                          children: quran
                                                              .getPageData(
                                                                  index)
                                                              .expand((e) {
                                                            // print(e);
                                                            List<InlineSpan>
                                                                spans = [];
                                                            for (var i =
                                                                    e["start"];
                                                                i <= e["end"];
                                                                i++) {
                                                              // Header
                                                              if (i == 1) {
                                                                spans.add(
                                                                    WidgetSpan(
                                                                  child: HeaderWidget(
                                                                      e: e,
                                                                      jsonData:
                                                                          widget
                                                                              .jsonData),
                                                                ));

                                                                if (index !=
                                                                        187 &&
                                                                    index !=
                                                                        1) {
                                                                  spans.add(
                                                                      WidgetSpan(
                                                                          child:
                                                                              Basmallah(
                                                                    index: getValue(
                                                                        "quranPageolorsIndex"),
                                                                  )));
                                                                }
                                                                if (index ==
                                                                        187 ||
                                                                    index ==
                                                                        1) {
                                                                  spans.add(
                                                                      WidgetSpan(
                                                                          child:
                                                                              Container(
                                                                    height:
                                                                        10.h,
                                                                  )));
                                                                }
                                                              }

                                                              // Verses
                                                              spans
                                                                  .add(TextSpan(
                                                                locale:
                                                                    const Locale(
                                                                        "ar"),
                                                                recognizer:
                                                                    LongPressGestureRecognizer()
                                                                      ..onLongPress =
                                                                          () {
                                                                        // print(
                                                                        //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                        showAyahOptionsSheet(
                                                                            index,
                                                                            e["surah"],
                                                                            i);
                                                                        print(
                                                                            "longpressed");
                                                                      }
                                                                      ..onLongPressDown =
                                                                          (details) {
                                                                        setState(
                                                                            () {
                                                                          selectedSpan =
                                                                              " ${e["surah"]}$i";
                                                                        });
                                                                      }
                                                                      ..onLongPressUp =
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          selectedSpan =
                                                                              "";
                                                                        });
                                                                        print(
                                                                            "finished long press");
                                                                      }
                                                                      ..onLongPressCancel = () =>
                                                                          setState(
                                                                              () {
                                                                            selectedSpan =
                                                                                "";
                                                                          }),
                                                                text: quran
                                                                    .getVerse(
                                                                        e["surah"],
                                                                        i),
                                                                style:
                                                                    TextStyle(
                                                                  color: primaryColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")],
                                                                  fontSize: getValue(
                                                                          "verticalViewFontSize")
                                                                      .toDouble(),
                                                                  // wordSpacing: -1.4,
                                                                  fontFamily:
                                                                      getValue(
                                                                          "selectedFontFamily"),
                                                                  backgroundColor: bookmarks
                                                                          .where((element) =>
                                                                              element["suraNumber"] == e["surah"] &&
                                                                              element["verseNumber"] ==
                                                                                  i)
                                                                          .isNotEmpty
                                                                      ? Color(int.parse(
                                                                              "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                          .withOpacity(
                                                                              .19)
                                                                      : (i == currentVersePlaying["verseNumber"] &&
                                                                              e["surah"] == state.suraNumber)
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.28)
                                                                          : shouldHighlightText
                                                                              ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                  ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                  : selectedSpan == " ${e["surah"]}$i"
                                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                      : Colors.transparent
                                                                              : selectedSpan == " ${e["surah"]}$i"
                                                                                  ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                  : Colors.transparent,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                      text:
                                                                          " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                                      ,
                                                                      style: TextStyle(
                                                                          color: isVerseStarred(e["surah"], i)
                                                                              ? Colors.amber
                                                                              : secondaryColors[getValue("quranPageolorsIndex")],
                                                                          fontFamily: "KFGQPC Uthmanic Script HAFS Regular")),

                                                                  //               ],
                                                                  //             ),
                                                                  //           ),
                                                                  //         ),
                                                                  //     ),
                                                                  //     ),
                                                                ],
                                                              ));
                                                              if (bookmarks
                                                                  .where((element) =>
                                                                      element["suraNumber"] ==
                                                                          e[
                                                                              "surah"] &&
                                                                      element["verseNumber"] ==
                                                                          i)
                                                                  .isNotEmpty) {
                                                                spans.add(
                                                                    WidgetSpan(
                                                                        alignment:
                                                                            PlaceholderAlignment
                                                                                .middle,
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .bookmark,
                                                                          color:
                                                                              Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                        )));
                                                              }
                                                            }
                                                            return spans;
                                                          }).toList(),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return VisibilityDetector(
                                              key: Key(index.toString()),
                                              onVisibilityChanged:
                                                  (VisibilityInfo info) {
                                                if (info.visibleFraction == 1) {
                                                  updateValue(
                                                      "lastRead", index);
                                                }
                                              },
                                              child: Column(
                                                children: [
                                                  Directionality(
                                                    textDirection:
                                                        m.TextDirection.rtl,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  20.0.w,
                                                              vertical: 26.h),
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: RichText(
                                                            key: richTextKeys[
                                                                index - 1],
                                                            textDirection: m
                                                                .TextDirection
                                                                .rtl,
                                                            textAlign: TextAlign
                                                                .center,
                                                            softWrap:
                                                                true, //locale: const Locale("ar"),
                                                            text: TextSpan(
                                                              locale:
                                                                  const Locale(
                                                                      "ar"),
                                                              children: quran
                                                                  .getPageData(
                                                                      index)
                                                                  .expand((e) {
                                                                // print(e);
                                                                List<InlineSpan>
                                                                    spans = [];
                                                                for (var i = e[
                                                                        "start"];
                                                                    i <=
                                                                        e["end"];
                                                                    i++) {
                                                                  // Header
                                                                  if (i == 1) {
                                                                    spans.add(
                                                                        WidgetSpan(
                                                                      child: HeaderWidget(
                                                                          e: e,
                                                                          jsonData:
                                                                              widget.jsonData),
                                                                    ));

                                                                    if (index !=
                                                                            187 &&
                                                                        index !=
                                                                            1) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                              child: Basmallah(
                                                                        index: getValue(
                                                                            "quranPageolorsIndex"),
                                                                      )));
                                                                    }
                                                                    if (index ==
                                                                            187 ||
                                                                        index ==
                                                                            1) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                              child: Container(
                                                                        height:
                                                                            10.h,
                                                                      )));
                                                                    }
                                                                  }

                                                                  // Verses
                                                                  spans.add(
                                                                      TextSpan(
                                                                    locale:
                                                                        const Locale(
                                                                            "ar"),
                                                                    recognizer:
                                                                        LongPressGestureRecognizer()
                                                                          ..onLongPress =
                                                                              () {
                                                                            // print(
                                                                            //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                            showAyahOptionsSheet(
                                                                                index,
                                                                                e["surah"],
                                                                                i);
                                                                            print("longpressed");
                                                                          }
                                                                          ..onLongPressDown =
                                                                              (details) {
                                                                            setState(() {
                                                                              selectedSpan = " ${e["surah"]}$i";
                                                                            });
                                                                          }
                                                                          ..onLongPressUp =
                                                                              () {
                                                                            setState(() {
                                                                              selectedSpan = "";
                                                                            });
                                                                            print("finished long press");
                                                                          }
                                                                          ..onLongPressCancel = () =>
                                                                              setState(() {
                                                                                selectedSpan = "";
                                                                              }),
                                                                    text: quran
                                                                        .getVerse(
                                                                            e["surah"],
                                                                            i),
                                                                    style:
                                                                        TextStyle(
                                                                      color: primaryColors[
                                                                          getValue(
                                                                              "quranPageolorsIndex")],
                                                                      fontSize:
                                                                          getValue("verticalViewFontSize")
                                                                              .toDouble(),
                                                                      // wordSpacing: -1.4,
                                                                      fontFamily:
                                                                          getValue(
                                                                              "selectedFontFamily"),
                                                                      backgroundColor: bookmarks
                                                                              .where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i)
                                                                              .isNotEmpty
                                                                          ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
                                                                          : shouldHighlightText
                                                                              ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                  ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                  : selectedSpan == " ${e["surah"]}$i"
                                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                      : Colors.transparent
                                                                              : selectedSpan == " ${e["surah"]}$i"
                                                                                  ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                  : Colors.transparent,
                                                                    ),
                                                                    children: [
                                                                      TextSpan(
                                                                          text:
                                                                              " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                                          ,
                                                                          style: TextStyle(
                                                                              color: isVerseStarred(e["surah"], i) ? Colors.amber : secondaryColors[getValue("quranPageolorsIndex")],
                                                                              fontFamily: "KFGQPC Uthmanic Script HAFS Regular")),

                                                                      //               ],
                                                                      //             ),
                                                                      //           ),
                                                                      //         ),
                                                                      //     ),
                                                                      //     ),
                                                                    ],
                                                                  ));
                                                                  if (bookmarks
                                                                      .where((element) =>
                                                                          element["suraNumber"] ==
                                                                              e[
                                                                                  "surah"] &&
                                                                          element["verseNumber"] ==
                                                                              i)
                                                                      .isNotEmpty) {
                                                                    spans.add(WidgetSpan(
                                                                        alignment: PlaceholderAlignment.middle,
                                                                        child: Icon(
                                                                          Icons
                                                                              .bookmark,
                                                                          color:
                                                                              Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                        )));
                                                                  }
                                                                }
                                                                return spans;
                                                              }).toList(),
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ); // print("snapshot.hasError");
                                            // print(snapshot.error);
                                          }

                                          return Container();
                                        }),
                                    /*currentDuration != null &&
                                      currentDuration.inMilliseconds >=
                                          startDuration &&
                                      currentDuration.inMilliseconds <=
                                          (startDuration +
                                              metadata.trackDuration)
                                  ? secondaryColors[getValue("quranPageolorsIndex")]
                                  : Colors.transparent*/
                                  ],
                                );
                              }
                              return Container();
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 28.0.h),
                        child: Container(
                          // duration: const Duration(milliseconds: 500),
                          height: 45.h, width: screenSize.width,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: (screenSize.width * .27).w,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          size: 24.sp,
                                          color: primaryColors[
                                              getValue("quranPageolorsIndex")],
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: (screenSize.width * .27).w,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          //  Scaffold.of(  scaffoldKey.currentState!.context)
                                          // .openEndDrawer();
                                          showSettingsSheet(context);
                                        },
                                        icon: Icon(
                                          Icons.settings,
                                          size: 24.sp,
                                          color: primaryColors[
                                              getValue("quranPageolorsIndex")],
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      // Positioned(
                      //     right: 1,
                      //     height: screenSize.height,
                      //     child: Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 108.0.h),
                      //       child: Opacity(opacity: .25,
                      //         child: SfSlider.vertical(
                      //           isInversed: true,
                      //           min: 0.0,
                      //           max: 10.0,inactiveColor: primaryColors[getValue("quranPageolorsIndex")].withOpacity(.5),
                      //           value: valueOfSlider,
                      //           activeColor: secondaryColors[getValue("quranPageolorsIndex")],
                      //           // interval: 0,
                      //           showTicks: false,
                      //           showLabels: false,
                      //           enableTooltip: false,
                      //           minorTicksPerInterval: 1,
                      //           onChanged: (dynamic value) {                             //       itemScrollController.scrollTo(index: 614, duration: const Duration(hours: 1));

                      //             setState(() {
                      //               valueOfSlider = value;
                      //             });
                      //           },

                      //           onChangeEnd: (dynamic value){
                      //             itemScrollController.scrollTo(index: 604, duration:  Duration(minutes:1~/value));
                      //           },
                      //         ),
                      //       ),
                      //     ))
                    ],
                  ),
                );
              } else if (getValue("alignmentType") == "versebyverse") {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor:
                      backgroundColors[getValue("quranPageolorsIndex")],
                  body: Stack(
                    children: [
                      ScrollablePositionedList.separated(
                        // ph
                        // physics: const ClampingScrollPhysics(),

                        itemCount: quran.totalPagesCount + 1,
                        separatorBuilder: (context, index) {
                          if (index == 0) return Container();
                          return Container(
                            color:
                                secondaryColors[getValue("quranPageolorsIndex")]
                                    .withOpacity(.45),
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 77.0.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    checkIfPageIncludesQuarterAndQuarterIndex(
                                                    widget.quarterJsonData,
                                                    quran.getPageData(index),
                                                    indexes)
                                                .includesQuarter ==
                                            true
                                        ? "${"page".tr()} ${(index).toString()} | ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex + 1) == 1 ? "" : "${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).quarterIndex).toString()}/${4.toString()}"} ${"hizb".tr()} ${(checkIfPageIncludesQuarterAndQuarterIndex(widget.quarterJsonData, quran.getPageData(index), indexes).hizbIndex + 1).toString()} | ${"juz".tr()}: ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])} "
                                        : "${"page".tr()} $index | ${"juz".tr()}: ${getJuzNumber(getPageData(index)[0]["surah"], getPageData(index)[0]["start"])}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: backgroundColors[
                                            getValue("quranPageolorsIndex")]),
                                  ),
                                  Text(
                                    widget.jsonData[quran.getPageData(index)[0]
                                            ["surah"] -
                                        1]["name"],
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamilies[0],
                                        color: backgroundColors[
                                            getValue("quranPageolorsIndex")]),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        itemScrollController: itemScrollController,
                        initialScrollIndex: getValue("lastRead"),
                        itemPositionsListener: itemPositionsListener,
                        itemBuilder: (context, index) {
                          // updateValue("lastRead", index);
                          // bool isEvenPage = index.isEven;

                          if (index == 0) {
                            return Container(
                              color: const Color(0xffFFFCE7),
                              child: Image.asset(
                                "assets/images/quran.jpg",
                                fit: BoxFit.fill,
                              ),
                            );
                          }
                          return BlocBuilder<QuranPagePlayerBloc,
                                  QuranPagePlayerState>(
                              bloc: qurapPagePlayerBloc,
                              builder: (context, state) {
                                if (state is QuranPagePlayerInitial ||
                                    state is QuranPagePlayerIdle) {
                                  return Column(
                                    children: [
                                      Directionality(
                                        textDirection: m.TextDirection.rtl,
                                        child: Padding(
                                          padding: const EdgeInsets.all(26.0),
                                          child: SizedBox(
                                              width: double.infinity,
                                              child: RichText(
                                                key: richTextKeys[index - 1],
                                                textDirection:
                                                    m.TextDirection.rtl,
                                                textAlign: TextAlign.right,
                                                softWrap:
                                                    true, //locale: const Locale("ar"),
                                                text: TextSpan(
                                                  locale: const Locale("ar"),
                                                  children: quran
                                                      .getPageData(index)
                                                      .expand((e) {
                                                    // print(e);
                                                    List<InlineSpan> spans = [];
                                                    for (var i = e["start"];
                                                        i <= e["end"];
                                                        i++) {
                                                      // Header
                                                      if (i == 1) {
                                                        spans.add(WidgetSpan(
                                                          child: HeaderWidget(
                                                              e: e,
                                                              jsonData: widget
                                                                  .jsonData),
                                                        ));

                                                        if (index != 187 &&
                                                            index != 1) {
                                                          spans.add(WidgetSpan(
                                                              child: Basmallah(
                                                            index: getValue(
                                                                "quranPageolorsIndex"),
                                                          )));
                                                        }
                                                        if (index == 187 ||
                                                            index == 1) {
                                                          spans.add(WidgetSpan(
                                                              child: Container(
                                                            height: 10.h,
                                                          )));
                                                        }
                                                      }

                                                      // Verses
                                                      spans.add(TextSpan(
                                                        locale:
                                                            const Locale("ar"),
                                                        children: [
                                                          TextSpan(
                                                            recognizer:
                                                                LongPressGestureRecognizer()
                                                                  ..onLongPress =
                                                                      () {
                                                                    // print(
                                                                    //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                    showAyahOptionsSheet(
                                                                        index,
                                                                        e["surah"],
                                                                        i);
                                                                    print(
                                                                        "longpressed");
                                                                  }
                                                                  ..onLongPressDown =
                                                                      (details) {
                                                                    setState(
                                                                        () {
                                                                      selectedSpan =
                                                                          " ${e["surah"]}$i";
                                                                    });
                                                                  }
                                                                  ..onLongPressUp =
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      selectedSpan =
                                                                          "";
                                                                    });
                                                                    print(
                                                                        "finished long press");
                                                                  }
                                                                  ..onLongPressCancel =
                                                                      () =>
                                                                          setState(
                                                                              () {
                                                                            selectedSpan =
                                                                                "";
                                                                          }),
                                                            text:
                                                                quran.getVerse(
                                                                    e["surah"],
                                                                    i),
                                                            style: TextStyle(
                                                              color: primaryColors[
                                                                  getValue(
                                                                      "quranPageolorsIndex")],
                                                              fontSize: getValue(
                                                                      "verseByVerseFontSize")
                                                                  .toDouble(),
                                                              // wordSpacing: -1.4,
                                                              fontFamily: getValue(
                                                                  "selectedFontFamily"),
                                                              backgroundColor: bookmarks
                                                                      .where((element) =>
                                                                          element["suraNumber"] == e["surah"] &&
                                                                          element["verseNumber"] ==
                                                                              i)
                                                                      .isNotEmpty
                                                                  ? Color(int.parse(
                                                                          "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                      .withOpacity(
                                                                          .19)
                                                                  : shouldHighlightText
                                                                      ? quran.getVerse(e["surah"], i) ==
                                                                              widget
                                                                                  .highlightVerse
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(
                                                                              .25)
                                                                          : selectedSpan ==
                                                                                  " ${e["surah"]}$i"
                                                                              ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(
                                                                                  .25)
                                                                              : Colors
                                                                                  .transparent
                                                                      : selectedSpan ==
                                                                              " ${e["surah"]}$i"
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(
                                                                              .25)
                                                                          : Colors
                                                                              .transparent,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                              ,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      24.sp,
                                                                  color: isVerseStarred(
                                                                          e[
                                                                              "surah"],
                                                                          i)
                                                                      ? Colors
                                                                          .amber
                                                                      : secondaryColors[
                                                                          getValue(
                                                                              "quranPageolorsIndex")],
                                                                  fontFamily:
                                                                      "KFGQPC Uthmanic Script HAFS Regular" //4  -- 7 like ayah
                                                                  // fontFamilies[5]
                                                                  )),
                                                          if (bookmarks
                                                              .where((element) =>
                                                                  element["suraNumber"] ==
                                                                      e[
                                                                          "surah"] &&
                                                                  element["verseNumber"] ==
                                                                      i)
                                                              .isNotEmpty)
                                                            WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Icon(
                                                                  Icons
                                                                      .bookmark,
                                                                  color: Color(
                                                                      int.parse(
                                                                          "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                )),
                                                          WidgetSpan(
                                                              child: Divider(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    .2),
                                                          )),
                                                          WidgetSpan(
                                                              child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                Directionality(
                                                              textDirection: translationDataList[getValue(
                                                                              "indexOfTranslationInVerseByVerse")]
                                                                          .typeInNativeLanguage ==
                                                                      "العربية"
                                                                  ? m.TextDirection
                                                                      .rtl
                                                                  : m.TextDirection
                                                                      .ltr,
                                                              child: get_translation_data
                                                                      .getVerseTranslationForVerseByVerse(
                                                                        dataOfCurrentTranslation,
                                                                        e["surah"],
                                                                        i,
                                                                        translationDataList[
                                                                            getValue("indexOfTranslationInVerseByVerse")],
                                                                      )
                                                                      .contains(">")
                                                                  ? Html(
                                                                      data: get_translation_data
                                                                          .getVerseTranslationForVerseByVerse(
                                                                        dataOfCurrentTranslation,
                                                                        e["surah"],
                                                                        i,
                                                                        translationDataList[
                                                                            getValue("indexOfTranslationInVerseByVerse")],
                                                                      ),
                                                                      style: {
                                                                        '*':
                                                                            Style(
                                                                          fontFamily:
                                                                              'cairo', // Set your custom font family
                                                                          fontSize:
                                                                              FontSize(14.sp),
                                                                          lineHeight:
                                                                              LineHeight(1.7.sp),

                                                                          // color: primaryColors[getValue("quranPageolorsIndex")]
                                                                          //     .withOpacity(.9),
                                                                        ),
                                                                      },
                                                                    )
                                                                  : Text(
                                                                      get_translation_data
                                                                          .getVerseTranslationForVerseByVerse(
                                                                        dataOfCurrentTranslation,
                                                                        e["surah"],
                                                                        i,
                                                                        translationDataList[
                                                                            getValue("indexOfTranslationInVerseByVerse")],
                                                                      ),
                                                                      style: TextStyle(
                                                                          color: primaryColors[getValue(
                                                                              "quranPageolorsIndex")],
                                                                          fontFamily: translationDataList[getValue("indexOfTranslationInVerseByVerse") ?? 0].typeInNativeLanguage == "العربية"
                                                                              ? "cairo"
                                                                              : "roboto",
                                                                          fontSize:
                                                                              14.sp),
                                                                    ),
                                                            ),
                                                          )),
                                                          WidgetSpan(
                                                              child: Divider(
                                                            height: 15.h,
                                                            color: primaryColors[
                                                                    getValue(
                                                                        "quranPageolorsIndex")]
                                                                .withOpacity(
                                                                    .3),
                                                          ))
                                                        ],
                                                      ));
                                                    }
                                                    return spans;
                                                  }).toList(),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (state is QuranPagePlayerPlaying) {
                                  printYellow("playing");
                                  return StreamBuilder(
                                      stream: state.audioPlayerStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final currentDuration =
                                              snapshot.data!.inMilliseconds;
                                          if (currentDuration !=
                                              state.durations[
                                                  state.durations.length -
                                                      1]["endDuration"]) {
                                            currentVersePlaying = state
                                                .durations
                                                .where((element) {
                                              return (element[
                                                          "startDuration"] <=
                                                      currentDuration &&
                                                  currentDuration <=
                                                      element["endDuration"]);
                                            }).first;
                                          }

                                          return Column(
                                            children: [
                                              Directionality(
                                                textDirection:
                                                    m.TextDirection.rtl,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      26.0),
                                                  child: SizedBox(
                                                      width: double.infinity,
                                                      child: RichText(
                                                        key: richTextKeys[
                                                            index - 1],
                                                        textDirection:
                                                            m.TextDirection.rtl,
                                                        textAlign:
                                                            TextAlign.right,
                                                        softWrap:
                                                            true, //locale: const Locale("ar"),
                                                        text: TextSpan(
                                                          locale: const Locale(
                                                              "ar"),
                                                          children: quran
                                                              .getPageData(
                                                                  index)
                                                              .expand((e) {
                                                            // print(e);
                                                            List<InlineSpan>
                                                                spans = [];
                                                            for (var i =
                                                                    e["start"];
                                                                i <= e["end"];
                                                                i++) {
                                                              // Header
                                                              if (i == 1) {
                                                                spans.add(
                                                                    WidgetSpan(
                                                                  child: HeaderWidget(
                                                                      e: e,
                                                                      jsonData:
                                                                          widget
                                                                              .jsonData),
                                                                ));

                                                                if (index !=
                                                                        187 &&
                                                                    index !=
                                                                        1) {
                                                                  spans.add(
                                                                      WidgetSpan(
                                                                          child:
                                                                              Basmallah(
                                                                    index: getValue(
                                                                        "quranPageolorsIndex"),
                                                                  )));
                                                                }
                                                                if (index ==
                                                                        187 ||
                                                                    index ==
                                                                        1) {
                                                                  spans.add(
                                                                      WidgetSpan(
                                                                          child:
                                                                              Container(
                                                                    height:
                                                                        10.h,
                                                                  )));
                                                                }
                                                              }

                                                              // Verses
                                                              spans
                                                                  .add(TextSpan(
                                                                locale:
                                                                    const Locale(
                                                                        "ar"),
                                                                children: [
                                                                  TextSpan(
                                                                    recognizer:
                                                                        LongPressGestureRecognizer()
                                                                          ..onLongPress =
                                                                              () {
                                                                            // print(
                                                                            //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                            showAyahOptionsSheet(
                                                                                index,
                                                                                e["surah"],
                                                                                i);
                                                                            print("longpressed");
                                                                          }
                                                                          ..onLongPressDown =
                                                                              (details) {
                                                                            setState(() {
                                                                              selectedSpan = " ${e["surah"]}$i";
                                                                            });
                                                                          }
                                                                          ..onLongPressUp =
                                                                              () {
                                                                            setState(() {
                                                                              selectedSpan = "";
                                                                            });
                                                                            print("finished long press");
                                                                          }
                                                                          ..onLongPressCancel = () =>
                                                                              setState(() {
                                                                                selectedSpan = "";
                                                                              }),
                                                                    text: quran
                                                                        .getVerse(
                                                                            e["surah"],
                                                                            i),
                                                                    style:
                                                                        TextStyle(
                                                                      color: primaryColors[
                                                                          getValue(
                                                                              "quranPageolorsIndex")],
                                                                      fontSize:
                                                                          getValue("verseByVerseFontSize")
                                                                              .toDouble(),
                                                                      // wordSpacing: -1.4,
                                                                      fontFamily:
                                                                          getValue(
                                                                              "selectedFontFamily"),
                                                                      backgroundColor: bookmarks
                                                                              .where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i)
                                                                              .isNotEmpty
                                                                          ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
                                                                          : (i == currentVersePlaying["verseNumber"] && e["surah"] == state.suraNumber)
                                                                              ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.28)
                                                                              : shouldHighlightText
                                                                                  ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                      : selectedSpan == " ${e["surah"]}$i"
                                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                          : Colors.transparent
                                                                                  : selectedSpan == " ${e["surah"]}$i"
                                                                                      ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                      : Colors.transparent,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                      text:
                                                                          " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                                      ,
                                                                      style: TextStyle(
                                                                          fontSize: 24
                                                                              .sp,
                                                                          color: isVerseStarred(e["surah"], i)
                                                                              ? Colors.amber
                                                                              : secondaryColors[getValue("quranPageolorsIndex")],
                                                                          fontFamily: "KFGQPC Uthmanic Script HAFS Regular")),
                                                                  if (bookmarks
                                                                      .where((element) =>
                                                                          element["suraNumber"] ==
                                                                              e[
                                                                                  "surah"] &&
                                                                          element["verseNumber"] ==
                                                                              i)
                                                                      .isNotEmpty)
                                                                    WidgetSpan(
                                                                        alignment:
                                                                            PlaceholderAlignment
                                                                                .middle,
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .bookmark,
                                                                          color:
                                                                              Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                        )),
                                                                  WidgetSpan(
                                                                      child: SizedBox(
                                                                          height:
                                                                              15.h)),
                                                                  WidgetSpan(
                                                                      child:
                                                                          SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        Directionality(
                                                                      textDirection: translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeInNativeLanguage ==
                                                                              "العربية"
                                                                          ? m.TextDirection
                                                                              .rtl
                                                                          : m.TextDirection
                                                                              .ltr,
                                                                      child: get_translation_data
                                                                              .getVerseTranslationForVerseByVerse(
                                                                                dataOfCurrentTranslation,
                                                                                e["surah"],
                                                                                i,
                                                                                translationDataList[getValue("indexOfTranslationInVerseByVerse")],
                                                                              )
                                                                              .contains(">")
                                                                          ? Html(
                                                                              data: get_translation_data.getVerseTranslationForVerseByVerse(
                                                                                dataOfCurrentTranslation,
                                                                                e["surah"],
                                                                                i,
                                                                                translationDataList[getValue("indexOfTranslationInVerseByVerse")],
                                                                              ),
                                                                              style: {
                                                                                '*': Style(
                                                                                  fontFamily: 'cairo', // Set your custom font family
                                                                                  fontSize: FontSize(14.sp),
                                                                                  lineHeight: LineHeight(1.7.sp),

                                                                                  // color: primaryColors[getValue("quranPageolorsIndex")]
                                                                                  //     .withOpacity(.9),
                                                                                ),
                                                                              },
                                                                            )
                                                                          : Text(
                                                                              get_translation_data.getVerseTranslationForVerseByVerse(
                                                                                dataOfCurrentTranslation,
                                                                                e["surah"],
                                                                                i,
                                                                                translationDataList[getValue("indexOfTranslationInVerseByVerse")],
                                                                              ),
                                                                              style: TextStyle(color: primaryColors[getValue("quranPageolorsIndex")], fontFamily: translationDataList[getValue("indexOfTranslationInVerseByVerse") ?? 0].typeInNativeLanguage == "العربية" ? "cairo" : "roboto", fontSize: 14.sp),
                                                                            ),
                                                                    ),
                                                                  )),
                                                                  WidgetSpan(
                                                                      child:
                                                                          Divider(
                                                                    height:
                                                                        15.h,
                                                                    color: primaryColors[
                                                                        getValue(
                                                                            "quranPageolorsIndex")],
                                                                  ))
                                                                ],
                                                              ));
                                                            }
                                                            return spans;
                                                          }).toList(),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else if (snapshot.hasError) {
                                          return Directionality(
                                            textDirection: m.TextDirection.rtl,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(26.0),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  child: RichText(
                                                    key:
                                                        richTextKeys[index - 1],
                                                    textDirection:
                                                        m.TextDirection.rtl,
                                                    textAlign: TextAlign.right,
                                                    softWrap:
                                                        true, //locale: const Locale("ar"),
                                                    text: TextSpan(
                                                      locale:
                                                          const Locale("ar"),
                                                      children: quran
                                                          .getPageData(index)
                                                          .expand((e) {
                                                        // print(e);
                                                        List<InlineSpan> spans =
                                                            [];
                                                        for (var i = e["start"];
                                                            i <= e["end"];
                                                            i++) {
                                                          // Header
                                                          if (i == 1) {
                                                            spans
                                                                .add(WidgetSpan(
                                                              child: HeaderWidget(
                                                                  e: e,
                                                                  jsonData: widget
                                                                      .jsonData),
                                                            ));

                                                            if (index != 187 &&
                                                                index != 1) {
                                                              spans.add(
                                                                  WidgetSpan(
                                                                      child:
                                                                          Basmallah(
                                                                index: getValue(
                                                                    "quranPageolorsIndex"),
                                                              )));
                                                            }
                                                            if (index == 187 ||
                                                                index == 1) {
                                                              spans.add(
                                                                  WidgetSpan(
                                                                      child:
                                                                          Container(
                                                                height: 10.h,
                                                              )));
                                                            }
                                                          }

                                                          // Verses
                                                          spans.add(TextSpan(
                                                            locale:
                                                                const Locale(
                                                                    "ar"),
                                                            children: [
                                                              TextSpan(
                                                                recognizer:
                                                                    LongPressGestureRecognizer()
                                                                      ..onLongPress =
                                                                          () {
                                                                        // print(
                                                                        //     "$index, ${e["surah"]}, ${e["start"] + i - 1}");
                                                                        showAyahOptionsSheet(
                                                                            index,
                                                                            e["surah"],
                                                                            i);
                                                                        print(
                                                                            "longpressed");
                                                                      }
                                                                      ..onLongPressDown =
                                                                          (details) {
                                                                        setState(
                                                                            () {
                                                                          selectedSpan =
                                                                              " ${e["surah"]}$i";
                                                                        });
                                                                      }
                                                                      ..onLongPressUp =
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          selectedSpan =
                                                                              "";
                                                                        });
                                                                        print(
                                                                            "finished long press");
                                                                      }
                                                                      ..onLongPressCancel = () =>
                                                                          setState(
                                                                              () {
                                                                            selectedSpan =
                                                                                "";
                                                                          }),
                                                                text: quran
                                                                    .getVerse(
                                                                        e["surah"],
                                                                        i),
                                                                style:
                                                                    TextStyle(
                                                                  color: primaryColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")],
                                                                  fontSize: getValue(
                                                                          "verseByVerseFontSize")
                                                                      .toDouble(),
                                                                  // wordSpacing: -1.4,
                                                                  fontFamily:
                                                                      getValue(
                                                                          "selectedFontFamily"),
                                                                  backgroundColor: bookmarks
                                                                          .where((element) =>
                                                                              element["suraNumber"] == e["surah"] &&
                                                                              element["verseNumber"] ==
                                                                                  i)
                                                                          .isNotEmpty
                                                                      ? Color(int.parse(
                                                                              "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                          .withOpacity(
                                                                              .19)
                                                                      : shouldHighlightText
                                                                          ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                              ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                              : selectedSpan == " ${e["surah"]}$i"
                                                                                  ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                                  : Colors.transparent
                                                                          : selectedSpan == " ${e["surah"]}$i"
                                                                              ? highlightColors[getValue("quranPageolorsIndex")].withOpacity(.25)
                                                                              : Colors.transparent,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                  text:
                                                                      " ${convertToArabicNumber((i).toString())} " //               quran.getVerseEndSymbol()
                                                                  ,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          24.sp,
                                                                      color: isVerseStarred(
                                                                              e[
                                                                                  "surah"],
                                                                              i)
                                                                          ? Colors
                                                                              .amber
                                                                          : Colors
                                                                              .blueAccent,
                                                                      fontFamily:
                                                                          "KFGQPC Uthmanic Script HAFS Regular")),
                                                              if (bookmarks
                                                                  .where((element) =>
                                                                      element["suraNumber"] ==
                                                                          e[
                                                                              "surah"] &&
                                                                      element["verseNumber"] ==
                                                                          i)
                                                                  .isNotEmpty)
                                                                WidgetSpan(
                                                                    alignment:
                                                                        PlaceholderAlignment
                                                                            .middle,
                                                                    child: Icon(
                                                                      Icons
                                                                          .bookmark,
                                                                      color: Color(
                                                                          int.parse(
                                                                              "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                    )),
                                                              WidgetSpan(
                                                                  child: SizedBox(
                                                                      height: 15
                                                                          .h)),
                                                              WidgetSpan(
                                                                  child:
                                                                      SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    Directionality(
                                                                  textDirection: translationDataList[getValue("indexOfTranslationInVerseByVerse")]
                                                                              .typeInNativeLanguage ==
                                                                          "العربية"
                                                                      ? m.TextDirection
                                                                          .rtl
                                                                      : m.TextDirection
                                                                          .ltr,
                                                                  child: get_translation_data
                                                                          .getVerseTranslationForVerseByVerse(
                                                                            dataOfCurrentTranslation,
                                                                            e["surah"],
                                                                            i,
                                                                            translationDataList[getValue("indexOfTranslationInVerseByVerse")],
                                                                          )
                                                                          .contains(">")
                                                                      ? Html(
                                                                          data:
                                                                              get_translation_data.getVerseTranslationForVerseByVerse(
                                                                            dataOfCurrentTranslation,
                                                                            e["surah"],
                                                                            i,
                                                                            translationDataList[getValue("indexOfTranslationInVerseByVerse")],
                                                                          ),
                                                                          style: {
                                                                            '*':
                                                                                Style(
                                                                              fontFamily: 'cairo', // Set your custom font family
                                                                              fontSize: FontSize(14.sp),
                                                                              lineHeight: LineHeight(1.7.sp),

                                                                              // color: primaryColors[getValue("quranPageolorsIndex")]
                                                                              //     .withOpacity(.9),
                                                                            ),
                                                                          },
                                                                        )
                                                                      : Text(
                                                                          get_translation_data
                                                                              .getVerseTranslationForVerseByVerse(
                                                                            dataOfCurrentTranslation,
                                                                            e["surah"],
                                                                            i,
                                                                            translationDataList[getValue("indexOfTranslationInVerseByVerse")],
                                                                          ),
                                                                          style: TextStyle(
                                                                              color: primaryColors[getValue("quranPageolorsIndex")],
                                                                              fontFamily: translationDataList[getValue("indexOfTranslationInVerseByVerse") ?? 0].typeInNativeLanguage == "العربية" ? "cairo" : "roboto",
                                                                              fontSize: 14.sp),
                                                                        ),
                                                                ),
                                                              )),
                                                              WidgetSpan(
                                                                  child:
                                                                      Divider(
                                                                height: 15.h,
                                                                color: primaryColors[
                                                                    getValue(
                                                                        "quranPageolorsIndex")],
                                                              ))
                                                            ],
                                                          ));
                                                        }
                                                        return spans;
                                                      }).toList(),
                                                    ),
                                                  )),
                                            ),
                                          );
                                        }
                                        return Container();
                                      });
                                }
                                return Container();
                              });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 28.0.h),
                        child: Container(
                          // duration: const Duration(milliseconds: 500),
                          height: 45.h,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: (screenSize.width * .27).w,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          size: 24.sp,
                                          color: primaryColors[
                                              getValue("quranPageolorsIndex")],
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: (screenSize.width * .27).w,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          showSettingsSheet(context);
                                        },
                                        icon: Icon(
                                          Icons.settings,
                                          size: 24.sp,
                                          color: primaryColors[
                                              getValue("quranPageolorsIndex")],
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container();
            },
          ),
          BlocBuilder<QuranPagePlayerBloc, QuranPagePlayerState>(
            bloc: qurapPagePlayerBloc,
            builder: (context, state) {
              if (state is QuranPagePlayerPlaying) {
                return Positioned(
                    bottom: 0,
                    width: screenSize.width,
                    child: Center(
                      child: Container(
                        width: screenSize.width,
                        decoration: BoxDecoration(
                            color: backgroundColors[
                                getValue("quranPageolorsIndex")],
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 1,
                                  color: primaryColors[
                                          getValue("quranPageolorsIndex")]
                                      .withOpacity(.7))
                            ],
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15.r),
                                topLeft: Radius.circular(15.r))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Directionality(
                              textDirection: m.TextDirection.rtl,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DropdownButton<int>(
                                    value: getValue("reciterIndex"),
                                    dropdownColor: backgroundColors[
                                        getValue("quranPageolorsIndex")],
                                    onChanged: (int? newIndex) async {
                                      updateValue("reciterIndex", newIndex);
                                      await downloadAndCacheSuraAudio(
                                          quran.getSurahNameEnglish(
                                              state.suraNumber),
                                          quran.getVerseCount(state.suraNumber),
                                          state.suraNumber,
                                          reciters[getValue("reciterIndex")]
                                              .identifier);
                                      state.player.dispose();
                                      // BlocProvider.of<QuranPagePlayerBloc>(context, listen: false)
                                      if (playerPageBloc.state
                                          is PlayerBlocPlaying) {
                                        await showDialog(
                                            context: context,
                                            builder: (a) {
                                              return AlertDialog(
                                                content: const Text(
                                                    "Close current player?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text("Back")),
                                                  TextButton(
                                                      onPressed: () {
                                                        playerPageBloc.add(
                                                            ClosePlayerEvent());
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          "close it")),
                                                ],
                                              );
                                            });
                                      }
                                      qurapPagePlayerBloc.add(PlayFromVerse(
                                          currentVersePlaying,
                                          reciters[getValue("reciterIndex")]
                                              .identifier,
                                          state.suraNumber,
                                          quran.getSurahNameEnglish(
                                              state.suraNumber)));
                                      setState(() {});

                                      // setstatee(() {});
                                    },
                                    items: reciters.map((reciter) {
                                      return DropdownMenuItem<int>(
                                        value: reciters.indexOf(reciter),
                                        child: Text(reciter.name,
                                            style: TextStyle(
                                                color: primaryColors[getValue(
                                                    "quranPageolorsIndex")])),
                                      );
                                    }).toList(),
                                  ),

                                  // Text(
                                  //   state.reciter["englishName"],
                                  //   style: TextStyle(
                                  //       color: primaryColors[
                                  //           getValue("quranPageolorsIndex")]),
                                  // ),
                                  IconButton(
                                      iconSize: 14.sp,
                                      onPressed: () {
                                        if (currentVersePlaying[
                                                "verseNumber"] !=
                                            1) {
                                          state.player.seek(Duration(
                                              milliseconds: state.durations
                                                  .where((element) =>
                                                      element["verseNumber"] ==
                                                      (currentVersePlaying[
                                                              "verseNumber"] -
                                                          1))
                                                  .first["startDuration"]
                                                  .toInt()));
                                        }
                                      },
                                      icon: const Icon(
                                          LineariconsFree.chevron_right)),
                                  GestureDetector(
                                    onTap: () async {
                                      // setState(() {});
                                      state.player.playing
                                          ? state.player.pause()
                                          : state.player.play();
                                      await Future.delayed(
                                          const Duration(milliseconds: 300));

                                      setState(() {}); // setState(() {});
                                    },
                                    child: Container(
                                      height: 28.h,
                                      width: 28.h,
                                      decoration: BoxDecoration(
                                        color: secondaryColors[
                                            getValue("quranPageolorsIndex")],
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          state.player.playing
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      state.player.stop();
                                      qurapPagePlayerBloc.add(StopPlaying());
                                      setState(() {});
                                    },
                                    child: Container(
                                      height: 28.h,
                                      width: 28.h,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.stop,
                                          size: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                      iconSize: 14.sp,
                                      onPressed: () {
                                        if (currentVersePlaying["verseNumber"] <
                                            state.durations.length) {
                                          state.player.seek(Duration(
                                              milliseconds: state.durations
                                                  .where((element) =>
                                                      element["verseNumber"] ==
                                                      (currentVersePlaying[
                                                              "verseNumber"] +
                                                          1))
                                                  .first["startDuration"]
                                                  .toInt()));
                                        }
                                      },
                                      icon: const Icon(
                                          LineariconsFree.chevron_left)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
              }
              return Container();
            },
          )
          //  if(isDownloading)
        ],
      ),
    );
  }

  showSettingsSheet(context) {
    int index = 0;

    showMaterialModalBottomSheet(
      enableDrag: true,
      duration: const Duration(milliseconds: 600),
      backgroundColor: Colors.transparent,
      context: context,
      animationCurve: Curves.easeInOutQuart,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(.1),
      bounce: true,
      builder: (a) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setStatee) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setStatee((() {
                          index = 0;
                        }));
                      },
                      child: CircleAvatar(
                        backgroundColor: index == 0
                            ? secondaryColors[getValue("quranPageolorsIndex")]
                            : Colors.grey,
                        child: const Icon(
                          Icons.color_lens,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (getValue("alignmentType") != "pageview")
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          setStatee((() {
                            index = 1;
                          }));
                        },
                        child: CircleAvatar(
                          backgroundColor: index == 1
                              ? secondaryColors[getValue("quranPageolorsIndex")]
                              : Colors.grey,
                          child: const Icon(
                            Icons.font_download,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setStatee((() {
                          index = 2;
                        }));
                      },
                      child: CircleAvatar(
                        backgroundColor: index == 2
                            ? secondaryColors[getValue("quranPageolorsIndex")]
                            : Colors.grey,
                        child: const Icon(
                          FontAwesome.align_center,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index == 0)
              Container(
                // height: (MediaQuery.of(context).size.height*.2).h,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: primaryColors[getValue("quranPageolorsIndex")]
                          .withOpacity(.3)),
                  color: Colors.grey,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 230.h,
                      width: MediaQuery.of(context).size.width,
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, childAspectRatio: 1.8 / 1),
                          scrollDirection: Axis.vertical,
                          itemCount: primaryColors.length,
                          itemBuilder: (a, i) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                              child: GestureDetector(
                                onTap: () {
                                  updateValue("quranPageolorsIndex", i);
                                  setState(() {});
                                  setStatee(() {});
                                },
                                child: SizedBox(
                                  width: 90.w,
                                  height: 40.h,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 90.w,
                                          height: 40.h,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 1,
                                                  color: Colors.grey
                                                      .withOpacity(.3)),
                                              BoxShadow(
                                                  blurRadius: 1,
                                                  offset: const Offset(-1, 1),
                                                  color: Colors.grey
                                                      .withOpacity(.3)),
                                            ],
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: backgroundColors[i],
                                          ),
                                        ),
                                      ),
                                      if (getValue("quranPageolorsIndex") != i)
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
                                      if (getValue("quranPageolorsIndex") == i)
                                        Center(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primaryColors[i],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.check,
                                                color: backgroundColors[
                                                    getValue(
                                                        "quranPageolorsIndex")],
                                              ),
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
                      height: 4.h,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ),
            if (index == 1 && getValue("alignmentType") != "pageview")
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: primaryColors[getValue("quranPageolorsIndex")]
                          .withOpacity(.3)),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                height: (MediaQuery.of(context).size.height * .4).h,
                child: Column(
                  children: [
                    Slider(
                      label: (getValue("alignmentType") == "versebyverse"
                              ? getValue("verseByVerseFontSize").toDouble()
                              : getValue("alignmentType") == "verticalview"
                                  ? getValue("verticalViewFontSize").toDouble()
                                  : getValue("pageViewFontSize").toDouble())
                          .toString(),
                      divisions: 30,
                      value: getValue("alignmentType") == "versebyverse"
                          ? getValue("verseByVerseFontSize").toDouble()
                          : getValue("alignmentType") == "verticalview"
                              ? getValue("verticalViewFontSize").toDouble()
                              : getValue("pageViewFontSize").toDouble(),
                      min: 15.0, // Minimum font size
                      max: 45.0, // Maximum font size
                      onChanged: (newSize) {
                        if (getValue("alignmentType") == "versebyverse") {
                          updateValue("verseByVerseFontSize", newSize);
                        } else if (getValue("alignmentType") ==
                            "verticalview") {
                          updateValue("verticalViewFontSize", newSize);
                        } else if (getValue("alignmentType") == "pageview") {
                          updateValue("pageViewFontSize", newSize);
                        }
                        // Call the function to update font size
                        setState(() {});
                        setStatee(
                          () {},
                        );
                      },
                    ),
                    EasyContainer(
                      child: Text("reset".tr()),
                      onTap: () {
                        updateValue("selectedFontFamily", "UthmanicHafs13");

                        if (getValue("alignmentType") == "versebyverse") {
                          updateValue("verseByVerseFontSize", 24);
                        } else if (getValue("alignmentType") ==
                            "verticalview") {
                          updateValue("verticalViewFontSize", 23);
                        } else if (getValue("alignmentType") == "pageview") {
                          updateValue("pageViewFontSize", 23);
                        }
                        updateValue("currentHeight", 2.0);

                        updateValue("currentLetterSpacing", 0);
                        setState(() {
                          // currentFontSize = 23;
                          currentHeight = 2;
                          // currentWordSpacing =
                          //     0;
                          currentLetterSpacing = 0;
                        });
                        setStatee(
                          () {},
                        );
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: fontFamilies.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              updateValue(
                                  "selectedFontFamily", fontFamilies[index]);
                              setState(() {});
                              setStatee(
                                  () {}); // I'm not sure what setStatee is, make sure it's defined correctly
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ',
                                    style: TextStyle(
                                      fontFamily: fontFamilies[index],
                                      fontSize: 18, // Use the current font size
                                    ),
                                  ),
                                  const VerticalDivider(),
                                  Text(
                                    fontFamilies[index],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (getValue("selectedFontFamily") ==
                                      fontFamilies[index])
                                    Icon(
                                      Elusive.ok_circled,
                                      color: primaryColors[
                                          getValue("quranPageolorsIndex")],
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (index == 2)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: primaryColors[getValue("quranPageolorsIndex")]
                          .withOpacity(.3)),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                width: MediaQuery.of(context).size.width,
                // height: (MediaQuery.of(context).size.height * .4).h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () async {
                          updateValue("alignmentType", "pageview");

                          setState(() {});
                          // print(index);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_pageController.hasClients) {
                              _pageController.jumpToPage(
                                getValue("lastRead"),
                              );
                            }
                          });
                          setStatee(() {});
                        },
                        child: Text("pageview".tr())),
                    TextButton(
                        onPressed: () async {
                          updateValue("alignmentType", "verticalview");

                          setState(() {});
                          await Future.delayed(
                              const Duration(microseconds: 400));
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            itemScrollController.jumpTo(
                              index: getValue("lastRead"),
                            );
                          });
                          setStatee(() {});
                        },
                        child: Text("verticalview".tr())),
                    TextButton(
                        onPressed: () {
                          setState(() {});
                          updateValue("alignmentType", "versebyverse");
                          setStatee(() {});
                        },
                        child: Text("versebyverse".tr())),
                    if (getValue("alignmentType") == "versebyverse")
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .8,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                  itemCount: translationDataList
                                                      .length,
                                                  itemBuilder: (c, i) {
                                                    return Container(
                                                      color: i ==
                                                              getValue(
                                                                  "indexOfTranslationInVerseByVerse")
                                                          ? Colors.blueGrey
                                                              .withOpacity(.1)
                                                          : Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (isDownloading !=
                                                              translationDataList[
                                                                      i]
                                                                  .url) {
                                                            if (File("${appDir!.path}/${translationDataList[i].typeText}.json")
                                                                    .existsSync() ||
                                                                i == 0 ||
                                                                i == 1) {
                                                              updateValue(
                                                                  "indexOfTranslationInVerseByVerse",
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
                                                            }
                                                            getTranslationData();
                                                            setState(() {});
                                                          }

                                                          setState(() {});

                                                          setStatee(() {});
                                                          if (mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      18.0.w,
                                                                  vertical:
                                                                      2.h),
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
                                                                              i ==
                                                                                  1
                                                                          ? MfgLabs
                                                                              .hdd
                                                                          : File("${appDir!.path}/${translationDataList[i].typeText}.json").existsSync()
                                                                              ? Icons.done
                                                                              : Icons.cloud_download,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size:
                                                                          18.sp,
                                                                    )
                                                                  : const CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
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
                              width: MediaQuery.of(context).size.width,
                              height: 40.h,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 14.0.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      translationDataList[getValue(
                                                  "indexOfTranslationInVerseByVerse") ??
                                              0]
                                          .typeTextInRelatedLanguage,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: translationDataList[getValue(
                                                              "indexOfTranslationInVerseByVerse") ??
                                                          0]
                                                      .typeInNativeLanguage ==
                                                  "العربية"
                                              ? "cairo"
                                              : "roboto"),
                                    ),
                                    Icon(
                                      FontAwesome.ellipsis,
                                      size: 24.sp,
                                      color: secondaryColors[
                                          getValue("quranPageolorsIndex")],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              )
          ],
        );
      }),
    );
  }

  showAyahOptionsSheet(
    index,
    surahNumber,
    verseNumber,
  ) {
    // print(/
    // "$surahNumber: $verseNumber",
    // );
    // print(quran.getVerse(surahNumber, verseNumber));
    showMaterialModalBottomSheet(
        enableDrag: true,
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.transparent,
        context: context,
        animationCurve: Curves.easeInOutQuart,
        elevation: 0,
        bounce: true,
        // barrierColor: Colors.transparent,
        // context: context,
        builder: (c) => StatefulBuilder(builder: (context, setstatee) {
              return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColors[getValue("quranPageolorsIndex")],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            "${context.locale.languageCode == "ar" ? quran.getSurahNameArabic(surahNumber) : quran.getSurahNameEnglish(surahNumber)}: $verseNumber",
                            style: TextStyle(
                                color: primaryColors[
                                    getValue("quranPageolorsIndex")]),
                          ),
                          trailing: SizedBox(
                            width: 200.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      isVerseStarred(surahNumber, verseNumber)
                                          ? removeStarredVerse(
                                              surahNumber, verseNumber)
                                          : addStarredVerse(
                                              surahNumber, verseNumber);
                                      setstatee(() {});
                                      setState(() {});
                                      richTextKeys[index - 1]
                                          .currentState
                                          ?.build(context);
                                    },
                                    icon: Icon(
                                      isVerseStarred(surahNumber, verseNumber)
                                          ? FontAwesome.star
                                          : FontAwesome.star_empty,
                                      color: primaryColors[
                                          getValue("quranPageolorsIndex")],
                                    )),
                                IconButton(
                                    onPressed: () {
                                      takeScreenshotFunction(
                                          index, surahNumber, verseNumber);
                                    },
                                    icon: Icon(Icons.share,
                                        color: primaryColors[
                                            getValue("quranPageolorsIndex")])),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 10.h,
                          color: primaryColors[getValue("quranPageolorsIndex")],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color:
                                  primaryColors[getValue("quranPageolorsIndex")]
                                      .withOpacity(.05),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (bookmarks.isNotEmpty)
                                    ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: bookmarks.length,
                                        itemBuilder: (c, i) {
                                          return GestureDetector(
                                            // color: Colors.transparent,
                                            onTap: () async {
                                              List bookmarks = json.decode(
                                                  getValue("bookmarks"));

                                              bookmarks[i]["verseNumber"] =
                                                  verseNumber;

                                              bookmarks[i]["suraNumber"] =
                                                  surahNumber;

                                              updateValue("bookmarks",
                                                  json.encode(bookmarks));
                                              // print(getValue("bookmarks"));
                                              setState(() {});
                                              fetchBookmarks();
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20.w,
                                                  ),
                                                  Icon(
                                                    Icons.bookmark,
                                                    color: Color(int.parse(
                                                        "0x${bookmarks[i]["color"]}")),
                                                  ),
                                                  SizedBox(
                                                    width: 20.w,
                                                  ),
                                                  Text(bookmarks[i]["name"],
                                                      style: TextStyle(
                                                          fontFamily: "cairo",
                                                          fontSize: 14.sp,
                                                          color: primaryColors[
                                                              getValue(
                                                                  "quranPageolorsIndex")])),
                                                  SizedBox(
                                                    width: 30.w,
                                                  ),
                                                  // if (getValue("redBookmark") != null)
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          getVerse(
                                                            int.parse(bookmarks[
                                                                        i][
                                                                    "suraNumber"]
                                                                .toString()),
                                                            int.parse(bookmarks[
                                                                        i][
                                                                    "verseNumber"]
                                                                .toString()),
                                                          ),
                                                          textDirection: m
                                                              .TextDirection
                                                              .rtl,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  fontFamilies[
                                                                      0],
                                                              fontSize: 13.sp,
                                                              color: primaryColors[
                                                                  getValue(
                                                                      "quranPageolorsIndex")],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis)),
                                                    ),
                                                  ),

                                                  IconButton(
                                                      onPressed: () {
                                                        //  String bookmarkName = _nameController.text;
                                                        // TODO: Perform actions with bookmarkName and _selectedColor
                                                        List bookmarks = json
                                                            .decode(getValue(
                                                                "bookmarks"));
                                                        // String hexCode =
                                                        //     _selectedColor.value.toRadixString(16).padLeft(8, '0');
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "${bookmarks[i]["name"]} removed");

                                                        bookmarks.removeWhere(
                                                            (e) =>
                                                                e["color"] ==
                                                                bookmarks[i]
                                                                    ["color"]);
                                                        updateValue(
                                                            "bookmarks",
                                                            json.encode(
                                                                bookmarks));
                                                        // print(getValue("bookmarks"));
                                                        setState(() {});
                                                        fetchBookmarks();
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Color(int.parse(
                                                            "0x${bookmarks[i]["color"]}")),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  if (bookmarks.isNotEmpty) const Divider(),
                                  EasyContainer(
                                    color: Colors.transparent,
                                    onTap: () async {
                                      await showAnimatedDialog(
                                          context: context,
                                          builder: (context) => BookmarksDialog(
                                                suraNumber: surahNumber,
                                                verseNumber: verseNumber,
                                              ));

                                      fetchBookmarks();
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          Icon(
                                            Icons.bookmark_add,
                                            color: secondaryColors[getValue(
                                                "quranPageolorsIndex")],
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          Text("newBookmark".tr(),
                                              style: TextStyle(
                                                  fontFamily: "cairo",
                                                  fontSize: 14.sp,
                                                  color: primaryColors[getValue(
                                                      "quranPageolorsIndex")])),
                                          SizedBox(
                                            width: 30.w,
                                          ),
                                          if (getValue("redBookmark") != null)
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    getVerse(
                                                      int.parse(getValue(
                                                              "redBookmark")
                                                          .toString()
                                                          .split('-')[0]),
                                                      int.parse(getValue(
                                                              "redBookmark")
                                                          .toString()
                                                          .split('-')[1]),
                                                    ),
                                                    textDirection:
                                                        m.TextDirection.rtl,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            fontFamilies[0],
                                                        fontSize: 13.sp,
                                                        color: primaryColors[
                                                            getValue(
                                                                "quranPageolorsIndex")],
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        EasyContainer(
                          color: primaryColors[getValue("quranPageolorsIndex")]
                              .withOpacity(.05),
                          borderRadius: 8,
                          onTap: () {
                            showMaterialModalBottomSheet(
                                enableDrag: true,
                                // backgroundColor: Colors.transparent,
                                context: context,
                                animationCurve: Curves.easeInOutQuart,
                                elevation: 0,
                                bounce: true,
                                duration: const Duration(milliseconds: 400),
                                backgroundColor: backgroundColor,
                                // Set this to true
                                // backgroundColor: Colors.transparent, // Set background color to transparent
                                // useSafeArea: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(13.r),
                                        topLeft: Radius.circular(13.r))),
                                isDismissible: true,
                                // constraints: BoxConstraints.expand(
                                //   height: MediaQuery.of(context).size.height,
                                // ),
                                builder: (d) {
                                  return TafseerAndTranslateSheet(
                                      surahNumber: surahNumber,
                                      isVerseByVerseSelection: false,
                                      verseNumber: verseNumber);
                                });
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20.w,
                                ),
                                Icon(
                                  FontAwesome5.book_open,
                                  color: getValue("quranPageolorsIndex") == 0
                                      ? secondaryColors[
                                          getValue("quranPageolorsIndex")]
                                      : highlightColors[
                                          getValue("quranPageolorsIndex")],
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Text(
                                    "${"tafseer".tr()} - ${"translation".tr()}",
                                    style: TextStyle(
                                        fontFamily: "cairo",
                                        fontSize: 14.sp,
                                        color: primaryColors[
                                            getValue("quranPageolorsIndex")])),
                                SizedBox(
                                  width: 30.w,
                                )
                              ],
                            ),
                          ),
                        ),
                        // EasyContainer(
                        //   color: primaryColors[getValue("quranPageolorsIndex")]
                        //       .withOpacity(.05),
                        //   onTap: () {
                        //     showMaterialModalBottomSheet(
                        //       enableDrag: true,
                        //         // backgroundColor: Colors.transparent,
                        //         context: context,
                        //         animationCurve: Curves.easeInOutQuart,
                        //         elevation: 0,
                        //         bounce: true,
                        //         duration: const Duration(milliseconds: 400),
                        //         backgroundColor: backgroundColors[
                        //             getValue("quranPageolorsIndex")],
                        //         // Set this to true
                        //         // backgroundColor: Colors.transparent, // Set background color to transparent
                        //         // useSafeArea: true,
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.only(
                        //                 topRight: Radius.circular(13.r),
                        //                 topLeft: Radius.circular(13.r))),
                        //         isDismissible: true,
                        //         // constraints: BoxConstraints.expand(
                        //         //   height: MediaQuery.of(context).size.height,
                        //         // ),
                        //         builder: (d) {
                        //           return TafseerAndTranslateSheet(
                        //               surahNumber: surahNumber,
                        //               isTranslateSheet: true,
                        //               verseNumber: verseNumber);
                        //         });
                        //   },
                        //   child: SizedBox(
                        //     width: MediaQuery.of(context).size.width,
                        //     child: Row(
                        //       children: [
                        //         SizedBox(
                        //           width: 20.w,
                        //         ),
                        //         Icon(
                        //           Icons.translate,
                        //           color: getValue("quranPageolorsIndex") == 0
                        //               ? secondaryColors[getValue("quranPageolorsIndex")]
                        //               : highlightColors[
                        //                   getValue("quranPageolorsIndex")],
                        //         ),
                        //         SizedBox(
                        //           width: 20.w,
                        //         ),
                        //         Text("translation".tr(),
                        //             style: TextStyle(
                        //                 fontFamily: "cairo",
                        //                 fontSize: 14.sp,
                        //                 color: primaryColors[
                        //                     getValue("quranPageolorsIndex")])),
                        //         SizedBox(
                        //           width: 30.w,
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 10.h,
                        ),
                        EasyContainer(
                          borderRadius: 8,
                          color: primaryColors[getValue("quranPageolorsIndex")]
                              .withOpacity(.05),
                          onTap: () async {
                            Navigator.pop(context);
                            // print(getValue("lastRead"));
                            // print(quran.getAudioURLBySurah(
                            //     surahNumber, reciters[2].identifier));
                            // print(quran.getAudioURLByVerse(surahNumber,
                            //     verseNumber, reciters[2].identifier));
                            await downloadAndCacheSuraAudio(
                                quran.getSurahNameEnglish(surahNumber),
                                quran.getVerseCount(surahNumber),
                                surahNumber,
                                reciters[getValue("reciterIndex")].identifier);
                            // print("lastt read ${getValue("lastRead")}");

                            // BlocProvider.of<QuranPagePlayerBloc>(context, listen: false)
                            if (playerPageBloc.state is PlayerBlocPlaying) {
                              if (mounted) {
                                await showDialog(
                                    context: context,
                                    builder: (a) {
                                      return AlertDialog(
                                        content: Text("closeplayer".tr()),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("back".tr())),
                                          TextButton(
                                              onPressed: () {
                                                playerPageBloc
                                                    .add(ClosePlayerEvent());
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("close".tr())),
                                        ],
                                      );
                                    });
                              }
                            }
                            if (qurapPagePlayerBloc.state
                                is QuranPagePlayerPlaying) {
                              qurapPagePlayerBloc.add(KillPlayerEvent());
                            }

                            qurapPagePlayerBloc.add(PlayFromVerse(
                                verseNumber,
                                reciters[getValue("reciterIndex")].identifier,
                                surahNumber,
                                quran.getSurahNameEnglish(surahNumber)));
                            if (getValue("alignmentType") == "verticalview" &&
                                quran.getPageNumber(surahNumber, verseNumber) >
                                    600) {
                              await Future.delayed(
                                  const Duration(milliseconds: 1000));
                              itemScrollController.jumpTo(
                                  index: quran.getPageNumber(
                                      surahNumber, verseNumber));
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20.w,
                                ),
                                Icon(
                                  FontAwesome5.book_reader,
                                  color: getValue("quranPageolorsIndex") == 0
                                      ? secondaryColors[
                                          getValue("quranPageolorsIndex")]
                                      : highlightColors[
                                          getValue("quranPageolorsIndex")],
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Text("play".tr(),
                                    style: TextStyle(
                                        fontFamily: "cairo",
                                        fontSize: 14.sp,
                                        color: primaryColors[
                                            getValue("quranPageolorsIndex")])),
                                SizedBox(
                                  width: 30.w,
                                ),
                                DropdownButton<int>(
                                  value: getValue("reciterIndex"),
                                  dropdownColor: backgroundColors[
                                      getValue("quranPageolorsIndex")],
                                  onChanged: (int? newIndex) {
                                    updateValue("reciterIndex", newIndex);
                                    setState(() {});
                                    setstatee(() {});
                                  },
                                  items: reciters.map((reciter) {
                                    return DropdownMenuItem<int>(
                                      value: reciters.indexOf(reciter),
                                      child: Text(
                                          context.locale.languageCode == "ar"
                                              ? reciter.name
                                              : reciter.englishName,
                                          style: TextStyle(
                                              color: primaryColors[getValue(
                                                  "quranPageolorsIndex")])),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                      ],
                    ),
                  ));
            }));
  }

  bool showSuraHeader = true;
  bool addAppSlogan = true;
  takeScreenshotFunction(index, surahNumber, verseNumber) {
    int firstVerse = verseNumber;
    int lastVerse = verseNumber;
    showAnimatedDialog(
      animationType: DialogTransitionType.size,
      context: context,
      builder: (builder) {
        return StatefulBuilder(builder: (context, setstatter) {
          return Dialog(
            // title: const Text('Share Ayah'),
            backgroundColor: backgroundColors[getValue("quranPageolorsIndex")],

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "share".tr(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: primaryColors[getValue("quranPageolorsIndex")],
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0, // Increase font size
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0), // Add spacing at the top
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'fromayah'.tr(),
                      style: TextStyle(
                        color: primaryColors[getValue("quranPageolorsIndex")],
                        fontSize: 16.0, // Increase font size
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    DropdownButton<int>(
                      dropdownColor:
                          backgroundColors[getValue("quranPageolorsIndex")],
                      value: firstVerse,
                      onChanged: (newValue) {
                        if (newValue! > lastVerse) {
                          setState(() {
                            lastVerse = newValue;
                          });
                          setstatter(() {});
                        }
                        setState(() {
                          firstVerse = newValue;
                        });
                        setstatter(() {});
                        // Handle dropdown selection
                      },
                      items: List.generate(
                        quran.getVerseCount(surahNumber),
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: primaryColors[
                                  getValue("quranPageolorsIndex")],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Text(
                      'toayah'.tr(),
                      style: TextStyle(
                        color: primaryColors[getValue("quranPageolorsIndex")],
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    DropdownButton<int>(
                      dropdownColor:
                          backgroundColors[getValue("quranPageolorsIndex")],
                      value: lastVerse,
                      onChanged: (newValue) {
                        if (newValue! > firstVerse) {
                          setState(() {
                            lastVerse = newValue;
                          });
                          setstatter(() {});
                        }
                        // Handle dropdown selection
                      },
                      items: List.generate(
                        quran.getVerseCount(surahNumber),
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: primaryColors[
                                  getValue("quranPageolorsIndex")],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0), // Add spacing between rows
                RadioListTile(
                  activeColor: highlightColors[getValue("quranPageolorsIndex")],
                  fillColor: MaterialStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  title: Text(
                    'asimage'.tr(),
                    style: TextStyle(
                      color: primaryColors[getValue("quranPageolorsIndex")],
                    ),
                  ),
                  value: 0,
                  groupValue: getValue("selectedShareTypeIndex"),
                  onChanged: (value) {
                    updateValue("selectedShareTypeIndex", value);
                    setState(() {});
                    setstatter(() {});
                  },
                ),
                RadioListTile(
                  activeColor: highlightColors[getValue("quranPageolorsIndex")],
                  fillColor: MaterialStatePropertyAll(
                      primaryColors[getValue("quranPageolorsIndex")]),
                  title: Text(
                    'astext'.tr(),
                    style: TextStyle(
                      color: primaryColors[getValue("quranPageolorsIndex")],
                    ),
                  ),
                  value: 1,
                  groupValue: getValue("selectedShareTypeIndex"),
                  onChanged: (value) {
                    updateValue("selectedShareTypeIndex", value);
                    setState(() {});
                    setstatter(() {});
                  },
                ),
                if (getValue("selectedShareTypeIndex") == 1)
                  Row(
                    children: [
                      Checkbox(
                        fillColor: MaterialStatePropertyAll(
                            primaryColors[getValue("quranPageolorsIndex")]),
                        checkColor:
                            backgroundColors[getValue("quranPageolorsIndex")],
                        value: getValue("textWithoutDiacritics"),
                        onChanged: (newValue) {
                          updateValue("textWithoutDiacritics", newValue);
                          setState(() {});
                          setstatter(() {});
                        },
                      ),
                      Text(
                        'withoutdiacritics'.tr(),
                        style: TextStyle(
                          color: primaryColors[getValue("quranPageolorsIndex")],
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),

                // if (getValue("selectedShareTypeIndex") == 0)
                Row(
                  children: [
                    Checkbox(
                      fillColor: MaterialStatePropertyAll(
                          primaryColors[getValue("quranPageolorsIndex")]),
                      checkColor:
                          backgroundColors[getValue("quranPageolorsIndex")],
                      value: getValue("addAppSlogan"),
                      onChanged: (newValue) {
                        updateValue("addAppSlogan", newValue);

                        setState(() {});
                        setstatter(() {});
                      },
                    ),
                    Text(
                      'addappname'.tr(),
                      style: TextStyle(
                        color: primaryColors[getValue("quranPageolorsIndex")],
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
                      checkColor:
                          backgroundColors[getValue("quranPageolorsIndex")],
                      value: getValue("addTafseer"),
                      onChanged: (newValue) {
                        updateValue("addTafseer", newValue);

                        setState(() {});
                        setstatter(() {});
                      },
                    ),
                    Text(
                      'addtafseer'.tr(),
                      style: TextStyle(
                        color: primaryColors[getValue("quranPageolorsIndex")],
                        fontSize: 16.0,
                      ),
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
                                  duration: const Duration(milliseconds: 150),
                                  backgroundColor: backgroundColor,
                                  context: context,
                                  builder: (builder) {
                                    return Directionality(
                                      textDirection: m.TextDirection.rtl,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .8,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                  itemCount: translationDataList
                                                      .length,
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
                                                              translationDataList[
                                                                      i]
                                                                  .url) {
                                                            if (File("${appDir!.path}/${translationDataList[i].typeText}.json")
                                                                    .existsSync() ||
                                                                i == 0 ||
                                                                i == 1) {
                                                              updateValue(
                                                                  "addTafseerValue",
                                                                  i);
                                                              setState(() {});
                                                              setstatter(() {});
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
                                                              // print(
                                                              //     'status $status   -> $status2');
                                                              if (status
                                                                      .isGranted &&
                                                                  status2
                                                                      .isGranted) {
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

                                                              await Dio().download(
                                                                  translationDataList[
                                                                          i]
                                                                      .url,
                                                                  "${appDir!.path}/${translationDataList[i].typeText}.json");
                                                            }
                                                            getTranslationData();
                                                            updateValue(
                                                                "addTafseerValue",
                                                                i);
                                                            setState(() {});
                                                            setstatter(() {});
                                                          }

                                                          setState(() {});

                                                          // setStatee(() {});
                                                          if (mounted) {
                                                            setstatter(() {});

                                                            Navigator.pop(
                                                                context);
                                                            setstatter(() {});
                                                          }
                                                          setstatter(() {});
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      18.0.w,
                                                                  vertical:
                                                                      2.h),
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
                                                                              i ==
                                                                                  1
                                                                          ? MfgLabs
                                                                              .hdd
                                                                          : File("${appDir!.path}/${translationDataList[i].typeText}.json").existsSync()
                                                                              ? Icons.done
                                                                              : Icons.cloud_download,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size:
                                                                          18.sp,
                                                                    )
                                                                  : const CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
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
                              width: MediaQuery.of(context).size.width * .7,
                              height: 40.h,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 14.0.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      color: secondaryColors[
                                          getValue("quranPageolorsIndex")],
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

                if (getValue("selectedShareTypeIndex") == 1)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: EasyContainer(
                        onTap: () async {
                          if (getValue("selectedShareTypeIndex") == 1) {
                            // print("sharing ");
                            List verses = [];
                            for (int i = firstVerse; i <= lastVerse; i++) {
                              verses.add(quran.getVerse(surahNumber, i,
                                  verseEndSymbol: true));
                            }
                            if (getValue("textWithoutDiacritics")) {
                              if (getValue("addTafseer")) {
                                String tafseer = "";
                                for (int verseNumber = firstVerse;
                                    verseNumber <= lastVerse;
                                    verseNumber++) {
                                  String verseTafseer =
                                      await translate.getVerseTranslation(
                                    surahNumber,
                                    verseNumber,
                                    translationDataList[
                                        getValue("addTafseerValue")],
                                  );
                                  tafseer = "$tafseer $verseTafseer";
                                }
                                Share.share(
                                  // "",
                                  "{${removeDiacritics(verses.join(''))}} [${quran.getSurahNameArabic(surahNumber)}: $firstVerse : $lastVerse]\n\n${removeHtmlTags(removeDiacritics(tafseer))}\n\n${getValue("addAppSlogan") ? "Shared with Skoon - faithful companion" : ""}",
                                  // "text/plain"
                                );
                              } else {
                                Share.share(
                                  // "",
                                  "{${removeDiacritics(verses.join(''))}} [${quran.getSurahNameArabic(surahNumber)}: $firstVerse : $lastVerse]${getValue("addAppSlogan") ? "Shared with Skoon - faithful companion" : ""}",
                                  // "text/plain"
                                );
                              }
                            } else {
                              if (getValue("addTafseer")) {
                                String tafseer = "";
                                for (int verseNumber = firstVerse;
                                    verseNumber <= lastVerse;
                                    verseNumber++) {
                                  String cTafseer =
                                      await translate.getVerseTranslation(
                                          surahNumber,
                                          verseNumber,
                                          translationDataList[
                                              getValue("addTafseerValue")]);
                                  tafseer = "$tafseer $cTafseer ";
                                }
                                Share.share(
                                  // "",
                                  "{${verses.join('')}} [${quran.getSurahNameArabic(surahNumber)}: $firstVerse : $lastVerse]\n\n${translationDataList[getValue("addTafseerValue")].typeTextInRelatedLanguage}:\n${removeHtmlTags(tafseer)}\n\n${getValue("addAppSlogan") ? "Shared with Skoon" : ""}",
                                  // "text/plain"
                                );
                              } else {
                                Share.share(
                                  // "",
                                  "{${verses.join('')}} [${quran.getSurahNameArabic(surahNumber)}: $firstVerse : $lastVerse]${getValue("addAppSlogan") ? "Shared with Skoon" : ""}",
                                  // "text/plain"
                                );
                              }
                            }
                          }
                        },
                        color: primaryColors[getValue("quranPageolorsIndex")],
                        child: Text(
                          "astext".tr(),
                          style: TextStyle(
                              color: backgroundColors[
                                  getValue("quranPageolorsIndex")]),
                        )),
                  ),
                if (getValue("selectedShareTypeIndex") == 0)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: EasyContainer(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ScreenShotPreviewPage(
                                      index: index,
                                      isQCF: getValue("alignmentType") ==
                                          "pageview",
                                      surahNumber: surahNumber,
                                      jsonData: widget.jsonData,
                                      firstVerse: firstVerse,
                                      lastVerse: lastVerse)));
                        },
                        color: primaryColors[getValue("quranPageolorsIndex")],
                        child: Text(
                          "preview".tr(),
                          style: TextStyle(
                              color: backgroundColors[
                                  getValue("quranPageolorsIndex")]),
                        )),
                  )
              ],
            ),
          );
        });
      },
    );
  }

  Set<String> starredVerses = {};

  addStarredVerse(int surahNumber, int verseNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }

    final verseKey = "$surahNumber-$verseNumber"; // Create a unique key
    starredVerses.add(verseKey);

    final jsonData = json.encode(
        starredVerses.toList()); // Convert Set to List for serialization
    prefs.setString("starredVerses", jsonData);
    Fluttertoast.showToast(msg: "Added to Starred verses");
  }

  removeStarredVerse(int surahNumber, int verseNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }

    final verseKey = "$surahNumber-$verseNumber"; // Create the same unique key
    starredVerses.remove(verseKey);

    final jsonData = json.encode(
        starredVerses.toList()); // Convert Set to List for serialization
    prefs.setString("starredVerses", jsonData);
    Fluttertoast.showToast(msg: "Removed from Starred verses");
  }

  bool isVerseStarred(int surahNumber, int verseNumber) {
    final verseKey = "$surahNumber-$verseNumber";
    return starredVerses.contains(verseKey);
  }

  bool isDownloading = false;
  Future<void> downloadAndCacheSuraAudio(
      String suraName, int totalVerses, suraNumber, reciterIdentifier) async {
    setState(() {
      isDownloading = true;
    });

    final dio = Dio();
    final appDir = await getTemporaryDirectory();
    final ffmpeg = FlutterFFmpeg();

    final fullSuraFilePath =
        "${appDir.path}-$reciterIdentifier-${suraName.replaceAll(" ", "")}.mp3";

    // Check if the full sura file already exists
    if (File(fullSuraFilePath).existsSync()) {
      // print('Full sura audio file already cached: $fullSuraFilePath');
    } else {
      Fluttertoast.showToast(msg: "Downloading..");
      final List<String> audioFilePaths = [];
      List verseNumberAndDuration = [];
      var startDuration = 0.0;

      for (int verse = 1; verse <= totalVerses; verse++) {
        final fileName =
            '$reciterIdentifier-${suraName.replaceAll(" ", "")}-$verse.mp3';
        final filePath = '${appDir.path}/$fileName';
        // print(filePath);
        // Check if the file already exists in the cache
        if (File(filePath).existsSync()) {
          // print('Audio file already cached: $filePath');
        } else {
          final audioUrl = quran.getAudioURLByVerse(suraNumber, verse,
              reciterIdentifier); // Replace with the actual audio URL
          try {
            await dio.download(audioUrl, filePath);
            // print('Audio file downloaded and cached: $filePath');
            final metadata = await MetadataRetriever.fromFile(File(filePath));
            verseNumberAndDuration.add({
              "verseNumber": verse,
              "startDuration": startDuration,
              "endDuration": startDuration + ((metadata.trackDuration!))
            });
            startDuration = startDuration + ((metadata.trackDuration!));
          } catch (e) {
            // print('Error downloading and caching audio: $e');
          }
        }

        audioFilePaths.add(filePath);
      }
      // print(verseNumberAndDuration);
      String jsonString = json.encode(verseNumberAndDuration);

      updateValue(
          "$reciterIdentifier-${suraName.replaceAll(" ", "")}-durations",
          jsonString.toString());

      String inputOptions =
          audioFilePaths.map((filePath) => "-i $filePath").join(" ");
      String cmd =
          "$inputOptions -filter_complex 'concat=n=${audioFilePaths.length}:v=0:a=1[a]' -map '[a]' -codec:a libmp3lame -qscale:a 2 $fullSuraFilePath";

      final int resultCode = await ffmpeg.execute(cmd);

      if (resultCode == 0) {
        // print('Full sura audio file combined successfully: $fullSuraFilePath');
        Fluttertoast.showToast(msg: "Done...");
      } else {
        // print(
        // 'Error combining audio files: FFmpeg returned error code $resultCode');
      }
    }

    // // Generate JSON file with durations for the full sura audio
    // final duration = await getAudioDuration(fullSuraFilePath);
    // final verseDurations = List.generate(totalVerses, (verse) {
    //   return {'verse': verse + 1, 'duration': duration / totalVerses};
    // });

    // final jsonFilePath = '${appDir.path}/$reciterIdentifier/${suraName.trim()}/verse_durations.json';
    // File(jsonFilePath).writeAsString(jsonEncode(verseDurations));

    // print('JSON file with verse durations for the full sura audio generated: $jsonFilePath');
  }

  // Future<double> getAudioDuration(String filePath) async {
  //   final ffmpeg = FlutterFFmpeg();
  //   final result =
  //       await ffmpeg.executeWithArguments(['-i', filePath, '-f', 'null', '-']);
  //   final durationMatch =
  //       RegExp(r"Duration: ([\d:.]+)").firstMatch(result.toString());

  //   if (durationMatch != null) {
  //     final durationString = durationMatch.group(1);
  //     final List<String> timeComponents = durationString!.split(':');
  //     if (timeComponents.length == 3) {
  //       final hours = int.parse(timeComponents[0]);
  //       final minutes = int.parse(timeComponents[1]);
  //       final seconds = double.parse(timeComponents[2]);
  //       return hours * 3600 + minutes * 60 + seconds;
  //     }
  //   }

  //   return 0.0; // Return 0 if duration extraction fails
  // }
}

class Result {
  bool includesQuarter;
  int index;
  int hizbIndex;
  int quarterIndex;

  Result(this.includesQuarter, this.index, this.hizbIndex, this.quarterIndex);
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 0.8,
      );
}

class ScrollListener extends ChangeNotifier {
  double bottom = 0;
  double _last = 0;

  ScrollListener.initialise(ScrollController controller, [double height = 56]) {
    controller.addListener(() {
      final current = controller.offset;
      bottom += _last - current;
      if (bottom <= -height) bottom = -height;
      if (bottom >= 0) bottom = 0;
      _last = current;
      if (bottom <= 0 && bottom >= -height) notifyListeners();
    });
  }
}

class WidgetSpanWrapper extends StatefulWidget {
  const WidgetSpanWrapper({super.key, required this.child});

  final Widget child;

  @override
  _WidgetSpanWrapperState createState() => _WidgetSpanWrapperState();
}

class _WidgetSpanWrapperState extends State<WidgetSpanWrapper> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: widget.child,
    );
  }
}
