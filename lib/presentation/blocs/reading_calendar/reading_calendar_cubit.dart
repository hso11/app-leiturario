import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/reading_session.dart';
import '../../../domain/usecases/reading_session/get_sessions_for_book.dart';
import '../../../domain/usecases/reading_session/upsert_reading_session.dart';
import '../../../domain/usecases/reading_session/delete_reading_session.dart';

part 'reading_calendar_state.dart';

@injectable
class ReadingCalendarCubit extends Cubit<ReadingCalendarState> {
  final GetSessionsForBook _getSessions;
  final UpsertReadingSession _upsert;
  final DeleteReadingSession _delete;
  final _uuid = const Uuid();

  ReadingCalendarCubit(this._getSessions, this._upsert, this._delete)
      : super(const ReadingCalendarInitial());

  Future<void> load(String bookId) async {
    emit(const ReadingCalendarLoading());
    try {
      final list = await _getSessions(bookId);
      final map = <DateTime, ReadingSession>{};
      for (final s in list) {
        map[s.date] = s;
      }
      emit(ReadingCalendarLoaded(bookId: bookId, sessions: map));
    } catch (e) {
      emit(ReadingCalendarError('Erro ao carregar sessões: $e'));
    }
  }

  Future<void> upsert({
    required String bookId,
    required DateTime date,
    required int pagesRead,
    String? existingId,
  }) async {
    try {
      await _upsert(UpsertSessionParams(
        id: existingId ?? _uuid.v4(),
        bookId: bookId,
        date: date,
        pagesRead: pagesRead,
      ));
      await load(bookId);
    } catch (e) {
      emit(ReadingCalendarError('Erro ao salvar sessão: $e'));
    }
  }

  Future<void> deleteSession(String id, String bookId) async {
    try {
      await _delete(id);
      await load(bookId);
    } catch (e) {
      emit(ReadingCalendarError('Erro ao remover sessão: $e'));
    }
  }
}
