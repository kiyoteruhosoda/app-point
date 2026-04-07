final class PointEntryRow {
  const PointEntryRow({
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
  final String type; // 'addition' | 'consumption'
  final String dateTime; // ISO-8601
  final int points;
  final String? reason;
  final String? application;
  final String? tag;

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'date_time': dateTime,
        'points': points,
        'reason': reason,
        'application': application,
        'tag': tag,
      };

  factory PointEntryRow.fromMap(Map<String, dynamic> map) => PointEntryRow(
        id: map['id'] as int,
        userId: map['user_id'] as int,
        type: map['type'] as String,
        dateTime: map['date_time'] as String,
        points: map['points'] as int,
        reason: map['reason'] as String?,
        application: map['application'] as String?,
        tag: map['tag'] as String?,
      );
}
