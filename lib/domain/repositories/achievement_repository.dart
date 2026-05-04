import '../entities/achievement.dart';

abstract interface class AchievementRepository {
  Future<Map<String, DateTime>> getEarnedAchievements();
  Future<void> saveEarnedAchievements(Map<String, DateTime> earned);
}
