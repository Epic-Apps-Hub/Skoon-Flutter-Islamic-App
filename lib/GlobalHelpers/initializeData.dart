import 'package:nabd/GlobalHelpers/hive_helper.dart';
import 'package:quran/quran.dart';

initHiveValues() async {
  nullValidator("headerPhotoIndex", 0);
  nullValidator("quranPageolorsIndex", 0);
  nullValidator("selectedFontFamily", "UthmanicHafs13");

  nullValidator("pageViewFontSize", 23);
  nullValidator("verseByVerseFontSize", 24);
  nullValidator("verticalViewFontSize", 22);

  nullValidator("currentHeight", 2.0);
  // nullValidator("currentWordSpacing", 0.0);
  nullValidator("currentLetterSpacing", 0.0);
  nullValidator("lastRead", "non");
  nullValidator("alignmentType", "pageview");
  nullValidator("addAppSlogan", true);
  nullValidator("showSuraHeader", true);
  nullValidator("textWithoutDiacritics", false);
  nullValidator("selectedShareTypeIndex", 0);
  nullValidator("showTafseerOrTranslation", true);
  nullValidator("translationName", "enSaheeh");
  nullValidator("reciterIndex", 0);
  nullValidator("favoriteRecitersList", "[]");
  nullValidator("favoriteSurahList", "[]");
  nullValidator("downloadedSurahs", "[]");          

  nullValidator("addTafseerValue", 0);
  nullValidator("addTafseer", false);
  nullValidator("showBottomBar", false);
  nullValidator("shouldShowAyahNotification", false);
  nullValidator("shouldShowZikrNotification", false);
  nullValidator("shouldShowZikrNotification2", false);
  nullValidator("shouldShowSallyNotification", false);
  nullValidator("shouldShowhadithNotification", false);
  nullValidator("shouldUsePrayerTimes", false);

  nullValidator("timesForShowinghadithNotifications", 0);
  nullValidator("timesForShowingAyahNotifications", 0);
  nullValidator("timesForShowingZikrNotifications", 0);
  nullValidator("zikrNotificationindex", 0);  nullValidator("timesForShowingZikrNotifications2", 0);
  nullValidator("zikrNotificationindex2", 0);
  nullValidator("indexOfTranslation", 0);
  nullValidator("indexOfTranslationInVerseByVerse", 1);
    nullValidator("darkMode", false);

  nullValidator("starredRadios", "[]");
  nullValidator("bookmarks", "[]");

  nullValidator("timesOfAppOpen", 0);
  nullValidator("showedDialog", false);
}
