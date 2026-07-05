part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String provider; // sempre 'supabase' (Google ou e-mail/senha)
  final String? userEmail;
  AuthAuthenticated({required this.provider, this.userEmail});
}

class AuthUnauthenticated extends AuthState {}

/// Cadastro concluído, mas a sessão depende de confirmação por e-mail
/// (confirmação ligada no painel do Supabase).
class AuthEmailConfirmationSent extends AuthState {
  final String email;
  AuthEmailConfirmationSent(this.email);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
