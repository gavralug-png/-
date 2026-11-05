import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/orthodox_cross.dart';
import '../widgets/ornaments.dart';

/// Экран победы после завершения всех пяти категорий.
class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final gold = AppColors.goldFor(context);
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ContentWidth(
            maxWidth: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.6, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                            colors: [AppColors.deepBlue, AppColors.navy]),
                        border: Border.all(color: AppColors.gold, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.gold.withAlpha(110),
                              blurRadius: 40,
                              spreadRadius: 4),
                        ],
                      ),
                      child: const Center(
                        child: OrthodoxCross(size: 90, color: AppColors.gold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text('Слава Богу!',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(context, size: 32)),
                const SizedBox(height: 8),
                Text('Вы прошли все пять категорий',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: gold, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                const OrnamentDivider(),
                const SizedBox(height: 18),
                GoldCard(
                  child: Column(
                    children: [
                      Text('${game.playerName}, ваш итог',
                          style: AppTheme.heading(context, size: 18)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Item(label: 'Очков', value: '${game.totalScore}'),
                          ),
                          Expanded(
                            child: _Item(label: 'Верных ответов', value: '${game.totalCorrect}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Продолжайте читать Священное Писание, молиться и участвовать в церковной жизни — путь познания веры не заканчивается.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.5, height: 1.4),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('В главное меню'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.heading(context, size: 28)),
        Text(label,
            style: TextStyle(
                fontSize: 13.5,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(200))),
      ],
    );
  }
}
