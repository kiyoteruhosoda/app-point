import 'package:rewardpoints/application/dto/user_dto.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';

final class GetUsersUseCase {
  const GetUsersUseCase(this._userRepo, this._pointRepo);
  final UserRepository _userRepo;
  final PointEntryRepository _pointRepo;

  Future<List<UserDto>> execute() async {
    final users = await _userRepo.getAll();
    final result = <UserDto>[];
    for (final user in users) {
      final entries = await _pointRepo.getByUserId(user.id);
      final balance = _computeBalance(entries);
      result.add(UserDto(
        id: user.id.value,
        name: user.name,
        createdAt: user.createdAt,
        pointBalance: balance,
      ));
    }
    return result;
  }

  int _computeBalance(List<PointEntry> entries) {
    var balance = 0;
    for (final e in entries) {
      if (e is PointAddition) {
        balance += e.points;
      } else if (e is PointConsumption) {
        balance -= e.points;
      }
    }
    return balance;
  }
}
