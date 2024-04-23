library quran;

import 'package:quran/reciters.dart';
// import 'package:quran/tafseers/jalalayn.dart';
// import 'package:quran/tafseers/muyassar.dart';
import 'package:quran/quran_text_normal.dart';
// import 'package:quran/tafseers/siraj_tafseer.dart';
// import 'package:quran/translations/amh-muhammedsadiqan.dart';
// import 'package:quran/translations/en_saheeh.dart';
// import 'package:quran/translations/ind-indonesianislam.dart';
// import 'package:quran/translations/jpn-ryoichimita.dart';
// import 'package:quran/translations/nld-fredleemhuis.dart';
// import 'package:quran/translations/por-helminasr.dart';
// import 'package:quran/translations/rus-ministryofawqaf.dart';
// import 'package:quran/translations/tr_saheeh.dart';
// import 'package:quran/translations/ml_abdulhameed.dart';

import 'juz_data.dart';
import 'page_data.dart';
import 'quran_text.dart';
import 'sajdah_verses.dart';
import 'surah_data.dart';

///Takes [pageNumber] and returns a list containing Surahs and the starting and ending Verse numbers in that page
///
///Example:
///
///```dart
///getPageData(604);
///```
///
/// Returns List of Page 604:
///
///```dart
/// [{surah: 112, start: 1, end: 5}, {surah: 113, start: 1, end: 4}, {surah: 114, start: 1, end: 5}]
///```
///
///Length of the list is the number of surah in that page.
List getPageData(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw "Invalid page number. Page number must be between 1 and 604";
  }
  return pageData[pageNumber - 1];
}

///The most standard and common copy of Arabic only Quran total pages count
const int totalPagesCount = 604;

///The constant total of makki surahs
const int totalMakkiSurahs = 89;

///The constant total of madani surahs
const int totalMadaniSurahs = 25;

///The constant total juz count
const int totalJuzCount = 30;

///The constant total surah count
const int totalSurahCount = 114;

///The constant total verse count
const int totalVerseCount = 6236;

///The constant 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'
const String basmala = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";

///The constant 'سَجْدَةٌ'
const String sajdah = "سَجْدَةٌ";

///Takes [pageNumber] and returns total surahs count in that page
int getSurahCountByPage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw "Invalid page number. Page number must be between 1 and 604";
  }
  return pageData[pageNumber - 1].length;
}

///Takes [pageNumber] and returns total verses count in that page
int getVerseCountByPage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw "Invalid page number. Page number must be between 1 and 604";
  }
  int totalVerseCount = 0;
  for (int i = 0; i < pageData[pageNumber - 1].length; i++) {
    totalVerseCount +=
        int.parse(pageData[pageNumber - 1][i]!["end"].toString());
  }
  return totalVerseCount;
}

///Takes [surahNumber] & [verseNumber] and returns Juz number
int getJuzNumber(int surahNumber, int verseNumber) {
  for (var juz in juz) {
    if (juz["verses"].keys.contains(surahNumber)) {
      if (verseNumber >= juz["verses"][surahNumber][0] &&
          verseNumber <= juz["verses"][surahNumber][1]) {
        return int.parse(juz["id"].toString());
      }
    }
  }
  return -1;
}

///Takes [juzNumber] and returns a map which contains keys as surah number and value as a list containing starting and ending verse numbers.
///
///Example:
///
///```dart
///getSurahAndVersesListFromJuz(1);
///```
///
/// Returns Map of Juz 1:
///
///```dart
/// Map<int, List<int>> surahAndVerses = {
///        1: [1, 7],
///        2: [1, 141] //2 is surahNumber, 1 is starting verse and 141 is ending verse number
/// };
///
/// print(surahAndVerseList[1]); //[1, 7] => starting verse : 1, ending verse: 7
///```
Map<int, List<int>> getSurahAndVersesFromJuz(int juzNumber) {
  return juz[juzNumber - 1]["verses"];
}

///Takes [surahNumber] and returns the Surah name
String getSurahName(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No Surah found with given surahNumber";
  }
  return surah[surahNumber - 1]['name'].toString();
}

///Takes [surahNumber] returns the Surah name in English
String getSurahNameEnglish(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No Surah found with given surahNumber";
  }
  return surah[surahNumber - 1]['english'].toString();
}

///Takes [surahNumber] returns the Surah name in Turkish
String getSurahNameTurkish(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No Surah found with given surahNumber";
  }
  return surah[surahNumber - 1]['turkish'].toString();
}

///Takes [surahNumber] returns the Surah name in Arabic
String getSurahNameArabic(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No Surah found with given surahNumber";
  }
  return surah[surahNumber - 1]['arabic'].toString();
}

///Takes [surahNumber], [verseNumber] and returns the page number of the Quran
int getPageNumber(int surahNumber, int verseNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No Surah found with given surahNumber";
  }

  for (int pageIndex = 0; pageIndex < pageData.length; pageIndex++) {
    for (int surahIndexInPage = 0;
        surahIndexInPage < pageData[pageIndex].length;
        surahIndexInPage++) {
      final e = pageData[pageIndex][surahIndexInPage];
      if (e['surah'] == surahNumber &&
          e['start'] <= verseNumber &&
          e['end'] >= verseNumber) {
        return pageIndex + 1;
      }
    }
  }

  throw "Invalid verse number.";
}

///Takes [surahNumber] and returns the place of revelation (Makkah / Madinah) of the surah
String getPlaceOfRevelation(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No Surah found with given surahNumber";
  }
  return surah[surahNumber - 1]['place'].toString();
}

///Takes [surahNumber] and returns the count of total Verses in the Surah
int getVerseCount(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "No verse found with given surahNumber";
  }
  return int.parse(surah[surahNumber - 1]['aya'].toString());
}

///Takes [surahNumber], [verseNumber] & [verseEndSymbol] (optional) and returns the Verse in Arabic
String getVerse(int surahNumber, int verseNumber,
    {bool verseEndSymbol = false}) {
  String verse = "";
  for (var i in quranText) {
    if (i['surah_number'] == surahNumber && i['verse_number'] == verseNumber) {
      verse = i['content'].toString();
      break;
    }
  }

  if (verse == "") {
    throw "No verse found with given surahNumber and verseNumber.\n\n";
  }

  return verse + (verseEndSymbol ? getVerseEndSymbol(verseNumber) : "");
}
String getVerseQCF(int surahNumber, int verseNumber,
    {bool verseEndSymbol = false}) {
  String verse = "";
  for (var i in quranText) {
    if (i['surah_number'] == surahNumber && i['verse_number'] == verseNumber) {
      verse = i['qcfData'].toString();//print(verse);
      break;
    }
  }

  if (verse == "") {
    throw "No verse found with given surahNumber and verseNumber.\n\n";
  }

  return verse + (verseEndSymbol ? getVerseEndSymbol(verseNumber) : "");
}
///Takes [juzNumber] and returns Juz URL (from Quran.com)
String getJuzURL(int juzNumber) {
  return "https://quran.com/juz/$juzNumber";
}

///Takes [surahNumber] and returns Surah URL (from Quran.com)
String getSurahURL(int surahNumber) {
  return "https://quran.com/$surahNumber";
}

///Takes [surahNumber] & [verseNumber] and returns Verse URL (from Quran.com)
String getVerseURL(int surahNumber, int verseNumber) {
  return "https://quran.com/$surahNumber/$verseNumber";
}

///Takes [verseNumber], [arabicNumeral] (optional) and returns '۝' symbol with verse number
String getVerseEndSymbol(int verseNumber, {bool arabicNumeral = true}) {
  var arabicNumeric = '';
  var digits = verseNumber.toString().split("").toList();

  if (!arabicNumeral) return '\u06dd${verseNumber.toString()}';

  const Map arabicNumbers = {
    "0": "٠",
    "1": "۱",
    "2": "۲",
    "3": "۳",
    "4": "٤",
    "5": "٥",
    "6": "٦",
    "7": "۷",
    "8": "۸",
    "9": "۹"
  };

  for (var e in digits) {
    arabicNumeric += arabicNumbers[e];
  }

  return '\u06dd$arabicNumeric';
}

///Takes [surahNumber] and returns the list of page numbers of the surah
List<int> getSurahPages(int surahNumber) {
  if (surahNumber > 114 || surahNumber <= 0) {
    throw "Invalid surahNumber";
  }

  const pagesCount = totalPagesCount;
  List<int> pages = [];
  for (int currentPage = 1; currentPage <= pagesCount; currentPage++) {
    final pageData = getPageData(currentPage);
    for (int j = 0; j < pageData.length; j++) {
      final currentSurahNum = pageData[j]['surah'];
      if (currentSurahNum == surahNumber) {
        pages.add(currentPage);
        break;
      }
    }
  }
  return pages;
}

enum SurahSeperator {
  none,
  surahName,
  surahNameArabic,
  surahNameEnglish,
  surahNameTurkish,
}

///Takes [pageNumber], [verseEndSymbol], [surahSeperator] & [customSurahSeperator] and returns the list of verses in that page
///if [customSurahSeperator] is given, [surahSeperator] will not work.
List<String> getVersesTextByPage(int pageNumber,
    {bool verseEndSymbol = false,
    SurahSeperator surahSeperator = SurahSeperator.none,
    String customSurahSeperator = ""}) {
  if (pageNumber > 604 || pageNumber <= 0) {
    throw "Invalid pageNumber";
  }

  List<String> verses = [];
  final pageData = getPageData(pageNumber);
  for (var data in pageData) {
    if (customSurahSeperator != "") {
      verses.add(customSurahSeperator);
    } else if (surahSeperator == SurahSeperator.surahName) {
      verses.add(getSurahName(data["surah"]));
    } else if (surahSeperator == SurahSeperator.surahNameArabic) {
      verses.add(getSurahNameArabic(data["surah"]));
    } else if (surahSeperator == SurahSeperator.surahNameEnglish) {
      verses.add(getSurahNameEnglish(data["surah"]));
    } else if (surahSeperator == SurahSeperator.surahNameTurkish) {
      verses.add(getSurahNameTurkish(data["surah"]));
    }
    for (int j = data["start"]; j <= data["end"]; j++) {
      verses.add(getVerse(data["surah"], j, verseEndSymbol: verseEndSymbol));
    }
  }
  return verses;
}

///Takes [surahNumber] and returns audio URL of that surah
String getAudioURLBySurah(int surahNumber, reciterIdentifier) {
  return "https://cdn.islamic.network/quran/audio-surah/64/$reciterIdentifier/$surahNumber.mp3";
}

getReciters() {
  return reciters;
}

///Takes [surahNumber] & [verseNumber] and returns audio URL of that verse
String getAudioURLByVerse(int surahNumber, int verseNumber, reciterIdentifier) {
  int verseNum = 0;
  for (var i in quranText) {
    if (i['surah_number'] == surahNumber && i['verse_number'] == verseNumber) {
      verseNum = quranText.indexOf(i) + 1;
      break;
    }
  }
  if (reciterIdentifier == "ar.parhizgar" ||
      reciterIdentifier == "ar.muhammadjibreel" ||
      reciterIdentifier == "ar.muhammadayyoub" ||
      reciterIdentifier == "ar.ibrahimakhbar" ||
      reciterIdentifier == "ar.minshawi") {
    return "https://cdn.islamic.network/quran/audio/128/$reciterIdentifier/$verseNum.mp3";
  } else {
    return "https://cdn.islamic.network/quran/audio/64/$reciterIdentifier/$verseNum.mp3";
  }
  // if(reciters.where((element) => element["reciterIdentifier"]==reciterIdentifier).first["bit"]==128){
  //     return "https://cdn.islamic.network/quran/audio/64/$reciterIdentifier/$verseNum.mp3";

  // }
}

///Takes [surahNumber] & [verseNumber] and returns true if verse is sajdah
bool isSajdahVerse(int surahNumber, int verseNumber) =>
    sajdahVerses[surahNumber] == verseNumber;

///Takes [verseNumber] and returns audio URL of that verse
String getAudioURLByVerseNumber(int verseNumber, reciterIdentifier) {
  return "https://cdn.islamic.network/quran/audio/64/$reciterIdentifier/$verseNumber.mp3";
}

enum Translation {
  enSaheeh,
  trSaheeh,
  mlAbdulHameed,
  amh_muhammedsadiqan,
  ind_indonesianislam,
  jpn_ryoichimita,
  nld_fredleemhuis,
  por_helminasr,
  rus_ministryofawqaf,
  tafseerMuyassar,
  tafseerjalalayn,
  tafseerSiraj
}

///Takes [surahNumber], [verseNumber], [verseEndSymbol] (optional) & [translation] (optional) and returns verse translation
String getVerseTranslation(int surahNumber, int verseNumber,
    {bool verseEndSymbol = false,
    Translation translation = Translation.enSaheeh}) {
  String verse = "";

  // var translationText = enSaheeh;

  // switch (translation) {
  //   case Translation.enSaheeh:
  //     translationText = enSaheeh;
  //     break;
  //   case Translation.trSaheeh:
  //     translationText = trSaheeh;
  //     break;
  //   case Translation.mlAbdulHameed:
  //     translationText = mlAbdulHameed;
  //     break;
  //   case Translation.amh_muhammedsadiqan:
  //     translationText = amh_muhammedsadiqan;
  //     break;
  //   case Translation.ind_indonesianislam:
  //     translationText = ind_indonesianislam;
  //     break;
  //   case Translation.jpn_ryoichimita:
  //     translationText = jpn_ryoichimita;
  //     break;
  //   case Translation.nld_fredleemhuis:
  //     translationText = nld_fredleemhuis;
  //     break;
  //   case Translation.por_helminasr:
  //     translationText = portugalTranslation;
  //     break;
  //   case Translation.rus_ministryofawqaf:
  //     translationText = rus_ministryofawqaf;
  //     break;
  //   default:
  //     translationText = enSaheeh;
  // }

  // if (translation == Translation.amh_muhammedsadiqan ||
  //     translation == Translation.ind_indonesianislam ||
  //     translation == Translation.jpn_ryoichimita ||
  //     translation == Translation.nld_fredleemhuis ||
  //     translation == Translation.por_helminasr ||
  //     translation == Translation.rus_ministryofawqaf) {
  //   for (var i in translationText) {
  //     if (i['chapter'] == surahNumber && i['verse'] == verseNumber) {
  //       verse = i['text'].toString();
  //       break;
  //     }
  //   }
  // } else {
  //   for (var i in translationText) {
  //     if (i['surah_number'] == surahNumber &&
  //         i['verse_number'] == verseNumber) {
  //       verse = i['content'].toString();
  //       break;
  //     }
  //   }
  // }

  if (verse == "") {
    throw "No verse found with given surahNumber and verseNumber.\n\n";
  }

  return verse +
      (verseEndSymbol
          ? getVerseEndSymbol(verseNumber, arabicNumeral: false)
          : "");
}

///Takes a list of words [words] and [translation] (optional) and returns a map containing no. of occurences and result of the word search in the traslation
// Map searchWordsInTranslation(List<String> words,
//     {Translation translation = Translation.enSaheeh}) {
//   var translationText = enSaheeh;

//   switch (translation) {
//     case Translation.enSaheeh:
//       translationText = enSaheeh;
//       break;
//     case Translation.trSaheeh:
//       translationText = trSaheeh;
//       break;
//     case Translation.mlAbdulHameed:
//       translationText = mlAbdulHameed;
//       break;
//     default:
//       translationText = enSaheeh;
//   }

//   List<Map> result = [];

//   for (var i in translationText) {
//     bool exist = false;
//     for (var word in words) {
//       if (i['content']
//           .toString()
//           .toLowerCase()
//           .contains(word.toString().toLowerCase())) {
//         exist = true;
//       }
//     }
//     if (exist) {
//       result.add({"surah": i["surah_number"], "verse": i["verse_number"]});
//     }
//   }

//   return {"occurences": result.length, "result": result};
// }

///Takes a list of words [words] and returns a map containing no. of occurences and result of the word search in the arabic quran text.
///
///You have to include the harakaat (diacritics) in the words
///
///Example:
///```dart
/// searchWords(["لِّلَّهِ","وَٱللَّهُ","ٱللَّهُ"])
///```
Map searchWords(String words) {
  List<Map> result = [];
// print(words);
  for (var i in quran_text_normal) {
    // bool exist = false;

    // bool exist = false;
    //  print(DartArabic.stripTashkeel( DartArabic.stripDiacritics(i['content'].toString()
    //         )));

    if (i['content'].toString().toLowerCase().contains(words.toLowerCase())) {
      result.add({"surah": i["surah_number"], "verse": i["verse_number"]});

      // print(i['content']);
      // result.add({"surah": i["surah_number"], "verse": i["verse_number"]});
    }
    // result.add({"surah": i["surah_number"], "verse": i["verse_number"]});
  }
  if (result.isEmpty) {
    for (var i in quranText) {
      if (i['content'].toString().toLowerCase().contains(words.toLowerCase())) {
        result.add({"surah": i["surah_number"], "verse": i["verse_number"]});

        // print(i['content']);
        // result.add({"surah": i["surah_number"], "verse": i["verse_number"]});
      }
    }
  }

  return {"occurences": result.length, "result": result};
}

String getTafseer(surahNumber, verseNumber, Translation tafseerType) {
//   if (tafseerType == Translation.tafseerMuyassar) {
//     return muyasser[surahNumber - 1]["ayahs"]
//         .where((a) => a["numberInSurah"] == verseNumber)
//         .first["text"];
//   } else if (tafseerType == Translation.tafseerjalalayn) {
//     return jalalayn[surahNumber - 1]["ayahs"]
//         .where((a) => a["numberInSurah"] == verseNumber)
//         .first["text"];
//   } else if (tafseerType == Translation.tafseerSiraj) {
//     final RegExp regex = RegExp(r'\((.*?)\)');
//     final Match? match = regex.firstMatch(siraj_tafseer
//         .where((element) =>
//             element["chapter"] == surahNumber &&
//             element["verse"] == verseNumber)
//         .first["text"]);
// // Extracted text inside parentheses
//     String extractedText = '';

//     if (match != null) {
//       extractedText = match.group(1) ?? '';
//     }

//     return extractedText.replaceAll(',', '\n');
//   }
  return "";
}

String normalise(String input) => input
    .replaceAll('\u0610', '') //ARABIC SIGN SALLALLAHOU ALAYHE WA SALLAM
    .replaceAll('\u0611', '') //ARABIC SIGN ALAYHE ASSALLAM
    .replaceAll('\u0612', '') //ARABIC SIGN RAHMATULLAH ALAYHE
    .replaceAll('\u0613', '') //ARABIC SIGN RADI ALLAHOU ANHU
    .replaceAll('\u0614', '') //ARABIC SIGN TAKHALLUS

    //Remove koranic anotation
    .replaceAll('\u0615', '') //ARABIC SMALL HIGH TAH
    .replaceAll(
        '\u0616', '') //ARABIC SMALL HIGH LIGATURE ALEF WITH LAM WITH YEH
    .replaceAll('\u0617', '') //ARABIC SMALL HIGH ZAIN
    .replaceAll('\u0618', '') //ARABIC SMALL FATHA
    .replaceAll('\u0619', '') //ARABIC SMALL DAMMA
    .replaceAll('\u061A', '') //ARABIC SMALL KASRA
    .replaceAll('\u06D6',
        '') //ARABIC SMALL HIGH LIGATURE SAD WITH LAM WITH ALEF MAKSURA
    .replaceAll('\u06D7',
        '') //ARABIC SMALL HIGH LIGATURE QAF WITH LAM WITH ALEF MAKSURA
    .replaceAll('\u06D8', '') //ARABIC SMALL HIGH MEEM INITIAL FORM
    .replaceAll('\u06D9', '') //ARABIC SMALL HIGH LAM ALEF
    .replaceAll('\u06DA', '') //ARABIC SMALL HIGH JEEM
    .replaceAll('\u06DB', '') //ARABIC SMALL HIGH THREE DOTS
    .replaceAll('\u06DC', '') //ARABIC SMALL HIGH SEEN
    .replaceAll('\u06DD', '') //ARABIC END OF AYAH
    .replaceAll('\u06DE', '') //ARABIC START OF RUB EL HIZB
    .replaceAll('\u06DF', '') //ARABIC SMALL HIGH ROUNDED ZERO
    .replaceAll('\u06E0', '') //ARABIC SMALL HIGH UPRIGHT RECTANGULAR ZERO
    .replaceAll('\u06E1', '') //ARABIC SMALL HIGH DOTLESS HEAD OF KHAH
    .replaceAll('\u06E2', '') //ARABIC SMALL HIGH MEEM ISOLATED FORM
    .replaceAll('\u06E3', '') //ARABIC SMALL LOW SEEN
    .replaceAll('\u06E4', '') //ARABIC SMALL HIGH MADDA
    .replaceAll('\u06E5', '') //ARABIC SMALL WAW
    .replaceAll('\u06E6', '') //ARABIC SMALL YEH
    .replaceAll('\u06E7', '') //ARABIC SMALL HIGH YEH
    .replaceAll('\u06E8', '') //ARABIC SMALL HIGH NOON
    .replaceAll('\u06E9', '') //ARABIC PLACE OF SAJDAH
    .replaceAll('\u06EA', '') //ARABIC EMPTY CENTRE LOW STOP
    .replaceAll('\u06EB', '') //ARABIC EMPTY CENTRE HIGH STOP
    .replaceAll('\u06EC', '') //ARABIC ROUNDED HIGH STOP WITH FILLED CENTRE
    .replaceAll('\u06ED', '') //ARABIC SMALL LOW MEEM

    //Remove tatweel
    .replaceAll('\u0640', '')

    //Remove tashkeel
    .replaceAll('\u064B', '') //ARABIC FATHATAN
    .replaceAll('\u064C', '') //ARABIC DAMMATAN
    .replaceAll('\u064D', '') //ARABIC KASRATAN
    .replaceAll('\u064E', '') //ARABIC FATHA
    .replaceAll('\u064F', '') //ARABIC DAMMA
    .replaceAll('\u0650', '') //ARABIC KASRA
    .replaceAll('\u0651', '') //ARABIC SHADDA
    .replaceAll('\u0652', '') //ARABIC SUKUN
    .replaceAll('\u0653', '') //ARABIC MADDAH ABOVE
    .replaceAll('\u0654', '') //ARABIC HAMZA ABOVE
    .replaceAll('\u0655', '') //ARABIC HAMZA BELOW
    .replaceAll('\u0656', '') //ARABIC SUBSCRIPT ALEF
    .replaceAll('\u0657', '') //ARABIC INVERTED DAMMA
    .replaceAll('\u0658', '') //ARABIC MARK NOON GHUNNA
    .replaceAll('\u0659', '') //ARABIC ZWARAKAY
    .replaceAll('\u065A', '') //ARABIC VOWEL SIGN SMALL V ABOVE
    .replaceAll('\u065B', '') //ARABIC VOWEL SIGN INVERTED SMALL V ABOVE
    .replaceAll('\u065C', '') //ARABIC VOWEL SIGN DOT BELOW
    .replaceAll('\u065D', '') //ARABIC REVERSED DAMMA
    .replaceAll('\u065E', '') //ARABIC FATHA WITH TWO DOTS
    .replaceAll('\u065F', '') //ARABIC WAVY HAMZA BELOW
    .replaceAll('\u0670', '') //ARABIC LETTER SUPERSCRIPT ALEF

    //Replace Waw Hamza Above by Waw
    .replaceAll('\u0624', '\u0648')

    //Replace Ta Marbuta by Ha
    .replaceAll('\u0629', '\u0647')

    //Replace Ya
    // and Ya Hamza Above by Alif Maksura
    .replaceAll('\u064A', '\u0649')
    .replaceAll('\u0626', '\u0649')

    // Replace Alifs with Hamza Above/Below
    // and with Madda Above by Alif
    .replaceAll('\u0622', '\u0627')
    .replaceAll('\u0623', '\u0627')
    .replaceAll('\u0625', '\u0627');

String removeDiacritics(String input) {
  Map<String, String> diacriticsMap = {
    'َ': '', // Fatha
    'ُ': '', // Damma
    'ِ': '', // Kasra
    'ّ': '', // Shadda
    'ً': '', // Tanwin Fatha
    'ٌ': '', // Tanwin Damma
    'ٍ': '', // Tanwin Kasra
  };

  // Create a regular expression pattern that matches Arabic diacritics
  String diacriticsPattern =
      diacriticsMap.keys.map((e) => RegExp.escape(e)).join('|');
  RegExp exp = RegExp('[$diacriticsPattern]');

  // Remove diacritics using the regular expression
  String textWithoutDiacritics = input.replaceAll(exp, '');

  return textWithoutDiacritics;
}
