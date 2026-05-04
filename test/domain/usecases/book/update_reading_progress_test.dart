import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import 'package:app_controle_leitura/domain/usecases/book/update_reading_progress.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/book_factory.dart';

void main() {
  late MockBookRepository repo;
  late UpdateReadingProgress updateReadingProgress;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockBookRepository();
    updateReadingProgress = UpdateReadingProgress(repo);
  });

  test('updates currentPage via repository.update', () async {
    final book = makeBook(id: 'b1', totalPages: 300, currentPage: 50);
    when(() => repo.getById('b1')).thenAnswer((_) async => book);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await updateReadingProgress(
        const UpdateReadingProgressParams(bookId: 'b1', currentPage: 150));

    final captured = verify(() => repo.update(captureAny())).captured;
    final updated = captured.first as Book;
    expect(updated.currentPage, 150);
  });

  test('does nothing when book does not exist', () async {
    when(() => repo.getById('missing')).thenAnswer((_) async => null);

    await updateReadingProgress(
        const UpdateReadingProgressParams(bookId: 'missing', currentPage: 50));

    verifyNever(() => repo.update(any()));
  });
}
