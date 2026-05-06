import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.status,
    required super.totalPages,
    super.startDate,
    super.endDate,
    super.targetDate,
    super.currentPage = 0,
    super.rating,
    super.review,
    super.genres = const [],
    super.coverUrl,
    super.position = 0,
  });

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      status: book.status,
      totalPages: book.totalPages,
      startDate: book.startDate,
      endDate: book.endDate,
      targetDate: book.targetDate,
      currentPage: book.currentPage,
      rating: book.rating,
      review: book.review,
      genres: book.genres,
      coverUrl: book.coverUrl,
      position: book.position,
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      status: BookStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookStatus.wantToRead,
      ),
      totalPages: json['totalPages'] as int,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      currentPage: (json['currentPage'] as int?) ?? 0,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      coverUrl: json['coverUrl'] as String?,
      position: (json['position'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'status': status.name,
      'totalPages': totalPages,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'currentPage': currentPage,
      'rating': rating,
      'review': review,
      'genres': genres,
      'coverUrl': coverUrl,
      'position': position,
    };
  }

  factory BookModel.fromSqliteMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      status: BookStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookStatus.wantToRead,
      ),
      totalPages: map['total_pages'] as int,
      startDate: map['start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)
          : null,
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      targetDate: map['target_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int)
          : null,
      currentPage: (map['current_page'] as int?) ?? 0,
      rating: map['rating'] as int?,
      review: map['review'] as String?,
      genres: (map['genres'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      coverUrl: map['cover_url'] as String?,
      position: (map['position'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'status': status.name,
      'total_pages': totalPages,
      'start_date': startDate?.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'target_date': targetDate?.millisecondsSinceEpoch,
      'current_page': currentPage,
      'rating': rating,
      'review': review,
      'genres': genres.isEmpty ? null : genres.join(','),
      'cover_url': coverUrl,
      'position': position,
    };
  }
}
