import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/book.dart';

class MonthlyChartWidget extends StatelessWidget {
  final List<Book> books;
  final int year;

  const MonthlyChartWidget({
    super.key,
    required this.books,
    required this.year,
  });

  List<double> _pagesPerMonth() {
    final data = List<double>.filled(12, 0);
    for (final book in books) {
      if (book.status == BookStatus.read &&
          book.endDate != null &&
          book.endDate!.year == year) {
        data[book.endDate!.month - 1] += book.totalPages.toDouble();
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final data = _pagesPerMonth();
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxY <= 0 ? 100.0 : maxY * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Páginas lidas em $year',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: effectiveMax,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final pages = rod.toY.toInt();
                    if (pages == 0) return null;
                    return BarTooltipItem(
                      '$pages págs',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final month = value.toInt() + 1;
                      final label = DateFormat('MMM', 'pt_BR')
                          .format(DateTime(year, month));
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary),
                        ),
                      );
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.textSecondary.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(12, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[i],
                      color: data[i] > 0
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
