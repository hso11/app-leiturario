import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../blocs/goal/goal_cubit.dart';

class AnnualGoalWidget extends StatelessWidget {
  const AnnualGoalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalCubit, GoalState>(
      builder: (context, state) {
        final goal = state.goal;
        final read = state.booksReadThisYear;

        return GestureDetector(
          onTap: () => _showSetGoalDialog(context, goal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.annualGoal,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 12, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 4),
                if (goal != null) ...[
                  Text(
                    '$read de $goal ${AppStrings.booksRead}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: goal > 0 ? (read / goal).clamp(0.0, 1.0) : 0,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ] else
                  Text(
                    AppStrings.setGoal,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSetGoalDialog(BuildContext context, int? currentGoal) {
    final controller = TextEditingController(
        text: currentGoal != null ? currentGoal.toString() : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.annualGoal),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Quantos livros?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v > 0) {
                context.read<GoalCubit>().setGoal(v);
              }
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
