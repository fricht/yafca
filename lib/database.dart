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

  Question(this.id, this.subject, this.question, this.answer, this.reversible, int history, this.archived) : history = computeHistory(history);

  static List<bool> computeHistory(int n) {
    List<bool> history = [];
    bool started = false;
    for (int i = 0; i < 64; i++) {
      bool b = ((n >> i) & 1) == 1;
      if (started) {
        history.add(b);
      } else {
        started = b;
      }
    }
    return history;
  }
}


class Cache {
  static List<String>? activeSubjects;
  static List<String>? archivedSubjects;
}


Future<void> initDatabase() async {
  deleteDatabase(dbName); // TODO : remove this line
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


Future<List<Question>> getSubjectQuestions(String subject, bool archived) async {
  Database database = await openDatabase(dbName);
  List<Map<String, dynamic>> result = await database.query(
    mainTable,
    columns: [
      Fields.id,
      Fields.subject,
      Fields.question,
      Fields.answer,
      Fields.reversible,
      Fields.history,
      Fields.archived,
    ],
    where: "${Fields.archived} = ?",
    whereArgs: [archived],
  );
  await database.close();
  return result.map((row) => Question(
      row[Fields.id],
      row[Fields.subject],
      row[Fields.question],
      row[Fields.answer],
      row[Fields.reversible],
      row[Fields.history],
      row[Fields.archived]
  )).toList();
}


// set methods


// add question

// add to history

// edit question by ID

// delete by ID

// delete whole subject (a/ a/o)
