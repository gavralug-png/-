import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/categories.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_route.dart';
import '../widgets/menu_button.dart';
import '../widgets/ornaments.dart';
import 'achievements_screen.dart';
import 'daily_screen.dart';
import 'level_select_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(fadeSlideRoute(page));

  void _start(BuildContext context, GameProvider game) {
    if (game.allCompleted) {
      _push(context, const LevelSelectScreen());
    } else {
      _push(context, QuizScreen(category: kCategories[game.currentLevelIndex]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final gold = AppColors.goldFor(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: ContentWidth(
            maxWidth: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 112)),
                const SizedBox(height: 18),
                Text('Православный путь',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(context, size: 31)),
                const SizedBox(height: 6),
                Text('Познавай веру. Изучай Священное Писание.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: onSurface.withAlpha(200))),
                const SizedBox(height: 16),
                const OrnamentDivider(),
                const SizedBox(height: 16),
                GoldCard(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    children: [
                      Text('Благословенного дня, ${game.playerName}!',
                          textAlign: TextAlign.center,
                          style: AppTheme.heading(context, size: 18)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              icon: Icons.star_rounded,
                              label: 'Очки',
                              value: '${game.totalScore}',
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              icon: Icons.flag_rounded,
                              label: 'Уровень',
                              value: game.allCompleted
                                  ? 'Все пройдены'
                                  : '${game.currentLevelIndex + 1} из ${kCategories.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: game.progress,
                          minHeight: 9,
                          backgroundColor: gold.withAlpha(50),
                          valueColor: AlwaysStoppedAnimation(gold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Прогресс: ${(game.progress * 100).round()}% · '
                        'вопросов пройдено ${game.answeredIds.length} из ${allQuestions.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: onSurface.withAlpha(200)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                MenuButton(
                  label: 'Начать игру',
                  icon: Icons.play_arrow_rounded,
                  primary: true,
                  onPressed: () => _start(context, game),
                ),
                const SizedBox(height: 10),
                MenuButton(
                  label: 'Выбрать уровень',
                  icon: Icons.layers_rounded,
                  onPressed: () => _push(context, const LevelSelectScreen()),
                ),
                const SizedBox(height: 10),
                MenuButton(
                  label: 'Ежедневный вопрос',
                  icon: Icons.wb_sunny_outlined,
                  badge: !game.dailyAnsweredToday,
                  onPressed: () => _push(context, const DailyScreen()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MenuButton(
                        label: 'Достижения',
                        icon: Icons.emoji_events_outlined,
                        onPressed: () => _push(context, const AchievementsScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MenuButton(
                        label: 'Настройки',
                        icon: Icons.settings_outlined,
                        onPressed: () => _push(context, const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.goldFor(context);
    return Column(
      children: [
        Icon(icon, color: gold, size: 26),
        const SizedBox(height: 2),
        Text(value,
            textAlign: TextAlign.center,
            style: AppTheme.heading(context, size: 18)),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(190))),
      ],
    );
  }
}
