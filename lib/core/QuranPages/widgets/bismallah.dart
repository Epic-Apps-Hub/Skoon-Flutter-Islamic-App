import 'package:flutter/material.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Basmallah extends StatefulWidget {
  int index;
   Basmallah({super.key, required this.index });

  @override
  State<Basmallah> createState() => _BasmallahState();
}

class _BasmallahState extends State<Basmallah> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
          left: (screenSize.width * .15).w,
          right: (screenSize.width * .15).w,
          bottom: 8.h),
      child: Image.asset(
        "assets/images/Basmala.png",
        color: primaryColors[widget.index].withOpacity(.9),
        width: MediaQuery.of(context).size.width.w,
      ),
    );
  }
}
