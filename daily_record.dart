/// Запись об ответе на «Вопрос дня».
class DailyRecord {
  const DailyRecord({
    required this.date,
    required this.questionId,
    required this.selectedIndex,
    required this.correct,
    required this.points,
  });

  final String date; // yyyy-MM-dd
  final String questionId;
  final int selectedIndex; // индекс в исходном списке вариантов
  final bool correct;
  final int points;

  Map<String, dynamic> toJson() => {
        'date': date,
        'qid': questionId,
        'sel': selectedIndex,
        'ok': correct,
        'pts': points,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> j) => DailyRecord(
        date: j['date'] as String,
        questionId: j['qid'] as String,
        selectedIndex: j['sel'] as int,
        correct: j['ok'] as bool,
        points: (j['pts'] as int?) ?? 0,
      );
}
