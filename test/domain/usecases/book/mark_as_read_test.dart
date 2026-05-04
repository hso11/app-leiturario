import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import 'package:app_controle_leitura/domain/usecases/book/mark_as_read.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/book_factory.dart';

void main() {
  late MockBookRepository repo;
  late MarkAsRead markAsRead;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockBookRepository();
    markAsRead = MarkAsRead(repo);
  });

  test('calls getById then update with status=read', () async {
    final book = makeBook(id: 'b1', totalPages: 300);
    when(() => repo.getById('b1')).thenAnswer((_) async => book);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await markAsRead(const MarkAsReadParams(id: 'b1'));

    verify(() => repo.getById('b1')).called(1);

    final captured = verify(() => repo.update(captureAny())).captured;
    final updated = captured.first as Book;
    expect(updated.status, BookStatus.read);
  });

  test('sets currentPage = totalPages when marking as read', () async {
    final book = makeBook(id: 'b1', totalPages: 300, currentPage: 100);
    when(() => repo.getById('b1')).thenAnswer((_) async => book);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await markAsRead(const MarkAsReadParams(id: 'b1'));

    final captured = verify(() => repo.update(captureAny())).captured;
    final updated = captured.first as Book;
    expect(updated.currentPage, 300);
  });

  test('propagates rating and review to updated book', () async {
    final book = makeBook(id: 'b1', totalPages: 200);
    when(() => repo.getById('b1')).thenAnswer((_) async => book);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await markAsRead(
        const MarkAsReadParams(id: 'b1', rating: 4, review: 'Great'));

    final captured = verify(() => repo.update(captureAny())).captured;
    final updated = captured.first as Book;
    expect(updated.rating, 4);
    expect(updated.review, 'Great');
  });

  test('does nothing when getById returns null', () async {
    when(() => repo.getById('missing')).thenAnswer((_) async => null);

    await markAsRead(const MarkAsReadParams(id: 'missing'));

    verifyNever(() => repo.update(any()));
  });
}
