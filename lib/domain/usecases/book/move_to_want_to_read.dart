import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class MoveToWantToRead implements UseCase<void, String> {
  final BookRepository _repository;
  MoveToWantToRead(this._repository);

  @override
  Future<void> call(String id) async {
    final book = await _repository.getById(id);
    if (book == null) return;
    final all = await _repository.getAll();
    final position = all.where((b) => b.status == BookStatus.wantToRead).length;
    await _repository.update(book.copyWith(
      status: BookStatus.wantToRead,
      clearStartDate: true,
      position: position,
    ));
  }
}
