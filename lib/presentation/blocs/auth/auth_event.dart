part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthEmailSignInRequested(this.email, this.password);
}

class AuthEmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  AuthEmailSignUpRequested(this.email, this.password);
}

class AuthSignOutRequested extends AuthEvent {}

/// Disparado internamente quando o supabase_flutter sinaliza login/logout
/// (inclusive o retorno do OAuth pelo deep link).
class AuthSessionChanged extends AuthEvent {
  final bool isSignedIn;
  AuthSessionChanged(this.isSignedIn);
}
