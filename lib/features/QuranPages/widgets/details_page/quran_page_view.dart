import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/features/home.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/blocs/bloc/quran_page_player_bloc.dart';
import 'package:nabd/features/QuranPages/widgets/bismallah.dart';
import 'package:nabd/features/QuranPages/widgets/header_widget.dart';
import 'package:nabd/features/QuranPages/widgets/details_page/quran_page_header.dart';
import 'package:quran/quran.dart' as quran;

class QuranPageView extends StatefulWidget {
  final PageController pageController;
  final Function(int) onPageChanged;
  final Function() onBack;
  final Function() onSettings;
  final Function(int, int, int) onShowAyahOptions;
  final List bookmarks;
  final dynamic jsonData;
  final dynamic quarterJsonData;
  final bool shouldHighlightText;
  final dynamic highlightVerse;
  final int index;

  const QuranPageView({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
    required this.onBack,
    required this.onSettings,
    required this.onShowAyahOptions,
    required this.bookmarks,
    required this.jsonData,
    required this.quarterJsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
    required this.index,
  }) : super(key: key);

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  String selectedSpan = "";
  List<GlobalKey> richTextKeys = List.generate(
    604,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_pageControllerScrollListener);
  }

  void _pageControllerScrollListener() {
    if (widget.pageController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    }
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_pageControllerScrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      onPageChanged: (a) {
        setState(() {
          selectedSpan = "";
        });
        widget.onPageChanged(a);
      },
      controller: widget.pageController,
      reverse: context.locale.languageCode == "ar" ? false : true,
      itemCount: quran.totalPagesCount + 1,
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
              color: backgroundColors[getValue("quranPageolorsIndex")],
              boxShadow: [
                if (isEvenPage)
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(-5, 0),
                  ),
              ],
              border: Border.fromBorderSide(BorderSide(
                  color: primaryColors[getValue("quranPageolorsIndex")]
                      .withValues(alpha: .05)))),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(right: 12.0.w, left: 12.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      QuranPageHeader(
                        index: index,
                        jsonData: widget.jsonData,
                        quarterJsonData: widget.quarterJsonData,
                        onBack: widget.onBack,
                        onSettings: widget.onSettings,
                      ),
                      BlocBuilder<QuranPagePlayerBloc, QuranPagePlayerState>(
                          bloc: qurapPagePlayerBloc,
                          builder: (context, state) {
                            if (state is QuranPagePlayerInitial ||
                                state is QuranPagePlayerIdle) {
                              return Directionality(
                                  textDirection: m.TextDirection.rtl,
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: RichText(
                                        key: richTextKeys[index - 1],
                                        textDirection: m.TextDirection.rtl,
                                        textAlign: (index == 1 ||
                                                index == 2 ||
                                                index > 570)
                                            ? TextAlign.center
                                            : TextAlign.center,
                                        softWrap: true,
                                        locale: const Locale("ar"),
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: primaryColors[getValue(
                                                "quranPageolorsIndex")],
                                            fontSize:
                                                getValue("pageViewFontSize")
                                                    .toDouble(),
                                            fontFamily:
                                                getValue("selectedFontFamily"),
                                          ),
                                          children: quran
                                              .getPageData(index)
                                              .expand((e) {
                                            List<InlineSpan> spans = [];
                                            for (var i = e["start"];
                                                i <= e["end"];
                                                i++) {
                                              // Header
                                              if (i == 1) {
                                                spans.add(WidgetSpan(
                                                  child: HeaderWidget(
                                                      e: e,
                                                      jsonData:
                                                          widget.jsonData),
                                                ));
                                                if (index != 187 &&
                                                    index != 1) {
                                                  spans.add(WidgetSpan(
                                                    child: Basmallah(
                                                        index: getValue(
                                                            "quranPageolorsIndex")),
                                                  ));
                                                }
                                                if (index == 187) {
                                                  spans.add(WidgetSpan(
                                                    child: Container(
                                                      height: 10.h,
                                                    ),
                                                  ));
                                                }
                                              }

                                              // Verses
                                              spans.add(TextSpan(
                                                recognizer:
                                                    LongPressGestureRecognizer()
                                                      ..onLongPress = () {
                                                        widget
                                                            .onShowAyahOptions(
                                                                index,
                                                                e["surah"],
                                                                i);
                                                      }
                                                      ..onLongPressDown =
                                                          (details) {
                                                        setState(() {
                                                          selectedSpan =
                                                              " ${e["surah"]}$i";
                                                        });
                                                      }
                                                      ..onLongPressUp = () {
                                                        setState(() {
                                                          selectedSpan = "";
                                                        });
                                                      }
                                                      ..onLongPressCancel =
                                                          () => setState(() {
                                                                selectedSpan =
                                                                    "";
                                                              }),
                                                text: i == e["start"]
                                                    ? "${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                                                    : quran
                                                        .getVerseQCF(
                                                            e["surah"], i)
                                                        .replaceAll(' ', ''),
                                                style: TextStyle(
                                                  color: widget.bookmarks
                                                          .where((element) =>
                                                              element["suraNumber"] ==
                                                                  e["surah"] &&
                                                              element["verseNumber"] ==
                                                                  i)
                                                          .isNotEmpty
                                                      ? Color(int.parse(
                                                          "0x${widget.bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                      : primaryColors[getValue(
                                                          "quranPageolorsIndex")],
                                                  height:
                                                      (index == 1 || index == 2)
                                                          ? 2.h
                                                          : 1.95.h,
                                                  letterSpacing: 0.w,
                                                  wordSpacing: 0,
                                                  fontFamily:
                                                      "QCF_P${index.toString().padLeft(3, "0")}",
                                                  fontSize: index == 1 ||
                                                          index == 2
                                                      ? 28.sp
                                                      : index == 145 ||
                                                              index == 201
                                                          ? index == 532 ||
                                                                  index == 533
                                                              ? 22.5.sp
                                                              : 22.4.sp
                                                          : 22.9.sp,
                                                  backgroundColor: widget
                                                          .shouldHighlightText
                                                      ? quran.getVerse(
                                                                  e["surah"],
                                                                  i) ==
                                                              widget
                                                                  .highlightVerse
                                                          ? highlightColors[
                                                                  getValue(
                                                                      "quranPageolorsIndex")]
                                                              .withValues(
                                                                  alpha: .25)
                                                          : selectedSpan ==
                                                                  " ${e["surah"]}$i"
                                                              ? highlightColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")]
                                                                  .withValues(
                                                                      alpha:
                                                                          .25)
                                                              : Colors
                                                                  .transparent
                                                      : selectedSpan ==
                                                              " ${e["surah"]}$i"
                                                          ? highlightColors[
                                                                  getValue(
                                                                      "quranPageolorsIndex")]
                                                              .withValues(
                                                                  alpha: .25)
                                                          : Colors.transparent,
                                                ),
                                                children: const <TextSpan>[],
                                              ));
                                            }
                                            return spans;
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ));
                            } else if (state is QuranPagePlayerPlaying) {
                              return Directionality(
                                textDirection: m.TextDirection.rtl,
                                child: StreamBuilder<Duration?>(
                                    stream: state.audioPlayerStream,
                                    builder: (context, snapshot) {
                                      var currentVersePlaying;
                                      if (snapshot.hasData) {
                                        final currentDuration =
                                            snapshot.data!.inMilliseconds;
                                        if (currentDuration !=
                                            state.durations[
                                                    state.durations.length - 1]
                                                ["endDuration"]) {
                                          currentVersePlaying =
                                              state.durations.where((element) {
                                            return (element["startDuration"] <=
                                                    currentDuration &&
                                                currentDuration <=
                                                    element["endDuration"]);
                                          }).first;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: SizedBox(
                                              width: double.infinity,
                                              child: RichText(
                                                key: richTextKeys[index - 1],
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
                                                    color: primaryColors[getValue(
                                                        "quranPageolorsIndex")],
                                                    fontSize: getValue(
                                                            "pageViewFontSize")
                                                        .toDouble(),
                                                    fontFamily: getValue(
                                                        "selectedFontFamily"),
                                                  ),
                                                  locale: const Locale("ar"),
                                                  children: quran
                                                      .getPageData(index)
                                                      .expand((e) {
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
                                                        if (index == 187) {
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
                                                                widget.onShowAyahOptions(
                                                                    index,
                                                                    e["surah"],
                                                                    i);
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
                                                              }
                                                              ..onLongPressCancel =
                                                                  () =>
                                                                      setState(
                                                                          () {
                                                                        selectedSpan =
                                                                            "";
                                                                      }),
                                                        text: quran
                                                            .getVerseQCF(
                                                                e["surah"], i)
                                                            .replaceAll(
                                                                ' ', ''),
                                                        style: TextStyle(
                                                          color: primaryColors[
                                                              getValue(
                                                                  "quranPageolorsIndex")],
                                                          height: (index == 1 ||
                                                                  index == 2)
                                                              ? 2.h
                                                              : 1.95.h,
                                                          letterSpacing: 0.w,
                                                          wordSpacing: 0,
                                                          fontFamily:
                                                              "QCF_P${index.toString().padLeft(3, "0")}",
                                                          fontSize: 22.9.sp,
                                                          backgroundColor: widget
                                                                  .bookmarks
                                                                  .where((element) =>
                                                                      element["suraNumber"] == e["surah"] &&
                                                                      element["verseNumber"] ==
                                                                          i)
                                                                  .isNotEmpty
                                                              ? Color(int.parse(
                                                                      "0x${widget.bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                  .withValues(
                                                                      alpha:
                                                                          .19)
                                                              : (i == currentVersePlaying["verseNumber"] &&
                                                                      (e["surah"] ==
                                                                          state
                                                                              .suraNumber))
                                                                  ? highlightColors[getValue("quranPageolorsIndex")]
                                                                      .withValues(
                                                                          alpha:
                                                                              .28)
                                                                  : widget.shouldHighlightText
                                                                      ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withValues(alpha: .25)
                                                                          : selectedSpan == " ${e["surah"]}$i"
                                                                              ? highlightColors[getValue("quranPageolorsIndex")].withValues(alpha: .25)
                                                                              : Colors.transparent
                                                                      : selectedSpan == " ${e["surah"]}$i"
                                                                          ? highlightColors[getValue("quranPageolorsIndex")].withValues(alpha: .25)
                                                                          : Colors.transparent,
                                                        ),
                                                        children: const [],
                                                      ));
                                                      if (widget.bookmarks
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
                                                                      "0x${widget.bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
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
                                          textDirection: m.TextDirection.rtl,
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: SizedBox(
                                                width: double.infinity,
                                                child: RichText(
                                                  key: richTextKeys[index - 1],
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
                                                      color: primaryColors[getValue(
                                                          "quranPageolorsIndex")],
                                                      fontSize: getValue(
                                                              "pageViewFontSize")
                                                          .toDouble(),
                                                      fontFamily: getValue(
                                                          "selectedFontFamily"),
                                                    ),
                                                    locale: const Locale("ar"),
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
                                                          if (index == 187) {
                                                            spans.add(WidgetSpan(
                                                                child: Container(
                                                              height: 10.h,
                                                            )));
                                                          }
                                                        }

                                                        // Verses
                                                        spans.add(TextSpan(
                                                          locale: const Locale(
                                                              "ar"),
                                                          recognizer:
                                                              LongPressGestureRecognizer()
                                                                ..onLongPress =
                                                                    () {
                                                                  widget.onShowAyahOptions(
                                                                      index,
                                                                      e["surah"],
                                                                      i);
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
                                                                }
                                                                ..onLongPressCancel =
                                                                    () =>
                                                                        setState(
                                                                            () {
                                                                          selectedSpan =
                                                                              "";
                                                                        }),
                                                          text: quran
                                                              .getVerseQCF(
                                                                  e["surah"], i)
                                                              .replaceAll(
                                                                  ' ', ''),
                                                          style: TextStyle(
                                                            color: primaryColors[
                                                                getValue(
                                                                    "quranPageolorsIndex")],
                                                            height: (index ==
                                                                        1 ||
                                                                    index == 2)
                                                                ? 2.h
                                                                : 1.95.h,
                                                            letterSpacing: 0.w,
                                                            fontFamily:
                                                                "QCF_P${index.toString().padLeft(3, "0")}",
                                                            fontSize: 22.9.sp,
                                                            backgroundColor: widget
                                                                    .bookmarks
                                                                    .where((element) =>
                                                                        element["suraNumber"] ==
                                                                            e[
                                                                                "surah"] &&
                                                                        element["verseNumber"] ==
                                                                            i)
                                                                    .isNotEmpty
                                                                ? Color(int.parse(
                                                                        "0x${widget.bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                    .withValues(
                                                                        alpha:
                                                                            .19)
                                                                : widget
                                                                        .shouldHighlightText
                                                                    ? quran.getVerse(e["surah"], i) ==
                                                                            widget
                                                                                .highlightVerse
                                                                        ? highlightColors[getValue("quranPageolorsIndex")]
                                                                            .withValues(alpha: .25)
                                                                        : selectedSpan == " ${e["surah"]}$i"
                                                                            ? highlightColors[getValue("quranPageolorsIndex")].withValues(alpha: .25)
                                                                            : Colors.transparent
                                                                    : selectedSpan == " ${e["surah"]}$i"
                                                                        ? highlightColors[getValue("quranPageolorsIndex")].withValues(alpha: .25)
                                                                        : Colors.transparent,
                                                          ),
                                                          children: const [],
                                                        ));
                                                        if (widget.bookmarks
                                                            .where((element) =>
                                                                element["suraNumber"] ==
                                                                    e[
                                                                        "surah"] &&
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
                                                                        "0x${widget.bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
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
        );
      },
    );
  }
}
