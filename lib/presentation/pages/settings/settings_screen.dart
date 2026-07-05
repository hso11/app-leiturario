import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/subscription_constants.dart';
import '../../../data/services/notification_service.dart';
import '../../../injection.dart';
import '../../blocs/subscription/subscription_cubit.dart';
import '../../blocs/sync/sync_cubit.dart';
import '../paywall/paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = getIt<NotificationService>();
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _notificationService.isEnabled;
    setState(() => _enabled = enabled);
  }

  Future<void> _toggleNotification(bool value) async {
    await _notificationService.setRemindersEnabled(value);
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, subState) {
          final isPremium = subState is SubscriptionPremium;
          return ListView(
            children: [
              // Plano atual
              _sectionHeader('Plano'),
              ListTile(
                leading: Icon(
                  isPremium ? Icons.auto_awesome : Icons.lock_outline,
                  color: isPremium ? AppColors.secondary : AppColors.textSecondary,
                ),
                title: Text(isPremium ? 'Leiturário Premium' : 'Plano Gratuito'),
                subtitle: Text(isPremium
                    ? 'Biblioteca ilimitada'
                    : 'Grátis até ${SubscriptionConstants.freeMaxBooks} livros • Premium para ilimitado'),
                trailing: isPremium
                    ? null
                    : ElevatedButton(
                        onPressed: () => PaywallScreen.show(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('Upgrade'),
                      ),
              ),

              // Sync em nuvem (disponível para todos)
              _sectionHeader('Sync em nuvem'),
              BlocConsumer<SyncCubit, SyncState>(
                listenWhen: (prev, curr) => prev.status != curr.status,
                listener: (context, syncState) {
                  if (syncState.status == SyncStatus.success) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text(AppStrings.syncSuccess),
                        behavior: SnackBarBehavior.floating,
                      ));
                  } else if (syncState.status == SyncStatus.error) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                            syncState.errorMessage ?? AppStrings.syncError),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ));
                  }
                },
                builder: (context, syncState) {
                  final syncing = syncState.status == SyncStatus.syncing;
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cloud_upload,
                            color: AppColors.primary),
                        title: const Text('Enviar para a nuvem'),
                        subtitle: Text(syncState.lastSync != null
                            ? 'Último sync: ${_formatDateTime(syncState.lastSync!)}'
                            : 'Faz backup deste celular no Supabase'),
                        trailing: syncing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        onTap: syncing
                            ? null
                            : () => context.read<SyncCubit>().push(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.cloud_download,
                            color: AppColors.secondary),
                        title: const Text('Trazer da nuvem'),
                        subtitle: const Text(
                            'Baixa os dados da nuvem e mescla com este celular'),
                        trailing: const Icon(Icons.download),
                        onTap: syncing
                            ? null
                            : () => context.read<SyncCubit>().pull(),
                      ),
                      if (syncState.status == SyncStatus.error &&
                          syncState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            syncState.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Notificações
              _sectionHeader('Notificações'),
              SwitchListTile(
                title: const Text('Lembretes de leitura'),
                subtitle: const Text(
                    'Notificações às 7h, 12h e 19h nos dias em que você não registrar leitura'),
                value: _enabled,
                activeThumbColor: AppColors.primary,
                onChanged: _toggleNotification,
              ),

              // Ajuda
              _sectionHeader(AppStrings.tutorialHelpSection),
              ListTile(
                leading: const Icon(Icons.school_outlined,
                    color: AppColors.primary),
                title: const Text(AppStrings.tutorialMenuItem),
                subtitle: const Text('Reveja como usar o app'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/tutorial?from=settings'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'há ${diff.inHours}h';
    return '${dt.day}/${dt.month} às ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
