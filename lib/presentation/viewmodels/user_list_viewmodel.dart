import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/dto/user_dto.dart';
import 'package:flutterbase/application/usecases/user/create_user_usecase.dart';
import 'package:flutterbase/application/usecases/user/delete_user_usecase.dart';
import 'package:flutterbase/application/usecases/user/get_users_usecase.dart';
import 'package:flutterbase/shared/errors/app_error.dart';

enum UserListState { loading, loaded, empty, error }

final class UserListViewModel extends ChangeNotifier {
  UserListViewModel(this._getUsers, this._createUser, this._deleteUser);
  final GetUsersUseCase _getUsers;
  final CreateUserUseCase _createUser;
  final DeleteUserUseCase _deleteUser;

  UserListState _state = UserListState.loading;
  List<UserDto> _users = [];
  AppError? _error;

  UserListState get state => _state;
  List<UserDto> get users => _users;
  AppError? get error => _error;

  Future<void> load() async {
    _state = UserListState.loading;
    _error = null;
    notifyListeners();
    try {
      _users = await _getUsers.execute();
      _state = _users.isEmpty ? UserListState.empty : UserListState.loaded;
    } catch (e, st) {
      _error = UnexpectedError('Failed to load users', cause: e, stackTrace: st);
      _state = UserListState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> createUser(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await _createUser.execute(name.trim());
      await load();
    } catch (e, st) {
      _error = UnexpectedError('Failed to create user', cause: e, stackTrace: st);
      _state = UserListState.error;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _deleteUser.execute(userId);
      await load();
    } catch (e, st) {
      _error = UnexpectedError('Failed to delete user', cause: e, stackTrace: st);
      _state = UserListState.error;
      notifyListeners();
    }
  }
}
