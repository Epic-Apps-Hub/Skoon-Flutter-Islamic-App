List<Map<String, String>> books = [
  {"name": "Abi Daud", "arabicName": "أبي داود", "file": "abi_daud.json"},
  {"name": "Ahmed", "arabicName": "أحمد", "file": "ahmed.json"},
  {"name": "Bukhari", "arabicName": "البخاري", "file": "bukhari.json"},
  {"name": "Darimi", "arabicName": "الدارمي", "file": "darimi.json"},
  {"name": "Ibn Maja", "arabicName": "ابن ماجه", "file": "ibn_maja.json"},
  {"name": "Malik", "arabicName": "مالك", "file": "malik.json"},
  {"name": "Muslim", "arabicName": "مسلم", "file": "muslim.json"},
  {"name": "Nasai", "arabicName": "النسائي", "file": "nasai.json"},
  {"name": "Trmizi", "arabicName": "الترمذي", "file": "trmizi.json"}
];

const baseHadithUrl="https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Hadith%20Books%20Json/";


class HadithModel {
  final int number;
  final String hadith;
  final String description;
  final String searchTerm;

  HadithModel({
    required this.number,
    required this.hadith,
    required this.description,
    required this.searchTerm,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      number: json['number'] as int,
      hadith: json['hadith'] as String,
      description: json['description'] as String,
      searchTerm: json['searchTerm'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'hadith': hadith,
      'description': description,
      'searchTerm': searchTerm,
    };
  }
}
