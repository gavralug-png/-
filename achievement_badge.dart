import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';

/// Золотой значок достижения (серый и с замком, пока не получен).
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.unlocked,
    this.size = 64,
  });

  final Achievement achievement;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.lightGold, AppColors.gold, Color(0xFFA8842F)],
              )
            : LinearGradient(
                colors: [Colors.grey.shade500, Colors.grey.shade700],
              ),
        border: Border.all(
          color: unlocked ? AppColors.lightGold : Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppColors.gold.withAlpha(90),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        unlocked ? achievement.icon : Icons.lock,
        color: unlocked ? AppColors.navy : Colors.white70,
        size: size * 0.5,
      ),
    );
  }
}
