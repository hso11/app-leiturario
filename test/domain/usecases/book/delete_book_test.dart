import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/domain/usecases/book/delete_book.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockBookRepository repo;
  late DeleteBook deleteBook;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockBookRepository();
    deleteBook = DeleteBook(repo);
  });

  test('calls repository.delete with the given id', () async {
    when(() => repo.delete('book-1')).thenAnswer((_) async {});

    await deleteBook('book-1');

    verify(() => repo.delete('book-1')).called(1);
  });
}
