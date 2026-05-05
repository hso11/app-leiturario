import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../domain/entities/book_price.dart';

@lazySingleton
class MercadoLivreService {
  Future<List<BookPrice>> search(String title, String author) async {
    if (title.trim().isEmpty) return [];

    final query = Uri.encodeQueryComponent('${title.trim()} ${author.trim()}');
    final uri = Uri.parse(
      'https://api.mercadolibre.com/sites/MLB/search?q=$query&category=MLB1193&limit=5',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results.map((item) {
        final map = item as Map<String, dynamic>;
        return BookPrice(
          title: (map['title'] as String?) ?? '',
          price: ((map['price'] as num?) ?? 0).toDouble(),
          currencyId: (map['currency_id'] as String?) ?? 'BRL',
          thumbnail: map['thumbnail'] as String?,
          url: (map['permalink'] as String?) ?? '',
        );
      }).where((p) => p.title.isNotEmpty && p.url.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}
