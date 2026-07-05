import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/sync/sync_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SyncCubit, SyncState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SyncStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text(AppStrings.syncSuccess),
              behavior: SnackBarBehavior.floating,
            ));
        } else if (state.status == SyncStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? AppStrings.syncError),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
        }
      },
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
        final hasError = state.status == SyncStatus.error;
        return IconButton(
          icon: Icon(
            hasError ? Icons.sync_problem : Icons.sync,
            color: hasError ? Colors.red : Colors.white,
          ),
          tooltip: hasError ? AppStrings.syncError : AppStrings.syncNow,
          onPressed: () => showSyncDirectionSheet(context),
        );
      },
    );
  }
}

/// Pergunta a direção do sync (enviar para a nuvem ou trazer da nuvem) e
/// dispara a ação escolhida no [SyncCubit].
void showSyncDirectionSheet(BuildContext context) {
  final cubit = context.read<SyncCubit>();
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Sincronizar',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: AppColors.primary),
              title: const Text('Enviar para a nuvem'),
              subtitle: const Text(
                  'Faz backup dos dados deste celular no Supabase.'),
              onTap: () {
                Navigator.pop(sheetContext);
                cubit.push();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.cloud_download, color: AppColors.secondary),
              title: const Text('Trazer da nuvem'),
              subtitle: const Text(
                  'Baixa os dados salvos na nuvem e mescla com este celular. '
                  'Útil ao reinstalar o app ou trocar de aparelho.'),
              onTap: () {
                Navigator.pop(sheetContext);
                cubit.pull();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
