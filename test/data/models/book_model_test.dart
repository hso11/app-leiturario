import 'package:flutter_test/flutter_test.dart';
import 'package:app_controle_leitura/data/models/book_model.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import '../../helpers/book_factory.dart';

void main() {
  group('BookModel.fromSqliteMap', () {
    test('reads current_page, rating, review and genres as CSV', () {
      final map = {
        'id': 'b1',
        'title': 'Dune',
        'author': 'Herbert',
        'status': 'read',
        'total_pages': 412,
        'start_date': null,
        'end_date': null,
        'target_date': null,
        'current_page': 200,
        'rating': 5,
        'review': 'Amazing',
        'genres': 'Sci-Fi,Classic',
      };
      final model = BookModel.fromSqliteMap(map);
      expect(model.currentPage, 200);
      expect(model.rating, 5);
      expect(model.review, 'Amazing');
      expect(model.genres, ['Sci-Fi', 'Classic']);
    });

    test('treats null fields with defaults', () {
      final map = {
        'id': 'b1',
        'title': 'T',
        'author': 'A',
        'status': 'wantToRead',
        'total_pages': 100,
        'start_date': null,
        'end_date': null,
        'target_date': null,
        'current_page': null,
        'rating': null,
        'review': null,
        'genres': null,
      };
      final model = BookModel.fromSqliteMap(map);
      expect(model.currentPage, 0);
      expect(model.rating, isNull);
      expect(model.genres, isEmpty);
    });
  });

  group('BookModel.toSqliteMap', () {
    test('serializes genres as comma-separated string', () {
      const model = BookModel(
        id: 'b1',
        title: 'T',
        author: 'A',
        status: BookStatus.wantToRead,
        totalPages: 100,
        genres: ['Fantasy', 'Adventure'],
      );
      final map = model.toSqliteMap();
      expect(map['genres'], 'Fantasy,Adventure');
    });

    test('serializes empty genres list as null', () {
      const model = BookModel(
        id: 'b1',
        title: 'T',
        author: 'A',
        status: BookStatus.wantToRead,
        totalPages: 100,
      );
      final map = model.toSqliteMap();
      expect(map['genres'], isNull);
    });
  });

  group('BookModel.fromJson', () {
    test('reads genres as JSON array', () {
      final json = {
        'id': 'b1',
        'title': 'T',
        'author': 'A',
        'status': 'wantToRead',
        'totalPages': 100,
        'startDate': null,
        'endDate': null,
        'targetDate': null,
        'currentPage': 0,
        'rating': null,
        'review': null,
        'genres': ['Fantasy', 'Drama'],
      };
      final model = BookModel.fromJson(json);
      expect(model.genres, ['Fantasy', 'Drama']);
    });
  });

  group('BookModel.toJson', () {
    test('serializes genres as JSON array', () {
      const model = BookModel(
        id: 'b1',
        title: 'T',
        author: 'A',
        status: BookStatus.wantToRead,
        totalPages: 100,
        genres: ['Sci-Fi'],
      );
      final json = model.toJson();
      expect(json['genres'], ['Sci-Fi']);
    });
  });

  group('BookModel.fromEntity', () {
    test('propagates all fields from entity', () {
      final book = makeBook(
        id: 'x',
        title: 'My Book',
        author: 'Author',
        status: BookStatus.reading,
        totalPages: 300,
        currentPage: 50,
        rating: 4,
        review: 'Good',
        genres: ['Novel'],
      );
      final model = BookModel.fromEntity(book);
      expect(model.id, 'x');
      expect(model.title, 'My Book');
      expect(model.currentPage, 50);
      expect(model.rating, 4);
      expect(model.review, 'Good');
      expect(model.genres, ['Novel']);
    });
  });
}
