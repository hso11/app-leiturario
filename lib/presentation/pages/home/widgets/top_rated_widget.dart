import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/entities/book.dart';

class TopRatedWidget extends StatelessWidget {
  final List<Book> books;
  const TopRatedWidget({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final rated = books
        .where((b) => b.rating != null)
        .toList()
      ..sort((a, b) {
        final cmp = b.rating!.compareTo(a.rating!);
        return cmp != 0 ? cmp : a.title.compareTo(b.title);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mais bem avaliados',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (rated.length < 3)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Avalie mais livros para ver seu ranking! ⭐',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          )
        else
          ...rated.take(5).map((book) => _TopRatedItem(book: book)),
      ],
    );
  }
}

class _TopRatedItem extends StatelessWidget {
  final Book book;
  const _TopRatedItem({required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _CoverThumb(coverUrl: book.coverUrl, title: book.title, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (i) => Icon(
                i < book.rating! ? Icons.star : Icons.star_border,
                size: 14,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? coverUrl;
  final String title;
  final double size;

  const _CoverThumb({required this.coverUrl, required this.title, required this.size});

  @override
  Widget build(BuildContext context) {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: coverUrl!,
          width: size,
          height: size * 1.4,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
