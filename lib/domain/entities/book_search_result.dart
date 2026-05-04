class BookSearchResult {
  final String title;
  final String author;
  final int? pageCount;
  final String? coverUrl;

  const BookSearchResult({
    required this.title,
    required this.author,
    this.pageCount,
    this.coverUrl,
  });
}
