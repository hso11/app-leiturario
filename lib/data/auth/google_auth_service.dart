import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'auth_service.dart';

@lazySingleton
class GoogleAuthService implements AuthService {
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  @override
  Future<bool> isSignedIn() => _googleSignIn.isSignedIn();

  @override
  Future<void> signIn() async {
    await _googleSignIn.signIn();
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<String?> getAccessToken() async {
    final account = _googleSignIn.currentUser ??
        await _googleSignIn.signInSilently();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.accessToken;
  }

  @override
  Future<String?> getUserEmail() async {
    final account = _googleSignIn.currentUser;
    return account?.email;
  }
}
