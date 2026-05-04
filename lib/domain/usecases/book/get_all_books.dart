import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class GetAllBooks implements UseCase<List<Book>, NoParams> {
  final BookRepository _repository;
  GetAllBooks(this._repository);

  @override
  Future<List<Book>> call(NoParams params) => _repository.getAll();
}
