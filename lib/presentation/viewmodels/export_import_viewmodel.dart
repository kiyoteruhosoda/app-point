import 'package:flutter/foundation.dart';
import 'package:rewardpoints/application/usecases/data/export_data_usecase.dart';
import 'package:rewardpoints/application/usecases/data/import_data_usecase.dart';
import 'package:rewardpoints/infrastructure/files/export_file_writer.dart';
import 'package:rewardpoints/shared/errors/app_error.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';

enum ExportImportState { idle, loading, success, error }

final class ExportImportViewModel extends ChangeNotifier {
  ExportImportViewModel(
    this._export,
    this._import,
    this._fileWriter,
    this._logger,
  );

  final ExportDataUseCase _export;
  final ImportDataUseCase _import;
  final ExportFileWriter _fileWriter;
  final AppLogger _logger;

  ExportImportState _state = ExportImportState.idle;
  AppError? _error;
  String? _lastMessage;

  ExportImportState get state => _state;
  AppError? get error => _error;
  String? get lastMessage => _lastMessage;

  Future<void> exportData() async {
    _logger.debug('[ExportImportViewModel] exportData started');
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _export.execute();
      final shareResult = await _fileWriter.shareJson(
        suggestedFileName: result.suggestedFileName,
        json: result.json,
      );
      _lastMessage = shareResult;
      _logger.info(
        '[ExportImportViewModel] exportData succeeded (status: $shareResult)',
      );
      _state = ExportImportState.success;
    } on ExportShareUnavailableException catch (e, st) {
      _logger.warning(
        '[ExportImportViewModel] exportData unavailable',
        error: e,
        stackTrace: st,
      );
      _error = UnexpectedError(e.message, cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } catch (e, st) {
      _logger.error(
        '[ExportImportViewModel] exportData failed',
        error: e,
        stackTrace: st,
      );
      _error = UnexpectedError('Share failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> importFromJson(String jsonContent) async {
    _logger.debug(
      '[ExportImportViewModel] importFromJson started (bytes: ${jsonContent.length})',
    );
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final count = await _import.executeFromJson(jsonContent);
      _lastMessage = count.toString();
      _logger.info(
        '[ExportImportViewModel] importFromJson succeeded (users: $count)',
      );
      _state = ExportImportState.success;
    } on InvalidImportDataException catch (e, st) {
      _logger.warning(
        '[ExportImportViewModel] importFromJson invalid data',
        error: e,
        stackTrace: st,
      );
      _error = UnexpectedError('Invalid JSON', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } catch (e, st) {
      _logger.error(
        '[ExportImportViewModel] importFromJson failed',
        error: e,
        stackTrace: st,
      );
      _error = UnexpectedError('Import failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _logger.debug('[ExportImportViewModel] reset');
    _state = ExportImportState.idle;
    _error = null;
    _lastMessage = null;
    notifyListeners();
  }
}
