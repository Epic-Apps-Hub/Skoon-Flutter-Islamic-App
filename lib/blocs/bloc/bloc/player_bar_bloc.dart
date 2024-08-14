import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';

part 'player_bar_event.dart';
part 'player_bar_state.dart';

class PlayerBarBloc extends Bloc<PlayerBarEvent, PlayerBarState> {
  PlayerBarBloc() : super(PlayerBarInitial(height: 60)) {
    on<PlayerBarEvent>((event, emit) {
      // if (event is HideBarEvent) {
      //   print("HideBarEvent");

      //   emit(PlayerBarHidden());
      // } else if (event is ShowBarEvent || event is MinimizeBarEvent) {
      //   print("ShowBarEvent MinimizeBarEvent");
      //   emit(PlayerBarVisible(height: 60));
      // } else if (event is ExtendBarEvent) {
      //   print("ExtendBarEvent");
      //   emit(PlayerBarVisible(height: 70));
      // } else if (event is CloseBarEvent) {
      //   print("CloseBarEvent");
        // emit(PlayerBarClosed());
      // }
    });
  }
}
