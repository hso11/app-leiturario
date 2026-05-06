import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/usecases/usecase.dart';
import '../../../data/services/notification_service.dart';
import '../../../domain/entities/achievement.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/usecases/book/add_book.dart';
import '../../../domain/usecases/book/delete_book.dart';
import '../../../domain/usecases/book/get_all_books.dart';
import '../../../domain/usecases/book/mark_as_read.dart';
import '../../../domain/usecases/book/move_to_reading.dart';
import '../../../domain/usecases/book/move_to_want_to_read.dart';
import '../../../domain/usecases/book/update_book.dart';
import '../../../domain/usecases/book/reorder_want_to_read.dart';
import '../../../domain/usecases/book/update_reading_progress.dart';
import '../../../domain/usecases/streak/record_reading_activity.dart';
import '../../../domain/usecases/achievement/check_achievements.dart';

part 'book_event.dart';
part 'book_state.dart';

@lazySingleton
class BookBloc extends Bloc<BookEvent, BookState> {
  final GetAllBooks _getAllBooks;
  final AddBook _addBook;
  final UpdateBook _updateBook;
  final DeleteBook _deleteBook;
  final MoveToReading _moveToReading;
  final MoveToWantToRead _moveToWantToRead;
  final MarkAsRead _markAsRead;
  final UpdateReadingProgress _updateReadingProgress;
  final ReorderWantToRead _reorderWantToRead;
  final RecordReadingActivity _recordReadingActivity;
  final CheckAchievements _checkAchievements;
  final NotificationService _notificationService;
  final _uuid = const Uuid();

  BookBloc(
    this._getAllBooks,
    this._addBook,
    this._updateBook,
    this._deleteBook,
    this._moveToReading,
    this._moveToWantToRead,
    this._markAsRead,
    this._updateReadingProgress,
    this._reorderWantToRead,
    this._recordReadingActivity,
    this._checkAchievements,
    this._notificationService,
  ) : super(BookInitial()) {
    on<BookLoadRequested>(_onLoad);
    on<BookAddRequested>(_onAdd);
    on<BookUpdateRequested>(_onUpdate);
    on<BookDeleteRequested>(_onDelete);
    on<BookMoveToReadingRequested>(_onMoveToReading);
    on<BookMoveToWantToReadRequested>(_onMoveToWantToRead);
    on<BookMarkAsReadRequested>(_onMarkAsRead);
    on<BookUpdateProgressRequested>(_onUpdateProgress);
    on<BookReorderRequested>(_onReorder);
  }

  Future<void> _onLoad(
      BookLoadRequested event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await _getAllBooks(const NoParams());
      emit(BooksLoaded(books));
    } catch (e) {
      emit(BookError('Erro ao carregar livros: $e'));
    }
  }

  Future<void> _onAdd(
      BookAddRequested event, Emitter<BookState> emit) async {
    try {
      final BookStatus status;
      final int currentPage;
      if (event.endDate != null) {
        status = BookStatus.read;
        currentPage = event.totalPages;
      } else if (event.startDate != null) {
        status = BookStatus.reading;
        currentPage = 0;
      } else {
        status = BookStatus.wantToRead;
        currentPage = 0;
      }
      final int position = (status == BookStatus.wantToRead && state is BooksLoaded)
          ? (state as BooksLoaded).wantToRead.length
          : 0;
      final book = Book(
        id: _uuid.v4(),
        title: event.title,
        author: event.author,
        status: status,
        totalPages: event.totalPages,
        currentPage: currentPage,
        startDate: event.startDate,
        endDate: event.endDate,
        genres: event.genres,
        coverUrl: event.coverUrl,
        position: position,
      );
      await _addBook(book);
      add(BookLoadRequested());
    } catch (e) {
      emit(BookError('Erro ao adicionar livro: $e'));
    }
  }

  Future<void> _onReorder(
      BookReorderRequested event, Emitter<BookState> emit) async {
    try {
      await _reorderWantToRead(event.orderedIds);
      add(BookLoadRequested());
    } catch (e) {
      emit(BookError('Erro ao reordenar livros: $e'));
    }
  }

  Future<void> _onUpdate(
      BookUpdateRequested event, Emitter<BookState> emit) async {
    try {
      await _updateBook(event.book);
      add(BookLoadRequested());
    } catch (e) {
      emit(BookError('Erro ao atualizar livro: $e'));
    }
  }

  Future<void> _onDelete(
      BookDeleteRequested event, Emitter<BookState> emit) async {
    try {
      await _deleteBook(event.id);
      add(BookLoadRequested());
    } catch (e) {
      emit(BookError('Erro ao deletar livro: $e'));
    }
  }

  Future<void> _onMoveToReading(
      BookMoveToReadingRequested event, Emitter<BookState> emit) async {
    try {
      await _moveToReading(event.id);
      add(BookLoadRequested());
    } catch (e) {
      emit(BookError('Erro ao mover livro: $e'));
    }
  }

  Future<void> _onMoveToWantToRead(
      BookMoveToWantToReadRequested event, Emitter<BookState> emit) async {
    try {
      await _moveToWantToRead(event.id);
      add(BookLoadRequested());
    } catch (e) {
      emit(BookError('Erro ao mover livro: $e'));
    }
  }

  Future<void> _onMarkAsRead(
      BookMarkAsReadRequested event, Emitter<BookState> emit) async {
    try {
      await _markAsRead(MarkAsReadParams(
        id: event.id,
        rating: event.rating,
        review: event.review,
      ));
      try { await _notificationService.onUserRead(); } catch (_) {}
      final books = await _getAllBooks(const NoParams());
      final newAchievements = await _checkAchievements(books);
      if (newAchievements.isNotEmpty) {
        emit(BookAchievementUnlocked(books, newAchievements));
      } else {
        emit(BooksLoaded(books));
      }
    } catch (e) {
      emit(BookError('Erro ao marcar como lido: $e'));
    }
  }

  Future<void> _onUpdateProgress(
      BookUpdateProgressRequested event, Emitter<BookState> emit) async {
    try {
      await _updateReadingProgress(UpdateReadingProgressParams(
        bookId: event.bookId,
        currentPage: event.currentPage,
      ));
      try { await _recordReadingActivity(DateTime.now()); } catch (_) {}
      try { await _notificationService.onUserRead(); } catch (_) {}
      final books = await _getAllBooks(const NoParams());
      final newAchievements = await _checkAchievements(books);
      if (newAchievements.isNotEmpty) {
        emit(BookAchievementUnlocked(books, newAchievements));
      } else {
        emit(BooksLoaded(books));
      }
    } catch (e) {
      emit(BookError('Erro ao atualizar progresso: $e'));
    }
  }
}
