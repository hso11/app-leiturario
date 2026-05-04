import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../datasources/local/database_helper.dart';

@lazySingleton
class NotificationService {
  static const int _morningId   = 10;
  static const int _afternoonId = 11;
  static const int _eveningId   = 12;
  static const String _keyEnabled = 'reading_reminders_enabled';

  final DatabaseHelper _dbHelper;
  final _plugin = FlutterLocalNotificationsPlugin();

  NotificationService(this._dbHelper);

  static const _morningMessages = [
    'Que tal começar o dia com algumas páginas? 📖',
    'Uma boa leitura pode animar qualquer manhã 😊',
    'Sua próxima aventura literária está te esperando ✨',
  ];

  static const _afternoonMessages = [
    'Ainda falta a leitura do dia, que tal depois do almoço pra relaxar? 😄',
    'A tarde é perfeita para uma pausa com um bom livro 📖',
    'Aproveite a hora do almoço para mergulhar numa boa leitura 📚',
  ];

  static const _eveningMessages = [
    'Uma leitura antes de dormir cai bem 🌙',
    'O dia está quase acabando... ainda dá tempo de ler! 📖',
    'Que tal encerrar o dia com um capítulo? Boas leituras! 🌙',
  ];

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: darwin);
    await _plugin.initialize(settings);

    try {
      await scheduleReadingReminders();
    } catch (_) {
      // Falha silenciosa — notificação não é crítica para o app funcionar
    }
  }

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
    if (enabled) {
      await scheduleReadingReminders();
    } else {
      await cancelAllReminders();
    }
  }

  Future<void> scheduleReadingReminders() async {
    if (!await isEnabled) return;

    await _plugin.cancel(_morningId);
    await _plugin.cancel(_afternoonId);
    await _plugin.cancel(_eveningId);

    if (await _hasReadToday()) return;

    const androidDetails = AndroidNotificationDetails(
      'reading_reminder',
      'Lembrete de leitura',
      channelDescription: 'Lembretes diários para ler',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    final slots = [
      (id: _morningId,   hour: 7,  title: 'Bom dia, leitor! 📚',    messages: _morningMessages),
      (id: _afternoonId, hour: 12, title: 'Lembrete de leitura 📖',  messages: _afternoonMessages),
      (id: _eveningId,   hour: 19, title: 'Hora da leitura 🌙',      messages: _eveningMessages),
    ];

    for (final slot in slots) {
      final message = slot.messages[dayOfYear % slot.messages.length];
      var target = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, slot.hour);
      if (target.isBefore(tz.TZDateTime.now(tz.local))) {
        target = target.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        slot.id,
        slot.title,
        message,
        target,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancel(_morningId);
    await _plugin.cancel(_afternoonId);
    await _plugin.cancel(_eveningId);
  }

  Future<void> onUserRead() async {
    await cancelAllReminders();
  }

  Future<bool> _hasReadToday() async {
    final now = DateTime.now();
    final todayMs =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final db = await _dbHelper.database;
    final result = await db.query(
      'reading_sessions',
      where: 'date = ?',
      whereArgs: [todayMs],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
