import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

@lazySingleton
class SupabaseAuthService implements AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Deep link de retorno do OAuth. Precisa bater com o intent-filter do
  /// AndroidManifest (scheme `com.helio.controleleitura`, host `login-callback`)
  /// e estar cadastrado em Authentication > URL Configuration > Redirect URLs
  /// no dashboard do Supabase.
  static const _redirectUrl = 'com.helio.controleleitura://login-callback/';

  /// Emite `true` quando uma sessão fica ativa (login concluído, inclusive
  /// quando o OAuth retorna pelo deep link) e `false` no logout.
  Stream<bool> get authStateChanges => _client.auth.onAuthStateChange
      .where((d) =>
          d.event == AuthChangeEvent.signedIn ||
          d.event == AuthChangeEvent.signedOut)
      .map((d) => d.event == AuthChangeEvent.signedIn);

  @override
  Future<bool> isSignedIn() async => _client.auth.currentUser != null;

  @override
  Future<void> signIn() => signInWithGoogle();

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirectUrl,
    );
  }

  /// Login com e-mail e senha. A sessão chega de forma síncrona e também
  /// dispara `authStateChanges`.
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Cadastro com e-mail e senha. Se a confirmação de e-mail estiver ligada no
  /// painel do Supabase, a sessão só fica ativa após o usuário confirmar.
  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  /// Envia e-mail para redefinição de senha.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<String?> getAccessToken() async =>
      _client.auth.currentSession?.accessToken;

  @override
  Future<String?> getUserEmail() async => _client.auth.currentUser?.email;
}
