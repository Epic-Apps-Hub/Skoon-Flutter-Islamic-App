import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/core/azkar/data/azkar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/core/azkar/model/dua_model.dart';
import 'package:nabd/core/azkar/views/zikr_detailspage.dart';
import 'package:quran/quran.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

class AzkarHomePage extends StatefulWidget {
  const AzkarHomePage({super.key});

  @override
  State<AzkarHomePage> createState() => _AzkarHomePageState();
}

class _AzkarHomePageState extends State<AzkarHomePage> {
  int index = 0;
  List tempAzkar = azkar;
  searchFunction(searchwords) {
    tempAzkar = azkar
        .where((element) =>
            removeDiacritics(element["category"]).contains(searchwords))
        .toList();

    // hadithes = filteredHadithes;
    if (searchwords == "") {
      tempAzkar = azkar;
    }

    setState(() {});
  }

  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                "assets/images/try6.png",
              ),
              alignment: Alignment.center,
              opacity: .6)),
      child: Scaffold(
        backgroundColor: getValue("darkMode")
              ? quranPagesColorDark
              :quranPagesColorLight,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              iconTheme: const IconThemeData(color:  Colors.white),
              backgroundColor: getValue("darkMode")
              ? darkModeSecondaryColor
              : blueColor,
              elevation: 0, // No shadow
              title: Text(
                "azkar".tr(),
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              expandedHeight: 100.h,
              collapsedHeight: kToolbarHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xffF5EFE8).withOpacity(.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: textEditingController,
                          onChanged: (val) {
                            searchFunction(val);
                          },
                          decoration: InputDecoration(
                            hintText: 'SearchDua'.tr(),
                            hintStyle: const TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (tempAzkar.length != azkar.length)
                        IconButton(
                            onPressed: () {
                              textEditingController.clear();
                              searchFunction("");
                            },
                            icon: const Icon(Icons.close, color: Colors.white))
                    ],
                  ),
                ),
              ),
            ),
            SliverList.builder(
                // shrinkWrap: true,
                itemCount: tempAzkar.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (f, i) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0.w,vertical: 6.h),
                    child: Material(
                      color:getValue("darkMode")
              ? darkModeSecondaryColor
              .withOpacity(.8): const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(.2),
                      shape: SuperellipseShape(
                        borderRadius: BorderRadius.circular(34.0.r),
                      ),
                      child:
                          // AnimatedOpacity(
                          // duration: const Duration(milliseconds: 500),
                          // opacity: dominantColor != null ? 1.0 : 0,
                          // child:
                          InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (builder) => ZikrPage(
                                        zikr: DuaModel.fromJson(tempAzkar[i]),
                                      )));
                        },
                        splashColor: getValue("darkMode")
              ? darkModeSecondaryColor
              .withOpacity(.5): blueColor.withOpacity(.2),
                        borderRadius: BorderRadius.circular(17.0.r),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 12.h,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tempAzkar[i]["category"],
                                      style: TextStyle(
                                        color:getValue("darkMode")
              ? Colors.white.withOpacity(.9): blueColor,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                     Icon(
                                      Icons.arrow_forward_ios,
                                      color: orangeColor,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
