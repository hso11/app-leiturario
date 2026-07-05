import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../blocs/book/book_bloc.dart';
import '../../../blocs/streak/streak_cubit.dart';
import '../../../widgets/premium_gate.dart';
import '../../../../domain/entities/book.dart';
import '../widgets/monthly_chart_widget.dart';
import '../widgets/top_rated_widget.dart';
import '../widgets/reading_heatmap_widget.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BooksLoaded) {
          return _StatsView(books: state.books);
        }
        if (state is BookError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}

class _StatsView extends StatelessWidget {
  final List<Book> books;
  const _StatsView({required this.books});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;

    final allRead = books.where((b) => b.status == BookStatus.read).toList();
    final readThisYear =
        allRead.where((b) => b.endDate?.year == year).toList();
    final pagesThisYear =
        readThisYear.fold<int>(0, (sum, b) => sum + b.totalPages);

    final booksWithDuration = allRead
        .where((b) => b.startDate != null && b.endDate != null)
        .toList();
    final avgDays = booksWithDuration.isEmpty
        ? null
        : booksWithDuration
                .map((b) => b.endDate!.difference(b.startDate!).inDays)
                .fold<int>(0, (a, b) => a + b) /
            booksWithDuration.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatCard(
              label: 'Total lidos',
              value: allRead.length.toString(),
              icon: Icons.menu_book,
              color: AppColors.read,
            ),
            _StatCard(
              label: 'Lidos em $year',
              value: readThisYear.length.toString(),
              icon: Icons.calendar_today,
              color: AppColors.primary,
            ),
            _StatCard(
              label: 'Páginas em $year',
              value: pagesThisYear.toString(),
              icon: Icons.auto_stories,
              color: AppColors.secondary,
            ),
            _StatCard(
              label: 'Dias/livro (média)',
              value: avgDays != null ? avgDays.toStringAsFixed(1) : '—',
              icon: Icons.timer_outlined,
              color: AppColors.reading,
            ),
          ],
        ),
        const SizedBox(height: 20),
        PremiumGate(
          featureName: 'Heatmap de leitura',
          lockedPlaceholder: const _LockedStatCard(
            icon: Icons.grid_on,
            label: 'Heatmap de leitura',
          ),
          child: _HeatmapSection(),
        ),
        const SizedBox(height: 20),
        PremiumGate(
          featureName: 'Gráfico mensal',
          lockedPlaceholder: const _LockedStatCard(
            icon: Icons.bar_chart,
            label: 'Gráfico de leitura mensal',
          ),
          child: MonthlyChartWidget(books: books, year: year),
        ),
        const SizedBox(height: 20),
        TopRatedWidget(books: books),
      ],
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final streakCubit = context.read<StreakCubit>();
    return FutureBuilder<Set<String>>(
      future: streakCubit.getActivityDates(),
      builder: (context, snapshot) {
        final dates = snapshot.data ?? {};
        return ReadingHeatmapWidget(activityDates: dates);
      },
    );
  }
}

class _LockedStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LockedStatCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showPremiumBottomSheet(context, label),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const Text('Disponível no Premium',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.lock_outline,
                size: 18, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 22, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
