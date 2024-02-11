import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:nabd/core/hadith/data/books.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

part 'hadith_event.dart';
part 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  HadithBloc() : super(HadithInitial()) {
    on<HadithEvent>((event, emit) async {
      if (event is DownloadHadithBook) {
        var appDir = await path_provider.getTemporaryDirectory();

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

        await dio.Dio().download(
          "$baseHadithUrl/${event.filename}",
          "${appDir.path}/${event.filename}",
          options: dio.Options(
              headers: {HttpHeaders.acceptEncodingHeader: "*"}), // disable gzip
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print("${(received / total * 100).toStringAsFixed(0)}%");
              emit(HadithDownloading(
                  "${(received / total * 100).toStringAsFixed(0)}%",
                  event.filename));
            } else {
              emit(HadithInitial());
            }
          },
        );
      } else if (event is GetHadithBook) {
        var book;
        var appDir = await path_provider.getTemporaryDirectory();

        if (File("${appDir.path}/${event.filename}").existsSync()) {
          File file = File("${appDir.path}/${event.filename}");

          String jsonData = await file.readAsString();
          book = json.decode(jsonData);
        }
        emit(HadithFetched(book));
      }
    });
  }
}
