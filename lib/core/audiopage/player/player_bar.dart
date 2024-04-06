import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nabd/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:nabd/blocs/bloc/player_bloc_bloc.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/home.dart';

import 'package:quran/quran.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  @override
  void initState() {
    addFavorites();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isMinimized) {
      return false;
    } else {
      BlocProvider.of<PlayerBarBloc>(context).add(MinimizeBarEvent());

      isMinimized = true;
    }
    return true;
  }

  List favoriteSurahList = [];
  addFavorites() {
    favoriteSurahList = json.decode(getValue("favoriteSurahList") ?? "[]");
    setState(() {});
  }

  final appDir = Directory("/storage/emulated/0/Download/skoon/");
  bool isPlaylistShown = false;
  bool isMinimized = true;
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Directionality(
        textDirection: m.TextDirection.ltr,
        child: BlocBuilder(
          bloc: playerPageBloc,
          builder: (context, state) {
            if (state is PlayerBlocPlaying) {
              return BlocBuilder<PlayerBarBloc, PlayerBarState>(
                bloc: BlocProvider.of<PlayerBarBloc>(context),
                builder: (context, statee) {
                  print(statee);
                  if (statee is PlayerBarHidden) {
                    return Positioned(
                        bottom: 25.h,
                        right: 25.w,
                        child: FadeInRight(
                          child: FadeInUp(
                            child: StreamBuilder(
                                stream: state.audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Opacity(
                                      opacity: .5,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: SpinPerfect(
                                          infinite: true,
                                          duration: const Duration(seconds: 7),
                                          animate: snapshot.data!.playing,
                                          child: GestureDetector(
                                            onTap: () {
                                              BlocProvider.of<PlayerBarBloc>(
                                                      context)
                                                  .add(ShowBarEvent());
                                            },
                                            child: Container(
                                              height: 45.h,
                                              width: 45.w,
                                              decoration:  BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
                                              ),
                                              child: Center(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                       getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
                                                  backgroundImage: const AssetImage(
                                                      "assets/images/quran.png"),
                                                  foregroundImage:
                                                      CachedNetworkImageProvider(
                                                    "${getValue("${state.reciter.name} photo url")}",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(height: 0,);
                                  }
                                }),
                          ),
                        ));
                  } else if (statee is PlayerBarVisible) {
                    if (statee.height == 60) {
                      isMinimized = true;
                    } else {
                      isMinimized = false;
                    }
                    return Positioned(
                      bottom: 0,
                      child: FadeInUp(
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              // if (statee.height == 60) {
                              BlocProvider.of<PlayerBarBloc>(context)
                                  .add(ExtendBarEvent());
                              // }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: statee.height == 60
                                  ? 60.h
                                  : (MediaQuery.of(context).size.height),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: statee.height == 60
                                      ? const m.Color.fromARGB(255, 82, 96, 175)
                                      : Colors.white,
                                  borderRadius: statee.height == 60
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(13),
                                          topRight: Radius.circular(13))
                                      : BorderRadius.zero),
                              child: statee.height == 60
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.0.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          StreamBuilder(
                                              stream: state.audioPlayer
                                                  .playerStateStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: SpinPerfect(
                                                      infinite: true,
                                                      duration: const Duration(
                                                          seconds: 7),
                                                      animate: snapshot
                                                          .data!.playing,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          BlocProvider.of<
                                                                      PlayerBarBloc>(
                                                                  context)
                                                              .add(
                                                                  ShowBarEvent());
                                                        },
                                                        child: Container(
                                                          height: 50.h,
                                                          width: 50.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color:
                                                                      darkPrimaryColor),
                                                          child: Center(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  darkPrimaryColor,
                                                              backgroundImage:
                                                                  const AssetImage(
                                                                      "assets/images/quran.png"),
                                                              foregroundImage:
                                                                  getValue("${state.reciter.name} photo url") !=
                                                                          null
                                                                      ? CachedNetworkImageProvider(
                                                                          "${getValue("${state.reciter.name} photo url")}",
                                                                        )
                                                                      : null,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              }),
                                          StreamBuilder(
                                              stream: state.audioPlayer
                                                  .playerStateStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      snapshot.data!.playing ==
                                                              true
                                                          ? state.audioPlayer
                                                              .pause()
                                                          : state.audioPlayer
                                                              .play();
                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 1.w)),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0.sp),
                                                          child: Icon(
                                                            snapshot.data!
                                                                        .playing ==
                                                                    true
                                                                ? Icons.pause
                                                                : Icons
                                                                    .play_arrow,
                                                            color: Colors.white,
                                                          ),
                                                        )),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              }),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          StreamBuilder<SequenceState?>(
                                              stream: state.audioPlayer
                                                  .sequenceStateStream,
                                              builder: (context, snapshot) {
                                                final statee = snapshot.data;
                                                if (statee?.sequence.isEmpty ??
                                                    true) {
                                                  return const SizedBox();
                                                }
                                                final metadata = statee!
                                                    .currentSource!
                                                    .tag as MediaItem;
                                                if (snapshot.hasData) {
                                                  return Text(
                                                      "${metadata.title} - " +
                                                          state.reciter.name,
                                                      textDirection:
                                                          m.TextDirection.rtl,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.sp,
                                                      ));
                                                } else {
                                                  return Container();
                                                }
                                              }),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              BlocProvider.of<PlayerBarBloc>(
                                                      context)
                                                  .add(HideBarEvent());
                                            },
                                            child: Container(
                                              // height: 30,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.w)),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.all(4.0.sp),
                                                  child: const Icon(
                                                    Icons.remove_red_eye,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          if (state.audioPlayer.playing ==
                                              false)
                                            GestureDetector(
                                              onTap: () {
                                                BlocProvider.of<PlayerBarBloc>(
                                                        context)
                                                    .add(CloseBarEvent());
                                                state.audioPlayer.pause();
                                                setState(() {});
                                              },
                                              child: Container(
                                                // height: 30,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.w)),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0.sp),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (state.audioPlayer.playing ==
                                              false)
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                        ],
                                      ),
                                    )
                                  : Material(
                                      color: darkPrimaryColor,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                opacity: .5,
                                                image: AssetImage(
                                                    "assets/images/framee.png"))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 35.h,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // SizedBox(
                                                  //   width: 12.w,
                                                  // ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12.0.h,
                                                        left: 12.w),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        BlocProvider.of<
                                                                    PlayerBarBloc>(
                                                                context)
                                                            .add(
                                                                MinimizeBarEvent());
                                                      },
                                                      icon: Icon(
                                                          LineariconsFree
                                                              .chevron_down,
                                                          size: 25.sp,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12.0.h,
                                                        left: 12.w),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          isPlaylistShown =
                                                              !isPlaylistShown;
                                                        });
                                                      },
                                                      icon: Icon(
                                                          Icons
                                                              .playlist_play_rounded,
                                                          size: 25.sp,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  // SizedBox(
                                                  //   width: 12.w,
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 35.h,
                                            ),
                                            // if (isPlaylistShown = false)
                                            Expanded(
                                              child:
                                                  StreamBuilder<SequenceState?>(
                                                stream: state.audioPlayer
                                                    .sequenceStateStream,
                                                builder: (context, snapshot) {
                                                  final statee = snapshot.data;
                                                  if (statee
                                                          ?.sequence.isEmpty ??
                                                      true) {
                                                    return const SizedBox();
                                                  }
                                                  final metadata = statee!
                                                      .currentSource!
                                                      .tag as MediaItem;
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(metadata.title,
                                                          textDirection: m
                                                              .TextDirection
                                                              .rtl,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 22.sp,
                                                          )),
                                                      Text(
                                                        textDirection:
                                                            m.TextDirection.rtl,
                                                        metadata.album!
                                                            .replaceAll(
                                                                "القارئ", ""),
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    .9)),
                                                      ),
                                                      SizedBox(
                                                        height: 30.h,
                                                      ),
                                                      StreamBuilder(
                                                          stream: state
                                                              .audioPlayer
                                                              .playerStateStream,
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        2.0),
                                                                child:
                                                                    SpinPerfect(
                                                                  infinite:
                                                                      true,
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              18),
                                                                  animate: snapshot
                                                                      .data!
                                                                      .playing,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      BlocProvider.of<PlayerBarBloc>(
                                                                              context)
                                                                          .add(
                                                                              ShowBarEvent());
                                                                    },
                                                                    child: Center(
                                                                        child: CircleAvatar(
                                                                            radius: isPlaylistShown == false ? 130.r : 60.r,
                                                                            foregroundImage: getValue("${metadata.album!.replaceAll("القارئ ", "")} photo url") != null
                                                                                ? CachedNetworkImageProvider(
                                                                                    getValue("${metadata.album!.replaceAll("القارئ ", "")} photo url"),
                                                                                  )
                                                                                : null,
                                                                            backgroundImage: CachedNetworkImageProvider(
                                                                              metadata.artUri.toString(),
                                                                            ))),
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return Container();
                                                            }
                                                          }),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            // if (isPlaylistShown = false)
                                            ControlButtons(state.audioPlayer),
                                            // if (isPlaylistShown == false)
                                            SizedBox(height: 30.0.h),
                                            // if (isPlaylistShown == true)
                                            StreamBuilder<Duration>(
                                              stream: state
                                                  .audioPlayer.positionStream,
                                              builder: (context, snapshot) {
                                                final positionData =
                                                    snapshot.data;
                                                if (snapshot.hasError) {
                                                  return Container();
                                                }
                                                if (snapshot.hasData == false) {
                                                  return Container(
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                }
                                                return Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 30.w,
                                                    ),
                                                    SizedBox(
                                                        child: Text(
                                                            textDirection: m
                                                                .TextDirection
                                                                .rtl,
                                                            formatDuration(
                                                                snapshot.data!),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white))),
                                                    Expanded(
                                                      child: SliderTheme(
                                                        data: SliderTheme.of(
                                                                context)
                                                            .copyWith(
                                                          activeTrackColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255), // Customize track color
                                                          inactiveTrackColor: Colors
                                                              .grey, // Customize inactive track color
                                                          thumbColor: Colors
                                                              .white, // Customize thumb color
                                                          overlayColor: Colors
                                                              .blue
                                                              .withAlpha(
                                                                  50), // Customize overlay color
                                                          thumbShape:
                                                              const RoundSliderThumbShape(
                                                                  enabledThumbRadius:
                                                                      10),
                                                          overlayShape:
                                                              const RoundSliderOverlayShape(
                                                                  overlayRadius:
                                                                      20),
                                                        ),
                                                        child: Slider(
                                                          value: snapshot
                                                              .data!.inSeconds
                                                              .toDouble(),
                                                          min: 0,
                                                          max: state
                                                              .audioPlayer
                                                              .duration!
                                                              .inSeconds
                                                              .toDouble(),
                                                          onChanged: (value) {
                                                            // Handle slider value change here
                                                            // Convert the double to an integer for seconds
                                                            int newSeconds =
                                                                value.toInt();
                                                            state.audioPlayer
                                                                .seek(Duration(
                                                                    seconds:
                                                                        newSeconds));
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        child: Text(
                                                      formatDuration(state
                                                          .audioPlayer
                                                          .duration!),
                                                      textDirection:
                                                          m.TextDirection.rtl,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    )),
                                                    SizedBox(
                                                      width: 30.w,
                                                    )
                                                  ],
                                                );
                                              },
                                            ),
                                            if (isPlaylistShown == false)
                                              SizedBox(height: 60.0.h),
                                            if (isPlaylistShown == false)
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 26.0.w),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        if (favoriteSurahList
                                                            .contains(
                                                                "${state.reciter.name}${state.moshaf.name}${state.audioPlayer.currentIndex! + 1}")) {
                                                          favoriteSurahList.remove(
                                                              "${state.reciter.name}${state.moshaf.name}${state.audioPlayer.currentIndex! + 1}"
                                                                  .trim());
                                                          updateValue(
                                                              "favoriteSurahList",
                                                              json.encode(
                                                                  favoriteSurahList));
                                                        } else {
                                                          favoriteSurahList.add(
                                                              "${state.reciter.name}${state.moshaf.name}${state.audioPlayer.currentIndex! + 1}"
                                                                  .trim());
                                                          updateValue(
                                                              "favoriteSurahList",
                                                              json.encode(
                                                                  favoriteSurahList));
                                                        }

                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                          favoriteSurahList.contains(
                                                                  "${state.reciter.name}${state.moshaf.name}${int.parse(state.surahNumbers[state.audioPlayer.currentIndex!])}"
                                                                      .trim())
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          size: 24.sp),
                                                      color: Colors.white,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        //               "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3"
                                                        // .replace(scheme: 'http');

                                                        if (File(
                                                                "${appDir.path}${state.reciter.name}-${state.moshaf.id}-${getSurahNameArabic(int.parse(state.surahNumbers[state.audioPlayer.currentIndex!]))}.mp3")
                                                            .existsSync()) {
                                                        } else {
                                                          playerPageBloc.add(DownloadSurah(
                                                              reciter:
                                                                  state.reciter,
                                                              moshaf:
                                                                  state.moshaf,
                                                              suraNumber: state
                                                                      .surahNumbers[
                                                                  state
                                                                      .audioPlayer
                                                                      .currentIndex!],
                                                              url:
                                                                  "${state.moshaf.server}/${state.surahNumbers[state.audioPlayer.currentIndex!].padLeft(3, "0")}.mp3"));
                                                        } // .replace(scheme: 'http')));
                                                      },
                                                      icon: Icon(
                                                          File("${appDir.path}${state.reciter.name}-${state.moshaf.id}-${getSurahNameArabic(int.parse(state.surahNumbers[state.audioPlayer.currentIndex!]))}.mp3")
                                                                  .existsSync()
                                                              ? Icons
                                                                  .download_done
                                                              : Icons.download,
                                                          size: 24.sp),
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (isPlaylistShown == false)
                                              SizedBox(height: 15.0.h),
                                            if (isPlaylistShown == true)
                                              SizedBox(height: 20.0.h),

                                            if (isPlaylistShown == true)
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0.w),
                                                child: Row(
                                                  children: [
                                                    StreamBuilder<LoopMode>(
                                                      stream: state.audioPlayer
                                                          .loopModeStream,
                                                      builder:
                                                          (context, snapshot) {
                                                        final loopMode =
                                                            snapshot.data ??
                                                                LoopMode.off;
                                                        var icons = [
                                                          Icon(Icons.repeat,
                                                              size: 27.sp,
                                                              color:
                                                                  Colors.grey),
                                                          Icon(Icons.repeat,
                                                              size: 27.sp,
                                                              color:
                                                                  Colors.white),
                                                          Icon(Icons.repeat_one,
                                                              size: 27.sp,
                                                              color:
                                                                  Colors.white),
                                                        ];
                                                        const cycleModes = [
                                                          LoopMode.off,
                                                          LoopMode.all,
                                                          LoopMode.one,
                                                        ];
                                                        final index = cycleModes
                                                            .indexOf(loopMode);
                                                        return IconButton(
                                                          icon: icons[index],
                                                          onPressed: () {
                                                            state.audioPlayer.setLoopMode(cycleModes[
                                                                (cycleModes.indexOf(
                                                                            loopMode) +
                                                                        1) %
                                                                    cycleModes
                                                                        .length]);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "قائمة التشغيل",
                                                        textDirection:
                                                            m.TextDirection.rtl,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17.sp,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    StreamBuilder<bool>(
                                                      stream: state.audioPlayer
                                                          .shuffleModeEnabledStream,
                                                      builder:
                                                          (context, snapshot) {
                                                        final shuffleModeEnabled =
                                                            snapshot.data ??
                                                                false;
                                                        return IconButton(
                                                          icon: shuffleModeEnabled
                                                              ? const Icon(
                                                                  Icons.shuffle,
                                                                  color: Colors
                                                                      .white)
                                                              : const Icon(
                                                                  Icons.shuffle,
                                                                  color: Colors
                                                                      .grey),
                                                          onPressed: () async {
                                                            final enable =
                                                                !shuffleModeEnabled;
                                                            if (enable) {
                                                              await state
                                                                  .audioPlayer
                                                                  .shuffle();
                                                            }
                                                            await state
                                                                .audioPlayer
                                                                .setShuffleModeEnabled(
                                                                    enable);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (isPlaylistShown == true)
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 600),
                                                height: isPlaylistShown
                                                    ? 240.0.h
                                                    : 50.h,
                                                child: MaterialApp(
                                                  //color:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
                                                  home: StreamBuilder<
                                                      SequenceState?>(
                                                    stream: state.audioPlayer
                                                        .sequenceStateStream,
                                                    builder:
                                                        (context, snapshot) {
                                                      final sequenceState =
                                                          snapshot.data;
                                                      final sequence =
                                                          sequenceState
                                                                  ?.sequence ??
                                                              [];
                                                      return ReorderableListView(
                                                        onReorder:
                                                            (int oldIndex,
                                                                int newIndex) {
                                                          if (oldIndex <
                                                              newIndex) {
                                                            newIndex--;
                                                          }
                                                          state.playList.move(
                                                              oldIndex,
                                                              newIndex);
                                                        },
                                                        children: [
                                                          for (var i = 0;
                                                              i <
                                                                  sequence
                                                                      .length;
                                                              i++)
                                                            Dismissible(
                                                              key: ValueKey(
                                                                  sequence[i]),
                                                              background:
                                                                  Container(
                                                                color: Colors
                                                                    .redAccent,
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child:
                                                                    const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              onDismissed:
                                                                  (dismissDirection) {
                                                                state.playList
                                                                    .removeAt(
                                                                        i);
                                                              },
                                                              child: Material(
                                                                color: i ==
                                                                        sequenceState!
                                                                            .currentIndex
                                                                    ? const m
                                                                        .Color.fromARGB(
                                                                        255,
                                                                        46,
                                                                        100,
                                                                        110)
                                                                    : darkPrimaryColor
                                                                        .withOpacity(
                                                                            .9),
                                                                child: ListTile(
                                                                  trailing:
                                                                      const Icon(
                                                                    Icons
                                                                        .reorder,
                                                                    color: Colors
                                                                        .white70,
                                                                  ),
                                                                  title: Text(
                                                                    sequence[i]
                                                                            .tag
                                                                            .title
                                                                        as String,
                                                                    textDirection: m
                                                                        .TextDirection
                                                                        .rtl,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  onTap: () {
                                                                    state.audioPlayer.seek(
                                                                        Duration
                                                                            .zero,
                                                                        index:
                                                                            i);
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),

                                            if (isPlaylistShown == false)
                                              GestureDetector(
                                                onTap: (() {
                                                  setState(() {
                                                    isPlaylistShown = true;
                                                  });
                                                }),
                                                child: FadeInUp(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 50.h,
                                                    decoration: BoxDecoration(
                                                        color: const m
                                                                .Color.fromARGB(
                                                                255,
                                                                82,
                                                                96,
                                                                175)
                                                            .withOpacity(.65)),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 10.w,
                                                        ),
                                                        Icon(
                                                          Icons.menu,
                                                          size: 28.sp,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 10.w,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "${state.audioPlayer.currentIndex! + 1}/${state.audioPlayer.sequence!.length}",
                                                              textDirection: m
                                                                  .TextDirection
                                                                  .rtl,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16.sp),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 200.w,
                                                        ),
                                                        Text(
                                                          "${state.audioPlayer.sequence![state.audioPlayer.currentIndex!].tag.title}",
                                                          textDirection: m
                                                              .TextDirection
                                                              .rtl,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18.sp),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (statee is PlayerBarClosed) {
                    print("object2222222");
                    return Container(height: 0,);
                  }
                  return Container(height: 0,);
                },
              );
            }
            return Container(height: 0,);
          },
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // IconButton(
        //   icon: const Icon(Icons.volume_up),
        //   onPressed: () {
        //     showSliderDialog(
        //       context: context,
        //       title: "Adjust volume",
        //       divisions: 10,
        //       min: 0.0,
        //       max: 1.0,
        //       stream: player.volumeStream,
        //       onChanged: player.setVolume,
        //     );
        //   },
        // ),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return IconButton(
              onPressed: () {
                player.seek(Duration(seconds: positionData!.inSeconds - 10));
              },
              icon: Icon(
                Icons.fast_rewind,
                color: Colors.white,
                size: 32.sp,
              ),
            );
          },
        ),
        SizedBox(
          width: 8.w,
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: Icon(
              Icons.skip_previous,
              color: Colors.white,
              size: 32.sp,
            ),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 32.0.w,
                height: 32.h,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 32.sp,
                color: Colors.white,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 32.sp,
                color: Colors.white,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 32.sp,
                color: Colors.white,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices!.first),
              );
            }
          },
        ),
        SizedBox(
          width: 8.w,
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: Icon(
              Icons.skip_next,
              color: Colors.white,
              size: 32.sp,
            ),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return IconButton(
              onPressed: () {
                player.seek(Duration(seconds: positionData!.inSeconds + 10));
              },
              icon: Icon(
                Icons.fast_forward,
                color: Colors.white,
                size: 32.sp,
              ),
            );
          },
        ),
      ],
    );
  }
}

String formatDuration(Duration duration, {bool includeHours = true}) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  if (includeHours) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
