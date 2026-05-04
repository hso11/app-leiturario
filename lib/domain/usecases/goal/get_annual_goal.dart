import 'package:injectable/injectable.dart';
import '../../repositories/goal_repository.dart';

@lazySingleton
class GetAnnualGoal {
  final GoalRepository _repository;
  GetAnnualGoal(this._repository);

  Future<int?> call(int year) => _repository.getAnnualGoal(year);
}
