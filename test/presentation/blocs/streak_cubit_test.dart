import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/presentation/blocs/streak/streak_cubit.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockStreakRepository repo;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockStreakRepository();
  });

  StreakCubit buildCubit() => StreakCubit(repo);

  group('StreakCubit.load', () {
    blocTest<StreakCubit, StreakState>(
      'loads streak and lastReadDate from repository',
      build: buildCubit,
      setUp: () {
        when(() => repo.getCurrentStreak()).thenAnswer((_) async => 5);
        when(() => repo.getLastReadDate())
            .thenAnswer((_) async => DateTime(2024, 4, 10));
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<StreakState>()
            .having((s) => s.currentStreak, 'streak', 5)
            .having((s) => s.lastReadDate?.day, 'lastReadDate.day', 10),
      ],
    );
  });

  group('StreakCubit.recordActivity', () {
    blocTest<StreakCubit, StreakState>(
      'calls repository and reloads state',
      build: buildCubit,
      setUp: () {
        when(() => repo.recordReadingActivity(any())).thenAnswer((_) async {});
        when(() => repo.getCurrentStreak()).thenAnswer((_) async => 3);
        when(() => repo.getLastReadDate())
            .thenAnswer((_) async => DateTime(2024, 4, 11));
      },
      act: (cubit) => cubit.recordActivity(),
      expect: () => [
        isA<StreakState>().having((s) => s.currentStreak, 'streak', 3),
      ],
      verify: (_) {
        verify(() => repo.recordReadingActivity(any())).called(1);
      },
    );
  });
}
