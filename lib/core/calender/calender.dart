import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart' as j;
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:flutter/material.dart' as m;
import 'package:jhijri_picker/jhijri_picker.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
// import 'package:jhijri_picker/jhijri_picker.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  int index = 1;
  var _today = j.HijriCalendar.now().toFormat(
                    "dd - MMMM - yyyy",
                  );
  var date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  getValue("darkMode")?quranPagesColorDark:quranPagesColorLight,
      appBar: AppBar(
        title: Text(
          "calender".tr(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:  getValue("darkMode")
              ? darkModeSecondaryColor
              :  blueColor,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30.h,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: JGlobalDatePicker(
              widgetType: WidgetType.JContainer,
              pickerType: index == 0 ? PickerType.JHijri : PickerType.JNormal,
              buttons: const SizedBox(),
              primaryColor: blueColor,
              calendarTextColor: Colors.black,
              backgroundColor: Colors.white,
              borderRadius: const Radius.circular(10),
              headerTitle: Container(
                decoration:  BoxDecoration(color:  getValue("darkMode")
              ? darkModeSecondaryColor
              : blueColor),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            index = 0;
                          });
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "calender".tr(),
                              style: TextStyle(
                                  color: index == 0 
                                      ? getValue("darkMode")
              ? Colors.white
              :  Colors.black
                                      : getValue("darkMode")
              ? Colors.white24
              :  Colors.black26,
                                  fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            index = 1;
                          });
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "normalCalender".tr(),
                              style: TextStyle(
                                  color: index == 1
                                      ? getValue("darkMode")
              ? Colors.white
              :  Colors.black
                                      : getValue("darkMode")
              ? Colors.white24
              :  Colors.black26,
                                  fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              startDate: JDateModel(dateTime: DateTime.parse("1984-12-24")),
              selectedDate: JDateModel(dateTime: DateTime.now()),
              endDate: JDateModel(dateTime: DateTime.parse("2030-09-20")),
              pickerMode: DatePickerMode.day,
              pickerTheme: Theme.of(context),
              locale: context.locale,
              textDirection: m.TextDirection.rtl,
              onChange: (val) {
                date = val.date;

                _today = j. HijriCalendar.fromDate(val.date).toFormat(
                    "dd - MMMM - yyyy",
                  );
                setState(() {});
                // return val;
              },
            ),
          ),
          SizedBox(
            height: 50.h,
          ),
          Container(      decoration: BoxDecoration(
                                                                color:
                                                                   Colors.white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.r)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                          decoration: BoxDecoration(
                                                                color:
                                                                     getValue("darkMode")?quranPagesColorDark:quranPagesColorLight
                                                                        .withOpacity(
                                                                            .6),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.r)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _today,
                        style: TextStyle(color: getValue("darkMode")
              ? Colors.white
              :  Colors.black, fontSize: 20.sp),
                      ),
                      Text(
                        DateFormat.yMMMEd(context.locale.languageCode).format(date),
                        style: TextStyle(color:  getValue("darkMode")
              ? Colors.white
              :  Colors.black, fontSize: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
