import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/sync/sync_cubit.dart';
import '../../../../core/constants/app_strings.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        if (state.status == SyncStatus.syncing) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          );
        }
        if (state.status == SyncStatus.error) {
          return IconButton(
            icon: const Icon(Icons.sync_problem, color: Colors.red),
            tooltip: AppStrings.syncError,
            onPressed: () => context.read<SyncCubit>().push(),
          );
        }
        return IconButton(
          icon: const Icon(Icons.sync, color: Colors.white),
          tooltip: AppStrings.syncNow,
          onPressed: () => context.read<SyncCubit>().push(),
        );
      },
    );
  }
}
