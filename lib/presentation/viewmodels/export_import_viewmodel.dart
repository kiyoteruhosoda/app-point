import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/usecases/data/export_data_usecase.dart';
import 'package:flutterbase/application/usecases/data/import_data_usecase.dart';
import 'package:flutterbase/shared/errors/app_error.dart';

enum ExportImportState { idle, loading, success, error }

final class ExportImportViewModel extends ChangeNotifier {
  ExportImportViewModel(this._export, this._import);
  final ExportDataUseCase _export;
  final ImportDataUseCase _import;

  ExportImportState _state = ExportImportState.idle;
  AppError? _error;
  String? _lastMessage;

  ExportImportState get state => _state;
  AppError? get error => _error;
  String? get lastMessage => _lastMessage;

  Future<void> exportData() async {
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final path = await _export.execute();
      _lastMessage = path;
      _state = ExportImportState.success;
    } catch (e, st) {
      _error = UnexpectedError('Export failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> importData(String filePath) async {
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final count = await _import.execute(filePath);
      _lastMessage = 'Imported $count users successfully';
      _state = ExportImportState.success;
    } catch (e, st) {
      _error = UnexpectedError('Import failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = ExportImportState.idle;
    _error = null;
    _lastMessage = null;
    notifyListeners();
  }
}
