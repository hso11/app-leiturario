import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/usecases/note/add_note.dart';
import '../../../domain/usecases/note/delete_note.dart';
import '../../../domain/usecases/note/get_all_notes.dart';
import '../../../domain/usecases/note/get_notes_by_book.dart';
import '../../../domain/usecases/note/update_note.dart';

part 'note_event.dart';
part 'note_state.dart';

@lazySingleton
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetAllNotes _getAllNotes;
  final GetNotesByBook _getNotesByBook;
  final AddNote _addNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;
  final _uuid = const Uuid();

  NoteBloc(
    this._getAllNotes,
    this._getNotesByBook,
    this._addNote,
    this._updateNote,
    this._deleteNote,
  ) : super(NoteInitial()) {
    on<NoteLoadAllRequested>(_onLoadAll);
    on<NoteLoadByBookRequested>(_onLoadByBook);
    on<NoteAddRequested>(_onAdd);
    on<NoteUpdateRequested>(_onUpdate);
    on<NoteDeleteRequested>(_onDelete);
  }

  Future<void> _onLoadAll(
      NoteLoadAllRequested event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await _getAllNotes(const NoParams());
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NoteError('Erro ao carregar anotações: $e'));
    }
  }

  Future<void> _onLoadByBook(
      NoteLoadByBookRequested event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await _getNotesByBook(event.bookId);
      emit(NotesLoaded(notes, filterBookId: event.bookId));
    } catch (e) {
      emit(NoteError('Erro ao carregar anotações: $e'));
    }
  }

  Future<void> _onAdd(
      NoteAddRequested event, Emitter<NoteState> emit) async {
    try {
      final note = Note(
        id: _uuid.v4(),
        bookId: event.bookId,
        content: event.content,
        createdAt: DateTime.now(),
        pageRef: event.pageRef,
      );
      await _addNote(note);
      add(NoteLoadByBookRequested(event.bookId));
    } catch (e) {
      emit(NoteError('Erro ao adicionar anotação: $e'));
    }
  }

  Future<void> _onUpdate(
      NoteUpdateRequested event, Emitter<NoteState> emit) async {
    try {
      await _updateNote(event.note);
      final s = state;
      if (s is NotesLoaded && s.filterBookId != null) {
        add(NoteLoadByBookRequested(s.filterBookId!));
      } else {
        add(NoteLoadAllRequested());
      }
    } catch (e) {
      emit(NoteError('Erro ao atualizar anotação: $e'));
    }
  }

  Future<void> _onDelete(
      NoteDeleteRequested event, Emitter<NoteState> emit) async {
    try {
      await _deleteNote(event.id);
      if (event.bookId != null) {
        add(NoteLoadByBookRequested(event.bookId!));
      } else {
        add(NoteLoadAllRequested());
      }
    } catch (e) {
      emit(NoteError('Erro ao deletar anotação: $e'));
    }
  }
}
