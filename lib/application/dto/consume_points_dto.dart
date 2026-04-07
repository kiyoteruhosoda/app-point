final class ConsumePointsDto {
  const ConsumePointsDto({
    required this.userId,
    required this.dateTime,
    required this.points,
    required this.application,
    this.tag,
  });
  final int userId;
  final DateTime dateTime;
  final int points;
  final String application;
  final String? tag;
}
