import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import 'achievement_badge.dart';

/// Показывает диалоги о полученных достижениях (по очереди).
Future<void> showNewAchievements(BuildContext context) async {
  final list = context.read<GameProvider>().takePendingAchievements();
  for (final a in list) {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _AchievementDialog(achievement: a),
    );
  }
}

class _AchievementDialog extends StatelessWidget {
  const _AchievementDialog({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.goldFor(context), width: 1.4),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Новое достижение!', style: AppTheme.heading(context, size: 20)),
          const SizedBox(height: 18),
          AchievementBadge(achievement: achievement, unlocked: true, size: 92),
          const SizedBox(height: 16),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: AppTheme.heading(context,
                size: 22, color: AppColors.goldFor(context)),
          ),
          const SizedBox(height: 6),
          Text(achievement.description, textAlign: TextAlign.center),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Продолжить'),
        ),
      ],
    );
  }
}
