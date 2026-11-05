import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/categories.dart';
import '../models/daily_record.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/daily_service.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_dialog.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ornaments.dart';
import '../widgets/question_view.dart';

/// «Вопрос дня»: один новый вопрос в сутки, 20 очков за верный ответ.
class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  static const _months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];

  static String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  void _answer(BuildContext context, int original) {
    final game = context.read<GameProvider>();
    final ok = original == game.todayQuestion.correctIndex;
    final record = game.answerDaily(original);
    if (record == null) return;
    context.read<AudioService>().playResult(ok);
    showNewAchievements(context);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final now = DateTime.now();
    final q = game.todayQuestion;
    final record = game.todayRecord;
    final order = DailyService.optionOrder(q.options.length, DailyService.dayNumber(now));
    final gold = AppColors.goldFor(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final history = game.dailyHistory.where((r) => r.date != game.todayKey).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return AppScaffold(
      title: 'Вопрос дня',
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Text(formatDate(now),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: gold, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              record == null
                  ? 'Верный ответ приносит ${GameProvider.pointsDaily} очков'
                  : 'Ответ на сегодняшний вопрос уже дан',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: onSurface.withAlpha(200)),
            ),
            const SizedBox(height: 14),
            QuestionView(
              question: q,
              order: order,
              selected: record?.selectedIndex,
              onSelect: (i) => _answer(context, i),
              pointsEarned: record?.points,
            ),
            if (record != null) ...[
              const SizedBox(height: 14),
              Text('Новый вопрос появится завтра.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5, color: onSurface.withAlpha(210))),
            ],
            const SizedBox(height: 26),
            const OrnamentDivider(),
            const SizedBox(height: 14),
            Text('История вопросов',
                textAlign: TextAlign.center,
                style: AppTheme.heading(context, size: 20)),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Text('Здесь появятся вопросы прошлых дней.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onSurface.withAlpha(190)))
            else
              for (final r in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryTile(record: r),
                ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final DailyRecord record;

  @override
  Widget build(BuildContext context) {
    final q = questionById(record.questionId);
    if (q == null) return const SizedBox.shrink();
    final date = DateTime.tryParse(record.date);
    final color = record.correct ? AppColors.success : AppColors.error;
    return GoldCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Icon(record.correct ? Icons.check_circle : Icons.cancel, color: color),
          title: Text(q.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text(
            date == null ? record.date : DailyScreen.formatDate(date),
            style: const TextStyle(fontSize: 13),
          ),
          children: [
            Text('Ваш ответ: ${q.options[record.selectedIndex]}',
                style: const TextStyle(fontSize: 14.5)),
            if (!record.correct) ...[
              const SizedBox(height: 4),
              Text('Правильный ответ: ${q.options[q.correctIndex]}',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 8),
            Text(q.explanation, style: const TextStyle(fontSize: 14.5, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
