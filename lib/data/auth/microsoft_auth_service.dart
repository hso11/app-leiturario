import 'package:injectable/injectable.dart';
import 'auth_service.dart';

/// Stub para validação no emulador.
/// Substituir por implementação real (aad_oauth ou msal_flutter) antes da Play Store.
@lazySingleton
class MicrosoftAuthService implements AuthService {
  @override
  Future<bool> isSignedIn() async => false;

  @override
  Future<void> signIn() async {
    throw UnimplementedError(
        'Microsoft auth não configurado. Configure aad_oauth antes da publicação.');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getUserEmail() async => null;
}
