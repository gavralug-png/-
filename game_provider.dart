import 'package:flutter/foundation.dart';
import '../data/achievements_data.dart';
import '../data/categories.dart';
import '../models/achievement.dart';
import '../models/daily_record.dart';
import '../models/question.dart';
import '../models/quiz_category.dart';
import '../services/daily_service.dart';
import '../services/storage_service.dart';

/// Игровое состояние: очки, уровни, достижения, вопрос дня.
/// Любое изменение сразу сохраняется в SharedPreferences.
class GameProvider extends ChangeNotifier {
  GameProvider(this._storage) {
    _load();
  }

  static const int pointsPerAnswer = 10;
  static const int pointsDaily = 20;

  final StorageService _storage;

  String playerName = '';
  int totalScore = 0;
  int totalCorrect = 0;
  int totalWrong = 0;
  int unlockedLevels = 1;
  final Set<int> completedCategories = {};
  final Set<String> answeredIds = {}; // вопросы уровней, на которые отвечали
  final Set<String> correctIds = {}; // вопросы уровней, решённые верно (хотя бы раз)
  final Set<String> achievementIds = {};
  final List<DailyRecord> dailyHistory = [];
  final List<Achievement> _pending = [];

  // ---------- Производные значения ----------

  bool get hasName => playerName.trim().isNotEmpty;
  bool get allCompleted => completedCategories.length == kCategories.length;

  /// Индекс первого непройденного уровня.
  int get currentLevelIndex {
    for (var i = 0; i < kCategories.length; i++) {
      if (!completedCategories.contains(i)) return i;
    }
    return kCategories.length - 1;
  }

  bool isUnlocked(int index) => index < unlockedLevels;

  double get progress =>
      allQuestions.isEmpty ? 0 : answeredIds.length / allQuestions.length;

  int answeredInCategory(QuizCategory c) =>
      c.questions.where((q) => answeredIds.contains(q.id)).length;

  int correctInCategory(QuizCategory c) =>
      c.questions.where((q) => correctIds.contains(q.id)).length;

  // ---------- Имя ----------

  Future<void> setName(String name) async {
    playerName = name.trim();
    _save();
    notifyListeners();
  }

  // ---------- Уровни ----------

  /// Фиксирует ответ на вопрос уровня. Очки начисляются один раз —
  /// при первом верном ответе на данный вопрос. Возвращает начисленные очки.
  int answerLevelQuestion(Question q, bool correct) {
    var earned = 0;
    answeredIds.add(q.id);
    if (correct) {
      totalCorrect++;
      if (correctIds.add(q.id)) {
        earned = pointsPerAnswer;
        totalScore += earned;
      }
    } else {
      totalWrong++;
    }
    _checkAchievements();
    _save();
    notifyListeners();
    return earned;
  }

  /// Отмечает категорию завершённой и открывает следующую.
  /// Возвращает true, если этим завершены все пять категорий (впервые).
  bool completeCategory(int index) {
    final wasAll = allCompleted;
    completedCategories.add(index);
    if (index + 2 > unlockedLevels && index + 1 < kCategories.length) {
      unlockedLevels = index + 2;
    }
    _checkAchievements();
    _save();
    notifyListeners();
    return !wasAll && allCompleted;
  }

  // ---------- Вопрос дня ----------

  String get todayKey => DailyService.dateKey(DateTime.now());

  Question get todayQuestion => DailyService.questionFor(DateTime.now());

  DailyRecord? get todayRecord {
    final key = todayKey;
    for (final r in dailyHistory) {
      if (r.date == key) return r;
    }
    return null;
  }

  bool get dailyAnsweredToday => todayRecord != null;

  /// [selected] — индекс варианта в исходном списке. Повторный ответ в тот же
  /// день не принимается и награды не даёт.
  DailyRecord? answerDaily(int selected) {
    if (todayRecord != null) return null;
    final q = todayQuestion;
    final ok = selected == q.correctIndex;
    final record = DailyRecord(
      date: todayKey,
      questionId: q.id,
      selectedIndex: selected,
      correct: ok,
      points: ok ? pointsDaily : 0,
    );
    dailyHistory.add(record);
    totalScore += record.points;
    if (ok) {
      totalCorrect++;
    } else {
      totalWrong++;
    }
    _checkAchievements();
    _save();
    notifyListeners();
    return record;
  }

  // ---------- Достижения ----------

  void _checkAchievements() {
    void grant(String id, bool condition) {
      if (condition && achievementIds.add(id)) {
        _pending.add(achievementById(id));
      }
    }

    grant('first_step', answeredIds.isNotEmpty || dailyHistory.isNotEmpty);
    grant('expert', correctIds.length >= 20);
    grant('scripture', completedCategories.contains(1));
    grant('saints', completedCategories.contains(2));
    grant('path', allCompleted);
  }

  /// Новые достижения, о которых ещё не сообщили игроку.
  List<Achievement> takePendingAchievements() {
    final list = List<Achievement>.from(_pending);
    _pending.clear();
    return list;
  }

  // ---------- Сброс ----------

  Future<void> resetProgress() async {
    totalScore = 0;
    totalCorrect = 0;
    totalWrong = 0;
    unlockedLevels = 1;
    completedCategories.clear();
    answeredIds.clear();
    correctIds.clear();
    achievementIds.clear();
    dailyHistory.clear();
    _pending.clear();
    _save();
    notifyListeners();
  }

  // ---------- Хранение ----------

  void _load() {
    final m = _storage.loadProgress();
    if (m == null) return;
    playerName = (m['name'] as String?) ?? '';
    totalScore = (m['score'] as int?) ?? 0;
    totalCorrect = (m['correct'] as int?) ?? 0;
    totalWrong = (m['wrong'] as int?) ?? 0;
    unlockedLevels =
        ((m['unlocked'] as int?) ?? 1).clamp(1, kCategories.length);
    completedCategories
        .addAll(((m['completed'] as List?) ?? const []).cast<int>());
    answeredIds.addAll(((m['answered'] as List?) ?? const []).cast<String>());
    correctIds
        .addAll(((m['correctIds'] as List?) ?? const []).cast<String>());
    achievementIds
        .addAll(((m['achievements'] as List?) ?? const []).cast<String>());
    for (final e in (m['daily'] as List?) ?? const []) {
      dailyHistory.add(DailyRecord.fromJson(Map<String, dynamic>.from(e as Map)));
    }
  }

  void _save() {
    _storage.saveProgress({
      'name': playerName,
      'score': totalScore,
      'correct': totalCorrect,
      'wrong': totalWrong,
      'unlocked': unlockedLevels,
      'completed': completedCategories.toList(),
      'answered': answeredIds.toList(),
      'correctIds': correctIds.toList(),
      'achievements': achievementIds.toList(),
      'daily': dailyHistory.map((r) => r.toJson()).toList(),
    });
  }
}
