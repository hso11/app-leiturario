import 'package:injectable/injectable.dart';
import '../../entities/book_list.dart';
import '../../repositories/book_list_repository.dart';

@lazySingleton
class CreateBookList {
  final BookListRepository _repository;
  CreateBookList(this._repository);

  Future<void> call(BookList list) => _repository.createBookList(list);
}
