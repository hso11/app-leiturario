import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class DeleteBook implements UseCase<void, String> {
  final BookRepository _repository;
  DeleteBook(this._repository);

  @override
  Future<void> call(String params) => _repository.delete(params);
}
