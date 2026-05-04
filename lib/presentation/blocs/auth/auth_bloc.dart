import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/auth/google_auth_service.dart';
import '../../../data/auth/microsoft_auth_service.dart';
import '../../../data/datasources/remote/google_drive_storage.dart';
import '../../../data/datasources/remote/onedrive_storage.dart';
import '../../../data/datasources/remote/sync_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleAuthService _googleAuth;
  final MicrosoftAuthService _microsoftAuth;
  final SyncService _syncService;
  final GoogleDriveStorage _googleDrive;
  final OneDriveStorage _oneDrive;

  AuthBloc(
    this._googleAuth,
    this._microsoftAuth,
    this._syncService,
    this._googleDrive,
    this._oneDrive,
  ) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthMicrosoftSignInRequested>(_onMicrosoftSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (await _googleAuth.isSignedIn()) {
        await _syncService.pullFromCloud(_googleDrive);
        final email = await _googleAuth.getUserEmail();
        emit(AuthAuthenticated(provider: 'google', userEmail: email));
      } else if (await _microsoftAuth.isSignedIn()) {
        await _syncService.pullFromCloud(_oneDrive);
        final email = await _microsoftAuth.getUserEmail();
        emit(AuthAuthenticated(provider: 'microsoft', userEmail: email));
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
      await _googleAuth.signIn();
      await _syncService.pullFromCloud(_googleDrive);
      final email = await _googleAuth.getUserEmail();
      emit(AuthAuthenticated(provider: 'google', userEmail: email));
    } catch (e) {
      emit(AuthError('Falha ao entrar com Google: $e'));
    }
  }

  Future<void> _onMicrosoftSignIn(
      AuthMicrosoftSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _microsoftAuth.signIn();
      await _syncService.pullFromCloud(_oneDrive);
      final email = await _microsoftAuth.getUserEmail();
      emit(AuthAuthenticated(provider: 'microsoft', userEmail: email));
    } catch (e) {
      emit(AuthError('Falha ao entrar com Microsoft: $e'));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (await _googleAuth.isSignedIn()) {
        await _googleAuth.signOut();
      } else if (await _microsoftAuth.isSignedIn()) {
        await _microsoftAuth.signOut();
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Falha ao sair: $e'));
    }
  }
}
