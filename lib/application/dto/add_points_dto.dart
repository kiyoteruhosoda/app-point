final class AddPointsDto {
  const AddPointsDto({
    required this.userId,
    required this.dateTime,
    required this.points,
    required this.reason,
  });
  final int userId;
  final DateTime dateTime;
  final int points;
  final String reason;
}
