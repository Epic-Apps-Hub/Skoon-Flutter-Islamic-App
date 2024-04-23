import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nabd/Core/audiopage/models/reciter.dart';
import 'package:nabd/Core/home.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:nabd/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart';
part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  PlayerBlocBloc() : super(PlayerBlocInitial()) {
    AudioPlayer? audioPlayer;

    on<PlayerBlocEvent>((event, emit) async {
      // ignore: unnecessary_null_comparison
      if (event is StartPlaying) {
        if (audioPlayer != null) {
          audioPlayer!.dispose();
        }
        audioPlayer = AudioPlayer();
        int nextMediaId = 0;
        List<String> surahNumbers = event.moshaf.surahList.split(',');
        final appDir = Directory("/storage/emulated/0/Download/skoon/");

        if (surahNumbers.any((element) {
          if (File(
                  "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(element))}.mp3")
              .existsSync()) {
            return true;
          } else {
            return false;
          }
        })) {
          PermissionStatus status = await Permission.storage.request();
          //PermissionStatus status1 = await Permission.accessMediaLocation.request();
          PermissionStatus status2 =
              await Permission.manageExternalStorage.request();
          print('status $status   -> $status2');
          if (status.isGranted && status2.isGranted) {
            print(true);
          } else if (status.isPermanentlyDenied ||
              status2.isPermanentlyDenied) {
            await openAppSettings();
          } else if (status.isDenied) {
            print('Permission Denied');
          }
        }
        List reciterLinks = surahNumbers.map((e) {
          if (File(
                  "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(e))}.mp3")
              .existsSync()) {
            var link = {
              "link": Uri.file(
                  "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(e))}.mp3"),
              "suraNumber": e
            };
            return link;
          } else {
            var link = {
              "link": Uri.parse(
                      "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3")
                  .replace(scheme: 'http'),
              "suraNumber": e
            };
            return link;
          }
        }).toList();

        var playList = reciterLinks.map((e) {
          // print( e["suraNumber"]);
          return AudioSource.uri(
            e["link"],
            tag: MediaItem(
              id: '${nextMediaId++}',
              album: "${event.reciter.name}",
              title: event.jsonData
                  .where((element) =>
                      element["id"].toString() == e["suraNumber"].toString())
                  .first["name"]
                  .toString(),
              artUri: Uri.parse(
                  "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            ),
          );
        }).toList();
        String currentSuraNumber = "";
        if (event.suraNumber == -1) {
          currentSuraNumber = surahNumbers[0];
        }
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());

        // Listen to errors during playback.
        audioPlayer!.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
        audioPlayer!.setLoopMode(LoopMode.off);
        try {
          // var originalUri = Uri.parse(
          //     "${event.moshaf.server}/${currentSuraNumber.toString().padLeft(3, "0")}.mp3");
          // var newUri = originalUri.replace(scheme: 'http');

          // print(surahNumbers.length);

          await audioPlayer!.setAudioSource(
              initialIndex: event.initialIndex,
              // initialIndex: 2//event.suraNumber == -1 ? int.parse(currentSuraNumber) : event.suraNumber
              // ,
              // initialPosition: Duration.zero,

              ConcatenatingAudioSource(children: playList));
        } catch (e) {
          // Catch load errors: 404, invalid url ...
          print("Error loading playlist: $e");
          // print(stackTrace);
        }
        audioPlayer!.play();

        BlocProvider.of<PlayerBarBloc>(event.buildContext).add(ShowBarEvent());
        emit(PlayerBlocPlaying(
            moshaf: event.moshaf,
            reciter: event.reciter,
            suraNumber: event.suraNumber == -1
                ? int.parse(currentSuraNumber)
                : event.suraNumber,
            // suraName: event.suraName,
            jsonData: event.jsonData,
            audioPlayer: audioPlayer!,
            surahNumbers: surahNumbers,
            playList: playList));
      } else if (event is DownloadSurah) {
        final dio = Dio();
        final appDir = Directory("/storage/emulated/0/Download/skoon/");
        // final ffmpeg = FlutterFFmpeg();
        PermissionStatus status = await Permission.storage.request();
        //PermissionStatus status1 = await Permission.accessMediaLocation.request();
        PermissionStatus status2 =
            await Permission.manageExternalStorage.request();
        print('status $status   -> $status2');
        if (status.isGranted && status2.isGranted) {
          print(true);
        } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
          await openAppSettings();
        } else if (status.isDenied) {
          print('Permission Denied');
        }
        final fullSuraFilePath =
            "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(event.suraNumber))}.mp3";

        // Check if the full sura file already exists
        if (File(fullSuraFilePath).existsSync()) {
          print('Full sura audio file already cached: $fullSuraFilePath');
        } else {
          try {
            await dio.download(event.url, fullSuraFilePath);
          } catch (e) {
            print(e);
          } // updateValue(
          //     "downloadedSurahs",
          //     json.decode(getValue("downloadedSurahs").add(
          //         "${event.suraName}-${event.moshafId}-${event.reciterName}")));
        }
      } else if (event is DownloadAllSurahs) {
        List<String> surahNumbers = event.moshaf.surahList.split(',');

        List reciterLinks = surahNumbers
            .map((e) => {
                  "link":
                      "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3",
                  "suraNumber": e
                })
            .toList();

        final dio = Dio();
        final appDir = Directory("/storage/emulated/0/Download/skoon/");
        // final ffmpeg = FlutterFFmpeg();
        PermissionStatus status = await Permission.storage.request();
        //PermissionStatus status1 = await Permission.accessMediaLocation.request();
        PermissionStatus status2 =
            await Permission.manageExternalStorage.request();
        print('status $status   -> $status2');
        if (status.isGranted && status2.isGranted) {
          print(true);
        } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
          await openAppSettings();
        } else if (status.isDenied) {
          print('Permission Denied');
        }

        for (var suraLink in reciterLinks) {
          final fullSuraFilePath =
              "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(suraLink["suraNumber"]))}.mp3";

          // Check if the full sura file already exists
          if (File(fullSuraFilePath).existsSync()) {
            print('Full sura audio file already cached: $fullSuraFilePath');
          } else {
            try {
              await dio.download(suraLink["link"], fullSuraFilePath);
            } catch (e) {
              print(e);
            }
          }
        }
      } else if (event is ClosePlayerEvent) {
        if (audioPlayer != null){ audioPlayer!.dispose();}
        emit(PlayerBlocInitial());
      } else if (event is PausePlayer) {
        emit(PlayerBlocPaused());
      }
    });
  }
}
