enum PointEntryTypeDto { addition, consumption }

final class PointEntryDto {
  const PointEntryDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.dateTime,
    required this.points,
    this.reason,
    this.application,
    this.tag,
  });
  final int id;
  final int userId;
  final PointEntryTypeDto type;
  final DateTime dateTime;
  final int points;
  final String? reason;
  final String? application;
  final String? tag;
}
