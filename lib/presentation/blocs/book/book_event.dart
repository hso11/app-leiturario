part of 'book_bloc.dart';

abstract class BookEvent {}

class BookLoadRequested extends BookEvent {}

class BookAddRequested extends BookEvent {
  final String title;
  final String author;
  final int totalPages;
  final List<String> genres;
  final String? coverUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  BookAddRequested({
    required this.title,
    required this.author,
    required this.totalPages,
    this.genres = const [],
    this.coverUrl,
    this.startDate,
    this.endDate,
  });
}

class BookUpdateRequested extends BookEvent {
  final Book book;
  BookUpdateRequested(this.book);
}

class BookDeleteRequested extends BookEvent {
  final String id;
  BookDeleteRequested(this.id);
}

class BookMoveToReadingRequested extends BookEvent {
  final String id;
  BookMoveToReadingRequested(this.id);
}

class BookMarkAsReadRequested extends BookEvent {
  final String id;
  final int? rating;
  final String? review;
  BookMarkAsReadRequested(this.id, {this.rating, this.review});
}

class BookUpdateProgressRequested extends BookEvent {
  final String bookId;
  final int currentPage;
  BookUpdateProgressRequested({required this.bookId, required this.currentPage});
}

class BookReorderRequested extends BookEvent {
  final List<String> orderedIds;
  BookReorderRequested(this.orderedIds);
}

class BookMoveToWantToReadRequested extends BookEvent {
  final String id;
  BookMoveToWantToReadRequested(this.id);
}
