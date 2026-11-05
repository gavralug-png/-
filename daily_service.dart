import 'dart:math';
import '../data/categories.dart';
import '../models/question.dart';

/// Выбор «Вопроса дня»: один и тот же вопрос в течение календарных суток,
/// без повторов, пока не пройден весь банк вопросов.
class DailyService {
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static int dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day)
      .difference(DateTime.utc(2024, 1, 1))
      .inDays;

  static Question questionFor(DateTime d) {
    final pool = allQuestions;
    final n = pool.length;
    var stride = 37;
    while (_gcd(stride, n) != 1) {
      stride++;
    }
    return pool[(dayNumber(d) * stride) % n];
  }

  /// Порядок показа вариантов ответа (стабилен в течение дня).
  static List<int> optionOrder(int count, int seed) =>
      List<int>.generate(count, (i) => i)..shuffle(Random(seed));

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
