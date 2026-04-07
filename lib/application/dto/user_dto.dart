final class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.pointBalance,
  });
  final int id;
  final String name;
  final DateTime createdAt;
  final int pointBalance;
}
