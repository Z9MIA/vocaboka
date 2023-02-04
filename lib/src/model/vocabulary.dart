class VocabularyFields {
  static final String id = "_id";
  static final String voca = "voca";
  static final String description = "description";
  static final String example = "example";
}

class Vocabulary {
  static String tableName = "voca";

  final int? id;
  String word;
  String meaning;
  String? example;

  Vocabulary(
      {this.id, required this.word, required this.meaning, this.example});

  Map<String, dynamic> toJson() {
    return {
      VocabularyFields.id: id,
      VocabularyFields.voca: word,
      VocabularyFields.description: meaning,
      VocabularyFields.example: example
    };
  }

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
        id: json[VocabularyFields.id] as int?,
        word: json[VocabularyFields.voca],
        meaning: json[VocabularyFields.description],
        example: json[VocabularyFields.example] ?? '');
  }

  Vocabulary clone(
      {int? id, String? voca, String? description, String? example}) {
    return Vocabulary(
        id: id ?? this.id,
        word: voca ?? this.word,
        meaning: description ?? this.meaning,
        example: example ?? this.example);
  }
}
