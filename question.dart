/// Вопрос викторины: текст, варианты, индекс верного ответа и объяснение.
class Question {
  const Question(
    this.id,
    this.text,
    this.options,
    this.correctIndex,
    this.explanation,
  );

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}
