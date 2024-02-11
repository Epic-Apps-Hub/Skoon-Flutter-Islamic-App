import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:nabd/core/hadith/data/books.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

getBookByName(bookFileName) async {
  var book;
  var appDir = await path_provider.getTemporaryDirectory();

  if (File("${appDir.path}/$bookFileName").existsSync()) {
    File file = File("${appDir.path}/$bookFileName");

    String jsonData = await file.readAsString();
    book = json.decode(jsonData);
  }

  return book;
}

downloadBook(bookFileName) async {
  var appDir = await path_provider.getTemporaryDirectory();

  PermissionStatus status = await Permission.storage.request();
  //PermissionStatus status1 = await Permission.accessMediaLocation.request();
  PermissionStatus status2 = await Permission.manageExternalStorage.request();
  print('status $status   -> $status2');
  if (status.isGranted && status2.isGranted) {
    print(true);
  } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
    await openAppSettings();
  } else if (status.isDenied) {
    print('Permission Denied');
  }

  await dio.Dio().download(
      "$baseHadithUrl/$bookFileName", "${appDir.path}/$bookFileName",
      options: dio.Options(
          headers: {HttpHeaders.acceptEncodingHeader: "*"}), // disable gzip
      onReceiveProgress: (received, total) {
    if (total != -1) {
      print("${(received / total * 100).toStringAsFixed(0)}%");
    }
  });
}
