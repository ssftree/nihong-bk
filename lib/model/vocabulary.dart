class Vocabulary {
  final String id;
  final String japanese;
  final String kanji;
  final String type;
  final String chinese;
  final String romaji;

  Vocabulary({
    required this.id,
    required this.japanese,
    required this.kanji,
    required this.type,
    required this.chinese,
    required this.romaji,
  });

  // Factory method to parse from JSON
  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] as String,
      japanese: json['japanese'] as String,
      kanji: json['kanji'] as String,
      type: json['type'] as String,
      chinese: json['chinese'] as String,
      romaji: json['romaji'] as String,
      softLink: json['soft_link'] != null ? json['soft_link'] as String : '',
    );
  }

  // Method to convert Vocabulary object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'kanji': kanji,
      'type': type,
      'chinese': chinese,
      'romaji': romaji,
    };
  }

  // Method to parse a list of Vocabulary from JSON array
  static List<Vocabulary> listFromJson(List<dynamic> jsonList) {
    var res= jsonList.map((json) => Vocabulary.fromJson(json)).toList();
    return res;
  }
}