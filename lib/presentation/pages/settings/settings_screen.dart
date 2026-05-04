import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/notification_service.dart';
import '../../../injection.dart';

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
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Notificações',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          SwitchListTile(
            title: const Text('Lembretes de leitura'),
            subtitle: const Text(
                'Notificações às 7h, 12h e 19h nos dias em que você não registrar leitura'),
            value: _enabled,
            activeColor: AppColors.primary,
            onChanged: _toggleNotification,
          ),
        ],
      ),
    );
  }
}
