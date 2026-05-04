import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/reading_session.dart';
import '../../repositories/reading_session_repository.dart';

class UpsertSessionParams {
  final String id;
  final String bookId;
  final DateTime date;
  final int pagesRead;

  const UpsertSessionParams({
    required this.id,
    required this.bookId,
    required this.date,
    required this.pagesRead,
  });
}

@lazySingleton
class UpsertReadingSession implements UseCase<void, UpsertSessionParams> {
  final ReadingSessionRepository _repository;
  UpsertReadingSession(this._repository);

  @override
  Future<void> call(UpsertSessionParams params) => _repository.upsert(
        ReadingSession(
          id: params.id,
          bookId: params.bookId,
          date: ReadingSession.normalizeDate(params.date),
          pagesRead: params.pagesRead,
        ),
      );
}
