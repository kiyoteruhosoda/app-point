final class UserRow {
  const UserRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  final int id;
  final String name;
  final String createdAt; // ISO-8601

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
      };

  factory UserRow.fromMap(Map<String, dynamic> map) => UserRow(
        id: map['id'] as int,
        name: map['name'] as String,
        createdAt: map['created_at'] as String,
      );
}
