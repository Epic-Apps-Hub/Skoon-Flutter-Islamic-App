part of 'quran_page_player_bloc.dart';

@immutable
 class QuranPagePlayerEvent {}

class PlayFromVerse extends QuranPagePlayerEvent{
  final int verse;
  final String reciterIdentifier;
  final int surahNumber;
  final String suraName;

  PlayFromVerse(this.verse, this.reciterIdentifier, this.surahNumber, this.suraName);

}

class PausePlaying extends QuranPagePlayerEvent{

}

class StopPlaying extends QuranPagePlayerEvent{


}

class KillPlayerEvent extends QuranPagePlayerEvent{
  
}