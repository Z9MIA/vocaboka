import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_database.dart';

class SqlVocaRepository {
  static Future<Vocabulary> create(Vocabulary vocabulary) async {
    var db = await SqlDatabase().database;
    var id = await db.insert(Vocabulary.tableName, vocabulary.toJson());
    return vocabulary.clone(id: id);
  }

  static Future<List<Vocabulary>> getAll() async {
    var db = await SqlDatabase().database;
    var result = await db.query(Vocabulary.tableName, columns: [
      VocabularyFields.id,
      VocabularyFields.voca,
      VocabularyFields.description
    ]);
    return result.map((data) => Vocabulary.fromJson(data)).toList();
  }
}
