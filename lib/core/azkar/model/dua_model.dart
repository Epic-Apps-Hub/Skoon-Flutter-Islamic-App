class DuaModel {
  final dynamic id;
  final String category;
  final String audio;
  final String filename;
  final List<DuaItem> array;

  DuaModel({
    required this.id,
    required this.category,
    required this.audio,
    required this.filename,
    required this.array,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    var array = json['array'] as List;
    List<DuaItem> duaItems =
        array.map((item) => DuaItem.fromJson(item)).toList();

    return DuaModel(
      id: json['id'],
      category: json['category'],
      audio: json['audio'],
      filename: json['filename'],
      array: duaItems,
    );
  }
}

class DuaItem {
  final dynamic id;
  final String text;
  final int count;
  final String audio;
  final String filename;

  DuaItem({
    required this.id,
    required this.text,
    required this.count,
    required this.audio,
    required this.filename,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      audio: json['audio'],
      filename: json['filename'],
    );
  }
}
