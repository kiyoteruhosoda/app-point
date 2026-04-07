import 'package:flutterbase/application/dto/consume_points_dto.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

final class ConsumePointsUseCase {
  const ConsumePointsUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<PointEntryDto> execute(ConsumePointsDto dto) async {
    final entry = await _repo.consumePoints(
      userId: UserId(dto.userId),
      dateTime: dto.dateTime,
      points: dto.points,
      application: dto.application,
      tag: dto.tag,
    );
    final consumption = entry as PointConsumption;
    return PointEntryDto(
      id: entry.id.value,
      userId: dto.userId,
      type: PointEntryTypeDto.consumption,
      dateTime: entry.dateTime,
      points: entry.points,
      application: consumption.application,
      tag: consumption.tag,
    );
  }
}
