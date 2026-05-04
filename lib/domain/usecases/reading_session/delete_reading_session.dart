import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/reading_session_repository.dart';

@lazySingleton
class DeleteReadingSession implements UseCase<void, String> {
  final ReadingSessionRepository _repository;
  DeleteReadingSession(this._repository);

  @override
  Future<void> call(String id) => _repository.delete(id);
}
