import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/reading_session.dart';
import '../../repositories/reading_session_repository.dart';

@lazySingleton
class GetSessionsForBook implements UseCase<List<ReadingSession>, String> {
  final ReadingSessionRepository _repository;
  GetSessionsForBook(this._repository);

  @override
  Future<List<ReadingSession>> call(String bookId) =>
      _repository.getByBook(bookId);
}
