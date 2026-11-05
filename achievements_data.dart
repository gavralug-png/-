import 'package:flutter/material.dart';
import '../models/achievement.dart';

const List<Achievement> kAchievements = [
  Achievement(
    id: 'first_step',
    title: 'Первый шаг',
    description: 'Завершить первый вопрос',
    icon: Icons.directions_walk,
  ),
  Achievement(
    id: 'expert',
    title: 'Знаток веры',
    description: 'Ответить правильно на 20 вопросов',
    icon: Icons.school,
  ),
  Achievement(
    id: 'scripture',
    title: 'Ученик Писания',
    description: 'Завершить категорию «Священное Писание»',
    icon: Icons.menu_book,
  ),
  Achievement(
    id: 'saints',
    title: 'Друг святых',
    description: 'Завершить категорию «Святые»',
    icon: Icons.favorite,
  ),
  Achievement(
    id: 'path',
    title: 'Путь познания',
    description: 'Завершить все пять категорий',
    icon: Icons.emoji_events,
  ),
];

Achievement achievementById(String id) =>
    kAchievements.firstWhere((a) => a.id == id);
