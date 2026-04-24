import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:rewardpoints/domain/repositories/log_share_repository.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:share_plus/share_plus.dart';

final class LogShareUnavailableException implements Exception {
  const LogShareUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class NativeShareGateway {
  Future<String> share(FileShareRequest request);
}

final class AndroidMethodChannelShareGateway implements NativeShareGateway {
  static const MethodChannel _channel = MethodChannel(
    'com.nolumia.rewardpoints.app/share',
  );

  @override
  Future<String> share(FileShareRequest request) async {
    final result = await _channel.invokeMethod<String>('shareFile', {
      'path': request.path,
      'mimeType': request.mimeType,
      'chooserTitle': request.chooserTitle,
      if (request.text != null) 'text': request.text,
      if (request.subject != null) 'subject': request.subject,
    });

    if (result == null || result.isEmpty) {
      throw const LogShareUnavailableException('共有結果を取得できませんでした。');
    }

    return result;
  }
}

final class SharePlusGateway implements NativeShareGateway {
  @override
  Future<String> share(FileShareRequest request) async {
    final result = await Share.shareXFiles(
      [XFile(request.path, mimeType: request.mimeType)],
      subject: request.subject,
      text: request.text,
    );

    return result.status.name;
  }
}

final class PlatformLogShareRepository implements LogShareRepository {
  PlatformLogShareRepository({
    NativeShareGateway? androidGateway,
    NativeShareGateway? fallbackGateway,
  }) : _androidGateway = androidGateway ?? AndroidMethodChannelShareGateway(),
       _fallbackGateway = fallbackGateway ?? SharePlusGateway();

  final NativeShareGateway _androidGateway;
  final NativeShareGateway _fallbackGateway;

  @override
  Future<String> share(FileShareRequest request) async {
    final status = Platform.isAndroid
        ? await _androidGateway.share(request)
        : await _fallbackGateway.share(request);

    if (status == ShareResultStatus.unavailable.name) {
      throw const LogShareUnavailableException('この端末では共有機能を利用できません。');
    }

    return status;
  }
}

final class LoggedLogShareRepository implements LogShareRepository {
  LoggedLogShareRepository(this._delegate, this._logger);

  final LogShareRepository _delegate;
  final AppLogger _logger;

  @override
  Future<String> share(FileShareRequest request) async {
    _logger.info('[LogShareRepository] share start (path: ${request.path})');
    try {
      final status = await _delegate.share(request);
      _logger.info('[LogShareRepository] share completed (status: $status)');
      return status;
    } on LogShareUnavailableException catch (e, st) {
      _logger.warning(
        '[LogShareRepository] share unavailable',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      _logger.error(
        '[LogShareRepository] share failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
