import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/streak_repository.dart';

class StreakState {
  final int currentStreak;
  final DateTime? lastReadDate;
  const StreakState({this.currentStreak = 0, this.lastReadDate});
}

@lazySingleton
class StreakCubit extends Cubit<StreakState> {
  final StreakRepository _repository;

  StreakCubit(this._repository) : super(const StreakState());

  Future<void> load() async {
    final streak = await _repository.getCurrentStreak();
    final lastDate = await _repository.getLastReadDate();
    emit(StreakState(currentStreak: streak, lastReadDate: lastDate));
  }

  Future<void> recordActivity() async {
    await _repository.recordReadingActivity(DateTime.now());
    final streak = await _repository.getCurrentStreak();
    final lastDate = await _repository.getLastReadDate();
    emit(StreakState(currentStreak: streak, lastReadDate: lastDate));
  }

  Future<Set<String>> getActivityDates() => _repository.getActivityDates();
}
