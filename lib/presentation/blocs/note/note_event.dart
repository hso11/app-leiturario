part of 'note_bloc.dart';

abstract class NoteEvent {}

class NoteLoadAllRequested extends NoteEvent {}

class NoteLoadByBookRequested extends NoteEvent {
  final String bookId;
  NoteLoadByBookRequested(this.bookId);
}

class NoteAddRequested extends NoteEvent {
  final String bookId;
  final String content;
  final int? pageRef;
  NoteAddRequested({
    required this.bookId,
    required this.content,
    this.pageRef,
  });
}

class NoteUpdateRequested extends NoteEvent {
  final Note note;
  NoteUpdateRequested(this.note);
}

class NoteDeleteRequested extends NoteEvent {
  final String id;
  final String? bookId; // if set, reload by book after delete
  NoteDeleteRequested(this.id, {this.bookId});
}
