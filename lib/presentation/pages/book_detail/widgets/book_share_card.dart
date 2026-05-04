import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/book.dart';

/// Card visual para compartilhamento — 4:5 ratio (feed Instagram).
/// Envolva com RepaintBoundary + GlobalKey para captura.
class BookShareCard extends StatelessWidget {
  final Book book;

  const BookShareCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(
        children: [
          // ── Fundo gradiente ───────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C5F8A), // primary escuro
                    Color(0xFF4A90D9), // primary
                    Color(0xFF7B68EE), // secondary
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Padrão decorativo de círculos ─────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _Circle(size: 200, opacity: 0.08),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _Circle(size: 160, opacity: 0.08),
          ),
          Positioned(
            top: 80,
            left: -30,
            child: _Circle(size: 100, opacity: 0.05),
          ),

          // ── Conteúdo ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Text(
                      'Terminei de ler!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Capa + info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CoverBlock(book: book),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            book.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.author,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (book.rating != null) ...[
                            const SizedBox(height: 10),
                            _StarRating(rating: book.rating!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divisor
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),

                const SizedBox(height: 16),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBlock(
                      value: '${book.totalPages}',
                      label: 'páginas',
                      icon: Icons.auto_stories,
                    ),
                    if (book.startDate != null && book.endDate != null)
                      _StatBlock(
                        value:
                            '${book.endDate!.difference(book.startDate!).inDays + 1}',
                        label: 'dias',
                        icon: Icons.calendar_today,
                      ),
                    if (book.pagesPerDay != null)
                      _StatBlock(
                        value: book.pagesPerDay!.toStringAsFixed(0),
                        label: 'págs/dia',
                        icon: Icons.speed,
                      ),
                    if (book.endDate != null)
                      _StatBlock(
                        value: DateFormat('MMM yy', 'pt_BR')
                            .format(book.endDate!),
                        label: 'concluído',
                        icon: Icons.check_circle_outline,
                      ),
                  ],
                ),

                const Spacer(),

                // Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book,
                        color: Colors.white54, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Controle de Leitura',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subwidgets ──────────────────────────────────────────────────────────────

class _CoverBlock extends StatelessWidget {
  final Book book;
  const _CoverBlock({required this.book});

  @override
  Widget build(BuildContext context) {
    const w = 90.0;
    const h = 130.0;

    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: book.coverUrl!,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _Fallback(book: book, w: w, h: h),
        ),
      );
    }
    return _Fallback(book: book, w: w, h: h);
  }
}

class _Fallback extends StatelessWidget {
  final Book book;
  final double w, h;
  const _Fallback({required this.book, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        book.title.isNotEmpty ? book.title[0].toUpperCase() : '📖',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w800,
        ),
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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: i < rating ? const Color(0xFFFFD700) : Colors.white38,
        );
      }),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBlock({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
