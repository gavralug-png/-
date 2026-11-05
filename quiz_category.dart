import 'package:flutter/material.dart';
import 'question.dart';

/// Категория (уровень) игры.
class QuizCategory {
  const QuizCategory({
    required this.index,
    required this.title,
    required this.description,
    required this.icon,
    required this.questions,
  });

  final int index;
  final String title;
  final String description;
  final IconData icon;
  final List<Question> questions;
}
