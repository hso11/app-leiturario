import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';

class ReadingHeatmapWidget extends StatelessWidget {
  final Set<String> activityDates;
  const ReadingHeatmapWidget({super.key, required this.activityDates});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Start 91 days ago on a Sunday (for clean grid)
    final startRaw = today.subtract(const Duration(days: 90));
    final weekdayOffset = startRaw.weekday % 7; // 0=Sun
    final gridStart = startRaw.subtract(Duration(days: weekdayOffset));

    // Build 13 columns × 7 rows
    final weeks = <List<DateTime?>>[];
    var cur = gridStart;
    while (cur.isBefore(today.add(const Duration(days: 1)))) {
      final week = <DateTime?>[];
      for (var d = 0; d < 7; d++) {
        final day = cur.add(Duration(days: d));
        week.add(day.isAfter(today) ? null : day);
      }
      weeks.add(week);
      cur = cur.add(const Duration(days: 7));
    }

    // Month labels
    final monthLabels = <int, String>{};
    for (var wi = 0; wi < weeks.length; wi++) {
      final first = weeks[wi].firstWhere((d) => d != null, orElse: () => null);
      if (first != null && first.day <= 7) {
        monthLabels[wi] = DateFormat('MMM', 'pt_BR').format(first);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Heatmap de leitura',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        // Month labels row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 16), // weekday label space
            ...List.generate(weeks.length, (wi) {
              return SizedBox(
                width: 14,
                child: Text(
                  monthLabels[wi] ?? '',
                  style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
                  overflow: TextOverflow.visible,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 2),
        // Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday labels
            const Column(
              children: [
                SizedBox(height: 1),
                _DayLabel('D'),
                _DayLabel('S'),
                _DayLabel('T'),
                _DayLabel('Q'),
                _DayLabel('Q'),
                _DayLabel('S'),
                _DayLabel('S'),
              ],
            ),
            const SizedBox(width: 2),
            ...weeks.map((week) => Column(
              children: week.map((day) {
                if (day == null) {
                  return const SizedBox(width: 12, height: 12, child: SizedBox());
                }
                final key =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                final active = activityDates.contains(key);
                return Padding(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            )),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('menos', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            ...List.generate(4, (i) {
              final alpha = 0.1 + i * 0.3;
              return Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: alpha),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
            const SizedBox(width: 4),
            const Text('mais', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Text(
        label,
        style: const TextStyle(fontSize: 7, color: AppColors.textSecondary),
      ),
    );
  }
}
