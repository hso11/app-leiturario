import '../entities/note.dart';

abstract interface class NoteRepository {
  Future<List<Note>> getAll();
  Future<List<Note>> getByBook(String bookId);
  Future<void> add(Note note);
  Future<void> update(Note note);
  Future<void> delete(String id);
}
