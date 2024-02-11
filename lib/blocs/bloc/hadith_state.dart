part of 'hadith_bloc.dart';

@immutable
 class HadithState {}

 class HadithInitial extends HadithState {}
 class HadithFetched extends HadithState {
  final List<Map> hadith_book;

  HadithFetched(this.hadith_book);

 }



class HadithDownloading extends HadithState{
  var progress;
  final String fileName;
  HadithDownloading(this.progress, this.fileName);
}