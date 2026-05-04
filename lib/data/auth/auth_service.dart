abstract interface class AuthService {
  Future<bool> isSignedIn();
  Future<void> signIn();
  Future<void> signOut();
  Future<String?> getAccessToken();
  Future<String?> getUserEmail();
}
