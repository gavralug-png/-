import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/quiz_category.dart';
import 'questions_bible.dart';
import 'questions_church.dart';
import 'questions_faith.dart';
import 'questions_feasts.dart';
import 'questions_saints.dart';

/// Пять категорий игры в порядке прохождения.
final List<QuizCategory> kCategories = [
  QuizCategory(
    index: 0,
    title: 'Основы православной веры',
    description: 'Символ веры, таинства, догматы',
    icon: Icons.church,
    questions: faithQuestions,
  ),
  QuizCategory(
    index: 1,
    title: 'Священное Писание',
    description: 'Ветхий и Новый Завет',
    icon: Icons.menu_book,
    questions: bibleQuestions,
  ),
  QuizCategory(
    index: 2,
    title: 'Святые',
    description: 'Жития и подвиги угодников Божиих',
    icon: Icons.auto_awesome,
    questions: saintsQuestions,
  ),
  QuizCategory(
    index: 3,
    title: 'Церковная жизнь',
    description: 'Богослужение, храм, посты',
    icon: Icons.account_balance,
    questions: churchQuestions,
  ),
  QuizCategory(
    index: 4,
    title: 'Православные праздники',
    description: 'Двунадесятые и великие праздники',
    icon: Icons.celebration,
    questions: feastsQuestions,
  ),
];

/// Все вопросы игры одним списком (используется для «Вопроса дня»).
final List<Question> allQuestions = [
  for (final c in kCategories) ...c.questions,
];

final Map<String, Question> _questionsById = {
  for (final q in allQuestions) q.id: q,
};

Question? questionById(String id) => _questionsById[id];
