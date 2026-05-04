import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/note.dart';
import '../../repositories/note_repository.dart';

@lazySingleton
class GetAllNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository _repository;
  GetAllNotes(this._repository);

  @override
  Future<List<Note>> call(NoParams params) => _repository.getAll();
}
