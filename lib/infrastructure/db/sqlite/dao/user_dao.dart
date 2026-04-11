import 'package:sqflite/sqflite.dart';
import 'package:rewardpoints/infrastructure/db/sqlite/rows/user_row.dart';

final class UserDao {
  const UserDao(this._db);
  final Database _db;
  static const String table = 'users';

  Future<List<UserRow>> getAll() async {
    final rows = await _db.query(table, orderBy: 'created_at ASC');
    return rows.map(UserRow.fromMap).toList();
  }

  Future<UserRow?> getById(int id) async {
    final rows = await _db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UserRow.fromMap(rows.first);
  }

  Future<int> insert(String name, String createdAt) async {
    return _db.insert(table, {'name': name, 'created_at': createdAt});
  }

  Future<void> delete(int id) async {
    await _db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
