part of 'quran_page_player_bloc.dart';

@immutable
 class QuranPagePlayerState {}

 class QuranPagePlayerInitial extends QuranPagePlayerState {}


class QuranPagePlayerPlaying extends QuranPagePlayerState {
Stream<Duration?>  audioPlayerStream;
AudioPlayer player;
int suraNumber;
List durations;
var reciter;

  QuranPagePlayerPlaying({required this.player,
    required this.audioPlayerStream,required this.suraNumber,required this.durations,
    required this.reciter
  });

}


class QuranPagePlayerStopped extends QuranPagePlayerState{
  
}


class QuranPagePlayerIdle extends QuranPagePlayerState{
  
}