import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/infrastructure/db/sqlite/dao/point_entry_dao.dart';
import 'package:rewardpoints/infrastructure/db/sqlite/dao/user_dao.dart';
import 'package:rewardpoints/infrastructure/db/sqlite/migrations/migration_v1.dart';
import 'package:rewardpoints/infrastructure/repositories/sqlite_point_entry_repository.dart';
import 'package:rewardpoints/infrastructure/repositories/sqlite_user_repository.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SqliteUserRepository userRepo;
  late SqlitePointEntryRepository pointRepo;

  setUp(() async {
    databaseFactory = databaseFactoryFfi;
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, _) => migrateV1(db),
    );
    userRepo = SqliteUserRepository(UserDao(db));
    pointRepo = SqlitePointEntryRepository(PointEntryDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('addition entry can be updated', () async {
    final user = await userRepo.create('Alice');
    final created = await pointRepo.addPoints(
      userId: user.id,
      dateTime: DateTime(2026, 4, 20, 10, 0),
      points: 100,
      reason: 'Campaign',
      tag: 'spring',
    );

    await pointRepo.update(
      created.id,
      dateTime: DateTime(2026, 4, 20, 12, 30),
      points: 80,
      reason: 'Manual fix',
      tag: 'edited',
    );

    final rows = await pointRepo.getByUserId(user.id);
    expect(rows, hasLength(1));
    final updated = rows.single as PointAddition;
    expect(updated.points, 80);
    expect(updated.reason, 'Manual fix');
    expect(updated.tag, 'edited');
  });

  test('consumption entry can be updated', () async {
    final user = await userRepo.create('Bob');
    final created = await pointRepo.consumePoints(
      userId: user.id,
      dateTime: DateTime(2026, 4, 20, 11, 0),
      points: 40,
      application: 'Store',
      tag: 'promo',
    );

    await pointRepo.update(
      created.id,
      dateTime: DateTime(2026, 4, 20, 13, 15),
      points: 30,
      application: 'Gift',
      tag: null,
    );

    final rows = await pointRepo.getByUserId(user.id);
    expect(rows, hasLength(1));
    final updated = rows.single as PointConsumption;
    expect(updated.points, 30);
    expect(updated.application, 'Gift');
    expect(updated.tag, isNull);
  });
}
