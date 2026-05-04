part of 'sync_cubit.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String? errorMessage;
  final DateTime? lastSync;

  const SyncState({
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.lastSync,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? errorMessage,
    DateTime? lastSync,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSync: lastSync ?? this.lastSync,
    );
  }
}
