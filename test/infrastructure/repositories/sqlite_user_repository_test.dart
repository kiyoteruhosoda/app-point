import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';
import 'package:flutterbase/infrastructure/db/sqlite/dao/user_dao.dart';
import 'package:flutterbase/infrastructure/db/sqlite/migrations/migration_v1.dart';
import 'package:flutterbase/infrastructure/repositories/sqlite_user_repository.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SqliteUserRepository repo;

  setUp(() async {
    databaseFactory = databaseFactoryFfi;
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, _) => migrateV1(db),
    );
    repo = SqliteUserRepository(UserDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create and retrieve user', () async {
    final user = await repo.create('Alice');

    expect(user.id.value, greaterThan(0));
    expect(user.name, 'Alice');

    final fetched = await repo.getById(user.id);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Alice');
  });

  test('getAll returns all created users', () async {
    await repo.create('Alice');
    await repo.create('Bob');

    final users = await repo.getAll();
    expect(users.length, 2);
    expect(users.map((u) => u.name), containsAll(['Alice', 'Bob']));
  });

  test('delete removes user', () async {
    final user = await repo.create('Charlie');
    await repo.delete(user.id);

    final fetched = await repo.getById(user.id);
    expect(fetched, isNull);
  });

  test('getById returns null for unknown id', () async {
    final result = await repo.getById(const UserId(9999));
    expect(result, isNull);
  });
}
