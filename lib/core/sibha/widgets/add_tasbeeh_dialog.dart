import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/constants.dart';

class AddTasbeehDialog extends StatefulWidget {
  Function function;

  AddTasbeehDialog({super.key, required this.function});

  @override
  State<AddTasbeehDialog> createState() => _AddTasbeehDialogState();
}

class _AddTasbeehDialogState extends State<AddTasbeehDialog> {
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor.withOpacity(.9),
      borderRadius: BorderRadius.circular(18.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30.h,
          ),
          Text(
            "Add To Sibha".tr(),
            style: TextStyle(color: Colors.black, fontSize: 22.sp),
          ),
          SizedBox(
            height: 30.h,
          ),
          TextField(
            controller: textEditingController,
            onChanged: (ca){

            },
            decoration:  InputDecoration(hintText: "Enter Custom Zikr".tr()),
          ),
          SizedBox(
            height: 30.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    if (textEditingController.text.isEmpty) {
                    } else {
                      widget.function(textEditingController.text);

                    }
                  },
                  child:  Text("Add".tr())),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text("cancel".tr())),
            ],
          ),
          SizedBox(
            height: 30.h,
          ),
        ],
      ),
    );
  }
}
