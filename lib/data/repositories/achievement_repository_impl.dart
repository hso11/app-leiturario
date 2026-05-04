import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/achievement_repository.dart';

@LazySingleton(as: AchievementRepository)
class AchievementRepositoryImpl implements AchievementRepository {
  static const _key = 'achievements_earned';

  @override
  Future<Map<String, DateTime>> getEarnedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, DateTime.parse(v as String)));
  }

  @override
  Future<void> saveEarnedAchievements(Map<String, DateTime> earned) async {
    final prefs = await SharedPreferences.getInstance();
    final map = earned.map((k, v) => MapEntry(k, v.toIso8601String()));
    await prefs.setString(_key, jsonEncode(map));
  }
}
