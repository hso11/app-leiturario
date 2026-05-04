abstract interface class GoalRepository {
  Future<int?> getAnnualGoal(int year);
  Future<void> setAnnualGoal(int year, int goal);
}
