part of 'player_bar_bloc.dart';

@immutable
class PlayerBarState {}

class PlayerBarInitial extends PlayerBarState {
  double height;
  PlayerBarInitial({
    required this.height,
  });
}

class PlayerBarVisible extends PlayerBarState {
  double height;
  PlayerBarVisible({
    required this.height,
  });
}

class PlayerBarHidden extends PlayerBarState {}

class PlayerBarClosed extends PlayerBarState {}
