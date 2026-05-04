part of 'book_list_cubit.dart';

abstract class BookListState {}

class BookListInitial extends BookListState {}

class BookListLoading extends BookListState {}

class BookListsLoaded extends BookListState {
  final List<BookList> lists;
  BookListsLoaded(this.lists);
}

class BookListError extends BookListState {
  final String message;
  BookListError(this.message);
}
