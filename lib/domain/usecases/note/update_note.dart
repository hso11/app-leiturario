import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/note.dart';
import '../../repositories/note_repository.dart';

@lazySingleton
class UpdateNote implements UseCase<void, Note> {
  final NoteRepository _repository;
  UpdateNote(this._repository);

  @override
  Future<void> call(Note params) => _repository.update(params);
}
