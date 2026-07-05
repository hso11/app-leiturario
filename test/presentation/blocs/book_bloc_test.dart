import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/core/usecases/usecase.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import 'package:app_controle_leitura/domain/usecases/book/mark_as_read.dart';
import 'package:app_controle_leitura/domain/usecases/book/update_reading_progress.dart';
import 'package:app_controle_leitura/presentation/blocs/book/book_bloc.dart';
import '../../helpers/mocks.dart';
import '../../helpers/book_factory.dart';
// MockCheckAchievements is declared in mocks.dart

void main() {
  late MockGetAllBooks getAllBooks;
  late MockAddBook addBook;
  late MockUpdateBook updateBook;
  late MockDeleteBook deleteBook;
  late MockMoveToReading moveToReading;
  late MockMoveToWantToRead moveToWantToRead;
  late MockMarkAsRead markAsRead;
  late MockUpdateReadingProgress updateReadingProgress;
  late MockReorderWantToRead reorderWantToRead;
  late MockRecordReadingActivity recordReadingActivity;
  late MockCheckAchievements checkAchievements;
  late MockNotificationService notificationService;

  setUpAll(registerFallbacks);

  setUp(() {
    getAllBooks = MockGetAllBooks();
    addBook = MockAddBook();
    updateBook = MockUpdateBook();
    deleteBook = MockDeleteBook();
    moveToReading = MockMoveToReading();
    moveToWantToRead = MockMoveToWantToRead();
    markAsRead = MockMarkAsRead();
    updateReadingProgress = MockUpdateReadingProgress();
    reorderWantToRead = MockReorderWantToRead();
    recordReadingActivity = MockRecordReadingActivity();
    checkAchievements = MockCheckAchievements();
    notificationService = MockNotificationService();
    when(() => notificationService.onUserRead()).thenAnswer((_) async {});
  });

  BookBloc buildBloc() => BookBloc(
        getAllBooks,
        addBook,
        updateBook,
        deleteBook,
        moveToReading,
        moveToWantToRead,
        markAsRead,
        updateReadingProgress,
        reorderWantToRead,
        recordReadingActivity,
        checkAchievements,
        notificationService,
      );

  group('BookLoadRequested', () {
    final books = [makeBook(id: '1'), makeBook(id: '2')];

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BooksLoaded] on success',
      build: buildBloc,
      setUp: () {
        when(() => getAllBooks(const NoParams()))
            .thenAnswer((_) async => books);
      },
      act: (bloc) => bloc.add(BookLoadRequested()),
      expect: () => [isA<BookLoading>(), isA<BooksLoaded>()],
    );

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookError] on failure',
      build: buildBloc,
      setUp: () {
        when(() => getAllBooks(const NoParams()))
            .thenThrow(Exception('DB error'));
      },
      act: (bloc) => bloc.add(BookLoadRequested()),
      expect: () => [isA<BookLoading>(), isA<BookError>()],
    );
  });

  group('BookAddRequested', () {
    blocTest<BookBloc, BookState>(
      'calls addBook then reloads',
      build: buildBloc,
      setUp: () {
        when(() => addBook(any())).thenAnswer((_) async {});
        when(() => getAllBooks(const NoParams()))
            .thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(BookAddRequested(
        title: 'New Book',
        author: 'Author',
        totalPages: 300,
      )),
      verify: (_) {
        verify(() => addBook(any())).called(1);
        verify(() => getAllBooks(const NoParams())).called(1);
      },
    );
  });

  group('BookDeleteRequested', () {
    blocTest<BookBloc, BookState>(
      'calls deleteBook with the correct id',
      build: buildBloc,
      setUp: () {
        when(() => deleteBook('book-1')).thenAnswer((_) async {});
        when(() => getAllBooks(const NoParams()))
            .thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(BookDeleteRequested('book-1')),
      verify: (_) {
        verify(() => deleteBook('book-1')).called(1);
      },
    );
  });

  group('BookMoveToReadingRequested', () {
    blocTest<BookBloc, BookState>(
      'calls moveToReading with the correct id',
      build: buildBloc,
      setUp: () {
        when(() => moveToReading('book-1')).thenAnswer((_) async {});
        when(() => getAllBooks(const NoParams()))
            .thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(BookMoveToReadingRequested('book-1')),
      verify: (_) {
        verify(() => moveToReading('book-1')).called(1);
      },
    );
  });

  group('BookMarkAsReadRequested', () {
    blocTest<BookBloc, BookState>(
      'calls markAsRead with id and rating',
      build: buildBloc,
      setUp: () {
        when(() => markAsRead(any())).thenAnswer((_) async {});
        when(() => getAllBooks(const NoParams())).thenAnswer((_) async => []);
        when(() => checkAchievements(any())).thenAnswer((_) async => []);
      },
      act: (bloc) =>
          bloc.add(BookMarkAsReadRequested('book-1', rating: 4, review: 'OK')),
      verify: (_) {
        final captured =
            verify(() => markAsRead(captureAny())).captured;
        final params = captured.first as MarkAsReadParams;
        expect(params.id, 'book-1');
        expect(params.rating, 4);
        expect(params.review, 'OK');
      },
    );
  });

  group('BookUpdateProgressRequested', () {
    blocTest<BookBloc, BookState>(
      'calls updateReadingProgress AND recordReadingActivity',
      build: buildBloc,
      setUp: () {
        when(() => updateReadingProgress(any())).thenAnswer((_) async {});
        when(() => recordReadingActivity(any())).thenAnswer((_) async {});
        when(() => getAllBooks(const NoParams())).thenAnswer((_) async => []);
        when(() => checkAchievements(any())).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(
          BookUpdateProgressRequested(bookId: 'book-1', currentPage: 100)),
      verify: (_) {
        final captured =
            verify(() => updateReadingProgress(captureAny())).captured;
        final params = captured.first as UpdateReadingProgressParams;
        expect(params.bookId, 'book-1');
        expect(params.currentPage, 100);
        verify(() => recordReadingActivity(any())).called(1);
      },
    );
  });

  group('BooksLoaded state helpers', () {
    test('history includes reading and read books', () {
      final books = [
        makeBook(status: BookStatus.wantToRead),
        makeBook(id: '2', status: BookStatus.reading),
        makeBook(id: '3', status: BookStatus.read),
      ];
      final state = BooksLoaded(books);
      expect(state.history.length, 2);
      expect(state.wantToRead.length, 1);
    });
  });
}
