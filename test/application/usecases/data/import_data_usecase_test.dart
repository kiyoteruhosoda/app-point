import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/application/usecases/data/import_data_usecase.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/point_entry_id.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

class _InMemoryUserRepo implements UserRepository {
  final List<User> users = [];
  int _nextId = 1;

  @override
  Future<List<User>> getAll() async => List.unmodifiable(users);
  @override
  Future<User?> getById(UserId id) async =>
      users.where((u) => u.id == id).firstOrNull;
  @override
  Future<User> create(String name) async {
    final u = User(
      id: UserId(_nextId++),
      name: name,
      createdAt: DateTime(2026, 1, 1),
    );
    users.add(u);
    return u;
  }

  @override
  Future<void> delete(UserId id) async =>
      users.removeWhere((u) => u.id == id);
}

class _InMemoryPointRepo implements PointEntryRepository {
  final List<PointEntry> entries = [];
  int _nextId = 100;

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) async =>
      entries.where((e) => e.userId == userId).toList();
  @override
  Future<PointEntry> addPoints(
      {required UserId userId,
      required DateTime dateTime,
      required int points,
      required String reason,
      String? tag}) async {
    final e = PointAddition(
      id: PointEntryId(_nextId++),
      userId: userId,
      dateTime: dateTime,
      points: points,
      reason: reason,
      tag: tag,
    );
    entries.add(e);
    return e;
  }

  @override
  Future<PointEntry> consumePoints(
      {required UserId userId,
      required DateTime dateTime,
      required int points,
      required String application,
      String? tag}) async {
    final e = PointConsumption(
      id: PointEntryId(_nextId++),
      userId: userId,
      dateTime: dateTime,
      points: points,
      application: application,
      tag: tag,
    );
    entries.add(e);
    return e;
  }

  @override
  Future<void> update(PointEntryId id,
          {required DateTime dateTime,
          required int points,
          String? reason,
          String? application,
          String? tag}) =>
      throw UnimplementedError();
  @override
  Future<void> delete(PointEntryId id) async =>
      entries.removeWhere((e) => e.id == id);
  @override
  Future<void> deleteByUserId(UserId userId) async =>
      entries.removeWhere((e) => e.userId == userId);
  @override
  Future<List<String>> getDistinctReasons(UserId userId) async => const [];
  @override
  Future<List<String>> getDistinctApplications(UserId userId) async => const [];
}

void main() {
  late _InMemoryUserRepo userRepo;
  late _InMemoryPointRepo pointRepo;
  late ImportDataUseCase useCase;

  setUp(() {
    userRepo = _InMemoryUserRepo();
    pointRepo = _InMemoryPointRepo();
    useCase = ImportDataUseCase(userRepo, pointRepo);
  });

  test('imports users and entries, returning user count', () async {
    final json = jsonEncode({
      'users': [
        {
          'id': 5,
          'name': 'Alice',
          'createdAt': DateTime.utc(2024, 1, 1).toIso8601String(),
        },
        {
          'id': 6,
          'name': 'Bob',
          'createdAt': DateTime.utc(2024, 1, 2).toIso8601String(),
        },
      ],
      'entries': [
        {
          'id': 100,
          'userId': 5,
          'dateTime': DateTime.utc(2024, 6, 1).toIso8601String(),
          'points': 50,
          'type': 'addition',
          'reason': 'Welcome',
        },
        {
          'id': 101,
          'userId': 6,
          'dateTime': DateTime.utc(2024, 6, 2).toIso8601String(),
          'points': 30,
          'type': 'consumption',
          'application': 'Store',
          'tag': 'campaign',
        },
      ],
    });

    final count = await useCase.executeFromJson(json);

    expect(count, 2);
    expect(userRepo.users.map((u) => u.name), ['Alice', 'Bob']);
    expect(pointRepo.entries, hasLength(2));
    final addition =
        pointRepo.entries.firstWhere((e) => e is PointAddition) as PointAddition;
    expect(addition.reason, 'Welcome');
    final consumption = pointRepo.entries
        .firstWhere((e) => e is PointConsumption) as PointConsumption;
    expect(consumption.application, 'Store');
    expect(consumption.tag, 'campaign');
  });

  test('replaces existing data before importing', () async {
    await userRepo.create('OldUser');
    final json = jsonEncode({'users': [], 'entries': []});
    await useCase.executeFromJson(json);
    expect(userRepo.users, isEmpty);
  });

  test('throws InvalidImportDataException on malformed JSON', () async {
    await expectLater(
      useCase.executeFromJson('not json'),
      throwsA(isA<InvalidImportDataException>()),
    );
  });

  test('throws InvalidImportDataException when missing keys', () async {
    await expectLater(
      useCase.executeFromJson(jsonEncode({'foo': 'bar'})),
      throwsA(isA<InvalidImportDataException>()),
    );
  });
}
