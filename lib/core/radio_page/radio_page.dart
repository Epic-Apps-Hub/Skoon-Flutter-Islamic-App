import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
// import 'package:flutter_radio_player/flutter_radio_player.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:radio_player/radio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  bool isLoading = true;
  var radiosData;
  getAndStoreRadioData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response response;

    try {
      if (context.locale.languageCode == "ms") {
        response =
            await Dio().get('http://mp3quran.net/api/v3/radios?language=eng');
      } else {
        response = await Dio().get(
            'http://mp3quran.net/api/v3/radios?language=${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}');
      }
      if (response.data != null) {
        final jsonData = json.encode(response.data['radios']);
        prefs.setString(
            "radios-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
            jsonData);
      }
    } catch (error) {
      print('Error while storing data: $error');
    }
  }

  List starredRadios = [];

  Future<void> fetchRadios() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString(
              "radios-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
          null) {
        await getAndStoreRadioData();
      }
      final jsonData = prefs.getString(
          "radios-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");

      if (jsonData != null) {
        final data = json.decode(jsonData) as List<dynamic>;
        starredRadios = json.decode(getValue("starredRadios"));
        setState(() {
          radiosData = data;
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error while fetching data: $error');
    }
  }

  bool isPlaying = false;
  List<String>? metadata;

  @override
  void initState() {
    radioPlayer.stateStream.listen((value) {
      if (mounted) {
        setState(() {
          isPlaying = value;
        });
      }
    });

    radioPlayer.metadataStream.listen((value) {
      if (mounted) {
        setState(() {
          metadata = value;
        });
      }
    });
    fetchRadios(); // TODO: implement initState
    super.initState();
  }

  filterData(keyword) async {
    await fetchRadios();
    radiosData = radiosData.where((element) {
      final elementName = element["name"].toString().toLowerCase();
      final searchValue = keyword.toString().toLowerCase();
      return elementName.startsWith(searchValue) ||
          elementName.contains(searchValue);
    }).toList();
    setState(() {});
  }

  int indexPlaying = -1;
  bool isShowingStarred = false;
  bool isSearching = false;
  RadioPlayer radioPlayer = RadioPlayer();
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          getValue("darkMode") ? quranPagesColorDark : quranPagesColorLight,
      appBar: AppBar(
        elevation: 0,
        actions: [
          // if (isSearching == false)
          IconButton(
              onPressed: () {
                if (isSearching) {
                  fetchRadios();
                }
                setState(() {
                  isSearching = !isSearching;
                });
              },
              icon: Icon(isSearching ? Icons.close : Icons.search)),

          if (isSearching == false)
            IconButton(
                onPressed: () {
                  if (isShowingStarred == false) {
                    radiosData = radiosData
                        .where(
                            (element) => starredRadios.contains(element["id"]))
                        .toList();
                  } else {
                    fetchRadios();
                  }
                  setState(() {
                    isShowingStarred = !isShowingStarred;
                  });
                },
                icon: Icon(
                  isShowingStarred ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ))
        ],
        centerTitle: true,
        // leading: Padding(

        backgroundColor:
            getValue("darkMode") ? darkModeSecondaryColor : blueColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: isSearching
            ? TextField(
                style: TextStyle(
                    color: getValue("darkMode")
                        ? Colors.white.withOpacity(.87)
                        : Colors.black87),
                decoration: InputDecoration(
                    hintText: "Search radios",
                    hintStyle: TextStyle(
                        color: getValue("darkMode")
                            ? Colors.white.withOpacity(.87)
                            : Colors.black87)),
                onChanged: ((value) {
                  filterData(
                    value,
                  );
                }),
              )
            : Text(
                "radios".tr(),
                style: const TextStyle(
                  fontFamily: "cairo",
                ),
              ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: darkPrimaryColor,
              ),
            )
          : ListView.builder(
              itemCount: radiosData.length,
              itemBuilder: (itemBuilder, i) {
                return EasyContainer(
                  onTap: () async {
                    if (indexPlaying == i) {
                      await radioPlayer.stop();
                      if (mounted) {
                        setState(() {
                          indexPlaying = -1;
                        });
                      }
                    } else {
                      await radioPlayer.stop();
                      await radioPlayer.setChannel(
                          title: radiosData[i]["name"],
                          url: radiosData[i]["url"],
                          imagePath: "assets/images/quran.png");
                      await radioPlayer.play();
                      if (mounted) {
                        setState(() {
                          indexPlaying = i;
                        });
                      }
                    }

                    // print(metadata);
                  },
                  borderRadius: 16.r,
                  color: getValue("darkMode")
                      ? darkModeSecondaryColor
                      : quranPagesColorLight,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(radiosData[i]["name"],
                            style: TextStyle(
                                color: getValue("darkMode")
                                    ? Colors.white.withOpacity(.87)
                                    : Colors.black.withOpacity(.87))),
                        SizedBox(
                          width: 20.w,
                        ),
                        if (indexPlaying == i)
                          LottieBuilder.asset("assets/images/playing.json",
                              width: 50.w),
                        if (indexPlaying == i)
                          Icon(
                            Icons.pause,
                            color: getValue("darkMode")
                                ? Colors.white.withOpacity(.87)
                                : Colors.black.withOpacity(.87),
                          ),
                        IconButton(
                            onPressed: () {
                              if (starredRadios.contains(radiosData[i]["id"])) {
                                starredRadios.remove(radiosData[i]["id"]);
                                updateValue("starredRadios",
                                    json.encode(starredRadios));
                              } else {
                                starredRadios.add(radiosData[i]["id"]);
                                updateValue("starredRadios",
                                    json.encode(starredRadios));
                              }
                              setState(() {});
                            },
                            icon: Icon(
                              starredRadios.contains(radiosData[i]["id"])
                                  ? Icons.star
                                  : Icons.star_border,
                              color: getValue("darkMode")
                                  ? Colors.white.withOpacity(.87)
                                  : Colors.black.withOpacity(.87),
                            ))
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
