abstract interface class StorageService {
  String get providerId;
  Future<bool> isAuthenticated();
  Future<void> upload(Map<String, dynamic> payload);
  Future<Map<String, dynamic>?> download();
  Future<void> deleteRemote();
}
