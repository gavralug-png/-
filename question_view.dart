import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'ornaments.dart';

/// Карточка вопроса с вариантами ответа и объяснением после ответа.
/// [order] — порядок показа вариантов (индексы исходного списка),
/// [selected] — выбранный вариант (индекс исходного списка) или null.
class QuestionView extends StatelessWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.order,
    required this.selected,
    required this.onSelect,
    this.pointsEarned,
  });

  final Question question;
  final List<int> order;
  final int? selected;
  final ValueChanged<int> onSelect;
  final int? pointsEarned;

  static const _letters = ['А', 'Б', 'В', 'Г'];

  @override
  Widget build(BuildContext context) {
    final answered = selected != null;
    final isCorrect = selected == question.correctIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoldCard(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Text(
            question.text,
            textAlign: TextAlign.center,
            style: AppTheme.heading(context, size: 21, weight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < order.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              letter: _letters[i],
              text: question.options[order[i]],
              state: _stateFor(order[i], answered),
              onTap: answered ? null : () => onSelect(order[i]),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 350),
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
            ),
            child: _Explanation(
              question: question,
              isCorrect: isCorrect,
              pointsEarned: pointsEarned,
            ),
          ),
        ],
      ],
    );
  }

  _OptState _stateFor(int original, bool answered) {
    if (!answered) return _OptState.idle;
    if (original == question.correctIndex) return _OptState.correct;
    if (original == selected) return _OptState.wrong;
    return _OptState.dim;
  }
}

enum _OptState { idle, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = AppColors.goldFor(context);
    Color border = gold.withAlpha(150);
    Color fill = dark ? AppColors.deepBlue : AppColors.parchment;
    IconData? trailing;
    Color? trailingColor;
    switch (state) {
      case _OptState.correct:
        border = AppColors.success;
        fill = AppColors.success.withAlpha(dark ? 70 : 45);
        trailing = Icons.check_circle;
        trailingColor = AppColors.success;
        break;
      case _OptState.wrong:
        border = AppColors.error;
        fill = AppColors.error.withAlpha(dark ? 70 : 45);
        trailing = Icons.cancel;
        trailingColor = AppColors.error;
        break;
      default:
        break;
    }
    return Opacity(
      opacity: state == _OptState.dim ? 0.55 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 1.3),
                    ),
                    child: Text(
                      letter,
                      style: AppTheme.heading(context, size: 15, color: gold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text, style: const TextStyle(fontSize: 16.5, height: 1.3)),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailing, color: trailingColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({
    required this.question,
    required this.isCorrect,
    required this.pointsEarned,
  });

  final Question question;
  final bool isCorrect;
  final int? pointsEarned;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;
    return GoldCard(
      highlight: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.info, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect ? 'Верно!' : 'Не совсем верно',
                  style: AppTheme.heading(context, size: 19, color: color),
                ),
              ),
              if ((pointsEarned ?? 0) > 0)
                Text(
                  '+$pointsEarned',
                  style: AppTheme.heading(context,
                      size: 19, color: AppColors.goldFor(context)),
                ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 10),
            Text(
              'Правильный ответ: ${question.options[question.correctIndex]}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Text(question.explanation, style: const TextStyle(fontSize: 15.5, height: 1.4)),
        ],
      ),
    );
  }
}
