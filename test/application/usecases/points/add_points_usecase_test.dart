import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/application/dto/add_points_dto.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/application/usecases/points/add_points_usecase.dart';
import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/point_entry_id.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

// ─── Fake ─────────────────────────────────────────────────────────────────────

class _FakePointEntryRepository implements PointEntryRepository {
  PointAddition? _nextAddition;

  void stubAddPoints(PointAddition entry) => _nextAddition = entry;

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) async => [];

  @override
  Future<PointEntry> addPoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String reason,
  }) async =>
      _nextAddition!;

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
  late _FakePointEntryRepository fakeRepo;
  late AddPointsUseCase useCase;

  setUp(() {
    fakeRepo = _FakePointEntryRepository();
    useCase = AddPointsUseCase(fakeRepo);
  });

  test('executes and returns PointEntryDto', () async {
    final now = DateTime(2024, 6, 1, 12, 0);
    final dto = AddPointsDto(
      userId: 1,
      dateTime: now,
      points: 50,
      reason: 'Reward',
    );

    fakeRepo.stubAddPoints(PointAddition(
      id: const PointEntryId(10),
      userId: const UserId(1),
      dateTime: now,
      points: 50,
      reason: 'Reward',
    ));

    final result = await useCase.execute(dto);

    expect(result.id, 10);
    expect(result.userId, 1);
    expect(result.type, PointEntryTypeDto.addition);
    expect(result.points, 50);
    expect(result.reason, 'Reward');
  });
}
