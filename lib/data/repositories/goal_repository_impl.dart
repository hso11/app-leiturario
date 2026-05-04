import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/goal_repository.dart';

@LazySingleton(as: GoalRepository)
class GoalRepositoryImpl implements GoalRepository {
  @override
  Future<int?> getAnnualGoal(int year) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('annual_goal_$year');
  }

  @override
  Future<void> setAnnualGoal(int year, int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('annual_goal_$year', goal);
  }
}
