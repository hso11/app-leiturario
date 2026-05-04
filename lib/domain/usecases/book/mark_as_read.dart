import 'package:injectable/injectable.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

class MarkAsReadParams {
  final String id;
  final int? rating;
  final String? review;
  const MarkAsReadParams({required this.id, this.rating, this.review});
}

@lazySingleton
class MarkAsRead {
  final BookRepository _repository;
  MarkAsRead(this._repository);

  Future<void> call(MarkAsReadParams params) async {
    final book = await _repository.getById(params.id);
    if (book == null) return;
    final updated = book.copyWith(
      status: BookStatus.read,
      endDate: DateTime.now(),
      currentPage: book.totalPages,
      rating: params.rating,
      review: params.review,
    );
    await _repository.update(updated);
  }
}
