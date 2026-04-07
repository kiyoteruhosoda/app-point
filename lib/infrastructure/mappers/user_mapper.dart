import 'package:flutterbase/domain/entities/user.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';
import 'package:flutterbase/infrastructure/db/sqlite/rows/user_row.dart';

final class UserMapper {
  const UserMapper._();

  static User toDomain(UserRow row) => User(
        id: UserId(row.id),
        name: row.name,
        createdAt: DateTime.parse(row.createdAt),
      );
}
