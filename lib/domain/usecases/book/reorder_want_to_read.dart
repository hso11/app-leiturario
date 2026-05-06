import 'package:injectable/injectable.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class ReorderWantToRead {
  final BookRepository _repository;
  ReorderWantToRead(this._repository);

  Future<void> call(List<String> orderedIds) =>
      _repository.reorderWantToRead(orderedIds);
}
