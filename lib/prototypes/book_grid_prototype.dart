import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum BookStatus { reading, read, wantToRead }

class _FakeBook {
  final String title;
  final String author;
  final BookStatus status;
  final String? coverUrl;
  final double? progress;
  final int? rating;

  const _FakeBook({
    required this.title,
    required this.author,
    required this.status,
    this.coverUrl,
    this.progress,
    this.rating,
  });
}

const _fakeBooks = [
  _FakeBook(
    title: 'O Senhor dos Anéis',
    author: 'J.R.R. Tolkien',
    status: BookStatus.reading,
    coverUrl: 'https://covers.openlibrary.org/b/id/8743161-L.jpg',
    progress: 0.65,
  ),
  _FakeBook(
    title: 'Dom Casmurro',
    author: 'Machado de Assis',
    status: BookStatus.read,
    coverUrl: 'https://covers.openlibrary.org/b/id/8231856-L.jpg',
    rating: 4,
  ),
  _FakeBook(
    title: 'Duna',
    author: 'Frank Herbert',
    status: BookStatus.wantToRead,
    coverUrl: 'https://covers.openlibrary.org/b/id/8577666-L.jpg',
  ),
  _FakeBook(
    title: '1984',
    author: 'George Orwell',
    status: BookStatus.read,
    coverUrl: 'https://covers.openlibrary.org/b/id/8575708-L.jpg',
    rating: 5,
  ),
  _FakeBook(
    title: 'Cem Anos de Solidão',
    author: 'Gabriel García Márquez',
    status: BookStatus.wantToRead,
    coverUrl: 'https://covers.openlibrary.org/b/id/8701592-L.jpg',
  ),
  _FakeBook(
    title: 'O Alquimista',
    author: 'Paulo Coelho',
    status: BookStatus.reading,
    coverUrl: 'https://covers.openlibrary.org/b/id/8241161-L.jpg',
    progress: 0.32,
  ),
];

class BookGridPrototypePage extends StatelessWidget {
  const BookGridPrototypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        title: const Text(
          'Minha Estante',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsBar(),
          const SizedBox(height: 8),
          _FilterChips(),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: _fakeBooks.length,
              itemBuilder: (context, index) =>
                  _BookGridCard(book: _fakeBooks[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(value: '6', label: 'Total'),
          _Divider(),
          _StatItem(value: '2', label: 'Lendo'),
          _Divider(),
          _StatItem(value: '2', label: 'Lidos'),
          _Divider(),
          _StatItem(value: '2', label: 'Quero Ler'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.12),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(label: 'Todos', selected: true),
          const SizedBox(width: 8),
          _Chip(label: 'Lendo'),
          const SizedBox(width: 8),
          _Chip(label: 'Lidos'),
          const SizedBox(width: 8),
          _Chip(label: 'Quero Ler'),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;

  const _Chip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white.withOpacity(0.6),
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _BookGridCard extends StatelessWidget {
  final _FakeBook book;

  const _BookGridCard({required this.book});

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Capa
          _CoverImage(url: book.coverUrl, title: book.title),

          // Gradiente inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 110,
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
            left: 10,
            right: 10,
            bottom: book.status == BookStatus.reading ? 24 : 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
                    fontSize: 11,
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
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
          if (book.status == BookStatus.reading && book.progress != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ProgressBar(progress: book.progress!, color: _statusColor),
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
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  final String title;

  const _CoverImage({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF2C2C2C),
      child: const Center(
        child: Icon(Icons.book_rounded, size: 48, color: Color(0xFF555555)),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressBar({required this.progress, required this.color});

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
