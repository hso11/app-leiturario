import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_controle_leitura/data/repositories/streak_repository_impl.dart';

void main() {
  late StreakRepositoryImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = StreakRepositoryImpl();
  });

  test('first registration sets streak to 1', () async {
    await repo.recordReadingActivity(DateTime(2024, 1, 1));
    expect(await repo.getCurrentStreak(), 1);
  });

  test('same day does not change streak', () async {
    await repo.recordReadingActivity(DateTime(2024, 1, 1));
    await repo.recordReadingActivity(DateTime(2024, 1, 1, 22, 0));
    expect(await repo.getCurrentStreak(), 1);
  });

  test('consecutive day increments streak', () async {
    await repo.recordReadingActivity(DateTime(2024, 1, 1));
    await repo.recordReadingActivity(DateTime(2024, 1, 2));
    expect(await repo.getCurrentStreak(), 2);
  });

  test('gap of 2+ days resets streak to 1', () async {
    await repo.recordReadingActivity(DateTime(2024, 1, 1));
    await repo.recordReadingActivity(DateTime(2024, 1, 3));
    expect(await repo.getCurrentStreak(), 1);
  });

  test('getLastReadDate returns null before any activity', () async {
    expect(await repo.getLastReadDate(), isNull);
  });

  test('getLastReadDate returns date after activity', () async {
    await repo.recordReadingActivity(DateTime(2024, 3, 15));
    final last = await repo.getLastReadDate();
    expect(last, isNotNull);
    expect(last!.day, 15);
    expect(last.month, 3);
  });
}
