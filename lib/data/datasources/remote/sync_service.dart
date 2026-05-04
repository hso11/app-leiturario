import 'package:injectable/injectable.dart';
import '../local/book_local_datasource.dart';
import '../local/note_local_datasource.dart';
import '../../models/book_model.dart';
import '../../models/note_model.dart';
import 'storage_service.dart';

@lazySingleton
class SyncService {
  final BookLocalDatasource _bookDs;
  final NoteLocalDatasource _noteDs;

  SyncService(this._bookDs, this._noteDs);

  Future<Map<String, dynamic>> exportDatabase() async {
    final books = await _bookDs.getAll();
    final notes = await _noteDs.getAll();
    return {
      'books': books.map((b) => b.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
    };
  }

  Future<void> importDatabase(Map<String, dynamic> payload) async {
    final booksJson = (payload['books'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final notesJson = (payload['notes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final books = booksJson.map((j) => BookModel.fromJson(j)).toList();
    final notes = notesJson.map((j) => NoteModel.fromJson(j)).toList();

    await _bookDs.replaceAll(books);
    await _noteDs.replaceAll(notes);
  }

  Future<void> pushToCloud(StorageService storageService) async {
    final payload = await exportDatabase();
    await storageService.upload(payload);
  }

  Future<void> pullFromCloud(StorageService storageService) async {
    final payload = await storageService.download();
    if (payload != null) {
      await importDatabase(payload);
    }
  }
}
