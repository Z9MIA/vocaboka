class VocabularyFields {
  static final String id = "_id";
  static final String voca = "voca";
  static final String description = "description";
  static final String example = "example";
}

class Vocabulary {
  static String tableName = "voca";

  final int? id;
  String voca;
  String description;
  String? example;

  Vocabulary(
      {this.id, required this.voca, required this.description, this.example});

  Map<String, dynamic> toJson() {
    return {
      VocabularyFields.id: id,
      VocabularyFields.voca: voca,
      VocabularyFields.description: description,
      VocabularyFields.example: example
    };
  }

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
        id: json[VocabularyFields.id] as int?,
        voca: json[VocabularyFields.voca],
        description: json[VocabularyFields.description],
        example: json[VocabularyFields.example] ?? '');
  }

  Vocabulary clone(
      {int? id, String? voca, String? description, String? example}) {
    return Vocabulary(
        id: id ?? this.id,
        voca: voca ?? this.voca,
        description: description ?? this.description,
        example: example ?? this.example);
  }
}
