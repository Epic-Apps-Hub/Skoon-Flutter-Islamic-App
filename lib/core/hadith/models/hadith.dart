// To parse this JSON data, do
//
//     final hadith = hadithFromJson(jsonString);

import 'dart:convert';

Hadith hadithFromJson(String str) => Hadith.fromJson(json.decode(str));

String hadithToJson(Hadith data) => json.encode(data.toJson());

class Hadith {
    String id;
    String title;
    String hadeeth;
    String attribution;
    String grade;
    String explanation;
    List<dynamic> hints;
    List<dynamic> categories;
    List<dynamic> translations;
    List<WordsMeaning> wordsMeanings;
    String reference;

    Hadith({
        required this.id,
        required this.title,
        required this.hadeeth,
        required this.attribution,
        required this.grade,
        required this.explanation,
        required this.hints,
        required this.categories,
        required this.translations,
        required this.wordsMeanings,
        required this.reference,
    });

    factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
        id: json["id"],
        title: json["title"],
        hadeeth: json["hadeeth"],
        attribution: json["attribution"],
        grade: json["grade"],
        explanation: json["explanation"],
        hints: List<dynamic>.from(json["hints"].map((x) => x)),
        categories: List<dynamic>.from(json["categories"].map((x) => x)),
        translations: List<dynamic>.from(json["translations"].map((x) => x)),
        wordsMeanings:json["words_meanings"]!=null||json["words_meanings"]!=[]? List<WordsMeaning>.from(json["words_meanings"].map((x) => WordsMeaning.fromJson(x))):[],
        reference: json["reference"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "hadeeth": hadeeth,
        "attribution": attribution,
        "grade": grade,
        "explanation": explanation,
        "hints": List<dynamic>.from(hints.map((x) => x)),
        "categories": List<dynamic>.from(categories.map((x) => x)),
        "translations": List<dynamic>.from(translations.map((x) => x)),
        "words_meanings": List<dynamic>.from(wordsMeanings.map((x) => x.toJson())),
        "reference": reference,
    };
}

class WordsMeaning {
    String word;
    String meaning;

    WordsMeaning({
        required this.word,
        required this.meaning,
    });

    factory WordsMeaning.fromJson(Map<String, dynamic> json) => WordsMeaning(
        word: json["word"],
        meaning: json["meaning"],
    );

    Map<String, dynamic> toJson() => {
        "word": word,
        "meaning": meaning,
    };
}
