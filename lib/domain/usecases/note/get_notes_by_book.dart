import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/note.dart';
import '../../repositories/note_repository.dart';

@lazySingleton
class GetNotesByBook implements UseCase<List<Note>, String> {
  final NoteRepository _repository;
  GetNotesByBook(this._repository);

  @override
  Future<List<Note>> call(String params) => _repository.getByBook(params);
}
