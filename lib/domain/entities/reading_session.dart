import 'package:equatable/equatable.dart';

class ReadingSession extends Equatable {
  final String id;
  final String bookId;
  final DateTime date; // sempre normalizado à meia-noite
  final int pagesRead;

  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.date,
    required this.pagesRead,
  });

  static DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  List<Object?> get props => [id, bookId, date, pagesRead];
}
