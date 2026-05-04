import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum BookStatus { reading, read, wantToRead }

class _FakeBook {
  final String title;
  final String author;
  final BookStatus status;
  final String? coverUrl;
  final double? progress; // 0.0 to 1.0, only for reading
  final int? rating; // 1-5, only for read
  final String? goalDate; // only for reading
  final String? readDuration; // only for read

  const _FakeBook({
    required this.title,
    required this.author,
    required this.status,
    this.coverUrl,
    this.progress,
    this.rating,
    this.goalDate,
    this.readDuration,
  });
}

const _fakeBooks = [
  _FakeBook(
    title: 'O Senhor dos Anéis',
    author: 'J.R.R. Tolkien',
    status: BookStatus.reading,
    coverUrl:
        'https://covers.openlibrary.org/b/id/8743161-M.jpg',
    progress: 0.65,
    goalDate: 'Meta: 15 mai 2026',
  ),
  _FakeBook(
    title: 'Dom Casmurro',
    author: 'Machado de Assis',
    status: BookStatus.read,
    coverUrl:
        'https://covers.openlibrary.org/b/id/8231856-M.jpg',
    rating: 4,
    readDuration: 'Lido em 12 dias',
  ),
  _FakeBook(
    title: 'Duna',
    author: 'Frank Herbert',
    status: BookStatus.wantToRead,
    coverUrl:
        'https://covers.openlibrary.org/b/id/8577666-M.jpg',
  ),
];

class BookCardPrototypePage extends StatelessWidget {
  const BookCardPrototypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Protótipo — Cards de Livros'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _fakeBooks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _BookCard(book: _fakeBooks[index]),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final _FakeBook book;

  const _BookCard({required this.book});

  Color get _borderColor {
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _borderColor, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(url: book.coverUrl, title: book.title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        icon: statusIcon,
                        label: statusLabel,
                        color: _borderColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (book.status == BookStatus.reading &&
                      book.progress != null) ...[
                    _ProgressRow(progress: book.progress!),
                    if (book.goalDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.goalDate!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                  if (book.status == BookStatus.read) ...[
                    if (book.rating != null)
                      _StarRating(rating: book.rating!),
                    if (book.readDuration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.readDuration!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  final String title;

  const _CoverImage({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 60,
        height: 84,
        child: url != null
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: const Center(
        child: Icon(Icons.book_rounded, size: 32, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final double progress;

  const _ProgressRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.reading),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
          size: 16,
          color: i < rating ? const Color(0xFFFFA726) : const Color(0xFFBDBDBD),
        );
      }),
    );
  }
}
