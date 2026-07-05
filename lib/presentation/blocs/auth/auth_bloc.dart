import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/auth/supabase_auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseAuthService _auth;
  late final StreamSubscription<bool> _authSub;

  AuthBloc(this._auth) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthEmailSignInRequested>(_onEmailSignIn);
    on<AuthEmailSignUpRequested>(_onEmailSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthSessionChanged>(_onSessionChanged);

    // O OAuth conclui de forma assíncrona: o navegador volta para o app pelo
    // deep link e o supabase_flutter estabelece a sessão. Reagimos a isso aqui.
    _authSub = _auth.authStateChanges
        .listen((signedIn) => add(AuthSessionChanged(signedIn)));
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }

  Future<void> _onSessionChanged(
      AuthSessionChanged event, Emitter<AuthState> emit) async {
    if (!event.isSignedIn) {
      emit(AuthUnauthenticated());
      return;
    }
    // A sincronização não roda mais automaticamente. O usuário escolhe a
    // direção (enviar/trazer) pelo ícone de sync.
    final email = await _auth.getUserEmail();
    emit(AuthAuthenticated(provider: 'supabase', userEmail: email));
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (await _auth.isSignedIn()) {
        final email = await _auth.getUserEmail();
        emit(AuthAuthenticated(provider: 'supabase', userEmail: email));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Abre o navegador; a sessão chega depois via authStateChanges.
      await _auth.signInWithGoogle();
    } catch (e) {
      emit(AuthError('Falha ao entrar com Google: $e'));
    }
  }

  Future<void> _onEmailSignIn(
      AuthEmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmail(event.email, event.password);
      // A sessão chega via authStateChanges; o estado autenticado é emitido lá.
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onEmailSignUp(
      AuthEmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _auth.signUpWithEmail(event.email, event.password);
      // Se a confirmação de e-mail estiver ligada, não há sessão ainda.
      if (res.session == null) {
        emit(AuthEmailConfirmationSent(event.email));
      }
      // Caso já venha sessão, authStateChanges emite o estado autenticado.
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  /// Traduz mensagens comuns do Supabase para PT-BR.
  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered')) {
      return 'Este e-mail já está cadastrado. Faça login.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('password')) {
      return 'A senha precisa ter pelo menos 6 caracteres.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('unable to validate email') ||
        msg.contains('invalid email')) {
      return 'E-mail inválido.';
    }
    return 'Não foi possível concluir. Tente novamente.';
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Falha ao sair: $e'));
    }
  }
}
