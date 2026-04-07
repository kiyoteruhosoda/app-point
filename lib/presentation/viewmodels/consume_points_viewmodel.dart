import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/dto/consume_points_dto.dart';
import 'package:flutterbase/application/usecases/points/consume_points_usecase.dart';
import 'package:flutterbase/shared/errors/app_error.dart';

enum ConsumePointsState { idle, loading, success, error }

final class ConsumePointsViewModel extends ChangeNotifier {
  ConsumePointsViewModel(this._consumePoints);
  final ConsumePointsUseCase _consumePoints;

  ConsumePointsState _state = ConsumePointsState.idle;
  AppError? _error;

  ConsumePointsState get state => _state;
  AppError? get error => _error;

  Future<void> submit({
    required int userId,
    required DateTime dateTime,
    required int points,
    required String application,
    String? tag,
  }) async {
    _state = ConsumePointsState.loading;
    _error = null;
    notifyListeners();
    try {
      await _consumePoints.execute(ConsumePointsDto(
        userId: userId,
        dateTime: dateTime,
        points: points,
        application: application,
        tag: tag,
      ));
      _state = ConsumePointsState.success;
    } catch (e, st) {
      _error = UnexpectedError('Failed to consume points', cause: e, stackTrace: st);
      _state = ConsumePointsState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = ConsumePointsState.idle;
    _error = null;
    notifyListeners();
  }
}
