import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/book_model.dart';
import 'database_helper.dart';

@lazySingleton
class BookLocalDatasource {
  final DatabaseHelper _dbHelper;
  BookLocalDatasource(this._dbHelper);

  Future<List<BookModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('books', orderBy: 'rowid DESC');
    return maps.map((m) => BookModel.fromSqliteMap(m)).toList();
  }

  Future<BookModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BookModel.fromSqliteMap(maps.first);
  }

  Future<void> insert(BookModel book) async {
    final db = await _dbHelper.database;
    await db.insert('books', book.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(BookModel book) async {
    final db = await _dbHelper.database;
    await db.update('books', book.toSqliteMap(),
        where: 'id = ?', whereArgs: [book.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> replaceAll(List<BookModel> books) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    batch.delete('books');
    for (final book in books) {
      batch.insert('books', book.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
