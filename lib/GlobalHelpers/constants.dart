import 'package:flutter/material.dart';
import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:nabd/models/TranslationInfo.dart';
import 'package:quran/quran.dart';

const Color primaryColor = Color(0xFF4A4039);
const Color accentColor = Color.fromARGB(255, 141, 74, 29);
//  const Color backgroundColor =   Color.fromARGB(255, 255, 252, 250)
// ;
const Color backgroundColor = Color.fromARGB(255, 247, 248, 255);
const Color textColor = Color(0xFF333333);
const Color headingColor = Color(0xFF555555);
const Color buttonColor = Color(0xFF5D9566);
const Color borderColor = Color(0xFFDDDDDD);
const Color homeBackgroundColor = Color.fromARGB(255, 87, 154, 98);
const Color goldColor = Color.fromARGB(255, 150, 97, 0);
Color quranPagesColorLight =
    const Color(0xffF1EEE5);Color quranPagesColorDark =
  const Color(0xff292C31);
const Color  darkModeSecondaryColor =Color(0xff443F42);
const Color darkPrimaryColor = Color.fromARGB(255, 17, 18, 27);
Color orangeColor = const Color(0xffF8672F);
Color blueColor =
const Color(0xff00a2b5);
List colorsOfBookmarks = [
  Colors.greenAccent.withOpacity(.1),
  Colors.redAccent.withOpacity(.1),
  Colors.blueAccent.withOpacity(.1)
];
List colorsOfBookmarks2 = [
  Colors.greenAccent,
  Colors.redAccent,
  Colors.blueAccent
];
List zikrNotfications = [
  "(ﷺ  صلي علي محمد)",
  "(لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ، وَالنِّعْمَةَ، لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ)",
  "(ربِّ اغفِرْ لي خطيئتي يومَ الدِّينَ)",
  "(أَحَبُّ الْكَلاَمِ إِلَى اللَّهِ أَرْبَعٌ: سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلاَ إِلَهَ إِلاَّ اللَّهُ، وَاللَّهُ أَكْبَرُ، لاَ يَضُرُّكَ بِأَيِّهِنَّ بَدَأتَ)",
  "(اللَّهُمَّ اغْفِرِ لِي، وَارْحَمْنِي، وَاهْدِنِي، وَعَافِنِي وَارْزُقْنِي)",
  "(اللَّهُمَّ إنِّي أَسْأَلُكَ الهُدَى وَالتُّقَى، وَالْعَفَافَ وَالْغِنَى)",
  "(اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي)",
  "(اللَّهُمَّ آتِنَا في الدُّنْيَا حَسَنَةً وفي الآخِرَةِ حَسَنَةً، وَقِنَا عَذَابَ النَّارِ)",
  "(اللَّهُمَّ إنِّي أَعُوذُ بكَ مِن زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ)",
  "(اللَّهمَّ إنِّي أعوذُ بِك من شرِّ ما عَمِلتُ، ومن شرِّ ما لم أعمَلْ)",
  "(اللهم إني أعوذُ بكَ منَ الهمِّ والحزَنِ، وأعوذُ بكَ منَ العجزِ والكسلِ، وأعوذُ بكَ منَ الجُبنِ والبخلِ، وأعوذُ بكَ مِن غلبةِ الدَّينِ وقهرِ الرجالِ)",
  "(اللَّهُمَّ اغْفِرْ لي وَارْحَمْنِي وَاهْدِنِي وَارْزُقْنِي)",
  "ﷺ  صلي علي محمد",
  "(اللَّهُمَّ مُصَرِّفَ القُلُوبِ صَرِّفْ قُلُوبَنَا علَى طَاعَتِكَ)",
  "(اللهم انفَعْني بما علَّمتَني وعلِّمْني ما ينفَعُني وزِدْني عِلمًا).",
  "(اللَّهُمَّ إنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، ولَا يَغْفِرُ الذُّنُوبَ إلَّا أنْتَ، فَاغْفِرْ لي مِن عِندِكَ مَغْفِرَةً إنَّكَ أنْتَ الغَفُورُ الرَّحِيمُ)",
  "(اللهمَّ إنَّي أعوذُ بك من شرِّ سمْعي، ومن شرِّ بصري، ومن شرِّ لساني، ومن شرِّ قلْبي، ومن شرِّ منيَّتي)",
  "(اللَّهمَّ إني أعوذُ بكَ من مُنكراتِ الأخلاقِ والأعمالِ والأَهواءِ والأدواءِ)",
  "(سبحان الله - الحمدلله - لا اله الا الله - الله اكبر)",
  "(لا اله الا انت سبحانك اني كنت من الظالمين)",
  "(اذكر الله)",
  "(اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك، ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء بذنبي فاغفر لي فإنه لا يغفر الذنوب إلا أنت)",
  "(استغفر الله)",
  "(ﷺ  صلي علي محمد)",
  "(اللهم اعني)",
  "(اللهم نجني)",
  "(اللهم اغفرلي)",
  "(ﷺ  صلي علي محمد)",
  "(لا حول ولا قوة الا بالله)",
  "(اشهد ان لا اله الا الله واشهد ان محمد رسول الله)",
  "(ﷺ  صلي علي محمد)",
  "(رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ)",
  "(اللَّهمَّ إنِّي أسألُكَ مِنَ الخيرِ كلِّهِ عاجلِهِ وآجلِهِ، ما عَلِمْتُ منهُ وما لم أعلَمْ، وأعوذُ بِكَ منَ الشَّرِّ كلِّهِ عاجلِهِ وآجلِهِ، ما عَلِمْتُ منهُ وما لم أعلَمْ، اللَّهمَّ إنِّي أسألُكَ من خيرِ ما سألَكَ عبدُكَ ونبيُّكَ، وأعوذُ بِكَ من شرِّ ما عاذَ بِهِ عبدُكَ ونبيُّكَ، اللَّهمَّ إنِّي أسألُكَ الجنَّةَ وما قرَّبَ إليها من قَولٍ أو عملٍ، وأعوذُ بِكَ منَ النَّارِ وما قرَّبَ إليها من قولٍ أو عملٍ، وأسألُكَ أن تجعلَ كلَّ قَضاءٍ قضيتَهُ لي خيرًا)",
  "(رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَى وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَدْخِلْنِي بِرَحْمَتِكَ فِي عِبَادِكَ الصَّالِحِينَ)",
  "(رَبَّنَا لاَ تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلاَ تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا رَبَّنَا وَلاَ تُحَمِّلْنَا مَا لاَ طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنتَ مَوْلاَنَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ)",
  "(رَّبِّ اغْفِرْ لِي وَلِوَالِدَيَّ)",
];

///goodcolor const Color quranPagesColor = Color(0xff276277);
///const Color quranPagesColor = Color(0xff4B919E);
///old green const Color quranPagesColor = Color.fromARGB(255, 85, 179, 101); //0xff457b9d
///const primaryC=Color(0xff795547);
///const primaryC=Color(0xff488395); //

// const Color primaryDarkColor = Color(0xFF2980B9);
// const Color accentDarkColor = Color(0xFFC0392B);
// const Color backgroundDarkColor = Color(0xFF2C3E50);
// const Color textDarkColor = Color(0xFFECF0F1);
// const Color headingDarkColor = Color(0xFFBDC3C7);
// const Color buttonDarkColor = Color(0xFF27AE60);
// const Color borderDarkColor = Color(0xFF34495E);
const List indexes = [
  [1, 2, 3, 4],
  [5, 6, 7, 8],
  [9, 10, 11, 12],
  [13, 14, 15, 16],
  [17, 18, 19, 20],
  [21, 22, 23, 24],
  [25, 26, 27, 28],
  [29, 30, 31, 32],
  [33, 34, 35, 36],
  [37, 38, 39, 40],
  [41, 42, 43, 44],
  [45, 46, 47, 48],
  [49, 50, 51, 52],
  [53, 54, 55, 56],
  [57, 58, 59, 60],
  [61, 62, 63, 64],
  [65, 66, 67, 68],
  [69, 70, 71, 72],
  [73, 74, 75, 76],
  [77, 78, 79, 80],
  [81, 82, 83, 84],
  [85, 86, 87, 88],
  [89, 90, 91, 92],
  [93, 94, 95, 96],
  [97, 98, 99, 100],
  [101, 102, 103, 104],
  [105, 106, 107, 108],
  [109, 110, 111, 112],
  [113, 114, 115, 116],
  [117, 118, 119, 120],
  [121, 122, 123, 124],
  [125, 126, 127, 128],
  [129, 130, 131, 132],
  [133, 134, 135, 136],
  [137, 138, 139, 140],
  [141, 142, 143, 144],
  [145, 146, 147, 148],
  [149, 150, 151, 152],
  [153, 154, 155, 156],
  [157, 158, 159, 160],
  [161, 162, 163, 164],
  [165, 166, 167, 168],
  [169, 170, 171, 172],
  [173, 174, 175, 176],
  [177, 178, 179, 180],
  [181, 182, 183, 184],
  [185, 186, 187, 188],
  [189, 190, 191, 192],
  [193, 194, 195, 196],
  [197, 198, 199, 200],
  [201, 202, 203, 204],
  [205, 206, 207, 208],
  [209, 210, 211, 212],
  [213, 214, 215, 216],
  [217, 218, 219, 220],
  [221, 222, 223, 224],
  [225, 226, 227, 228],
  [229, 230, 231, 232],
  [233, 234, 235, 236],
  [237, 238, 239, 240]
];



const List<String> fontFamilies = [
  "UthmanicHafs13",
  "AmiriQuran",
  "Taha",
  "me",
  "qaloon", //shows verse end sympol good
  "pdsm",
  "noor ehuda",
  "hafs-nastaleeq-ver10-org",
  "hafs-smart-07",
  "jomhuria-regular-full-org",
  "mada-regular-full",
  "markazi-text-regular-full-org",
  "noto-kufi-arabic-regular-full",
  "qumbul-v7-full",
  "qur-std",
  "shorooq-full-org",
];
const List primaryColors = [  Colors.black,
Color(0xff283618),
  accentColor,
  Colors.black,
  Color(0XFf4C76BA),
  Colors.white,
  Color(0xffBFAE99),
  Color.fromARGB(255, 255, 255, 255),
  Color.fromARGB(255, 255, 211, 167),
  Color.fromARGB(255, 0, 0, 0),
  Colors.white,
  Colors.black,
  Colors.black,
  Colors.black,
  Colors.black,
  Colors.black,
  Colors.black,
];
const List backgroundColors = [  Color.fromARGB(255, 255, 248, 240),
Color(0xfffefae0),
  Color(0xffFFFCE7),
  Colors.white,
  Colors.white,
  Color(0xff22303C),
  Color(0xff213440),
  Color(0xff6d6d6d),
  Color(0xff4e4c4f),
  Color(0xfff3f6f4),
  Color.fromARGB(255, 38, 38, 38),
  Color(0xffE7F7FE),
  Color(0xffF4FDD3),
  Color(0xffFEEED4),
  Color(0xffD2F4CF),
  Color(0xffFEFADF),
  Color(0xffEAF0FE)
];const List secondaryColors = [  Color(0xff946735),
  Color(0xff606c38),

  Color.fromARGB(255, 189, 139, 2),
  Color.fromARGB(255, 43, 43, 43),
  Color.fromARGB(255, 0, 95, 184),
  Color.fromARGB(255, 23, 147, 255),
  Color.fromARGB(255, 102, 95, 0),
  Color.fromARGB(255, 255, 204, 129),
  Color.fromARGB(255, 255, 180, 82),
  Color.fromARGB(255, 22, 21, 20),
  Color.fromARGB(255, 216, 216, 216),
  Color.fromARGB(255, 18, 28, 32),
  Color.fromARGB(255, 28, 29, 23),
  Color.fromARGB(255, 58, 45, 23),
  Color.fromARGB(255, 31, 46, 29),
  Color.fromARGB(255, 36, 34, 22),
  Color.fromARGB(255, 24, 29, 43)
];
const List highlightColors = [  Color.fromARGB(172, 255, 201, 54),
  Color.fromARGB(96, 188, 107, 37),

  Color.fromARGB(255, 255, 244, 157),
  Color.fromARGB(255, 89, 216, 255),
  Color.fromARGB(255, 89, 216, 255),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 255, 244, 157),
  Color.fromARGB(255, 255, 244, 157),
  Color.fromARGB(255, 255, 244, 157),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 255, 244, 157),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 120, 192, 255),
  Color.fromARGB(255, 120, 192, 255),
];

var languagesLetters = [
  {
    "ar": [
      "أ",
      "ب",
      "ت",
      "ث",
      "ج",
      "ح",
      "خ",
      "د",
      "ذ",
      "ر",
      "ز",
      "س",
      "ش",
      "ص",
      "ض",
      "ط",
      "ظ",
      "ع",
      "غ",
      "ف",
      "ق",
      "ك",
      "ل",
      "م",
      "ن",
      "ه",
      "و",
      "ي"
    ]
  },
  {
    "en": List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))
  },
  {
    "de": List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))
  },
  {
    "am": [
      "አ",
      "ብ",
      "ት",
      "ቸ",
      "ጅ",
      "ህ",
      "ክ",
      "ድ",
      "ዴ",
      "ረ",
      "ዝ",
      "ስ",
      "ሽ",
      "ሽ",
      "ድ",
      "ጥ",
      "ዝ",
      "ዐ",
      "ግ",
      "ፈ",
      "ቅ",
      "ቀ",
      "ል",
      "መ",
      "ን",
      "ህ",
      "ወ",
      "የ"
    ]
  },
  {
    "ms": List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))
  },
  {
    "pt": List.generate(
        26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))
  },
  {
    "tr": List.generate(
        29, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))
  },
  {
    "ru": List.generate(
        33, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))
  }
];
