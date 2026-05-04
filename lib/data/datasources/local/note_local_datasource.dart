import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/note_model.dart';
import 'database_helper.dart';

@lazySingleton
class NoteLocalDatasource {
  final DatabaseHelper _dbHelper;
  NoteLocalDatasource(this._dbHelper);

  Future<List<NoteModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('notes', orderBy: 'created_at DESC');
    return maps.map((m) => NoteModel.fromSqliteMap(m)).toList();
  }

  Future<List<NoteModel>> getByBook(String bookId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('notes',
        where: 'book_id = ?',
        whereArgs: [bookId],
        orderBy: 'created_at DESC');
    return maps.map((m) => NoteModel.fromSqliteMap(m)).toList();
  }

  Future<void> insert(NoteModel note) async {
    final db = await _dbHelper.database;
    await db.insert('notes', note.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(NoteModel note) async {
    final db = await _dbHelper.database;
    await db.update('notes', note.toSqliteMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> replaceAll(List<NoteModel> notes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    batch.delete('notes');
    for (final note in notes) {
      batch.insert('notes', note.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
