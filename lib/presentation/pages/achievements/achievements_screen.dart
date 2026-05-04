import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/achievement.dart';
import '../../../domain/repositories/achievement_repository.dart';
import '../../../injection.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conquistas')),
      body: FutureBuilder<Map<String, DateTime>>(
        future: getIt<AchievementRepository>().getEarnedAchievements(),
        builder: (context, snapshot) {
          final earned = snapshot.data ?? {};
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: Achievement.all.length,
            itemBuilder: (context, i) {
              final achievement = Achievement.all[i];
              final earnedAt = earned[achievement.id];
              return _AchievementCard(
                achievement: achievement.copyWith(earnedAt: earnedAt),
              );
            },
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isEarned = achievement.isEarned;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEarned
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 32,
              color: isEarned ? null : const Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isEarned ? null : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          if (isEarned && achievement.earnedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Conquistado em ${DateFormat('d MMM yy', 'pt_BR').format(achievement.earnedAt!)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ] else if (!isEarned) ...[
            const SizedBox(height: 4),
            const Icon(Icons.lock_outline, size: 14, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}
