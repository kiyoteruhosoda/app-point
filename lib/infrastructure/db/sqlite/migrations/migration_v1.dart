import 'package:sqflite/sqflite.dart';

Future<void> migrateV1(Database db) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE point_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      date_time TEXT NOT NULL,
      points INTEGER NOT NULL,
      reason TEXT,
      application TEXT,
      tag TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''');
}
