import 'package:injectable/injectable.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

class UpdateReadingProgressParams {
  final String bookId;
  final int currentPage;
  const UpdateReadingProgressParams({required this.bookId, required this.currentPage});
}

@lazySingleton
class UpdateReadingProgress {
  final BookRepository _repository;
  UpdateReadingProgress(this._repository);

  Future<void> call(UpdateReadingProgressParams params) async {
    final book = await _repository.getById(params.bookId);
    if (book == null) return;
    final Book updated;
    if (params.currentPage >= book.totalPages) {
      updated = book.copyWith(
        currentPage: book.totalPages,
        status: BookStatus.read,
        endDate: DateTime.now(),
      );
    } else {
      updated = book.copyWith(currentPage: params.currentPage);
    }
    await _repository.update(updated);
  }
}
