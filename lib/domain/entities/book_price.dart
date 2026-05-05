class BookPrice {
  final String title;
  final double price;
  final String currencyId;
  final String? thumbnail;
  final String url;

  const BookPrice({
    required this.title,
    required this.price,
    required this.currencyId,
    this.thumbnail,
    required this.url,
  });
}
