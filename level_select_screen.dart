import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/categories.dart';
import '../models/quiz_category.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_route.dart';
import '../widgets/ornaments.dart';
import 'quiz_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    return AppScaffold(
      title: 'Выбор уровня',
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            for (final c in kCategories)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _LevelCard(
                  category: c,
                  unlocked: game.isUnlocked(c.index),
                  completed: game.completedCategories.contains(c.index),
                  answered: game.answeredInCategory(c),
                  correct: game.correctInCategory(c),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.category,
    required this.unlocked,
    required this.completed,
    required this.answered,
    required this.correct,
  });

  final QuizCategory category;
  final bool unlocked;
  final bool completed;
  final int answered;
  final int correct;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.goldFor(context);
    final total = category.questions.length;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Opacity(
      opacity: unlocked ? 1 : 0.6,
      child: GoldCard(
        onTap: () {
          if (!unlocked) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Сначала завершите предыдущий уровень'),
              ));
            return;
          }
          Navigator.of(context)
              .push(fadeSlideRoute(QuizScreen(category: category)));
        },
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.5),
                color: gold.withAlpha(30),
              ),
              child: Icon(
                !unlocked
                    ? Icons.lock_outline
                    : completed
                        ? Icons.check_rounded
                        : category.icon,
                color: completed ? AppColors.success : gold,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Уровень ${category.index + 1}',
                      style: TextStyle(
                          fontSize: 12.5, color: gold, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(category.title, style: AppTheme.heading(context, size: 17)),
                  const SizedBox(height: 3),
                  Text(category.description,
                      style: TextStyle(fontSize: 13.5, color: onSurface.withAlpha(200))),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : answered / total,
                      minHeight: 6,
                      backgroundColor: gold.withAlpha(50),
                      valueColor: AlwaysStoppedAnimation(gold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('Верно решено: $correct из $total',
                      style: TextStyle(fontSize: 12.5, color: onSurface.withAlpha(190))),
                ],
              ),
            ),
            if (unlocked) Icon(Icons.chevron_right, color: gold),
          ],
        ),
      ),
    );
  }
}
