class BookList {
  final String id;
  final String name;
  final List<String> bookIds;
  final DateTime createdAt;

  const BookList({
    required this.id,
    required this.name,
    required this.bookIds,
    required this.createdAt,
  });

  BookList copyWith({
    String? name,
    List<String>? bookIds,
  }) {
    return BookList(
      id: id,
      name: name ?? this.name,
      bookIds: bookIds ?? this.bookIds,
      createdAt: createdAt,
    );
  }
}
