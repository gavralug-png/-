import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/achievements_data.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ornaments.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final gold = AppColors.goldFor(context);
    final got = game.achievementIds.length;
    return AppScaffold(
      title: 'Достижения',
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text('Получено: $got из ${kAchievements.length}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: gold, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const OrnamentDivider(),
            const SizedBox(height: 16),
            for (final a in kAchievements)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: game.achievementIds.contains(a.id) ? 1 : 0.75,
                  child: GoldCard(
                    highlight: game.achievementIds.contains(a.id),
                    child: Row(
                      children: [
                        AchievementBadge(
                          achievement: a,
                          unlocked: game.achievementIds.contains(a.id),
                          size: 66,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: AppTheme.heading(context, size: 18)),
                              const SizedBox(height: 4),
                              Text(a.description,
                                  style: TextStyle(
                                      fontSize: 14.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(210))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
