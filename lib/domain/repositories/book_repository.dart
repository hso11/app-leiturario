import '../entities/book.dart';

abstract interface class BookRepository {
  Future<List<Book>> getAll();
  Future<Book?> getById(String id);
  Future<void> add(Book book);
  Future<void> update(Book book);
  Future<void> delete(String id);
  Future<void> reorderWantToRead(List<String> orderedIds);
}
