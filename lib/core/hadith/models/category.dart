// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
    String id;
    String title;
    String hadeethsCount;
    dynamic parentId;

    Category({
        required this.id,
        required this.title,
        required this.hadeethsCount,
        required this.parentId,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        title: json["title"],
        hadeethsCount: json["hadeeths_count"],
        parentId: json["parent_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "hadeeths_count": hadeethsCount,
        "parent_id": parentId,
    };
}
