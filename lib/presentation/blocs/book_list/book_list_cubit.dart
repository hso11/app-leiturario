import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/book_list.dart';
import '../../../domain/usecases/book_list/get_all_book_lists.dart';
import '../../../domain/usecases/book_list/create_book_list.dart';
import '../../../domain/usecases/book_list/delete_book_list.dart';
import '../../../domain/usecases/book_list/add_book_to_list.dart';
import '../../../domain/usecases/book_list/remove_book_from_list.dart';

part 'book_list_state.dart';

@lazySingleton
class BookListCubit extends Cubit<BookListState> {
  final GetAllBookLists _getAll;
  final CreateBookList _create;
  final DeleteBookList _delete;
  final AddBookToList _addBook;
  final RemoveBookFromList _removeBook;
  final _uuid = const Uuid();

  BookListCubit(
    this._getAll,
    this._create,
    this._delete,
    this._addBook,
    this._removeBook,
  ) : super(BookListInitial());

  Future<void> load() async {
    emit(BookListLoading());
    try {
      final lists = await _getAll();
      emit(BookListsLoaded(lists));
    } catch (e) {
      emit(BookListError('Erro ao carregar listas: $e'));
    }
  }

  Future<void> create(String name) async {
    final list = BookList(
      id: _uuid.v4(),
      name: name.trim(),
      bookIds: [],
      createdAt: DateTime.now(),
    );
    await _create(list);
    await load();
  }

  Future<void> delete(String id) async {
    await _delete(id);
    await load();
  }

  Future<void> addBook(String listId, String bookId) async {
    await _addBook(listId, bookId);
    await load();
  }

  Future<void> removeBook(String listId, String bookId) async {
    await _removeBook(listId, bookId);
    await load();
  }
}
