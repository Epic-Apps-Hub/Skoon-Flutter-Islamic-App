
import 'dart:typed_data';

import 'package:nabd/core/QuranPages/helpers/save_image.dart';
import 'package:share_plus/share_plus.dart';

void shareImage(Uint8List capturedImage) async {
  try {
    final tempImageFile = await saveImageToTempDirectory(capturedImage);

    await Share.shareFiles(
      [tempImageFile.path],
      // text: '',
      // subject: 'Image Subject',
      mimeTypes: ['image/png'], // Adjust mime type as needed
      // filenames: ['temp_image.png'], // Adjust the filename as needed
    );

    // Optionally, delete the temporary file after sharing
    await tempImageFile.delete();
  } catch (e) {
    print('Error sharing image: $e');
  }
}
