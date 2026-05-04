import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../datasources/local/database_helper.dart';
import '../../domain/entities/book_list.dart';
import '../../domain/repositories/book_list_repository.dart';

@LazySingleton(as: BookListRepository)
class BookListRepositoryImpl implements BookListRepository {
  final DatabaseHelper _db;
  BookListRepositoryImpl(this._db);

  @override
  Future<List<BookList>> getAllBookLists() async {
    final db = await _db.database;
    final lists = await db.query('book_lists', orderBy: 'created_at ASC');
    final result = <BookList>[];
    for (final row in lists) {
      final id = row['id'] as String;
      final items = await db.query(
        'book_list_items',
        where: 'list_id = ?',
        whereArgs: [id],
      );
      result.add(BookList(
        id: id,
        name: row['name'] as String,
        bookIds: items.map((i) => i['book_id'] as String).toList(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      ));
    }
    return result;
  }

  @override
  Future<void> createBookList(BookList list) async {
    final db = await _db.database;
    await db.insert('book_lists', {
      'id': list.id,
      'name': list.name,
      'created_at': list.createdAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> deleteBookList(String id) async {
    final db = await _db.database;
    await db.delete('book_lists', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addBookToList(String listId, String bookId) async {
    final db = await _db.database;
    await db.insert(
      'book_list_items',
      {'list_id': listId, 'book_id': bookId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> removeBookFromList(String listId, String bookId) async {
    final db = await _db.database;
    await db.delete(
      'book_list_items',
      where: 'list_id = ? AND book_id = ?',
      whereArgs: [listId, bookId],
    );
  }
}
