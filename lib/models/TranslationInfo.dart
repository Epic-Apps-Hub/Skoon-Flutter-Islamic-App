import 'package:quran/quran.dart';

class TranslationInfo {
  final String typeText;
  final String typeTextInRelatedLanguage;
    final String typeInNativeLanguage;

  final Translation typeAsEnumValue;

  TranslationInfo({
    required this.typeText,
    required this.typeTextInRelatedLanguage,
    required this.typeInNativeLanguage,
    required this.typeAsEnumValue,
  });
}
