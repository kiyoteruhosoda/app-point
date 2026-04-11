import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/application/usecases/user/get_users_usecase.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/point_entry_id.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

class _FakeUserRepository implements UserRepository {
  final List<User> _users;
  _FakeUserRepository(this._users);

  @override
  Future<List<User>> getAll() async => List.unmodifiable(_users);

  @override
  Future<User?> getById(UserId id) async =>
      _users.where((u) => u.id == id).firstOrNull;

  @override
  Future<User> create(String name) async =>
      throw UnimplementedError('not needed');

  @override
  Future<void> delete(UserId id) async => throw UnimplementedError();
}

class _FakePointEntryRepository implements PointEntryRepository {
  final Map<int, List<PointEntry>> _entries;
  _FakePointEntryRepository(this._entries);

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) async =>
      _entries[userId.value] ?? [];

  @override
  Future<PointEntry> addPoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String reason,
  }) =>
      throw UnimplementedError();

  @override
  Future<PointEntry> consumePoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String application,
    String? tag,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> delete(PointEntryId id) => throw UnimplementedError();

  @override
  Future<void> deleteByUserId(UserId userId) => throw UnimplementedError();
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  final now = DateTime(2024, 1, 1);

  test('returns empty list when no users', () async {
    final useCase = GetUsersUseCase(
      _FakeUserRepository([]),
      _FakePointEntryRepository({}),
    );

    final result = await useCase.execute();
    expect(result, isEmpty);
  });

  test('returns users with correct balance', () async {
    final user1 = User(id: const UserId(1), name: 'Alice', createdAt: now);
    final entries = {
      1: [
        PointAddition(
          id: const PointEntryId(1),
          userId: const UserId(1),
          dateTime: now,
          points: 100,
          reason: 'Bonus',
        ),
        PointConsumption(
          id: const PointEntryId(2),
          userId: const UserId(1),
          dateTime: now,
          points: 30,
          application: 'Store',
        ),
      ],
    };

    final useCase = GetUsersUseCase(
      _FakeUserRepository([user1]),
      _FakePointEntryRepository(entries),
    );

    final result = await useCase.execute();

    expect(result.length, 1);
    expect(result.first.name, 'Alice');
    expect(result.first.pointBalance, 70); // 100 - 30
  });

  test('returns zero balance when no entries', () async {
    final user = User(id: const UserId(2), name: 'Bob', createdAt: now);
    final useCase = GetUsersUseCase(
      _FakeUserRepository([user]),
      _FakePointEntryRepository({}),
    );

    final result = await useCase.execute();
    expect(result.first.pointBalance, 0);
  });

  test('multiple users each get correct balance', () async {
    final user1 = User(id: const UserId(1), name: 'Alice', createdAt: now);
    final user2 = User(id: const UserId(2), name: 'Bob', createdAt: now);
    final entries = {
      1: [
        PointAddition(
          id: const PointEntryId(1),
          userId: const UserId(1),
          dateTime: now,
          points: 200,
          reason: 'Reward',
        ),
      ],
      2: [
        PointConsumption(
          id: const PointEntryId(2),
          userId: const UserId(2),
          dateTime: now,
          points: 50,
          application: 'App',
        ),
      ],
    };

    final useCase = GetUsersUseCase(
      _FakeUserRepository([user1, user2]),
      _FakePointEntryRepository(entries),
    );

    final result = await useCase.execute();
    expect(result.length, 2);
    expect(result.firstWhere((u) => u.name == 'Alice').pointBalance, 200);
    expect(result.firstWhere((u) => u.name == 'Bob').pointBalance, -50);
  });
}
