import 'package:rewardpoints/application/dto/user_dto.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';

final class CreateUserUseCase {
  const CreateUserUseCase(this._userRepo);
  final UserRepository _userRepo;

  Future<UserDto> execute(String name) async {
    final user = await _userRepo.create(name);
    return UserDto(
      id: user.id.value,
      name: user.name,
      createdAt: user.createdAt,
      pointBalance: 0,
    );
  }
}
