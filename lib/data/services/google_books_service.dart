import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../core/constants/app_config.dart';
import '../../domain/entities/book_search_result.dart';

@lazySingleton
class GoogleBooksService {
  Future<List<BookSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=intitle:$encoded&maxResults=5&key=$kGoogleBooksApiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      final info = (item as Map<String, dynamic>)['volumeInfo'] as Map<String, dynamic>? ?? {};
      final authors = info['authors'] as List<dynamic>?;
      final imageLinks = info['imageLinks'] as Map<String, dynamic>?;
      String? thumbnail = imageLinks?['thumbnail'] as String?;
      if (thumbnail != null) {
        thumbnail = thumbnail.replaceFirst('http://', 'https://');
      }
      return BookSearchResult(
        title: (info['title'] as String?) ?? '',
        author: authors != null && authors.isNotEmpty
            ? authors.first as String
            : '',
        pageCount: info['pageCount'] as int?,
        coverUrl: thumbnail,
      );
    }).where((r) => r.title.isNotEmpty).toList();
  }
}
