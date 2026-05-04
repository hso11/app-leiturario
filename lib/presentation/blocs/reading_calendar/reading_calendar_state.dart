part of 'reading_calendar_cubit.dart';

abstract class ReadingCalendarState extends Equatable {
  const ReadingCalendarState();
}

class ReadingCalendarInitial extends ReadingCalendarState {
  const ReadingCalendarInitial();
  @override
  List<Object?> get props => [];
}

class ReadingCalendarLoading extends ReadingCalendarState {
  const ReadingCalendarLoading();
  @override
  List<Object?> get props => [];
}

class ReadingCalendarLoaded extends ReadingCalendarState {
  final String bookId;
  final Map<DateTime, ReadingSession> sessions;

  const ReadingCalendarLoaded({
    required this.bookId,
    required this.sessions,
  });

  int get totalPages =>
      sessions.values.fold(0, (sum, s) => sum + s.pagesRead);

  @override
  List<Object?> get props => [bookId, sessions];
}

class ReadingCalendarError extends ReadingCalendarState {
  final String message;
  const ReadingCalendarError(this.message);
  @override
  List<Object?> get props => [message];
}
