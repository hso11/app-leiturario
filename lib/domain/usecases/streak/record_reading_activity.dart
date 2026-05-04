import 'package:injectable/injectable.dart';
import '../../repositories/streak_repository.dart';

@lazySingleton
class RecordReadingActivity {
  final StreakRepository _repository;
  RecordReadingActivity(this._repository);

  Future<void> call(DateTime date) => _repository.recordReadingActivity(date);
}
