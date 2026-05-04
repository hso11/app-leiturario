import 'package:injectable/injectable.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/note_local_datasource.dart';
import '../models/note_model.dart';

@LazySingleton(as: NoteRepository)
class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDatasource _datasource;
  NoteRepositoryImpl(this._datasource);

  @override
  Future<List<Note>> getAll() => _datasource.getAll();

  @override
  Future<List<Note>> getByBook(String bookId) =>
      _datasource.getByBook(bookId);

  @override
  Future<void> add(Note note) =>
      _datasource.insert(NoteModel.fromEntity(note));

  @override
  Future<void> update(Note note) =>
      _datasource.update(NoteModel.fromEntity(note));

  @override
  Future<void> delete(String id) => _datasource.delete(id);
}
