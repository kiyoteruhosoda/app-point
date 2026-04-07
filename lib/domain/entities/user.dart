import 'package:flutterbase/domain/value_objects/user_id.dart';

final class User {
  const User({required this.id, required this.name, required this.createdAt});
  final UserId id;
  final String name;
  final DateTime createdAt;

  User copyWith({UserId? id, String? name, DateTime? createdAt}) => User(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
}
