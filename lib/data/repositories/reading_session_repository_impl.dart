import 'package:injectable/injectable.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/repositories/reading_session_repository.dart';
import '../datasources/local/reading_session_local_datasource.dart';
import '../models/reading_session_model.dart';

@LazySingleton(as: ReadingSessionRepository)
class ReadingSessionRepositoryImpl implements ReadingSessionRepository {
  final ReadingSessionLocalDatasource _datasource;
  ReadingSessionRepositoryImpl(this._datasource);

  @override
  Future<List<ReadingSession>> getByBook(String bookId) =>
      _datasource.getByBook(bookId);

  @override
  Future<void> upsert(ReadingSession session) =>
      _datasource.upsert(ReadingSessionModel.fromEntity(session));

  @override
  Future<void> delete(String id) => _datasource.delete(id);
}
