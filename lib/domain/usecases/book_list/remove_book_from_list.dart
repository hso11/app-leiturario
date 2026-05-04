import 'package:injectable/injectable.dart';
import '../../repositories/book_list_repository.dart';

@lazySingleton
class RemoveBookFromList {
  final BookListRepository _repository;
  RemoveBookFromList(this._repository);

  Future<void> call(String listId, String bookId) =>
      _repository.removeBookFromList(listId, bookId);
}
