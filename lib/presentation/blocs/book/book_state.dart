part of 'book_bloc.dart';

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;
  BooksLoaded(this.books);

  List<Book> get history =>
      books.where((b) => b.status == BookStatus.read).toList();

  List<Book> get reading =>
      books.where((b) => b.status == BookStatus.reading).toList();

  List<Book> get wantToRead {
    final list = books.where((b) => b.status == BookStatus.wantToRead).toList();
    list.sort((a, b) => a.position.compareTo(b.position));
    return list;
  }
}

/// Extends BooksLoaded so BlocBuilder sees it as loaded state
class BookAchievementUnlocked extends BooksLoaded {
  final List<Achievement> newAchievements;
  BookAchievementUnlocked(List<Book> books, this.newAchievements) : super(books);
}

class BookError extends BookState {
  final String message;
  BookError(this.message);
}
