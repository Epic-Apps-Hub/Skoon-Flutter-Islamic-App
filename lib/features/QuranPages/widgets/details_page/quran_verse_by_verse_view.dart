import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/blocs/bloc/quran_page_player_bloc.dart';
import 'package:nabd/features/home.dart';
import 'package:nabd/features/QuranPages/helpers/convertNumberToAr.dart';
import 'package:nabd/features/QuranPages/helpers/translation/get_translation_data.dart'
    as get_translation_data;
import 'package:nabd/features/QuranPages/widgets/bismallah.dart';
import 'package:nabd/features/QuranPages/widgets/header_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class QuranVerseByVerseView extends StatefulWidget {
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Function(int) onPageChanged;
  final List bookmarks;
  final dynamic jsonData;
  final bool shouldHighlightText;
  final dynamic highlightVerse;
  final Function(int, int, int) onShowAyahOptions;
  final List translationDataList;
  final Map dataOfCurrentTranslation;
  final bool Function(int, int) isVerseStarred;
  final VoidCallback onBack;

  const QuranVerseByVerseView({
    Key? key,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.onPageChanged,
    required this.bookmarks,
    required this.jsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
    required this.onShowAyahOptions,
    required this.translationDataList,
    required this.dataOfCurrentTranslation,
    required this.isVerseStarred,
    required this.onBack,
  }) : super(key: key);

  @override
  State<QuranVerseByVerseView> createState() => _QuranVerseByVerseViewState();
}

class _QuranVerseByVerseViewState extends State<QuranVerseByVerseView> {
  String selectedSpan = "";
  List<GlobalKey> richTextKeys = List.generate(
    604,
    (_) => GlobalKey(),
  );

  var isDownloading; // Can be bool or url string based on legacy code
  Directory? appDir;

  @override
  void initState() {
    super.initState();
    _initDir();
  }

  _initDir() async {
    appDir = await getTemporaryDirectory();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColors[getValue("quranPageolorsIndex")],
      body: Stack(
        children: [
          ScrollablePositionedList.separated(
            itemCount: quran.totalPagesCount + 1,
            separatorBuilder: (context, index) {
              return Container();
            },
            itemScrollController: widget.itemScrollController,
            initialScrollIndex: getValue("lastRead"),
            itemPositionsListener: widget.itemPositionsListener,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(height: 0);
              }

              return BlocBuilder<QuranPagePlayerBloc, QuranPagePlayerState>(
                bloc: qurapPagePlayerBloc,
                builder: (context, state) {
                  // Common logic for rendering text spans
                  List<InlineSpan> buildSpans(
                      Map e, bool isPlaying, Map? currentVersePlaying) {
                    List<InlineSpan> spans = [];
                    for (var i = e["start"]; i <= e["end"]; i++) {
                      if (i == 1) {
                        spans.add(WidgetSpan(
                            child:
                                HeaderWidget(e: e, jsonData: widget.jsonData)));
                        if (index != 187 && index != 1) {
                          spans.add(WidgetSpan(
                              child: Basmallah(
                                  index: getValue("quranPageolorsIndex"))));
                        }
                        if (index == 187 || index == 1) {
                          spans.add(WidgetSpan(child: Container(height: 10.h)));
                        }
                      }

                      bool isHighlighted = isPlaying &&
                          (currentVersePlaying != null &&
                              i == currentVersePlaying["verseNumber"] &&
                              e["surah"] ==
                                  (state is QuranPagePlayerPlaying
                                      ? state.suraNumber
                                      : -1));

                      spans.add(TextSpan(
                          recognizer: LongPressGestureRecognizer()
                            ..onLongPress = () {
                              widget.onShowAyahOptions(index, e["surah"], i);
                            }
                            ..onLongPressDown = (_) {
                              setState(() {
                                selectedSpan = " ${e["surah"]}$i";
                              });
                            }
                            ..onLongPressUp = () {
                              setState(() {
                                selectedSpan = "";
                              });
                            }
                            ..onLongPressCancel = () => setState(() {
                                  selectedSpan = "";
                                }),
                          text: quran.getVerse(e["surah"], i),
                          style: TextStyle(
                              color: primaryColors[
                                  getValue("quranPageolorsIndex")],
                              fontSize:
                                  getValue("verseByVerseFontSize").toDouble(),
                              fontFamily: getValue("selectedFontFamily"),
                              backgroundColor: isHighlighted
                                  ? highlightColors[getValue("quranPageolorsIndex")]
                                      .withValues(alpha: .28)
                                  : (widget.bookmarks.any((b) =>
                                          b["suraNumber"] == e["surah"] &&
                                          b["verseNumber"] == i)
                                      ? Color(int.parse("0x${widget.bookmarks.firstWhere((b) => b["suraNumber"] == e["surah"] && b["verseNumber"] == i)["color"]}"))
                                          .withValues(alpha: .19)
                                      : widget.shouldHighlightText &&
                                              quran.getVerse(e["surah"], i) ==
                                                  widget.highlightVerse
                                          ? highlightColors[getValue(
                                                  "quranPageolorsIndex")]
                                              .withValues(alpha: .25)
                                          : selectedSpan == " ${e["surah"]}$i"
                                              ? highlightColors[getValue(
                                                      "quranPageolorsIndex")]
                                                  .withValues(alpha: .25)
                                              : Colors.transparent))));

                      spans.add(TextSpan(
                          text: " ${convertToArabicNumber((i).toString())} ",
                          style: TextStyle(
                              fontSize: 24.sp,
                              color: widget.isVerseStarred(e["surah"], i)
                                  ? Colors.amber
                                  : secondaryColors[
                                      getValue("quranPageolorsIndex")],
                              fontFamily:
                                  "KFGQPC Uthmanic Script HAFS Regular")));

                      if (widget.bookmarks.any((b) =>
                          b["suraNumber"] == e["surah"] &&
                          b["verseNumber"] == i)) {
                        spans.add(WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.bookmark,
                                color: Color(int.parse(
                                    "0x${widget.bookmarks.firstWhere((b) => b["suraNumber"] == e["surah"] && b["verseNumber"] == i)["color"]}")))));
                      }

                      spans.add(WidgetSpan(
                          child: Divider(
                              color: Colors.grey.withValues(alpha: .2))));

                      spans.add(WidgetSpan(
                          child: SizedBox(
                              width: double.infinity,
                              child: Directionality(
                                  textDirection: widget
                                              .translationDataList[getValue(
                                                  "indexOfTranslationInVerseByVerse")]
                                              .typeInNativeLanguage ==
                                          "العربية"
                                      ? m.TextDirection.rtl
                                      : m.TextDirection.ltr,
                                  child: Builder(builder: (context) {
                                    String translation = get_translation_data
                                        .getVerseTranslationForVerseByVerse(
                                            widget.dataOfCurrentTranslation,
                                            e["surah"],
                                            i,
                                            widget.translationDataList[getValue(
                                                "indexOfTranslationInVerseByVerse")]);
                                    if (translation.contains(">")) {
                                      return Html(data: translation, style: {
                                        '*': Style(
                                            fontFamily: 'cairo',
                                            fontSize: FontSize(14.sp),
                                            lineHeight: LineHeight(1.7.sp))
                                      });
                                    } else {
                                      return Text(translation,
                                          style: TextStyle(
                                              color: primaryColors[getValue(
                                                  "quranPageolorsIndex")],
                                              fontFamily: widget
                                                          .translationDataList[
                                                              getValue(
                                                                      "indexOfTranslationInVerseByVerse") ??
                                                                  0]
                                                          .typeInNativeLanguage ==
                                                      "العربية"
                                                  ? "cairo"
                                                  : "roboto",
                                              fontSize: 14.sp));
                                    }
                                  })))));

                      spans.add(WidgetSpan(
                          child: Divider(
                              height: 15.h,
                              color:
                                  primaryColors[getValue("quranPageolorsIndex")]
                                      .withValues(alpha: .3))));
                    }
                    return spans;
                  }

                  Widget buildContent(Map? currentVersePlaying) {
                    return VisibilityDetector(
                      key: Key(index.toString()),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 1) {
                          widget.onPageChanged(index);
                        }
                      },
                      child: Column(
                        children: [
                          Directionality(
                              textDirection: m.TextDirection.rtl,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0.w, vertical: 26.h),
                                  child: SizedBox(
                                      width: double.infinity,
                                      child: RichText(
                                          key: richTextKeys[index - 1],
                                          textDirection: m.TextDirection.rtl,
                                          textAlign: TextAlign.right,
                                          text: TextSpan(
                                              locale: const Locale("ar"),
                                              children: quran
                                                  .getPageData(index)
                                                  .expand((e) {
                                                return buildSpans(
                                                    e,
                                                    currentVersePlaying != null,
                                                    currentVersePlaying);
                                              }).toList()))))),
                          const SizedBox(height: 20),
                          _buildTranslationSelector(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }

                  if (state is QuranPagePlayerPlaying) {
                    return StreamBuilder<Duration?>(
                        stream: state.audioPlayerStream,
                        builder: (context, snapshot) {
                          var currentVersePlaying;
                          if (snapshot.hasData) {
                            final currentDuration =
                                snapshot.data!.inMilliseconds;
                            if (state.durations.isNotEmpty &&
                                currentDuration !=
                                    state.durations.last["endDuration"]) {
                              try {
                                currentVersePlaying = state.durations
                                    .firstWhere((el) =>
                                        el["startDuration"] <=
                                            currentDuration &&
                                        currentDuration <= el["endDuration"]);
                              } catch (e) {}
                            }
                          }
                          return buildContent(currentVersePlaying);
                        });
                  }

                  return buildContent(null);
                },
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 28.0.h),
            child: Container(
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
                            onPressed: widget.onBack,
                            icon: Icon(Icons.arrow_back_ios,
                                size: 24.sp,
                                color: primaryColors[
                                    getValue("quranPageolorsIndex")]))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTranslationSelector() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.0.w),
        child: EasyContainer(
            color: Colors.transparent,
            elevation: 0,
            onTap: () {
              showMaterialModalBottomSheet(
                  enableDrag: true,
                  backgroundColor:
                      backgroundColors[getValue("quranPageolorsIndex")],
                  context: context,
                  builder: (context) {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height * .7,
                        child: SingleChildScrollView(
                            child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Select Translation",
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColors[
                                          getValue("quranPageolorsIndex")]))),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * .65,
                              child: ListView.builder(
                                  itemCount: widget.translationDataList.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: EasyContainer(
                                            color: secondaryColors[getValue(
                                                    "quranPageolorsIndex")]
                                                .withValues(alpha: .1),
                                            onTap: () async {
                                              if (widget.translationDataList[i]
                                                      .url ==
                                                  null) {
                                                updateValue(
                                                    "indexOfTranslationInVerseByVerse",
                                                    i);
                                                setstatter(() {});
                                                Navigator.pop(context);
                                              } else {
                                                // Check if file exists
                                                bool exists = File(
                                                        "${appDir!.path}/${widget.translationDataList[i].typeText}.json")
                                                    .existsSync();
                                                if (exists) {
                                                  updateValue(
                                                      "indexOfTranslationInVerseByVerse",
                                                      i);
                                                  setstatter(() {});
                                                  Navigator.pop(context);
                                                } else {
                                                  // Download logic
                                                  setState(() {
                                                    isDownloading = widget
                                                        .translationDataList[i]
                                                        .url;
                                                  });
                                                  try {
                                                    await Dio().download(
                                                        widget
                                                            .translationDataList[
                                                                i]
                                                            .url,
                                                        "${appDir!.path}/${widget.translationDataList[i].typeText}.json");
                                                    setState(() {
                                                      isDownloading = false;
                                                      updateValue(
                                                          "indexOfTranslationInVerseByVerse",
                                                          i);
                                                    });
                                                    Navigator.pop(context);
                                                  } catch (e) {
                                                    setState(() {
                                                      isDownloading = false;
                                                    });
                                                  }
                                                }
                                              }
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 18.0.w,
                                                    vertical: 2.h),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          widget
                                                              .translationDataList[
                                                                  i]
                                                              .typeTextInRelatedLanguage,
                                                          style: TextStyle(
                                                              color: primaryColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")]
                                                                  .withValues(
                                                                      alpha:
                                                                          .9),
                                                              fontSize: 14.sp)),
                                                      isDownloading !=
                                                              widget
                                                                  .translationDataList[
                                                                      i]
                                                                  .url
                                                          ? Icon(
                                                              (i == 0 || i == 1)
                                                                  ? MfgLabs.hdd
                                                                  : File("${appDir!.path}/${widget.translationDataList[i].typeText}.json")
                                                                          .existsSync()
                                                                      ? Icons
                                                                          .done
                                                                      : Icons
                                                                          .cloud_download,
                                                              color: Colors
                                                                  .blueAccent,
                                                              size: 18.sp)
                                                          : const CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors
                                                                  .blueAccent)
                                                    ]))));
                                  }))
                        ])));
                  });
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 40.h,
                decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0.w),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              widget
                                  .translationDataList[getValue(
                                          "indexOfTranslationInVerseByVerse") ??
                                      0]
                                  .typeTextInRelatedLanguage,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: widget
                                              .translationDataList[getValue(
                                                      "indexOfTranslationInVerseByVerse") ??
                                                  0]
                                              .typeInNativeLanguage ==
                                          "العربية"
                                      ? "cairo"
                                      : "roboto")),
                          Icon(FontAwesome.ellipsis,
                              size: 24.sp,
                              color: secondaryColors[
                                  getValue("quranPageolorsIndex")])
                        ])))));
  }

  void setstatter(VoidCallback fn) {
    if (mounted) setState(fn);
  }
}
