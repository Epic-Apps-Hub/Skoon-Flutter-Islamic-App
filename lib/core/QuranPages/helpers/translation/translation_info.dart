import 'package:nabd/core/QuranPages/helpers/translation/translationdata.dart';

class TranslationData {
  final String typeText;
  final String typeTextInRelatedLanguage;
    final String typeInNativeLanguage;
final String url;

  final Translation typeAsEnumValue;

  TranslationData({
    required this.typeText,
    required this.typeTextInRelatedLanguage,required this.url,
    required this.typeInNativeLanguage,
    required this.typeAsEnumValue,
  });
}