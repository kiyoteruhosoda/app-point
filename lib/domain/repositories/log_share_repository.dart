final class FileShareRequest {
  const FileShareRequest({
    required this.path,
    required this.mimeType,
    required this.chooserTitle,
    this.text,
    this.subject,
  });

  final String path;
  final String mimeType;
  final String chooserTitle;
  final String? text;
  final String? subject;
}

abstract interface class LogShareRepository {
  Future<String> share(FileShareRequest request);
}
