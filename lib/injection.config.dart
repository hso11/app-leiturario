// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_controle_leitura/data/auth/google_auth_service.dart'
    as _i903;
import 'package:app_controle_leitura/data/auth/microsoft_auth_service.dart'
    as _i968;
import 'package:app_controle_leitura/data/datasources/local/book_local_datasource.dart'
    as _i450;
import 'package:app_controle_leitura/data/datasources/local/database_helper.dart'
    as _i258;
import 'package:app_controle_leitura/data/datasources/local/note_local_datasource.dart'
    as _i314;
import 'package:app_controle_leitura/data/datasources/local/reading_session_local_datasource.dart'
    as _i19;
import 'package:app_controle_leitura/data/datasources/remote/google_drive_storage.dart'
    as _i1055;
import 'package:app_controle_leitura/data/datasources/remote/onedrive_storage.dart'
    as _i53;
import 'package:app_controle_leitura/data/datasources/remote/sync_service.dart'
    as _i107;
import 'package:app_controle_leitura/data/repositories/achievement_repository_impl.dart'
    as _i412;
import 'package:app_controle_leitura/data/repositories/book_list_repository_impl.dart'
    as _i353;
import 'package:app_controle_leitura/data/repositories/book_repository_impl.dart'
    as _i195;
import 'package:app_controle_leitura/data/repositories/goal_repository_impl.dart'
    as _i985;
import 'package:app_controle_leitura/data/repositories/note_repository_impl.dart'
    as _i219;
import 'package:app_controle_leitura/data/repositories/reading_session_repository_impl.dart'
    as _i318;
import 'package:app_controle_leitura/data/repositories/streak_repository_impl.dart'
    as _i772;
import 'package:app_controle_leitura/data/services/google_books_service.dart'
    as _i818;
import 'package:app_controle_leitura/data/services/mercado_livre_service.dart'
    as _i497;
import 'package:app_controle_leitura/data/services/notification_service.dart'
    as _i926;
import 'package:app_controle_leitura/domain/repositories/achievement_repository.dart'
    as _i1038;
import 'package:app_controle_leitura/domain/repositories/book_list_repository.dart'
    as _i928;
import 'package:app_controle_leitura/domain/repositories/book_repository.dart'
    as _i196;
import 'package:app_controle_leitura/domain/repositories/goal_repository.dart'
    as _i85;
import 'package:app_controle_leitura/domain/repositories/note_repository.dart'
    as _i522;
import 'package:app_controle_leitura/domain/repositories/reading_session_repository.dart'
    as _i930;
import 'package:app_controle_leitura/domain/repositories/streak_repository.dart'
    as _i767;
import 'package:app_controle_leitura/domain/usecases/achievement/check_achievements.dart'
    as _i700;
import 'package:app_controle_leitura/domain/usecases/book/add_book.dart'
    as _i397;
import 'package:app_controle_leitura/domain/usecases/book/delete_book.dart'
    as _i1009;
import 'package:app_controle_leitura/domain/usecases/book/get_all_books.dart'
    as _i206;
import 'package:app_controle_leitura/domain/usecases/book/mark_as_read.dart'
    as _i246;
import 'package:app_controle_leitura/domain/usecases/book/move_to_reading.dart'
    as _i300;
import 'package:app_controle_leitura/domain/usecases/book/update_book.dart'
    as _i214;
import 'package:app_controle_leitura/domain/usecases/book/update_reading_progress.dart'
    as _i304;
import 'package:app_controle_leitura/domain/usecases/book_list/add_book_to_list.dart'
    as _i507;
import 'package:app_controle_leitura/domain/usecases/book_list/create_book_list.dart'
    as _i126;
import 'package:app_controle_leitura/domain/usecases/book_list/delete_book_list.dart'
    as _i742;
import 'package:app_controle_leitura/domain/usecases/book_list/get_all_book_lists.dart'
    as _i681;
import 'package:app_controle_leitura/domain/usecases/book_list/remove_book_from_list.dart'
    as _i29;
import 'package:app_controle_leitura/domain/usecases/goal/get_annual_goal.dart'
    as _i758;
import 'package:app_controle_leitura/domain/usecases/goal/set_annual_goal.dart'
    as _i711;
import 'package:app_controle_leitura/domain/usecases/note/add_note.dart'
    as _i268;
import 'package:app_controle_leitura/domain/usecases/note/delete_note.dart'
    as _i987;
import 'package:app_controle_leitura/domain/usecases/note/get_all_notes.dart'
    as _i742;
import 'package:app_controle_leitura/domain/usecases/note/get_notes_by_book.dart'
    as _i265;
import 'package:app_controle_leitura/domain/usecases/note/update_note.dart'
    as _i624;
import 'package:app_controle_leitura/domain/usecases/reading_session/delete_reading_session.dart'
    as _i341;
import 'package:app_controle_leitura/domain/usecases/reading_session/get_sessions_for_book.dart'
    as _i898;
import 'package:app_controle_leitura/domain/usecases/reading_session/upsert_reading_session.dart'
    as _i93;
import 'package:app_controle_leitura/domain/usecases/streak/record_reading_activity.dart'
    as _i1025;
import 'package:app_controle_leitura/presentation/blocs/auth/auth_bloc.dart'
    as _i209;
import 'package:app_controle_leitura/presentation/blocs/book/book_bloc.dart'
    as _i689;
import 'package:app_controle_leitura/presentation/blocs/book_list/book_list_cubit.dart'
    as _i379;
import 'package:app_controle_leitura/presentation/blocs/book_price/book_price_cubit.dart'
    as _i436;
import 'package:app_controle_leitura/presentation/blocs/goal/goal_cubit.dart'
    as _i826;
import 'package:app_controle_leitura/presentation/blocs/note/note_bloc.dart'
    as _i508;
import 'package:app_controle_leitura/presentation/blocs/reading_calendar/reading_calendar_cubit.dart'
    as _i14;
import 'package:app_controle_leitura/presentation/blocs/streak/streak_cubit.dart'
    as _i856;
import 'package:app_controle_leitura/presentation/blocs/sync/sync_cubit.dart'
    as _i677;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i903.GoogleAuthService>(() => _i903.GoogleAuthService());
    gh.lazySingleton<_i968.MicrosoftAuthService>(
        () => _i968.MicrosoftAuthService());
    gh.lazySingleton<_i258.DatabaseHelper>(() => _i258.DatabaseHelper());
    gh.lazySingleton<_i818.GoogleBooksService>(
        () => _i818.GoogleBooksService());
    gh.lazySingleton<_i497.MercadoLivreService>(
        () => _i497.MercadoLivreService());
    gh.lazySingleton<_i1038.AchievementRepository>(
        () => _i412.AchievementRepositoryImpl());
    gh.lazySingleton<_i53.OneDriveStorage>(
        () => _i53.OneDriveStorage(gh<_i968.MicrosoftAuthService>()));
    gh.lazySingleton<_i767.StreakRepository>(
        () => _i772.StreakRepositoryImpl());
    gh.lazySingleton<_i450.BookLocalDatasource>(
        () => _i450.BookLocalDatasource(gh<_i258.DatabaseHelper>()));
    gh.lazySingleton<_i314.NoteLocalDatasource>(
        () => _i314.NoteLocalDatasource(gh<_i258.DatabaseHelper>()));
    gh.lazySingleton<_i19.ReadingSessionLocalDatasource>(
        () => _i19.ReadingSessionLocalDatasource(gh<_i258.DatabaseHelper>()));
    gh.lazySingleton<_i926.NotificationService>(
        () => _i926.NotificationService(gh<_i258.DatabaseHelper>()));
    gh.lazySingleton<_i700.CheckAchievements>(() => _i700.CheckAchievements(
          gh<_i1038.AchievementRepository>(),
          gh<_i767.StreakRepository>(),
        ));
    gh.lazySingleton<_i85.GoalRepository>(() => _i985.GoalRepositoryImpl());
    gh.lazySingleton<_i1025.RecordReadingActivity>(
        () => _i1025.RecordReadingActivity(gh<_i767.StreakRepository>()));
    gh.lazySingleton<_i856.StreakCubit>(
        () => _i856.StreakCubit(gh<_i767.StreakRepository>()));
    gh.factory<_i436.BookPriceCubit>(
        () => _i436.BookPriceCubit(gh<_i497.MercadoLivreService>()));
    gh.lazySingleton<_i758.GetAnnualGoal>(
        () => _i758.GetAnnualGoal(gh<_i85.GoalRepository>()));
    gh.lazySingleton<_i711.SetAnnualGoal>(
        () => _i711.SetAnnualGoal(gh<_i85.GoalRepository>()));
    gh.lazySingleton<_i1055.GoogleDriveStorage>(
        () => _i1055.GoogleDriveStorage(gh<_i903.GoogleAuthService>()));
    gh.lazySingleton<_i196.BookRepository>(
        () => _i195.BookRepositoryImpl(gh<_i450.BookLocalDatasource>()));
    gh.lazySingleton<_i928.BookListRepository>(
        () => _i353.BookListRepositoryImpl(gh<_i258.DatabaseHelper>()));
    gh.lazySingleton<_i930.ReadingSessionRepository>(() =>
        _i318.ReadingSessionRepositoryImpl(
            gh<_i19.ReadingSessionLocalDatasource>()));
    gh.lazySingleton<_i397.AddBook>(
        () => _i397.AddBook(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i1009.DeleteBook>(
        () => _i1009.DeleteBook(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i206.GetAllBooks>(
        () => _i206.GetAllBooks(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i246.MarkAsRead>(
        () => _i246.MarkAsRead(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i300.MoveToReading>(
        () => _i300.MoveToReading(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i214.UpdateBook>(
        () => _i214.UpdateBook(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i304.UpdateReadingProgress>(
        () => _i304.UpdateReadingProgress(gh<_i196.BookRepository>()));
    gh.lazySingleton<_i522.NoteRepository>(
        () => _i219.NoteRepositoryImpl(gh<_i314.NoteLocalDatasource>()));
    gh.lazySingleton<_i826.GoalCubit>(() => _i826.GoalCubit(
          gh<_i758.GetAnnualGoal>(),
          gh<_i711.SetAnnualGoal>(),
          gh<_i206.GetAllBooks>(),
        ));
    gh.lazySingleton<_i507.AddBookToList>(
        () => _i507.AddBookToList(gh<_i928.BookListRepository>()));
    gh.lazySingleton<_i126.CreateBookList>(
        () => _i126.CreateBookList(gh<_i928.BookListRepository>()));
    gh.lazySingleton<_i742.DeleteBookList>(
        () => _i742.DeleteBookList(gh<_i928.BookListRepository>()));
    gh.lazySingleton<_i681.GetAllBookLists>(
        () => _i681.GetAllBookLists(gh<_i928.BookListRepository>()));
    gh.lazySingleton<_i29.RemoveBookFromList>(
        () => _i29.RemoveBookFromList(gh<_i928.BookListRepository>()));
    gh.lazySingleton<_i107.SyncService>(() => _i107.SyncService(
          gh<_i450.BookLocalDatasource>(),
          gh<_i314.NoteLocalDatasource>(),
        ));
    gh.lazySingleton<_i677.SyncCubit>(
        () => _i677.SyncCubit(gh<_i107.SyncService>()));
    gh.lazySingleton<_i209.AuthBloc>(() => _i209.AuthBloc(
          gh<_i903.GoogleAuthService>(),
          gh<_i968.MicrosoftAuthService>(),
          gh<_i107.SyncService>(),
          gh<_i1055.GoogleDriveStorage>(),
          gh<_i53.OneDriveStorage>(),
        ));
    gh.lazySingleton<_i689.BookBloc>(() => _i689.BookBloc(
          gh<_i206.GetAllBooks>(),
          gh<_i397.AddBook>(),
          gh<_i214.UpdateBook>(),
          gh<_i1009.DeleteBook>(),
          gh<_i300.MoveToReading>(),
          gh<_i246.MarkAsRead>(),
          gh<_i304.UpdateReadingProgress>(),
          gh<_i1025.RecordReadingActivity>(),
          gh<_i700.CheckAchievements>(),
          gh<_i926.NotificationService>(),
        ));
    gh.lazySingleton<_i268.AddNote>(
        () => _i268.AddNote(gh<_i522.NoteRepository>()));
    gh.lazySingleton<_i987.DeleteNote>(
        () => _i987.DeleteNote(gh<_i522.NoteRepository>()));
    gh.lazySingleton<_i742.GetAllNotes>(
        () => _i742.GetAllNotes(gh<_i522.NoteRepository>()));
    gh.lazySingleton<_i265.GetNotesByBook>(
        () => _i265.GetNotesByBook(gh<_i522.NoteRepository>()));
    gh.lazySingleton<_i624.UpdateNote>(
        () => _i624.UpdateNote(gh<_i522.NoteRepository>()));
    gh.lazySingleton<_i341.DeleteReadingSession>(
        () => _i341.DeleteReadingSession(gh<_i930.ReadingSessionRepository>()));
    gh.lazySingleton<_i898.GetSessionsForBook>(
        () => _i898.GetSessionsForBook(gh<_i930.ReadingSessionRepository>()));
    gh.lazySingleton<_i93.UpsertReadingSession>(
        () => _i93.UpsertReadingSession(gh<_i930.ReadingSessionRepository>()));
    gh.factory<_i14.ReadingCalendarCubit>(() => _i14.ReadingCalendarCubit(
          gh<_i898.GetSessionsForBook>(),
          gh<_i93.UpsertReadingSession>(),
          gh<_i341.DeleteReadingSession>(),
        ));
    gh.lazySingleton<_i379.BookListCubit>(() => _i379.BookListCubit(
          gh<_i681.GetAllBookLists>(),
          gh<_i126.CreateBookList>(),
          gh<_i742.DeleteBookList>(),
          gh<_i507.AddBookToList>(),
          gh<_i29.RemoveBookFromList>(),
        ));
    gh.lazySingleton<_i508.NoteBloc>(() => _i508.NoteBloc(
          gh<_i742.GetAllNotes>(),
          gh<_i265.GetNotesByBook>(),
          gh<_i268.AddNote>(),
          gh<_i624.UpdateNote>(),
          gh<_i987.DeleteNote>(),
        ));
    return this;
  }
}
