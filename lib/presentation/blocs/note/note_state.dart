part of 'note_bloc.dart';

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NotesLoaded extends NoteState {
  final List<Note> notes;
  final String? filterBookId;
  NotesLoaded(this.notes, {this.filterBookId});
}

class NoteError extends NoteState {
  final String message;
  NoteError(this.message);
}
