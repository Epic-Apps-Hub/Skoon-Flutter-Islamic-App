part of 'player_bar_bloc.dart';

@immutable
 class PlayerBarEvent {}


class HideBarEvent extends PlayerBarEvent{

}

class ShowBarEvent extends PlayerBarEvent{}
class ExtendBarEvent extends PlayerBarEvent{}
class MinimizeBarEvent extends PlayerBarEvent{}

class CloseBarEvent extends PlayerBarEvent{}