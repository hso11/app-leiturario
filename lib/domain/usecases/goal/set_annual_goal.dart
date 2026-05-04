import 'package:injectable/injectable.dart';
import '../../repositories/goal_repository.dart';

class SetAnnualGoalParams {
  final int year;
  final int goal;
  const SetAnnualGoalParams({required this.year, required this.goal});
}

@lazySingleton
class SetAnnualGoal {
  final GoalRepository _repository;
  SetAnnualGoal(this._repository);

  Future<void> call(SetAnnualGoalParams params) =>
      _repository.setAnnualGoal(params.year, params.goal);
}
