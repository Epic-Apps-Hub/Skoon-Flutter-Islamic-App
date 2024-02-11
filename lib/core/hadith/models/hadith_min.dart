// To parse this JSON data, do
//
//     final hadithMin = hadithMinFromJson(jsonString);

import 'dart:convert';

HadithMin hadithMinFromJson(String str) => HadithMin.fromJson(json.decode(str));

String hadithMinToJson(HadithMin data) => json.encode(data.toJson());

class HadithMin {
    String id;
    String title;
    List<String> translations;

    HadithMin({
        required this.id,
        required this.title,
        required this.translations,
    });

    factory HadithMin.fromJson(Map<String, dynamic> json) => HadithMin(
        id: json["id"],
        title: json["title"],
        translations: List<String>.from(json["translations"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "translations": List<dynamic>.from(translations.map((x) => x)),
    };
}
