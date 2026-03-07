import 'dart:async';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:nabd/features/QuranPages/helpers/translation/translationdata.dart';
import 'package:nabd/features/QuranPages/helpers/quran_page_utils.dart';
import 'package:nabd/features/QuranPages/widgets/details_page/quran_page_view.dart';
import 'package:nabd/features/QuranPages/widgets/details_page/quran_vertical_view.dart';
import 'package:nabd/features/QuranPages/widgets/details_page/quran_verse_by_verse_view.dart';
import 'package:nabd/features/QuranPages/helpers/quran_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:quran/quran.dart' as quran;

import 'package:nabd/features/QuranPages/widgets/details_page/ayah_options_sheet.dart';

import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';


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
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

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
    return QuranPageUtils.getTotalCharacters(stringList);
  }

  checkIfAyahIsAStartOfSura() {}
  String? swipeDirection;
  late PageController _pageController;

  var english = RegExp(r'[a-zA-Z]');

  String selectedSpan = "";

  ScreenshotController screenshotController = ScreenshotController();

  double currentHeight = 2.0;
  // double currentWordSpacing = 0.0;
  double currentLetterSpacing = 0.0;

  List<GlobalKey> richTextKeys = List.generate(
    604, // Replace with the number of pages in your PageView
    (_) => GlobalKey(),
  );
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * .5,
      ),
      backgroundColor: Colors.transparent,
      body: Builder(builder: (context) {
        if (getValue("alignmentType") == "pageview") {
          return QuranPageView(
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedSpan = "";
              });
              this.index = index;
              updateValue("lastRead", index);
            },
            onBack: () => Navigator.pop(context),
            onSettings: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
            onShowAyahOptions: (p, s, v) => showAyahOptionsSheet(p, s, v),
            bookmarks: bookmarks,
            jsonData: widget.jsonData,
            quarterJsonData: widget.quarterJsonData,
            shouldHighlightText: widget.shouldHighlightText,
            highlightVerse: widget.highlightVerse,
            index: index,
          );
        } else if (getValue("alignmentType") == "verticalview") {
          return QuranVerticalView(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            onPageChanged: (i) {
              index = i;
              updateValue("lastRead", i);
            },
            bookmarks: bookmarks,
            jsonData: widget.jsonData,
            quarterJsonData: widget.quarterJsonData,
            shouldHighlightText: widget.shouldHighlightText,
            highlightVerse: widget.highlightVerse,
            onShowAyahOptions: (p, s, v) => showAyahOptionsSheet(p, s, v),
          );
        } else {
          return QuranVerseByVerseView(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            onPageChanged: (i) {
              index = i;
              updateValue("lastRead", i);
            },
            bookmarks: bookmarks,
            jsonData: widget.jsonData,
            shouldHighlightText: widget.shouldHighlightText,
            highlightVerse: widget.highlightVerse,
            onShowAyahOptions: (p, s, v) => showAyahOptionsSheet(p, s, v),
            translationDataList: translationDataList,
            dataOfCurrentTranslation: dataOfCurrentTranslation,
            isVerseStarred: isVerseStarred,
            onBack: () => Navigator.pop(context),
          );
        }
      }),
    );
  }

  showAyahOptionsSheet(index, surahNumber, verseNumber) {
    AyahOptionsSheet.show(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      index: index,
      bookmarks: bookmarks,
      jsonData: widget.jsonData,
      onAddBookmark: (s, v) async {
        List<String> colorOptions = [
          "0xFF2196F3",
          "0xFFF44336",
          "0xFFE91E63",
          "0xFF9C27B0",
          "0xFF3F51B5"
        ];
        String selectedColor = colorOptions[0];
        bookmarks.add({
          "suraNumber": s,
          "verseNumber": v,
          "color": selectedColor.replaceAll("0x", "")
        });
        updateValue("bookmarks", json.encode(bookmarks));
        setState(() {});
      },
      onRemoveBookmark: (s, v) {
        bookmarks.removeWhere((element) =>
            element["suraNumber"] == s && element["verseNumber"] == v);
        updateValue("bookmarks", json.encode(bookmarks));
        setState(() {});
      },
      isVerseStarred: isVerseStarred,
      onToggleStar: (s, v) {
        if (isVerseStarred(s, v)) {
          removeStarredVerse(s, v);
        } else {
          addStarredVerse(s, v);
        }
        setState(() {});
      },
    );
  }

  bool showSuraHeader = true;
  bool addAppSlogan = true;

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
}
