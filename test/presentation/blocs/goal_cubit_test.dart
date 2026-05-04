import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/core/usecases/usecase.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import 'package:app_controle_leitura/domain/usecases/goal/set_annual_goal.dart';
import 'package:app_controle_leitura/presentation/blocs/goal/goal_cubit.dart';
import '../../helpers/mocks.dart';
import '../../helpers/book_factory.dart';

void main() {
  late MockGetAnnualGoal getAnnualGoal;
  late MockSetAnnualGoal setAnnualGoal;
  late MockGetAllBooks getAllBooks;

  setUpAll(registerFallbacks);

  setUp(() {
    getAnnualGoal = MockGetAnnualGoal();
    setAnnualGoal = MockSetAnnualGoal();
    getAllBooks = MockGetAllBooks();
  });

  GoalCubit buildCubit() =>
      GoalCubit(getAnnualGoal, setAnnualGoal, getAllBooks);

  final currentYear = DateTime.now().year;

  group('GoalCubit.load', () {
    blocTest<GoalCubit, GoalState>(
      'loads goal and counts books read in current year',
      build: buildCubit,
      setUp: () {
        when(() => getAnnualGoal(currentYear)).thenAnswer((_) async => 12);
        when(() => getAllBooks(const NoParams())).thenAnswer((_) async => [
              makeBook(
                  status: BookStatus.read,
                  endDate: DateTime(currentYear, 6, 1)),
              makeBook(
                  id: '2',
                  status: BookStatus.read,
                  endDate: DateTime(currentYear, 9, 1)),
              makeBook(
                  id: '3',
                  status: BookStatus.wantToRead),
            ]);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<GoalState>().having((s) => s.goal, 'goal', 12).having(
            (s) => s.booksReadThisYear, 'booksReadThisYear', 2),
      ],
    );
  });

  group('GoalCubit.setGoal', () {
    blocTest<GoalCubit, GoalState>(
      'persists goal and emits updated state',
      build: buildCubit,
      setUp: () {
        when(() => setAnnualGoal(any())).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.setGoal(20),
      expect: () => [
        isA<GoalState>().having((s) => s.goal, 'goal', 20),
      ],
      verify: (_) {
        final captured =
            verify(() => setAnnualGoal(captureAny())).captured;
        final params = captured.first as SetAnnualGoalParams;
        expect(params.goal, 20);
        expect(params.year, currentYear);
      },
    );
  });

  group('GoalCubit.updateBooksRead', () {
    test('emits new state when count changes', () {
      final cubit = buildCubit();
      final books = [
        makeBook(status: BookStatus.read, endDate: DateTime(currentYear, 1, 1)),
      ];
      cubit.updateBooksRead(books);
      expect(cubit.state.booksReadThisYear, 1);
    });

    test('does not emit when count is the same', () async {
      final cubit = buildCubit();
      // Initial state has booksReadThisYear = 0
      cubit.updateBooksRead([]); // same count — no emit
      expect(cubit.state.booksReadThisYear, 0);
    });
  });
}
