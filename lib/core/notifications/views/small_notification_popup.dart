import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nabd/GlobalHelpers/constants.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool isGold = true;

  final _goldColors = const [
    Color(0xFFa2790d),
    Color(0xFFebd197),
    Color(0xFFa2790d),
  ];

  final _silverColors = const [
    Color(0xFFAEB2B8),
    Color(0xFFC7C9CB),
    Color(0xFFD7D7D8),
    Color(0xFFAEB2B8),
  ];

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      // log("$event");
      setState(() {
        isGold = !isGold;
      });
    });
  }

  List<String> azkarList = [
    "سُبْحَانَ اللَّهِ",
    "الْحَمْدُ لِلَّهِ",
    "اللَّهُ أَكْبَرُ",
    "لَا إِلَٰهَ إِلَّا اللَّهُ",
    "أَسْتَغْفِرُ اللَّهَ",
    "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
    "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
    "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ",
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
    "لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ",
    "صلي علي النبي",
    "رسول الله ﷺ قال: من صلى علي واحدة صلى الله عليه عشرا",
    "صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا",
    "اللَّهُمَّ مُصَرِّفَ القُلُوبِ صَرِّفْ قُلُوبَنَا علَى طَاعَتِكَ",
    "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ",
    "اللَّهُمَّ اغْفِرْ لي وَارْحَمْنِي وَاهْدِنِي وَارْزُقْنِي"
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: goldColor.withOpacity(.2),
                    blurRadius: 2,
                    spreadRadius: 2)
              ],
              color:  quranPagesColorLight,
              image: const DecorationImage(
                  image: AssetImage("assets/images/zikrback.png"),
                  fit: BoxFit.cover,
                  opacity: .2),
              borderRadius: BorderRadius.circular(26.0),
            ),
            child: GestureDetector(
              onTap: ()async {setState(() {
                
              });
                                       await FlutterOverlayWindow.closeOverlay();

              },
              child: Stack(
                children: [
                  Center(
                      child: Text(
                    azkarList[Random().nextInt(azkarList.length)],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: goldColor, fontSize: 26, fontFamily: "Taha"),
                  )),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () async {setState(() {
                          
                        });
                          await FlutterOverlayWindow.closeOverlay();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
