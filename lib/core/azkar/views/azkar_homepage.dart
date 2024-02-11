import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/core/azkar/data/azkar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/core/azkar/model/dua_model.dart';
import 'package:nabd/core/azkar/views/zikr_detailspage.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

class AzkarHomePage extends StatefulWidget {
  const AzkarHomePage({super.key});

  @override
  State<AzkarHomePage> createState() => _AzkarHomePageState();
}

class _AzkarHomePageState extends State<AzkarHomePage> {
  int index = 0;
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
        appBar: AppBar(
          backgroundColor: quranPagesColor,
          centerTitle: true,
          title:  Text(
         "azkar".tr(),
            style: const TextStyle(
              fontFamily: "cairo",
            ),
          ),
        ),
        body:
            // ListView(shrinkWrap: true, children: [
            PageView(
          onPageChanged: (value) {
            setState(() {
              index = value;
            });
          },
          children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: azkar
                    
                    .length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (f, i) {
             
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                    child: Material(
                      color: const Color.fromARGB(255, 255, 255, 255)
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
                                        zikr: DuaModel.fromJson(azkar[i]),
                                      )));
                        },
                        splashColor: quranPagesColor.withOpacity(.2),
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
                                      azkar[i]["category"],
                                      style: TextStyle(
                                        color: quranPagesColor,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios),
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
        // ]),
      ),
    );
  }
}
