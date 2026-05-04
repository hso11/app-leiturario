import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class DatabaseHelper {
  static const _dbName = 'booktracker.db';
  static const _dbVersion = 6;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        status TEXT NOT NULL,
        total_pages INTEGER NOT NULL,
        start_date INTEGER,
        end_date INTEGER,
        target_date INTEGER,
        current_page INTEGER NOT NULL DEFAULT 0,
        rating INTEGER,
        review TEXT,
        genres TEXT,
        cover_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        page_ref INTEGER,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE book_lists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE book_list_items (
        list_id TEXT NOT NULL,
        book_id TEXT NOT NULL,
        PRIMARY KEY (list_id, book_id),
        FOREIGN KEY (list_id) REFERENCES book_lists(id) ON DELETE CASCADE,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_sessions (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        pages_read INTEGER NOT NULL,
        UNIQUE(book_id, date),
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE books ADD COLUMN target_date INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE books ADD COLUMN current_page INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE books ADD COLUMN rating INTEGER');
      await db.execute('ALTER TABLE books ADD COLUMN review TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN genres TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE books ADD COLUMN cover_url TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS book_lists (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS book_list_items (
          list_id TEXT NOT NULL,
          book_id TEXT NOT NULL,
          PRIMARY KEY (list_id, book_id),
          FOREIGN KEY (list_id) REFERENCES book_lists(id) ON DELETE CASCADE,
          FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_sessions (
          id TEXT PRIMARY KEY,
          book_id TEXT NOT NULL,
          date INTEGER NOT NULL,
          pages_read INTEGER NOT NULL,
          UNIQUE(book_id, date),
          FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('notes');
    await db.delete('reading_sessions');
    await db.delete('book_list_items');
    await db.delete('book_lists');
    await db.delete('books');
  }
}
