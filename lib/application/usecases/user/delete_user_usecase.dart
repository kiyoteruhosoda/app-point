import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

final class DeleteUserUseCase {
  const DeleteUserUseCase(this._userRepo, this._pointRepo);
  final UserRepository _userRepo;
  final PointEntryRepository _pointRepo;

  Future<void> execute(int userId) async {
    final id = UserId(userId);
    await _pointRepo.deleteByUserId(id);
    await _userRepo.delete(id);
  }
}
