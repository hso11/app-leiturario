import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/book_model.dart';
import '../../models/note_model.dart';
import '../local/book_local_datasource.dart';
import '../local/note_local_datasource.dart';
@lazySingleton
class SupabaseSyncService {
  final BookLocalDatasource _bookDs;
  final NoteLocalDatasource _noteDs;

  SupabaseSyncService(this._bookDs, this._noteDs);

  SupabaseClient get _client => Supabase.instance.client;

  /// Envia o estado local (celular -> nuvem). Faz upsert por id, então
  /// re-enviar é idempotente. Não apaga nada na nuvem.
  Future<void> push() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    final books = await _bookDs.getAll();
    final notes = await _noteDs.getAll();

    if (books.isNotEmpty) {
      await _client.from('books').upsert(
        books
            .map((b) => {...b.toSqliteMap(), 'user_id': userId})
            .toList(),
        onConflict: 'id',
      );
    }

    if (notes.isNotEmpty) {
      await _client.from('notes').upsert(
        notes
            .map((n) => {...n.toSqliteMap(), 'user_id': userId})
            .toList(),
        onConflict: 'id',
      );
    }
  }

  /// Traz o estado da nuvem (nuvem -> celular). Mescla: faz upsert por id no
  /// SQLite local, preservando registros que existem só no celular. Não apaga
  /// nada localmente. Útil ao reinstalar o app ou trocar de aparelho.
  Future<void> pull() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    final bookRows = await _client.from('books').select().eq('user_id', userId);
    final noteRows = await _client.from('notes').select().eq('user_id', userId);

    // As linhas da nuvem usam o mesmo formato do toSqliteMap (a coluna extra
    // user_id é ignorada pelo fromSqliteMap). insert() usa ConflictAlgorithm
    // .replace, então funciona como upsert por id.
    for (final row in bookRows) {
      await _bookDs.insert(BookModel.fromSqliteMap(row));
    }
    for (final row in noteRows) {
      await _noteDs.insert(NoteModel.fromSqliteMap(row));
    }
  }
}
