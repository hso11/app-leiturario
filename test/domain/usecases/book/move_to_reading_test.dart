import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import 'package:app_controle_leitura/domain/usecases/book/move_to_reading.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/book_factory.dart';

void main() {
  late MockBookRepository repo;
  late MoveToReading moveToReading;

  setUpAll(registerFallbacks);

  setUp(() {
    repo = MockBookRepository();
    moveToReading = MoveToReading(repo);
  });

  test('sets status=reading and startDate on update', () async {
    final book = makeBook(id: 'b1', endDate: DateTime(2023));
    when(() => repo.getById('b1')).thenAnswer((_) async => book);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await moveToReading('b1');

    final captured = verify(() => repo.update(captureAny())).captured;
    final updated = captured.first as Book;
    expect(updated.status, BookStatus.reading);
    expect(updated.startDate, isNotNull);
  });

  test('clears endDate when moving to reading', () async {
    final book = makeBook(id: 'b1', endDate: DateTime(2023));
    when(() => repo.getById('b1')).thenAnswer((_) async => book);
    when(() => repo.update(any())).thenAnswer((_) async {});

    await moveToReading('b1');

    final captured = verify(() => repo.update(captureAny())).captured;
    final updated = captured.first as Book;
    expect(updated.endDate, isNull);
  });

  test('does nothing when book does not exist', () async {
    when(() => repo.getById('missing')).thenAnswer((_) async => null);

    await moveToReading('missing');

    verifyNever(() => repo.update(any()));
  });
}
