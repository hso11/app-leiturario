import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String bookId;
  final String content;
  final DateTime createdAt;
  final int? pageRef;

  const Note({
    required this.id,
    required this.bookId,
    required this.content,
    required this.createdAt,
    this.pageRef,
  });

  Note copyWith({
    String? id,
    String? bookId,
    String? content,
    DateTime? createdAt,
    int? pageRef,
    bool clearPageRef = false,
  }) {
    return Note(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      pageRef: clearPageRef ? null : (pageRef ?? this.pageRef),
    );
  }

  @override
  List<Object?> get props => [id, bookId, content, createdAt, pageRef];
}
