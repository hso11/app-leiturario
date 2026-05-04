import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../blocs/streak/streak_cubit.dart';

class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        final streak = state.currentStreak;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: streak > 0 ? Colors.deepOrange : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.readingStreak,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: streak > 0
                            ? Colors.deepOrange
                            : AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                streak > 0
                    ? '$streak ${AppStrings.streak}'
                    : 'Nenhum dia ainda',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: streak > 0 ? null : AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}
