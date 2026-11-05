import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/categories.dart';
import '../models/quiz_category.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_dialog.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_route.dart';
import '../widgets/orthodox_cross.dart';
import '../widgets/ornaments.dart';
import 'quiz_screen.dart';
import 'victory_screen.dart';

/// Статистика по итогам уровня.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.category,
    required this.correct,
    required this.wrong,
    required this.earned,
    required this.victory,
  });

  final QuizCategory category;
  final int correct;
  final int wrong;
  final int earned;
  final bool victory;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showNewAchievements(context);
    });
  }

  String _message(double pct) {
    if (pct >= 0.9) return 'Прекрасный результат! Слава Богу!';
    if (pct >= 0.6) return 'Хороший результат. Продолжайте изучать веру.';
    return 'Путь познания — это труд. Повторите уровень и закрепите знания.';
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final total = widget.category.questions.length;
    final pct = total == 0 ? 0.0 : widget.correct / total;
    final gold = AppColors.goldFor(context);
    final next = widget.category.index + 1;
    final hasNext = next < kCategories.length && game.isUnlocked(next);

    return AppScaffold(
      title: 'Итоги уровня',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: OrthodoxCross(size: 56, color: gold)),
              const SizedBox(height: 12),
              Text('Уровень пройден',
                  textAlign: TextAlign.center,
                  style: AppTheme.heading(context, size: 26)),
              const SizedBox(height: 4),
              Text(widget.category.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: gold, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              const OrnamentDivider(),
              const SizedBox(height: 18),
              Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pct),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => CircularProgressIndicator(
                            value: v,
                            strokeWidth: 9,
                            backgroundColor: gold.withAlpha(50),
                            valueColor: AlwaysStoppedAnimation(gold),
                          ),
                        ),
                      ),
                      Text('${(pct * 100).round()}%',
                          style: AppTheme.heading(context, size: 30)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(_message(pct),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              GoldCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _Block(
                          label: 'Правильно',
                          value: '${widget.correct}',
                          color: AppColors.success),
                    ),
                    Expanded(
                      child: _Block(
                          label: 'Неправильно',
                          value: '${widget.wrong}',
                          color: AppColors.error),
                    ),
                    Expanded(
                      child: _Block(
                          label: 'Очки', value: '+${widget.earned}', color: gold),
                    ),
                  ],
                ),
              ),
              if (widget.earned < widget.correct * GameProvider.pointsPerAnswer)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Очки за вопрос начисляются один раз — при первом верном ответе на него.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(190)),
                  ),
                ),
              const SizedBox(height: 22),
              if (widget.victory)
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(fadeSlideRoute(const VictoryScreen())),
                  child: const Text('Завершить путь'),
                )
              else if (hasNext)
                FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    fadeSlideRoute(QuizScreen(category: kCategories[next])),
                  ),
                  child: const Text('Следующий уровень'),
                ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  fadeSlideRoute(QuizScreen(category: widget.category)),
                ),
                child: const Text('Повторить уровень'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('В главное меню'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.heading(context, size: 26, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(200))),
      ],
    );
  }
}
