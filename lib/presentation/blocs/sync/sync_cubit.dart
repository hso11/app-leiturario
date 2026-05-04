import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/datasources/remote/storage_service.dart';
import '../../../data/datasources/remote/sync_service.dart';

part 'sync_state.dart';

@lazySingleton
class SyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;
  StorageService? _activeStorage;

  SyncCubit(this._syncService) : super(const SyncState());

  void setActiveStorage(StorageService storage) {
    _activeStorage = storage;
  }

  void clearActiveStorage() {
    _activeStorage = null;
  }

  Future<void> push() async {
    if (_activeStorage == null) return;
    emit(state.copyWith(status: SyncStatus.syncing, clearError: true));
    try {
      await _syncService.pushToCloud(_activeStorage!);
      emit(state.copyWith(
        status: SyncStatus.success,
        lastSync: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> pull() async {
    if (_activeStorage == null) return;
    emit(state.copyWith(status: SyncStatus.syncing, clearError: true));
    try {
      await _syncService.pullFromCloud(_activeStorage!);
      emit(state.copyWith(
        status: SyncStatus.success,
        lastSync: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
