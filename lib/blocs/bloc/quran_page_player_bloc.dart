// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:ffi';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart';
import 'package:quran/reciters.dart';

part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';

class QuranPagePlayerBloc
    extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  QuranPagePlayerBloc() : super(QuranPagePlayerInitial()) {
     AudioPlayer? audioPlayer;
// audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    on<QuranPagePlayerEvent>((event, emit) async {
      if (event is PlayFromVerse) {
        if(audioPlayer!=null) {
          audioPlayer!.dispose();
        }
        audioPlayer=AudioPlayer();
        String storedJsonString = getValue(
            "${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}-durations");
        // Decode the JSON string back into a list
        List<dynamic> decodedList = json.decode(storedJsonString);

        // Cast the decoded list to the appropriate type
        List durations = List.from(decodedList);

        double duration = durations
            .where((element) => element["verseNumber"] == event.verse)
            .first["startDuration"];
        final appDir = await getTemporaryDirectory();

        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());
        // Listen to errors during playback.
        audioPlayer!.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
          // print('A stream error occurred: $e');
        });
        try {
          await audioPlayer!.setAudioSource(ConcatenatingAudioSource(children: [
            AudioSource.file(
              "${appDir.path}-${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}.mp3",
              tag: MediaItem(
                id: event.suraName,
                album: reciters
                    .where((element) =>
                        element["identifier"] == event.reciterIdentifier)
                    .first["englishName"],
                title: getSurahNameArabic(event.surahNumber),
                artUri: Uri.parse(
                    "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
              ),
            )
          ]));
        } catch (e, stackTrace) {
          // Catch load errors: 404, invalid url ...
          print("Error loading playlist: $e");
          print(stackTrace);
        }
        audioPlayer!.seek(Duration(milliseconds: duration.toInt()));
        audioPlayer!.play();
        // await audioPlayer.setFilePath(
        //     "${appDir.path}-${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}.mp3",
        //     initialPosition: Duration(
        //         milliseconds: event.verse == 1
        //             ? 0
        //             : (int.parse(duration.toString().replaceAll(".0", "")))));
        // await audioPlayer.play();
        // await audioPlayer.play(
        //     DeviceFileSource(
        //         "${appDir.path}-${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}.mp3",),
        //     position: Duration(
        //         milliseconds: event.verse == 1
        //             ? 0
        //             : (int.parse(duration.toString().replaceAll(".0", "")))));
        Fluttertoast.showToast(msg: "Start Playing");
        // audioPlayer.durationStream.listen((event) {
        //   print(event!.inMilliseconds.toString());
        // });

        emit(QuranPagePlayerPlaying(
            player: audioPlayer!,
            audioPlayerStream: audioPlayer!.positionStream,
            suraNumber: event.surahNumber,
            reciter: reciters
                .where((element) =>
                    element["identifier"] == event.reciterIdentifier)
                .first,
            durations: durations));
      } else if (event is StopPlaying) {
        emit(QuranPagePlayerInitial());
      } else if (event is KillPlayerEvent) {
        audioPlayer!.dispose();
        emit(QuranPagePlayerInitial());
      }
    });
  }
}
