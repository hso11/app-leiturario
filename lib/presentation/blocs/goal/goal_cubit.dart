import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/book/get_all_books.dart';
import '../../../domain/usecases/goal/get_annual_goal.dart';
import '../../../domain/usecases/goal/set_annual_goal.dart';
import '../../../core/usecases/usecase.dart';

class GoalState {
  final int? goal;
  final int booksReadThisYear;
  const GoalState({this.goal, this.booksReadThisYear = 0});

  GoalState copyWith({int? goal, int? booksReadThisYear, bool clearGoal = false}) {
    return GoalState(
      goal: clearGoal ? null : (goal ?? this.goal),
      booksReadThisYear: booksReadThisYear ?? this.booksReadThisYear,
    );
  }
}

@lazySingleton
class GoalCubit extends Cubit<GoalState> {
  final GetAnnualGoal _getAnnualGoal;
  final SetAnnualGoal _setAnnualGoal;
  final GetAllBooks _getAllBooks;

  GoalCubit(this._getAnnualGoal, this._setAnnualGoal, this._getAllBooks)
      : super(const GoalState());

  Future<void> load() async {
    final year = DateTime.now().year;
    final goal = await _getAnnualGoal(year);
    final books = await _getAllBooks(const NoParams());
    final readThisYear = books
        .where((b) =>
            b.status == BookStatus.read && b.endDate?.year == year)
        .length;
    emit(GoalState(goal: goal, booksReadThisYear: readThisYear));
  }

  Future<void> setGoal(int goal) async {
    final year = DateTime.now().year;
    await _setAnnualGoal(SetAnnualGoalParams(year: year, goal: goal));
    emit(state.copyWith(goal: goal));
  }

  void updateBooksRead(List<Book> books) {
    final year = DateTime.now().year;
    final count = books
        .where((b) => b.status == BookStatus.read && b.endDate?.year == year)
        .length;
    if (count != state.booksReadThisYear) {
      emit(state.copyWith(booksReadThisYear: count));
    }
  }
}
