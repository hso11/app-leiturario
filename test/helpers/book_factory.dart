import 'package:app_controle_leitura/domain/entities/book.dart';

Book makeBook({
  String id = 'book-1',
  String title = 'Test Book',
  String author = 'Test Author',
  BookStatus status = BookStatus.wantToRead,
  int totalPages = 200,
  DateTime? startDate,
  DateTime? endDate,
  DateTime? targetDate,
  int currentPage = 0,
  int? rating,
  String? review,
  List<String> genres = const [],
}) {
  return Book(
    id: id,
    title: title,
    author: author,
    status: status,
    totalPages: totalPages,
    startDate: startDate,
    endDate: endDate,
    targetDate: targetDate,
    currentPage: currentPage,
    rating: rating,
    review: review,
    genres: genres,
  );
}
