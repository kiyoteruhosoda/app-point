import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/domain/repositories/log_share_repository.dart';
import 'package:rewardpoints/infrastructure/logging/log_share_repository_impl.dart';

class _FakeShareGateway implements NativeShareGateway {
  _FakeShareGateway(this.result);

  final String result;
  FileShareRequest? lastRequest;

  @override
  Future<String> share(FileShareRequest request) async {
    lastRequest = request;
    return result;
  }
}

void main() {
  test('Android以外ではフォールバック実装を利用する', () async {
    final android = _FakeShareGateway('android');
    final fallback = _FakeShareGateway('dismissed');
    final repository = PlatformLogShareRepository(
      androidGateway: android,
      fallbackGateway: fallback,
    );

    final result = await repository.share(
      const FileShareRequest(
        path: '/tmp/export.log',
        mimeType: 'text/plain',
        chooserTitle: 'ログを共有',
      ),
    );

    expect(result, 'dismissed');
    expect(android.lastRequest, isNull);
    expect(fallback.lastRequest?.path, '/tmp/export.log');
  });
}
