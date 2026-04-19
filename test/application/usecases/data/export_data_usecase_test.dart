import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/application/usecases/data/export_data_usecase.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/point_entry_id.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

class _FakeUserRepo implements UserRepository {
  _FakeUserRepo(this.users);
  final List<User> users;

  @override
  Future<List<User>> getAll() async => users;
  @override
  Future<User?> getById(UserId id) async =>
      users.where((u) => u.id == id).firstOrNull;
  @override
  Future<User> create(String name) => throw UnimplementedError();
  @override
  Future<void> delete(UserId id) => throw UnimplementedError();
}

class _FakePointRepo implements PointEntryRepository {
  _FakePointRepo(this.byUser);
  final Map<UserId, List<PointEntry>> byUser;

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) async =>
      byUser[userId] ?? const [];
  @override
  Future<PointEntry> addPoints(
          {required UserId userId,
          required DateTime dateTime,
          required int points,
          required String reason,
          String? tag}) =>
      throw UnimplementedError();
  @override
  Future<PointEntry> consumePoints(
          {required UserId userId,
          required DateTime dateTime,
          required int points,
          required String application,
          String? tag}) =>
      throw UnimplementedError();
  @override
  Future<void> update(PointEntryId id,
          {required DateTime dateTime,
          required int points,
          String? reason,
          String? application,
          String? tag}) =>
      throw UnimplementedError();
  @override
  Future<void> delete(PointEntryId id) => throw UnimplementedError();
  @override
  Future<void> deleteByUserId(UserId userId) => throw UnimplementedError();
  @override
  Future<List<String>> getDistinctReasons(UserId userId) async => const [];
  @override
  Future<List<String>> getDistinctApplications(UserId userId) async => const [];
}

void main() {
  test('serialises users and entries with correct structure', () async {
    final createdAt = DateTime.utc(2024, 1, 1);
    final user = User(
      id: const UserId(1),
      name: 'Alice',
      createdAt: createdAt,
    );
    final entry = PointAddition(
      id: const PointEntryId(10),
      userId: const UserId(1),
      dateTime: DateTime.utc(2024, 6, 1, 12, 0),
      points: 50,
      reason: 'Reward',
    );
    final useCase = ExportDataUseCase(
      _FakeUserRepo([user]),
      _FakePointRepo({const UserId(1): [entry]}),
    );

    final result = await useCase.execute(now: DateTime(2026, 4, 19, 12, 3));

    expect(result.suggestedFileName, 'point_data_20260419_1203.json');
    final payload = jsonDecode(result.json) as Map<String, dynamic>;
    final users = payload['users'] as List;
    final entries = payload['entries'] as List;
    expect(users, hasLength(1));
    expect(users.first, {
      'id': 1,
      'name': 'Alice',
      'createdAt': createdAt.toIso8601String(),
    });
    expect(entries, hasLength(1));
    expect(entries.first, {
      'id': 10,
      'userId': 1,
      'dateTime': entry.dateTime.toIso8601String(),
      'points': 50,
      'type': 'addition',
      'reason': 'Reward',
    });
  });

  test('writes consumption entries with application and optional tag',
      () async {
    final user = User(
      id: const UserId(2),
      name: 'Bob',
      createdAt: DateTime.utc(2024, 1, 1),
    );
    final entry = PointConsumption(
      id: const PointEntryId(11),
      userId: const UserId(2),
      dateTime: DateTime.utc(2024, 6, 2),
      points: 30,
      application: 'Store',
      tag: 'campaign',
    );
    final useCase = ExportDataUseCase(
      _FakeUserRepo([user]),
      _FakePointRepo({const UserId(2): [entry]}),
    );

    final result = await useCase.execute(now: DateTime(2026, 4, 19, 9, 5));
    final payload = jsonDecode(result.json) as Map<String, dynamic>;
    final entries = payload['entries'] as List;
    expect(entries.first, {
      'id': 11,
      'userId': 2,
      'dateTime': entry.dateTime.toIso8601String(),
      'points': 30,
      'type': 'consumption',
      'application': 'Store',
      'tag': 'campaign',
    });
  });
}
