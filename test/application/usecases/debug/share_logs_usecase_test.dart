import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/application/usecases/debug/share_logs_usecase.dart';
import 'package:rewardpoints/domain/repositories/log_share_repository.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:rewardpoints/shared/logging/log_entry.dart';
import 'package:rewardpoints/shared/logging/log_level.dart';

class _FakeLogger implements AppLogger {
  _FakeLogger({this.exportPath});

  final String? exportPath;

  @override
  void clearBuffer() {}

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  List<LogEntry> get entries => const [];

  @override
  List<LogEntry> entriesForLevel(LogLevel? level) => const [];

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  Future<String?> exportLogs() async => exportPath;

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  Future<List<File>> logFiles() async => const [];

  @override
  LogLevel get minLevel => LogLevel.info;

  @override
  void setMinLevel(LogLevel level) {}

  @override
  void verbose(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
}

class _FakeLogShareRepository implements LogShareRepository {
  FileShareRequest? request;
  String status = 'success';

  @override
  Future<String> share(FileShareRequest request) async {
    this.request = request;
    return status;
  }
}

void main() {
  test('exportしたログファイルを共有し、共有ステータスを返す', () async {
    final logger = _FakeLogger(exportPath: '/tmp/logs/export.log');
    final repository = _FakeLogShareRepository()..status = 'dismissed';
    final useCase = ShareLogsUseCase(logger, repository);

    final result = await useCase.execute();

    expect(result, 'dismissed');
    expect(repository.request?.path, '/tmp/logs/export.log');
    expect(repository.request?.mimeType, 'text/plain');
    expect(repository.request?.chooserTitle, 'ログを共有');
  });

  test('exportに失敗した場合はドメイン例外を返す', () async {
    final logger = _FakeLogger(exportPath: null);
    final repository = _FakeLogShareRepository();
    final useCase = ShareLogsUseCase(logger, repository);

    expect(useCase.execute, throwsA(isA<ShareLogsFailedException>()));
  });
}
