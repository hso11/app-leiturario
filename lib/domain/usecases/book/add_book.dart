import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class AddBook implements UseCase<void, Book> {
  final BookRepository _repository;
  AddBook(this._repository);

  @override
  Future<void> call(Book params) => _repository.add(params);
}
