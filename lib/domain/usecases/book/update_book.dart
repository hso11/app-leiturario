import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class UpdateBook implements UseCase<void, Book> {
  final BookRepository _repository;
  UpdateBook(this._repository);

  @override
  Future<void> call(Book params) => _repository.update(params);
}
