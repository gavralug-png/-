import 'package:flutter_test/flutter_test.dart';
import 'package:pravoslavny_put/data/categories.dart';
import 'package:pravoslavny_put/services/daily_service.dart';

void main() {
  test('5 категорий, в каждой не менее 20 вопросов, всего не менее 100', () {
    expect(kCategories.length, 5);
    for (final c in kCategories) {
      expect(c.questions.length, greaterThanOrEqualTo(20), reason: c.title);
    }
    expect(allQuestions.length, greaterThanOrEqualTo(100));
  });

  test('вопросы корректны: уникальные id, 3–4 варианта, верный индекс, объяснение', () {
    final ids = <String>{};
    for (final q in allQuestions) {
      expect(ids.add(q.id), isTrue, reason: 'повтор id ${q.id}');
      expect(q.options.length, inInclusiveRange(3, 4), reason: q.id);
      expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1), reason: q.id);
      expect(q.options.toSet().length, q.options.length, reason: 'одинаковые варианты ${q.id}');
      expect(q.explanation.trim(), isNotEmpty, reason: q.id);
    }
  });

  test('вопрос дня стабилен в течение суток и не повторяется весь цикл', () {
    final d = DateTime(2026, 11, 5, 9);
    expect(DailyService.questionFor(d).id,
        DailyService.questionFor(DateTime(2026, 11, 5, 23)).id);
    final seen = <String>{};
    for (var i = 0; i < allQuestions.length; i++) {
      seen.add(DailyService.questionFor(DateTime(2026, 1, 1).add(Duration(days: i))).id);
    }
    expect(seen.length, allQuestions.length);
  });
}
