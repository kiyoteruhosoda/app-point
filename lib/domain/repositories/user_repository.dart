import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

abstract interface class UserRepository {
  Future<List<User>> getAll();
  Future<User?> getById(UserId id);
  Future<User> create(String name);
  Future<void> delete(UserId id);
}
