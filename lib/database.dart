import 'package:sqflite/sqflite.dart';


const String dbName = "com.fricht.yafca.db";
const String mainTable = "questions";
class Fields {
  static const String id = "id";
  static const String subject = "subject";
  static const String question = "question";
  static const String answer = "answer";
  static const String reversible = "reversible";
  static const String history = "history";
  static const String archived = "archived";
}


class Question {
  final int id;
  final String subject;
  final String question;
  final String answer;
  final bool reversible;
  final List<bool> history;
  final bool archived;

  Question(this.id, this.subject, this.question, this.answer, this.reversible, this.history, this.archived);
}


class Cache {
  static List<String>? activeSubjects;
  static List<String>? archivedSubjects;
}


Future<void> initDatabase() async {
  Database database = await openDatabase(
    dbName,
    version: 1,
    onCreate: (db, version) {
      db.execute("""
        CREATE TABLE IF NOT EXISTS $mainTable (
          ${Fields.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          ${Fields.subject} TEXT NOT NULL,
          ${Fields.question} TEXT NOT NULL,
          ${Fields.answer} TEXT NOT NULL,
          ${Fields.reversible} INTEGER NOT NULL,
          ${Fields.history} INTEGER NOT NULL,
          ${Fields.archived} INTEGER NOT NULL
        )
      """);
    },
  );
  await database.close();
}


// get methods


Future<List<String>> getActiveSubjects() async {
  if (Cache.activeSubjects == null) {
    Database database = await openDatabase(dbName);
    List<Map<String, dynamic>> result = await database.query(
      mainTable,
      columns: [Fields.subject],
      where: "${Fields.archived} = ?",
      whereArgs: [0],
      distinct: true,
    );
    await database.close();
    Cache.activeSubjects = result.map((row) => row[Fields.subject] as String).toList();
  }
  return Cache.activeSubjects!;
}


Future<List<String>> getArchivedSubjects() async {
  if (Cache.archivedSubjects == null) {
    Database database = await openDatabase(dbName);
    List<Map<String, dynamic>> result = await database.query(
      mainTable,
      columns: [Fields.subject],
      where: "${Fields.archived} = ?",
      whereArgs: [1],
      distinct: true,
    );
    await database.close();
    Cache.archivedSubjects = result.map((row) => row[Fields.subject] as String).toList();
  }
  return Cache.archivedSubjects!;
}


// get questions of subject (a/ a/o)


// set methods


// add question

// add to history

// edit question bt ID

// delete by ID

// delete whole subject (a/ a/o)
