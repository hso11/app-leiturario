import '../../domain/entities/reading_session.dart';

class ReadingSessionModel extends ReadingSession {
  const ReadingSessionModel({
    required super.id,
    required super.bookId,
    required super.date,
    required super.pagesRead,
  });

  factory ReadingSessionModel.fromEntity(ReadingSession s) {
    return ReadingSessionModel(
      id: s.id,
      bookId: s.bookId,
      date: ReadingSession.normalizeDate(s.date),
      pagesRead: s.pagesRead,
    );
  }

  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) {
    return ReadingSessionModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      date: ReadingSession.normalizeDate(DateTime.parse(json['date'] as String)),
      pagesRead: json['pagesRead'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'date': date.toIso8601String(),
        'pagesRead': pagesRead,
      };

  factory ReadingSessionModel.fromSqliteMap(Map<String, dynamic> map) {
    return ReadingSessionModel(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      date: ReadingSession.normalizeDate(
          DateTime.fromMillisecondsSinceEpoch(map['date'] as int)),
      pagesRead: map['pages_read'] as int,
    );
  }

  Map<String, dynamic> toSqliteMap() => {
        'id': id,
        'book_id': bookId,
        'date': date.millisecondsSinceEpoch,
        'pages_read': pagesRead,
      };
}
