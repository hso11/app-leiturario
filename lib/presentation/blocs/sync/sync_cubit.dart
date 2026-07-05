import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/datasources/remote/supabase_sync_service.dart';

part 'sync_state.dart';

@lazySingleton
class SyncCubit extends Cubit<SyncState> {
  final SupabaseSyncService _syncService;

  SyncCubit(this._syncService) : super(const SyncState());

  /// Envia os dados do celular para a nuvem (backup).
  Future<void> push() => _run(_syncService.push);

  /// Traz os dados da nuvem para o celular (mescla por id).
  Future<void> pull() => _run(_syncService.pull);

  Future<void> _run(Future<void> Function() action) async {
    emit(state.copyWith(status: SyncStatus.syncing, clearError: true));
    try {
      await action();
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
