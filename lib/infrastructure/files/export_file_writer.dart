import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ExportFileWriter {
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  });
}

final class ExportShareUnavailableException implements Exception {
  const ExportShareUnavailableException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class PlatformExportFileWriter implements ExportFileWriter {
  @override
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$suggestedFileName');
    await file.writeAsString(json, encoding: utf8, flush: true);

    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      fileNameOverrides: [suggestedFileName],
      subject: 'RewardPoints Export',
      text: 'RewardPoints data export JSON',
    );

    if (result.status == ShareResultStatus.unavailable) {
      throw const ExportShareUnavailableException(
        'この端末では共有先アプリ選択が利用できません（share_plus status: unavailable）。',
      );
    }

    return result.status.name;
  }
}

final class LoggedExportFileWriter implements ExportFileWriter {
  LoggedExportFileWriter(this._delegate, this._logger);

  final ExportFileWriter _delegate;
  final AppLogger _logger;

  @override
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  }) async {
    _logger.info(
      '[ExportFileWriter] shareJson start '
      '(fileName: $suggestedFileName, bytes: ${utf8.encode(json).length})',
    );
    try {
      final result = await _delegate.shareJson(
        suggestedFileName: suggestedFileName,
        json: json,
      );
      _logger.info(
        '[ExportFileWriter] shareJson completed (status: $result)',
      );
      return result;
    } on ExportShareUnavailableException catch (e, st) {
      _logger.warning(
        '[ExportFileWriter] shareJson unavailable',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      _logger.error(
        '[ExportFileWriter] shareJson failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
