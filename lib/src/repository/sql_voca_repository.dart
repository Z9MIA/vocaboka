import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_database.dart';

class SqlVocaRepository {
  static Future<Vocabulary> create(Vocabulary vocabulary) async {
    print("create: ${vocabulary.toJson()}");
    var db = await SqlDatabase().database;
    var id = await db.insert(Vocabulary.tableName, vocabulary.toJson());
    return vocabulary.clone(id: id);
  }

  static Future<void> update(Vocabulary vocabulary) async {
    print("update: ${vocabulary.toJson()}");
    var db = await SqlDatabase().database;
    await db.update(Vocabulary.tableName, vocabulary.toJson(),
        where: "${VocabularyFields.id} = ?", whereArgs: [vocabulary.id]);
  }

  static Future<void> delete(int id) async {
    var db = await SqlDatabase().database;
    await db.delete(Vocabulary.tableName,
        where: "${VocabularyFields.id} = ?", whereArgs: [id]);
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

  static Future<Vocabulary> getOne(int id) async {
    var db = await SqlDatabase().database;
    var result = await db.query(Vocabulary.tableName,
        columns: [
          VocabularyFields.id,
          VocabularyFields.voca,
          VocabularyFields.description
        ],
        where: "${VocabularyFields.id} = ?",
        whereArgs: [id]);
    assert(result.isNotEmpty);
    return Vocabulary.fromJson(result[0]);
  }
}
