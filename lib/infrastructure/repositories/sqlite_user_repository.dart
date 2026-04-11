import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';
import 'package:rewardpoints/infrastructure/db/sqlite/dao/user_dao.dart';
import 'package:rewardpoints/infrastructure/mappers/user_mapper.dart';

final class SqliteUserRepository implements UserRepository {
  const SqliteUserRepository(this._dao);
  final UserDao _dao;

  @override
  Future<List<User>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(UserMapper.toDomain).toList();
  }

  @override
  Future<User?> getById(UserId id) async {
    final row = await _dao.getById(id.value);
    return row == null ? null : UserMapper.toDomain(row);
  }

  @override
  Future<User> create(String name) async {
    final createdAt = DateTime.now().toIso8601String();
    final id = await _dao.insert(name, createdAt);
    return User(
      id: UserId(id),
      name: name,
      createdAt: DateTime.parse(createdAt),
    );
  }

  @override
  Future<void> delete(UserId id) async {
    await _dao.delete(id.value);
  }
}
