import 'package:injectable/injectable.dart';
import '../../entities/book_list.dart';
import '../../repositories/book_list_repository.dart';

@lazySingleton
class GetAllBookLists {
  final BookListRepository _repository;
  GetAllBookLists(this._repository);

  Future<List<BookList>> call() => _repository.getAllBookLists();
}
