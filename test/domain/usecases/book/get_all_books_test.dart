import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/core/usecases/usecase.dart';
import 'package:app_controle_leitura/domain/usecases/book/get_all_books.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/book_factory.dart';

void main() {
  late MockBookRepository repo;
  late GetAllBooks getAllBooks;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockBookRepository();
    getAllBooks = GetAllBooks(repo);
  });

  test('returns list from repository', () async {
    final books = [makeBook(id: '1'), makeBook(id: '2')];
    when(() => repo.getAll()).thenAnswer((_) async => books);

    final result = await getAllBooks(const NoParams());

    expect(result, books);
    verify(() => repo.getAll()).called(1);
  });
}
