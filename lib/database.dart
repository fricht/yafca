import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


late final String dbName;
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

  int listToHistory() {
    int n = 1;
    for (bool h in history.reversed) {
      n = (n << 1) | (h ? 1 : 0);
    }
    return n;
  }

  Map<String, dynamic> getInsertMap() {
    return {
      Fields.subject: subject,
      Fields.question: question,
      Fields.answer: answer,
      Fields.reversible: reversible ? 1 : 0,
      Fields.history: listToHistory(),
      Fields.archived: archived ? 1 : 0,
    };
  }
}


class Cache {
  static Set<String>? activeSubjects;
  static Set<String>? archivedSubjects;

  static void unsetCache() {
    activeSubjects = null;
    archivedSubjects = null;
  }
}


Future<void> initDatabase() async {
  dbName = join(await getDatabasesPath(), "com.fricht.yafca.db");
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


Future<Set<String>> getActiveSubjects() async {
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
    Cache.activeSubjects = result.map((row) => row[Fields.subject] as String).toSet();
  }
  return Cache.activeSubjects!;
}


Future<Set<String>> getArchivedSubjects() async {
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
    Cache.archivedSubjects = result.map((row) => row[Fields.subject] as String).toSet();
  }
  return Cache.archivedSubjects!;
}


Future<Set<String>> getAllSubjects() async {
  return {...(await getActiveSubjects()), ...(await getArchivedSubjects())};
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
    whereArgs: [archived ? 1 : 0],
  );
  await database.close();
  return result.map((row) => Question(
      row[Fields.id],
      row[Fields.subject],
      row[Fields.question],
      row[Fields.answer],
      row[Fields.reversible] == 1,
      row[Fields.history],
      row[Fields.archived] == 1,
  )).toList();
}


// set methods


// add question
Future<void> addQuestion(Question question) async {
  Cache.unsetCache();
  Database database = await openDatabase(dbName);
  database.insert(
    mainTable,
    question.getInsertMap(),
  );
  await database.close();
}

// add to history

// edit question by ID

// delete by ID

// delete whole subject (a/ a/o)
