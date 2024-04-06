import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:nabd/Core/audiopage/models/reciter.dart';
import 'package:nabd/blocs/bloc/player_bloc_bloc.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/blocs/bloc/quran_page_player_bloc.dart';
import 'package:nabd/core/audiopage/player/player_bar.dart';
import 'package:nabd/core/home.dart';

import 'package:quran/quran.dart' as quran;

class RecitersSurahListPage extends StatefulWidget {
  Reciter reciter;
  Moshaf mushaf;
  var jsonData;

  RecitersSurahListPage(
      {super.key,
      required this.reciter,
      required this.mushaf,
      required this.jsonData});

  @override
  State<RecitersSurahListPage> createState() => _RecitersSurahListPageState();
}

class _RecitersSurahListPageState extends State<RecitersSurahListPage> {
  // List<String> get surahNumbers => widget.mushaf.surahList.split(',');
  late List surahs;

  addSuraNames() {
    surahs = [];
    filteredSurahs = [];
    setState(() {
      surahs = widget.mushaf.surahList
          .split(',')
          .map((e) {
                  print(e);
                  print(widget.jsonData);
print(widget.jsonData.where((element)=>element["id"].toString()==e.toString()));
            return {
                "surahNumber": e,
                "suraName": widget.jsonData.where((element)=>element["id"].toString()==e.toString()).first["name"]
              };})
          .toList();
    });

    print(surahs.length);
  }

  List favoriteSurahs = [];
  filterFavoritesOnly() {
    favoriteSurahs = [];
    // print(favoriteSurahList);
// print(favoriteSurahList.contains(
//           "${widget.reciter.name}${widget.mushaf.name}${4- 1}"));
    for (var element in surahs) {
      if (favoriteSurahList.contains(
          "${widget.reciter.name}${widget.mushaf.name}${int.parse(element["surahNumber"])}"
              .trim())) {
        // print("true");
        favoriteSurahs.add(element);
      }
    }
    setState(() {});
    // print(surahs.length);
    // surahs = surahs.where((element) {
    //   // print(element);
    //   return favoriteSurahList.contains(
    //       "${widget.reciter.name}${widget.mushaf.name}${element["surahNumber"]}");
    // }).toList();

    setState(() {});
  }

  filterDownloadsOnly() {
    favoriteSurahs = [];
    // print(favoriteSurahList);
// print(favoriteSurahList.contains(
//           "${widget.reciter.name}${widget.mushaf.name}${4- 1}"));
    for (var element in surahs) {
      if (File(
              "${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(element["surahNumber"]))}.mp3")
          .existsSync()) {
        favoriteSurahs.add(element);
      }
    }
    setState(() {});
    // print(surahs.length);
    // surahs = surahs.where((element) {
    //   // print(element);
    //   return favoriteSurahList.contains(
    //       "${widget.reciter.name}${widget.mushaf.name}${element["surahNumber"]}");
    // }).toList();

    setState(() {});
  }

  addFavorites() {
    favoriteSurahList = json.decode(getValue("favoriteSurahList"));
    setState(() {});
  }

  Future storePhotoUrl() async {
    final url =
        'https://www.googleapis.com/customsearch/v1?key=AIzaSyCR7ttKFGB4dG5MDJI3ygqiESjpWmKePrY&cx=f7b7aaf5b2f0e47e0&q=القارئ ${widget.reciter.name}&searchType=image';
    if (getValue("${widget.reciter.name} photo url") == null) {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        print("photo url added");
        updateValue("${widget.reciter.name} photo url",
            response.data["items"][0]['link']);
        setState(() {});
      } else {
        throw Exception('Failed to load images');
      }
    }
  }

  List filteredSurahs = [];

  filterSurahs(value) {
    addSuraNames();
    setState(() {
      filteredSurahs = surahs
          .where((element) =>
              quran.normalise(element["suraName"]).contains(value))
          .toList();
    });
  }

  // String photoUrl = "";
  @override
  void initState() {
    addFavorites();
    addSuraNames();
    super.initState();
    storePhotoUrl();
  }

  List favoriteSurahList = [];

  var selectedMode = "all";
  var searchQuery = "";
  final appDir = Directory("/storage/emulated/0/Download/skoon/");

  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return  Stack(
        children: [
          Scaffold(extendBodyBehindAppBar: true,
            backgroundColor:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
            appBar: AppBar(
              backgroundColor:  getValue("darkMode")?darkModeSecondaryColor.withOpacity(.9): blueColor,
              elevation: 0,
              title: Text(
                "${widget.reciter.name} - ${widget.mushaf.name}",
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              automaticallyImplyLeading: true,
              bottom: PreferredSize(
                preferredSize: Size(screenSize.width, screenSize.height * .1),
                child: Padding(
                  padding:  const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Container(
                            decoration: BoxDecoration(
                                color:  const Color(0xffF6F6F6),
                                borderRadius: BorderRadius.circular(5.r)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0.w),
                                    child: TextField(
                                      controller: textEditingController,
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });

                                        filterSurahs(value);
                                        if (value == "") {
                                          addSuraNames();
                                        }
                                        // filterReciters(
                                        //     value); // Call the filter method when the text changes
                                      },
                                      decoration: InputDecoration(
                                        hintText: "searchBysura".tr(),
                                        hintStyle: TextStyle(
                                            fontFamily: "cairo",
                                            fontSize: 14.sp,
                                            color:  const Color.fromARGB(
                                                73, 0, 0, 0)),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:  const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // fetchReciters();
                                      // textEditingController.text = "";
                                      textEditingController.clear();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      setState(() {
                                        searchQuery = "";
                                      });
                                      addSuraNames();
                                    },
                                    child: Icon(
                                        searchQuery == ""
                                            ? FontAwesome.search
                                            : Icons.close,
                                        color:
                                             const Color.fromARGB(73, 0, 0, 0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                enableDrag: true,
                                isDismissible: true,
                                showDragHandle: true,
                                builder: ((context) {
                                  return StatefulBuilder(builder: (context, s) {
                                      return Container(
                                        child: ListView(
                                          children: [
                                            EasyContainer(
                                              elevation: 0,
                                              padding: 0,
                                              margin: 0,
                                              onTap: () async {
                                                if (selectedMode != "all") {
                                                  // addSuraNames();
                                                  setState(() {
                                                    selectedMode = "all";
                                                  }); //       s((){});

                                                  // await Future.delayed(
                                                  //      Duration(milliseconds: 200));
                                                  Navigator.pop(context);

                                                  // print(favoriteRecitersList.length);

                                                  // itemScrollController.scrollTo(
                                                  //     index: 0,
                                                  //     duration:  Duration(
                                                  //         seconds: 1));
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.0.h),
                                                child: SizedBox(
                                                  height: 45.h,
                                                  // color: Colors.red,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .all_inclusive_rounded,
                                                        color: selectedMode ==
                                                                "all"
                                                            ? blueColor
                                                            : Colors.grey,
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                       Text("all".tr()),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Icon(
                                                              selectedMode ==
                                                                      "all"
                                                                  ? FontAwesome
                                                                      .dot_circled
                                                                  : FontAwesome
                                                                      .circle_empty,
                                                              color: selectedMode ==
                                                                      "all"
                                                                  ? blueColor
                                                                  : Colors.grey,
                                                              size: 20.sp,
                                                            ),
                                                            SizedBox(
                                                              width: 40.w,
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 15.h,
                                              color: Colors.grey,
                                            ),
                                            EasyContainer(
                                              elevation: 0,
                                              padding: 0,
                                              margin: 0,
                                              onTap: () async {
                                                // filteredReciters = [];

                                                setState(() {
                                                  selectedMode = "favorite";
                                                });
                                                filterFavoritesOnly();
                                                // s((){});
                                                // await Future.delayed(
                                                //      Duration(milliseconds: 200));
                                                Navigator.pop(context);

                                                // itemScrollController.scrollTo(
                                                //     index: 0,
                                                //     duration:  Duration(
                                                //         seconds: 1));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.0.h),
                                                child: SizedBox(
                                                  height: 45.h,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                      ),
                                                      Icon(
                                                        Icons.favorite,
                                                        color: selectedMode ==
                                                                "favorite"
                                                            ? blueColor
                                                            : Colors.grey,
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Text("favorites".tr()),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Icon(
                                                              selectedMode ==
                                                                      "favorite"
                                                                  ? FontAwesome
                                                                      .dot_circled
                                                                  : FontAwesome
                                                                      .circle_empty,
                                                              color: selectedMode ==
                                                                      "favorite"
                                                                  ? blueColor
                                                                  : Colors.grey,
                                                              size: 20.sp,
                                                            ),
                                                            SizedBox(
                                                              width: 40.w,
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 15.h,
                                              color: Colors.grey,
                                            ),
                                            EasyContainer(
                                              elevation: 0,
                                              padding: 0,
                                              margin: 0,
                                              onTap: () async {
                                                // filteredReciters = [];
                                                filterDownloadsOnly();

                                                setState(() {
                                                  selectedMode = "downloads";
                                                });
                                                // s((){});
                                                // await Future.delayed(
                                                //      Duration(milliseconds: 200));
                                                Navigator.pop(context);

                                                // itemScrollController.scrollTo(
                                                //     index: 0,
                                                //     duration:  Duration(
                                                //         seconds: 1));
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.0.h),
                                                child: SizedBox(
                                                  height: 45.h,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                      ),
                                                      Icon(
                                                        Icons.download,
                                                        color: selectedMode ==
                                                                "downloads"
                                                            ? blueColor
                                                            : Colors.grey,
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Text("downloaded".tr()),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Icon(
                                                              selectedMode ==
                                                                      "downloads"
                                                                  ? FontAwesome
                                                                      .dot_circled
                                                                  : FontAwesome
                                                                      .circle_empty,
                                                              color: selectedMode ==
                                                                      "downloads"
                                                                  ? blueColor
                                                                  : Colors.grey,
                                                              size: 20.sp,
                                                            ),
                                                            SizedBox(
                                                              width: 40.w,
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }));
                          },
                          icon:  const Icon(FontAwesome.filter,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding:  const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: blueColor,
                    backgroundImage: CachedNetworkImageProvider(
                        "${getValue("${widget.reciter.name} photo url")}"),
                  ),
                )
                // Transform(
                //     transform: Matrix4.rotationY(math.pi),
                //     alignment: Alignment.center,
                //     child: IconButton(
                //         onPressed: () {
                //           Navigator.pop(context);
                //         },
                //         icon:  Icon(
                //           Entypo.logout,
                //           color: Colors.white,
                //         )))
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            body: Container(
              child: ListView.separated(
                physics:  const BouncingScrollPhysics(),
                separatorBuilder: (context, index) =>  const Divider(),
                itemCount: filteredSurahs.isNotEmpty
                    ? filteredSurahs.length
                    : selectedMode == "all"
                        ? surahs.length
                        : favoriteSurahs.length,
                itemBuilder: (BuildContext context, int index) {
                  dynamic surah = filteredSurahs.isNotEmpty
                      ? filteredSurahs[index]
                      : selectedMode == "all"
                          ? surahs[index]
                          : favoriteSurahs[index];
                  return EasyContainer(
                    borderRadius: 12.r,
                    elevation: 0,
                    padding: 0,
                    margin: 0,
                    onTap: () async {
                      //print("suraNumber"+ favoriteSurahs[index]["surahNumber"]);
                      if (qurapPagePlayerBloc.state is QuranPagePlayerPlaying) {
                        await showDialog(
                            context: context,
                            builder: (a) {
                              return AlertDialog(
                                content:  Text("closeplayer".tr()),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child:  Text("cancel".tr())),
                                  TextButton(
                                      onPressed: () {
                                        qurapPagePlayerBloc
                                            .add(KillPlayerEvent());
                                        Navigator.pop(context);
                                      },
                                      child:  Text("close".tr())),
                                ],
                              );
                            });
                      }
                
                      print(surah);
                      playerPageBloc.add(StartPlaying(buildContext: context,
                          moshaf: widget.mushaf,
                          reciter: widget.reciter,
                          suraNumber: int.parse(selectedMode == "all"
                              ? surah["surahNumber"]
                              : surah["surahNumber"]),
                          initialIndex:   surahs.indexOf(surah),
                          jsonData: widget.jsonData));
                    },
                    color: getValue("darkMode")?darkModeSecondaryColor.withOpacity(.9): Colors.white,
                    child: ListTile(
                        leading: Image.asset(
                          "assets/images/${quran.getPlaceOfRevelation(int.parse(selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"])) == "makkah" || quran.getPlaceOfRevelation(int.parse(surah["surahNumber"])) == "Makkah" ? "Makkah" : "Madinah"}.png",
                          height: 25.h,
                          width: 25.w,
                        ),
                        trailing: SizedBox(
                          width: 140.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (qurapPagePlayerBloc.state
                                      is QuranPagePlayerPlaying) {
                                    await showDialog(
                                        context: context,
                                        builder: (a) {
                                          return AlertDialog(
                                            content:  Text(
                                                "closeplayer".tr()),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text("cancel".tr())),
                                              TextButton(
                                                  onPressed: () {
                                                    qurapPagePlayerBloc
                                                        .add(KillPlayerEvent());
                                                    Navigator.pop(context);
                                                  },
                                                  child:
                                                       Text("close".tr())),
                                            ],
                                          );
                                        });
                                  }
                                  playerPageBloc.add(StartPlaying(
                                      moshaf: widget.mushaf,
                                      reciter: widget.reciter,buildContext: context,
                                      suraNumber: int.parse(
                                          selectedMode == "all"
                                              ? surah["surahNumber"]
                                              : surah["surahNumber"]),
                                      initialIndex: selectedMode == "all"
                                          ? index
                                          : surahs.indexOf(surah),
                                      jsonData: widget.jsonData));
                                },
                                icon: Icon(
                                  Icons.play_arrow,
                                  size: 24.sp,
                                ),
                                color: blueColor,
                              ),
                              IconButton(
                                onPressed: () {
                                  //               "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3"
                                  // .replace(scheme: 'http');

                                  if (File(
                                          "${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"]))}.mp3")
                                      .existsSync()) {
                                  } else {
                                    playerPageBloc.add(DownloadSurah(
                                        reciter: widget.reciter,
                                        moshaf: widget.mushaf,
                                        suraNumber: selectedMode == "all"
                                            ? surah["surahNumber"]
                                            : surah["surahNumber"],
                                        url:
                                            "${widget.mushaf.server}/${(selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"]).padLeft(3, "0")}.mp3"));
                                  } // .replace(scheme: 'http')));
                                },
                                icon: Icon(
                                    File("${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"]))}.mp3")
                                            .existsSync()
                                        ? Icons.download_done
                                        : Icons.download,
                                    size: 24.sp),
                                color: orangeColor,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (favoriteSurahList.contains(
                                      "${widget.reciter.name}${widget.mushaf.name}${selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"]}")) {
                                    favoriteSurahList.remove(
                                        "${widget.reciter.name}${widget.mushaf.name}${selectedMode == "all" ? surahs[index]["surahNumber"] : favoriteSurahs[index]["surahNumber"]}"
                                            .trim());
                                    updateValue("favoriteSurahList",
                                        json.encode(favoriteSurahList));
                                  } else {
                                    favoriteSurahList.add(
                                        "${widget.reciter.name}${widget.mushaf.name}${selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"]}"
                                            .trim());
                                    updateValue("favoriteSurahList",
                                        json.encode(favoriteSurahList));
                                  }

                                  setState(() {});
                                },
                                icon: Icon(
                                    favoriteSurahList.contains(
                                            "${widget.reciter.name}${widget.mushaf.name}${selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"]}"
                                                .trim())
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 24.sp),
                                color: Colors.redAccent,
                              )
                            ],
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              "${ context.locale.languageCode=="ar"? widget.jsonData[(int.parse(selectedMode == "all" ? surah["surahNumber"] : surah["surahNumber"])) - 1]["name"]:surah["suraName"]}",
                              style: TextStyle(
                                  fontFamily:context.locale.languageCode=="ar"? "qaloon":"roboto", fontSize:context.locale.languageCode=="ar"? 22.sp:17.sp,
                                 color:  getValue("darkMode")?Colors.white.withOpacity(.9):Colors.black87
                                  ),
                            ),
                          ],
                        )),
                  );
                },
              ),
            ),
          ),
   ],
    
    );
  }
}
