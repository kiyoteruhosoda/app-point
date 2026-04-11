import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:rewardpoints/infrastructure/db/sqlite/migrations/migration_v1.dart';

final class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'app_point.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => migrateV1(db),
    );
  }
}
