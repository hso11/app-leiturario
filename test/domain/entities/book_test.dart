import 'package:flutter_test/flutter_test.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import '../../helpers/book_factory.dart';

void main() {
  group('Book.readingProgress', () {
    test('returns null when totalPages == 0', () {
      final book = makeBook(totalPages: 0, currentPage: 0);
      expect(book.readingProgress, isNull);
    });

    test('returns 0.5 when currentPage=100, totalPages=200', () {
      final book = makeBook(totalPages: 200, currentPage: 100);
      expect(book.readingProgress, 0.5);
    });

    test('clamps to 1.0 when currentPage > totalPages', () {
      final book = makeBook(totalPages: 100, currentPage: 150);
      expect(book.readingProgress, 1.0);
    });
  });

  group('Book.pagesPerDay', () {
    test('returns null for non-read books', () {
      final book = makeBook(status: BookStatus.reading);
      expect(book.pagesPerDay, isNull);
    });

    test('calculates correctly for book read over 2 days', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 3); // 2 days
      final book = makeBook(
        status: BookStatus.read,
        totalPages: 200,
        startDate: start,
        endDate: end,
      );
      expect(book.pagesPerDay, 100.0);
    });

    test('returns totalPages when read on the same day (0 days diff)', () {
      final day = DateTime(2024, 1, 1);
      final book = makeBook(
        status: BookStatus.read,
        totalPages: 200,
        startDate: day,
        endDate: day,
      );
      expect(book.pagesPerDay, 200.0);
    });
  });

  group('Book.copyWith', () {
    test('preserves fields not altered', () {
      final book = makeBook(title: 'Original', author: 'AuthorA');
      final copy = book.copyWith(title: 'New Title');
      expect(copy.title, 'New Title');
      expect(copy.author, 'AuthorA');
    });

    test('clearEndDate sets endDate to null', () {
      final book = makeBook(endDate: DateTime(2024, 1, 1));
      final copy = book.copyWith(clearEndDate: true);
      expect(copy.endDate, isNull);
    });
  });

  group('Book.props', () {
    test('two equal books have the same props', () {
      final a = makeBook();
      final b = makeBook();
      expect(a, equals(b));
    });

    test('props includes all 13 fields', () {
      final book = makeBook();
      expect(book.props.length, 13);
    });
  });
}
