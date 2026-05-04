import 'package:injectable/injectable.dart';
import '../../repositories/book_list_repository.dart';

@lazySingleton
class AddBookToList {
  final BookListRepository _repository;
  AddBookToList(this._repository);

  Future<void> call(String listId, String bookId) =>
      _repository.addBookToList(listId, bookId);
}
