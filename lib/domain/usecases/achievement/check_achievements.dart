import 'package:injectable/injectable.dart';
import '../../entities/achievement.dart';
import '../../entities/book.dart';
import '../../repositories/achievement_repository.dart';
import '../../repositories/streak_repository.dart';

@lazySingleton
class CheckAchievements {
  final AchievementRepository _achievementRepository;
  final StreakRepository _streakRepository;

  CheckAchievements(this._achievementRepository, this._streakRepository);

  Future<List<Achievement>> call(List<Book> books) async {
    final streak = await _streakRepository.getCurrentStreak();
    final alreadyEarned = await _achievementRepository.getEarnedAchievements();

    final readBooks = books.where((b) => b.status == BookStatus.read).toList();
    final ratedBooks = books.where((b) => b.rating != null).toList();

    // Genre counts
    final genreCounts = <String, int>{};
    for (final b in readBooks) {
      for (final g in b.genres) {
        genreCounts[g] = (genreCounts[g] ?? 0) + 1;
      }
    }
    final maxGenreCount = genreCounts.isEmpty
        ? 0
        : genreCounts.values.reduce((a, b) => a > b ? a : b);

    // Speed reader: any book read in ≤ 3 days
    final hasSpeedRead = readBooks.any((b) {
      if (b.startDate == null || b.endDate == null) return false;
      return b.endDate!.difference(b.startDate!).inDays <= 3;
    });

    bool meets(String id) {
      switch (id) {
        case 'first_book':
          return readBooks.isNotEmpty;
        case 'ten_books':
          return readBooks.length >= 10;
        case 'thirty_books':
          return readBooks.length >= 30;
        case 'streak_7':
          return streak >= 7;
        case 'streak_30':
          return streak >= 30;
        case 'critic':
          return ratedBooks.length >= 10;
        case 'genre_master':
          return maxGenreCount >= 5;
        case 'speed_reader':
          return hasSpeedRead;
        default:
          return false;
      }
    }

    final now = DateTime.now();
    final newlyEarned = <Achievement>[];
    final updatedEarned = Map<String, DateTime>.from(alreadyEarned);

    for (final achievement in Achievement.all) {
      if (!alreadyEarned.containsKey(achievement.id) && meets(achievement.id)) {
        updatedEarned[achievement.id] = now;
        newlyEarned.add(achievement.copyWith(earnedAt: now));
      }
    }

    if (newlyEarned.isNotEmpty) {
      await _achievementRepository.saveEarnedAchievements(updatedEarned);
    }

    return newlyEarned;
  }
}
