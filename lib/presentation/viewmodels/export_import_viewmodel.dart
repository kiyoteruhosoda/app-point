import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rewardpoints/application/usecases/data/export_data_usecase.dart';
import 'package:rewardpoints/application/usecases/data/import_data_usecase.dart';
import 'package:rewardpoints/shared/errors/app_error.dart';
import 'package:share_plus/share_plus.dart';

enum ExportImportState { idle, loading, success, error }

typedef ShareFilesFn = Future<ShareResult> Function(List<XFile> files);

final class ExportImportViewModel extends ChangeNotifier {
  ExportImportViewModel(
    this._export,
    this._import, {
    ShareFilesFn? shareFiles,
  }) : _shareFiles = shareFiles ?? _defaultShareFiles;

  final ExportDataUseCase _export;
  final ImportDataUseCase _import;
  final ShareFilesFn _shareFiles;

  ExportImportState _state = ExportImportState.idle;
  AppError? _error;
  String? _lastMessage;

  ExportImportState get state => _state;
  AppError? get error => _error;
  String? get lastMessage => _lastMessage;

  static Future<ShareResult> _defaultShareFiles(List<XFile> files) =>
      Share.shareXFiles(files);

  Future<void> exportData() async {
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _export.execute();
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, result.suggestedFileName));
      await file.writeAsString(result.json);
      await _shareFiles([
        XFile(file.path, mimeType: 'application/json', name: result.suggestedFileName),
      ]);
      _lastMessage = result.suggestedFileName;
      _state = ExportImportState.success;
    } catch (e, st) {
      _error = UnexpectedError('Export failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> importFromJson(String jsonContent) async {
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final count = await _import.executeFromJson(jsonContent);
      _lastMessage = count.toString();
      _state = ExportImportState.success;
    } on InvalidImportDataException catch (e, st) {
      _error = UnexpectedError('Invalid JSON', cause: e, stackTrace: st);
      _state = ExportImportState.error;
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
