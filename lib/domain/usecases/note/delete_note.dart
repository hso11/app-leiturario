import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/note_repository.dart';

@lazySingleton
class DeleteNote implements UseCase<void, String> {
  final NoteRepository _repository;
  DeleteNote(this._repository);

  @override
  Future<void> call(String params) => _repository.delete(params);
}
