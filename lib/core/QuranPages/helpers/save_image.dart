import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

Future<File> saveImageToTempDirectory(Uint8List imageBytes) async {
  final tempDir = await getTemporaryDirectory();
  final tempFilePath = '${tempDir.path}/temp_image.png';

  final file = File(tempFilePath);
  await file.writeAsBytes(imageBytes);

  return file;
}

Future<void> saveImageToGallery(Uint8List capturedImage) async {
  try {
    final result = await ImageGallerySaver.saveImage(
      capturedImage,
      quality: 100, // Adjust the image quality as needed
    );

    if (result != null && result['isSuccess']) {
      Fluttertoast.showToast(msg: "Saved Successfully");
      // Image saved successfully
      print('Image saved to gallery');
    } else {
      // Image save failed
      print('Failed to save image to gallery');
    }
  } catch (e) {
    print('Error saving image to gallery: $e');
  }
}
