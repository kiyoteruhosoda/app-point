import 'package:sqflite/sqflite.dart';
import 'package:flutterbase/infrastructure/db/sqlite/rows/point_entry_row.dart';

final class PointEntryDao {
  const PointEntryDao(this._db);
  final Database _db;
  static const String table = 'point_entries';

  Future<List<PointEntryRow>> getByUserId(int userId) async {
    final rows = await _db.query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_time DESC',
    );
    return rows.map(PointEntryRow.fromMap).toList();
  }

  Future<int> insert(PointEntryRow row) async {
    final map = row.toMap()..remove('id');
    return _db.insert(table, map);
  }

  Future<void> delete(int id) async {
    await _db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByUserId(int userId) async {
    await _db.delete(table, where: 'user_id = ?', whereArgs: [userId]);
  }
}
