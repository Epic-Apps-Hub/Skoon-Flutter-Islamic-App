import 'package:nabd/core/QuranPages/helpers/translation/translation_info.dart';

enum Translation {
  baghawy,
  e3rab,
  katheer,
  qortoby,
  sa3dy,
  tabary,
  waseet,
  ar_ma3any,
  ar_muyassar,
  bn_bengali,
  bs_korkut,
  de_bubenheim,
  en_sahih,
  es_navio,
  fr_hamidullah,
  ha_gumi,
  id_indonesian,
  indonesian,
  it_piccardo,
  ku_asan,
  ml_abdulhameed,
  ms_basmeih,
  nl_siregar,
  pr_tagi,
  pt_elhayek,
  ru_kuliev,
  russian,
  so_abduh,
  sq_nahi,
  sv_bernstrom,
  sw_barwani,
  ta_tamil,
  th_thai,
  tr_diyanet,
  ur_jalandhry,
  uz_sodik,
  zh_jian,
  tafheem,
  tanweer,
}

List<TranslationData> translationDataList = [
  TranslationData(
    typeText: 'ar_muyassar',
    typeTextInRelatedLanguage: 'التفسير الميسر',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.ar_muyassar,
    url: "  d"
  ), TranslationData(
    typeText: 'en_sahih',
    typeTextInRelatedLanguage: 'English - Sahih International',
    typeInNativeLanguage: 'English',
    typeAsEnumValue: Translation.en_sahih, url: "  fs"
  ),
  TranslationData(
    typeText: 'baghawy',
    typeTextInRelatedLanguage: 'تفسير البغوي',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.baghawy,    url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/baghawy.json"

  ),
  TranslationData(
    typeText: 'e3rab',
    typeTextInRelatedLanguage: 'إعراب كلمات القرآن الكريم',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.e3rab, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/e3rab.json"
  ),
  TranslationData(
    typeText: 'katheer',
    typeTextInRelatedLanguage: 'تفسير ابن كثير',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.katheer, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/katheer.json"
  ),
  TranslationData(
    typeText: 'qortoby',
    typeTextInRelatedLanguage: 'تفسير القرطبي',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.qortoby, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/qortoby.json"
  ),
  TranslationData(
    typeText: 'sa3dy',
    typeTextInRelatedLanguage: 'تفسير السعدي',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.sa3dy, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/sa3dy.json"
  ),
  TranslationData(
    typeText: 'tabary',
    typeTextInRelatedLanguage: 'تفسير الطبري',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.tabary, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/tabary.json"
  ),
  TranslationData(
    typeText: 'waseet',
    typeTextInRelatedLanguage: 'التفسير الوسيط',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.waseet, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/waseet.json"
  ),
  TranslationData(
    typeText: 'ar_ma3any',
    typeTextInRelatedLanguage: 'معاني الكلمات',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.ar_ma3any, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ar_ma3any.json"
  ),
  TranslationData(
    typeText: 'tanweer',
    typeTextInRelatedLanguage: 'تفسير التحرير والتنوير',
    typeInNativeLanguage: 'العربية',
    typeAsEnumValue: Translation.tanweer,
    url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/tanweer.json"
  ), 
    TranslationData(
    typeText: 'tafheem',
    typeTextInRelatedLanguage:
        'English - Tafheem-ul-Quran by Syed Abu-al-A\'la Maududi',
    typeInNativeLanguage: 'English',
    typeAsEnumValue: Translation.tafheem, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/tafheem.json"
  ),
  TranslationData(
    typeText: 'bn_bengali',
    typeTextInRelatedLanguage: 'বাংলা ভাষা - মুহিউদ্দীন খান',
    typeInNativeLanguage: 'Bengali',
    typeAsEnumValue: Translation.bn_bengali, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/bn_bengali.json"
  ),
  TranslationData(
    typeText: 'bs_korkut',
    typeTextInRelatedLanguage: 'Bosanski - Korkut',
    typeInNativeLanguage: 'Bosnian',
    typeAsEnumValue: Translation.bs_korkut, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/bs_korkut.json"
  ),
  TranslationData(
    typeText: 'de_bubenheim',
    typeTextInRelatedLanguage: 'Deutsch - Bubenheim & Elyas',
    typeInNativeLanguage: 'German',
    typeAsEnumValue: Translation.de_bubenheim, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/de_bubenheim.json"
  ),

  TranslationData(
    typeText: 'es_navio',
    typeTextInRelatedLanguage: 'Español - Abdel Ghani Navio',
    typeInNativeLanguage: 'Spanish',
    typeAsEnumValue: Translation.es_navio, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/baghawy.json"
  ),
  TranslationData(
    typeText: 'fr_hamidullah',
    typeTextInRelatedLanguage: 'Français - Hamidullah',
    typeInNativeLanguage: 'French',
    typeAsEnumValue: Translation.fr_hamidullah, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/fr_hamidullah.json"
  ),
  TranslationData(
    typeText: 'ha_gumi',
    typeTextInRelatedLanguage: 'Hausa - Gumi',
    typeInNativeLanguage: 'Hausa',
    typeAsEnumValue: Translation.ha_gumi, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ha_gumi.json"
  ),
  TranslationData(
    typeText: 'id_indonesian',
    typeTextInRelatedLanguage: 'Indonesian - Bahasa Indonesia',
    typeInNativeLanguage: 'Indonesian',
    typeAsEnumValue: Translation.id_indonesian, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/id_indonesian.json"
  ),
  TranslationData(
    typeText: 'indonesian',
    typeTextInRelatedLanguage: 'Indonesian - Tafsir Jalalayn',
    typeInNativeLanguage: 'Indonesian',
    typeAsEnumValue: Translation.indonesian, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/indonesian.json"
  ),
  TranslationData(
    typeText: 'it_piccardo',
    typeTextInRelatedLanguage: 'Italiano - Piccardo',
    typeInNativeLanguage: 'Italian',
    typeAsEnumValue: Translation.it_piccardo, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/it_piccardo.json"
  ),
  TranslationData(
    typeText: 'ku_asan',
    typeTextInRelatedLanguage: 'كوردى - برهان محمد أمين',
    typeInNativeLanguage: 'Kurdish',
    typeAsEnumValue: Translation.ku_asan, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ku_asan.json"
  ),
  TranslationData(
    typeText: 'ml_abdulhameed',
    typeTextInRelatedLanguage: 'Malayalam - Abdul Hameed and Kunhi',
    typeInNativeLanguage: 'Malayalam',
    typeAsEnumValue: Translation.ml_abdulhameed, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ml_abdulhameed.json"
  ),
  TranslationData(
    typeText: 'ms_basmeih',
    typeTextInRelatedLanguage: 'Melayu - Basmeih',
    typeInNativeLanguage: 'Malay',
    typeAsEnumValue: Translation.ms_basmeih, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/baghawy.json"
  ),
  TranslationData(
    typeText: 'nl_siregar',
    typeTextInRelatedLanguage: 'Dutch - Sofian Siregar',
    typeInNativeLanguage: 'Dutch',
    typeAsEnumValue: Translation.nl_siregar, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/nl_siregar.json"
  ),
  TranslationData(
    typeText: 'pr_tagi',
    typeTextInRelatedLanguage: 'فارسى - حسین تاجی گله داری',
    typeInNativeLanguage: 'Persian',
    typeAsEnumValue: Translation.pr_tagi, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/pr_tagi.json"
  ),
  TranslationData(
    typeText: 'pt_elhayek',
    typeTextInRelatedLanguage: 'Português - El Hayek',
    typeInNativeLanguage: 'Portuguese',
    typeAsEnumValue: Translation.pt_elhayek, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/pt_elhayek.json"
  ),
  TranslationData(
    typeText: 'ru_kuliev',
    typeTextInRelatedLanguage: 'Русский - Кулиев',
    typeInNativeLanguage: 'Russian',
    typeAsEnumValue: Translation.ru_kuliev, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ru_kuliev.json"
  ),
  TranslationData(
    typeText: 'russian',
    typeTextInRelatedLanguage: 'Русский - Кулиев -ас-Саади',
    typeInNativeLanguage: 'Russian',
    typeAsEnumValue: Translation.russian, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/russian.json"
  ),
  TranslationData(
    typeText: 'so_abduh',
    typeTextInRelatedLanguage: 'Somali - Abduh',
    typeInNativeLanguage: 'Somali',
    typeAsEnumValue: Translation.so_abduh, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/so_abduh.json"
  ),
  TranslationData(
    typeText: 'sq_nahi',
    typeTextInRelatedLanguage: 'Shqiptar - Efendi Nahi',
    typeInNativeLanguage: 'Albanian',
    typeAsEnumValue: Translation.sq_nahi, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/sq_nahi.json"
  ),
  TranslationData(
    typeText: 'sv_bernstrom',
    typeTextInRelatedLanguage: 'Swedish - Bernström',
    typeInNativeLanguage: 'Swedish',
    typeAsEnumValue: Translation.sv_bernstrom, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/sv_bernstrom.json"
  ),
  TranslationData(
    typeText: 'sw_barwani',
    typeTextInRelatedLanguage: 'Swahili - Al-Barwani',
    typeInNativeLanguage: 'Swahili',
    typeAsEnumValue: Translation.sw_barwani, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/sw_barwani.json"
  ),
  TranslationData(
    typeText: 'ta_tamil',
    typeTextInRelatedLanguage: 'தமிழ் - ஜான் டிரஸ்ட்',
    typeInNativeLanguage: 'Tamil',
    typeAsEnumValue: Translation.ta_tamil, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ta_tamil.json"
  ),
  TranslationData(
    typeText: 'th_thai',
    typeTextInRelatedLanguage: 'ภาษาไทย - ภาษาไทย',
    typeInNativeLanguage: 'Thai',
    typeAsEnumValue: Translation.th_thai, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/th_thai.json"
  ),
  TranslationData(
    typeText: 'tr_diyanet',
    typeTextInRelatedLanguage: 'Türkçe - Diyanet Isleri',
    typeInNativeLanguage: 'Turkish',
    typeAsEnumValue: Translation.tr_diyanet, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/tr_diyanet.json"
  ),
  TranslationData(
    typeText: 'ur_jalandhry',
    typeTextInRelatedLanguage: 'اردو - جالندربرى',
    typeInNativeLanguage: 'Urdu',
    typeAsEnumValue: Translation.ur_jalandhry, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/ur_jalandhry.json"
  ),
  TranslationData(
    typeText: 'uz_sodik',
    typeTextInRelatedLanguage: 'Uzbek - Мухаммад Содик',
    typeInNativeLanguage: 'Uzbek',
    typeAsEnumValue: Translation.uz_sodik, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/uz_sodik.json"
  ),
  TranslationData(
    typeText: 'zh_jian',
    typeTextInRelatedLanguage: '中国语文 - Ma Jian',
    typeInNativeLanguage: 'Chinese',
    typeAsEnumValue: Translation.zh_jian, url: "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/zh_jian.json"
  ),

];
