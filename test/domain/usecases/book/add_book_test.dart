import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/domain/usecases/book/add_book.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/book_factory.dart';

void main() {
  late MockBookRepository repo;
  late AddBook addBook;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockBookRepository();
    addBook = AddBook(repo);
  });

  test('calls repository.add with the given book', () async {
    final book = makeBook();
    when(() => repo.add(book)).thenAnswer((_) async {});

    await addBook(book);

    verify(() => repo.add(book)).called(1);
  });
}
