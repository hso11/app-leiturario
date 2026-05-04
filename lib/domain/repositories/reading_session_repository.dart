import '../entities/reading_session.dart';

abstract interface class ReadingSessionRepository {
  Future<List<ReadingSession>> getByBook(String bookId);
  Future<void> upsert(ReadingSession session);
  Future<void> delete(String id);
}
