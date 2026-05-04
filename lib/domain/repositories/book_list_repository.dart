import '../entities/book_list.dart';

abstract interface class BookListRepository {
  Future<List<BookList>> getAllBookLists();
  Future<void> createBookList(BookList list);
  Future<void> deleteBookList(String id);
  Future<void> addBookToList(String listId, String bookId);
  Future<void> removeBookFromList(String listId, String bookId);
}
