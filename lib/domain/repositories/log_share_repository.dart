abstract interface class LogShareRepository {
  Future<String> share({required String filePath});
}
