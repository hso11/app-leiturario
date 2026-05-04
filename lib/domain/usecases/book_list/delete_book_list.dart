import 'package:injectable/injectable.dart';
import '../../repositories/book_list_repository.dart';

@lazySingleton
class DeleteBookList {
  final BookListRepository _repository;
  DeleteBookList(this._repository);

  Future<void> call(String id) => _repository.deleteBookList(id);
}
