import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/streak_repository.dart';

@LazySingleton(as: StreakRepository)
class StreakRepositoryImpl implements StreakRepository {
  static const _keyCount = 'streak_count';
  static const _keyLastDate = 'streak_last_date';
  static const _keyActivitySet = 'streak_activity_set';

  @override
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCount) ?? 0;
  }

  @override
  Future<DateTime?> getLastReadDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyLastDate);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  @override
  Future<void> recordReadingActivity(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_keyLastDate);
    final currentStreak = prefs.getInt(_keyCount) ?? 0;

    final today = DateTime(date.year, date.month, date.day);
    final todayStr = _dateKey(today);
    int newStreak;

    if (lastMs == null) {
      newStreak = 1;
    } else {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // Same day — just update activity set
        await _addToActivitySet(prefs, todayStr);
        return;
      } else if (diff == 1) {
        newStreak = currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    await prefs.setInt(_keyCount, newStreak);
    await prefs.setInt(_keyLastDate, today.millisecondsSinceEpoch);
    await _addToActivitySet(prefs, todayStr);
  }

  @override
  Future<Set<String>> getActivityDates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyActivitySet);
    if (raw == null) return {};
    final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
    return list.toSet();
  }

  Future<void> _addToActivitySet(SharedPreferences prefs, String dateStr) async {
    final raw = prefs.getString(_keyActivitySet);
    final set = raw != null
        ? (jsonDecode(raw) as List<dynamic>).cast<String>().toSet()
        : <String>{};
    set.add(dateStr);
    // Keep only last 90 days
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    set.removeWhere((s) {
      final parts = s.split('-');
      if (parts.length != 3) return true;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return d.isBefore(cutoff);
    });
    await prefs.setString(_keyActivitySet, jsonEncode(set.toList()));
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
