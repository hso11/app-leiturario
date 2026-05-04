import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/book.dart';
import '../../repositories/book_repository.dart';

@lazySingleton
class MoveToReading implements UseCase<void, String> {
  final BookRepository _repository;
  MoveToReading(this._repository);

  @override
  Future<void> call(String params) async {
    final book = await _repository.getById(params);
    if (book == null) return;
    final updated = book.copyWith(
      status: BookStatus.reading,
      startDate: DateTime.now(),
      clearEndDate: true,
    );
    await _repository.update(updated);
  }
}
