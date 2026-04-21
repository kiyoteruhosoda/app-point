import 'package:rewardpoints/domain/repositories/log_share_repository.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';

final class ShareLogsFailedException implements Exception {
  const ShareLogsFailedException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ShareLogsUseCase {
  const ShareLogsUseCase(this._logger, this._repository);

  final AppLogger _logger;
  final LogShareRepository _repository;

  Future<String> execute() async {
    final path = await _logger.exportLogs();
    if (path == null) {
      throw const ShareLogsFailedException('ログファイルの作成に失敗しました。');
    }

    try {
      return await _repository.share(
        FileShareRequest(
          path: path,
          mimeType: 'text/plain',
          chooserTitle: 'ログを共有',
          subject: 'PointBook Logs',
          text: 'PointBook application logs',
        ),
      );
    } catch (e) {
      throw ShareLogsFailedException('ログ共有に失敗しました: $e');
    }
  }
}
