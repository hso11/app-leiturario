abstract interface class StreakRepository {
  Future<int> getCurrentStreak();
  Future<DateTime?> getLastReadDate();
  Future<void> recordReadingActivity(DateTime date);
  Future<Set<String>> getActivityDates();
}
