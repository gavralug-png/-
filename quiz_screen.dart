import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/quiz_category.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_route.dart';
import '../widgets/question_view.dart';
import 'result_screen.dart';

/// Прохождение одного уровня (категории).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.category});

  final QuizCategory category;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _scroll = ScrollController();
  late final List<List<int>> _orders;

  int _index = 0;
  int _correct = 0;
  int _wrong = 0;
  int _earned = 0;
  int _lastPoints = 0;
  int? _selected; // индекс выбранного варианта в исходном списке

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _orders = [
      for (final q in widget.category.questions)
        (List<int>.generate(q.options.length, (i) => i)..shuffle(rnd)),
    ];
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Question get _question => widget.category.questions[_index];

  void _select(int original) {
    if (_selected != null) return;
    final ok = original == _question.correctIndex;
    final points = context.read<GameProvider>().answerLevelQuestion(_question, ok);
    context.read<AudioService>().playResult(ok);
    setState(() {
      _selected = original;
      _lastPoints = points;
      _earned += points;
      if (ok) {
        _correct++;
      } else {
        _wrong++;
      }
    });
  }

  void _next() {
    if (_index == widget.category.questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _lastPoints = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _finish() {
    final victory =
        context.read<GameProvider>().completeCategory(widget.category.index);
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(
        ResultScreen(
          category: widget.category,
          correct: _correct,
          wrong: _wrong,
          earned: _earned,
          victory: victory,
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из уровня?'),
        content: const Text(
            'Ответы, которые вы уже дали, сохранены. Уровень будет засчитан, когда вы ответите на все вопросы.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Остаться')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Выйти')),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final total = cat.questions.length;
    final answered = _selected != null;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final gold = AppColors.goldFor(context);
    final isLast = _index == total - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await _confirmExit();
        if (leave && mounted) Navigator.of(context).pop();
      },
      child: AppScaffold(
        title: cat.title,
        body: ContentWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Вопрос ${_index + 1} из $total',
                            style: TextStyle(fontSize: 14, color: onSurface.withAlpha(210))),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 18, color: gold),
                            const SizedBox(width: 3),
                            Text('$_earned',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_index + (answered ? 1 : 0)) / total,
                        minHeight: 7,
                        backgroundColor: gold.withAlpha(50),
                        valueColor: AlwaysStoppedAnimation(gold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(_index),
                      child: QuestionView(
                        question: _question,
                        order: _orders[_index],
                        selected: _selected,
                        onSelect: _select,
                        pointsEarned: _lastPoints,
                      ),
                    ),
                  ),
                ),
              ),
              if (answered)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(isLast ? 'Завершить уровень' : 'Следующий вопрос'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
