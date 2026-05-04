import 'package:injectable/injectable.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/local/book_local_datasource.dart';
import '../models/book_model.dart';

@LazySingleton(as: BookRepository)
class BookRepositoryImpl implements BookRepository {
  final BookLocalDatasource _datasource;
  BookRepositoryImpl(this._datasource);

  @override
  Future<List<Book>> getAll() => _datasource.getAll();

  @override
  Future<Book?> getById(String id) => _datasource.getById(id);

  @override
  Future<void> add(Book book) =>
      _datasource.insert(BookModel.fromEntity(book));

  @override
  Future<void> update(Book book) =>
      _datasource.update(BookModel.fromEntity(book));

  @override
  Future<void> delete(String id) => _datasource.delete(id);
}
