import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/book.dart';

class BookGridCard extends StatelessWidget {
  final Book book;

  const BookGridCard({super.key, required this.book});

  Color get _statusColor {
    switch (book.status) {
      case BookStatus.reading:
        return AppColors.reading;
      case BookStatus.read:
        return AppColors.read;
      case BookStatus.wantToRead:
        return AppColors.wantToRead;
    }
  }

  (IconData, String) get _statusInfo {
    switch (book.status) {
      case BookStatus.reading:
        return (Icons.menu_book_rounded, 'Lendo');
      case BookStatus.read:
        return (Icons.check_circle_rounded, 'Lido');
      case BookStatus.wantToRead:
        return (Icons.bookmark_rounded, 'Quero Ler');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusIcon, statusLabel) = _statusInfo;

    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Capa
            _CoverImage(book: book, statusColor: _statusColor),

            // Gradiente inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 70,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.92),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Título e autor
            Positioned(
              left: 6,
              right: 6,
              bottom: book.status == BookStatus.reading ? 20 : 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Badge de status (topo direito)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 10, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Barra de progresso (somente lendo)
            if (book.status == BookStatus.reading &&
                book.readingProgress != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ProgressBar(
                  progress: book.readingProgress!,
                  color: _statusColor,
                  current: book.currentPage,
                  total: book.totalPages,
                ),
              ),

            // Estrelas (somente lido)
            if (book.status == BookStatus.read && book.rating != null)
              Positioned(
                left: 10,
                bottom: 8,
                child: _StarRating(rating: book.rating!),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final Book book;
  final Color statusColor;

  const _CoverImage({required this.book, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: book.coverUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: statusColor.withOpacity(0.3),
      child: Center(
        child: Text(
          book.title.isNotEmpty ? book.title[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final int current;
  final int total;

  const _ProgressBar({
    required this.progress,
    required this.color,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Container(
      height: 20,
      color: Colors.black.withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 13,
          color: i < rating ? const Color(0xFFFFA726) : Colors.white38,
        );
      }),
    );
  }
}
