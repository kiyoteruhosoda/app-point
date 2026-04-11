import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

final class GetPointBalanceUseCase {
  const GetPointBalanceUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<int> execute(int userId) async {
    final entries = await _repo.getByUserId(UserId(userId));
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
