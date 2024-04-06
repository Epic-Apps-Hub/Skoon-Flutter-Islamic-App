import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';

class BookmarksDialog extends StatefulWidget {
  int verseNumber;
  int suraNumber;

  BookmarksDialog(
      {super.key, required this.suraNumber, required this.verseNumber});

  @override
  _BookmarksDialogState createState() => _BookmarksDialogState();
}

class _BookmarksDialogState extends State<BookmarksDialog> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue; // Initial color for the bookmark

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // title: const Text('Add Bookmark'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const SizedBox(width: 3000,),
            TextField(
              controller: _nameController,
              decoration:  InputDecoration(labelText: 'nameOfBookmark'.tr()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                 Text('${"color".tr()}: '),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _showColorPickerDialog();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
      
                
              ],
            ),
      
            Row(
              children: [
                    TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child:  Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              // Use the entered name and selected color as needed
              String bookmarkName = _nameController.text;
              // TODO: Perform actions with bookmarkName and _selectedColor
              List bookmarks = json.decode(getValue("bookmarks"));
              String hexCode =
                  _selectedColor.value.toRadixString(16).padLeft(8, '0');
             
              bookmarks.add({
                "name": bookmarkName,
                "color": hexCode,
                "suraNumber": widget.suraNumber,
                "verseNumber": widget.verseNumber
              });
              updateValue("bookmarks", json.encode(bookmarks));
              // print(getValue("bookmarks"));
              setState(() {});
              Navigator.of(context).pop(); // Close the dialog
            },
            child:  Text('saveBookmark'.tr()),
          ),
           
              ],
            )
          ],
        ),
      ),
   
    );
  }

  // Function to show the color picker dialog
  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('color'.tr()),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: BorderRadius.circular(8.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the color picker dialog
              },
              child:  Text('saveBookmark'.tr()),
            ),
          ],
        );
      },
    );
  }
}

// Example of how to use the dialog
// Call this method when you want to show the dialog:
// showDialog(context: context, builder: (context) => BookmarksDialog());