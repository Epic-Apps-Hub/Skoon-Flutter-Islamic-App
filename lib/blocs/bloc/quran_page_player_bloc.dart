// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart';
import 'package:quran/reciters.dart';

part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';
class QuranPagePlayerBloc
    extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  QuranPagePlayerBloc() : super(QuranPagePlayerInitial()) {

    on<QuranPagePlayerEvent>((event, emit) async {
      if (event is PlayFromVerse) {
      

        // audioPlayer = AudioPlayer();

        // Retrieve stored durations JSON
        String? storedJsonString = getValue(
          "${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}-durations",
        );

        if (storedJsonString == null) {
          Fluttertoast.showToast(msg: "Durations data not found");
          return;
        }

        // Decode durations
        List<dynamic> decodedList;
        try {
          decodedList = json.decode(storedJsonString);
        } catch (e) {
          Fluttertoast.showToast(msg: "Invalid durations data");
          return;
        }

        List durations = List.from(decodedList);

        // Get verse start time
        final verseData = durations.firstWhere(
          (element) => element["verseNumber"] == event.verse,
          orElse: () => null,
        );
        if (verseData == null) {
          Fluttertoast.showToast(msg: "Verse duration not found");
          return;
        }
        double duration = verseData["startDuration"];

        // Verify reciter exists
        final reciterMatch = reciters.firstWhere(
          (element) => element["identifier"] == event.reciterIdentifier,
          orElse: () => null,
        );
        if (reciterMatch == null) {
          Fluttertoast.showToast(msg: "Reciter not found");
          return;
        }

        final appDir = await getTemporaryDirectory();
        final filePath =
            "${appDir.path}-${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}.mp3";

        // Check file exists
        if (!File(filePath).existsSync()) {
          Fluttertoast.showToast(msg: "Audio file not found");
          return;
        }

        // Configure audio session
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());

        // Listen for playback errors
        audioPlayer.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
          Fluttertoast.showToast(msg: "Playback error: $e");
        });

        try {
          await audioPlayer.setAudioSource(
            ConcatenatingAudioSource(
              children: [
                AudioSource.file(
                  filePath,
                  // Remove this tag if you don't want background playback
                  tag: MediaItem(
                    id: event.suraName,
                    album: reciterMatch["englishName"],
                    title: getSurahNameArabic(event.surahNumber),
                    artUri: Uri.parse(
                        "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg"),
                  ),
                )
              ],
            ),
          );
        } catch (e) {
          Fluttertoast.showToast(msg: "Error loading audio");
          return;
        }

        // Seek to the verse position
        audioPlayer.seek(Duration(milliseconds: duration.toInt()));
        audioPlayer.play();

        Fluttertoast.showToast(msg: "Start Playing");

        emit(QuranPagePlayerPlaying(
          player: audioPlayer,
          audioPlayerStream: audioPlayer.positionStream,
          suraNumber: event.surahNumber,
          reciter: reciterMatch,
          durations: durations,
        ));

      } else if (event is StopPlaying) {
        if (audioPlayer != null) {
          await audioPlayer.stop();
        }
        emit(QuranPagePlayerInitial());

      } else if (event is KillPlayerEvent) {
        if (audioPlayer != null) {
          await audioPlayer.stop();
          // audioPlayer = null;
        }
        emit(QuranPagePlayerInitial());
      }
    });
  }
}
