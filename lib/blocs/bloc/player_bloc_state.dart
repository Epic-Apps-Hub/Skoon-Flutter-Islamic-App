part of 'player_bloc_bloc.dart';

@immutable
class PlayerBlocState {}

class PlayerBlocInitial extends PlayerBlocState {}

class PlayerBlocPlaying extends PlayerBlocState {
  Moshaf moshaf;
  Reciter reciter;
  int suraNumber;
  // String suraName;
  var jsonData;
  AudioPlayer audioPlayer;
  List surahNumbers;var playList;

  // bool isHidden;
  PlayerBlocPlaying({
    required this.moshaf,
    required this.reciter,
    required this.suraNumber,
    // required this.suraName,
    required this.jsonData,required this.audioPlayer,required this.surahNumbers,required this.playList
    // required this.isHidden
  });
}

class PlayerBlocPaused extends PlayerBlocState {}

class PlayerBlocClosed extends PlayerBlocState {}
