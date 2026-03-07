import 'package:nabd/features/QuranPages/helpers/result.dart';

class QuranPageUtils {
  static int getTotalCharacters(List<String> stringList) {
    int total = 0;
    for (String str in stringList) {
      total += str.length;
    }
    return total;
  }

  static Result checkIfPageIncludesQuarterAndQuarterIndex(
      List<dynamic> array, List<dynamic> pageData, List<dynamic> indexes) {
    for (int i = 0; i < array.length; i++) {
      int surah = array[i]['surah'];
      int ayah = array[i]['ayah'];
      for (int j = 0; j < pageData.length; j++) {
        int pageSurah = pageData[j]['surah'];
        int start = pageData[j]['start'];
        int end = pageData[j]['end'];
        if ((surah == pageSurah) && (ayah >= start) && (ayah <= end)) {
          int targetIndex = i + 1;
          for (int hizbIndex = 0; hizbIndex < indexes.length; hizbIndex++) {
            List<int> hizb = indexes[hizbIndex];
            for (int quarterIndex = 0;
                quarterIndex < hizb.length;
                quarterIndex++) {
              if (hizb[quarterIndex] == targetIndex) {
                return Result(true, i, hizbIndex, quarterIndex);
              }
            }
          }
        }
      }
    }
    return Result(false, -1, -1, -1);
  }
}
