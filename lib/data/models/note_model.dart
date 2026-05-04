import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.bookId,
    required super.content,
    required super.createdAt,
    super.pageRef,
  });

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      bookId: note.bookId,
      content: note.content,
      createdAt: note.createdAt,
      pageRef: note.pageRef,
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pageRef: json['pageRef'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'pageRef': pageRef,
    };
  }

  factory NoteModel.fromSqliteMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      pageRef: map['page_ref'] as int?,
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'book_id': bookId,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'page_ref': pageRef,
    };
  }
}
