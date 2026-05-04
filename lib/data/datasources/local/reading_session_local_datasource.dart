import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/reading_session_model.dart';
import 'database_helper.dart';

@lazySingleton
class ReadingSessionLocalDatasource {
  final DatabaseHelper _dbHelper;
  ReadingSessionLocalDatasource(this._dbHelper);

  Future<List<ReadingSessionModel>> getByBook(String bookId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reading_sessions',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'date ASC',
    );
    return maps.map((m) => ReadingSessionModel.fromSqliteMap(m)).toList();
  }

  Future<void> upsert(ReadingSessionModel session) async {
    final db = await _dbHelper.database;
    await db.insert(
      'reading_sessions',
      session.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('reading_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> replaceAll(List<ReadingSessionModel> sessions) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    batch.delete('reading_sessions');
    for (final s in sessions) {
      batch.insert('reading_sessions', s.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
