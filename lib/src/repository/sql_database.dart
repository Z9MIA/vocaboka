import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/vocabulary.dart';

class SqlDatabase {
  static final SqlDatabase instance = SqlDatabase._instance();

  Database? _database;

  SqlDatabase._instance() {
    _initDatabase();
  }

  factory SqlDatabase() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await _initDatabase();
    return _database!;
  }

  Future<void> _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'voca.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _onDatabaseCreated);
  }

  void _onDatabaseCreated(Database db, int version) async {
    await db.execute('''
  create table ${Vocabulary.tableName} (
    ${VocabularyFields.id} integer primary key autoincrement,
    ${VocabularyFields.voca} text not null,
    ${VocabularyFields.description} text not null, 
    ${VocabularyFields.example} text
  )
''');
  }

  void closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
