import 'package:flutter/material.dart';

/// Восьмиконечный православный крест (рисуется кодом, без картинок).
class OrthodoxCross extends StatelessWidget {
  const OrthodoxCross({super.key, this.size = 80, this.color, this.strokeWidth});

  final double size; // высота креста
  final Color? color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.secondary;
    return CustomPaint(
      size: Size(size * 0.62, size),
      painter: CrossPainter(c, strokeWidth ?? size * 0.07),
    );
  }
}

class CrossPainter extends CustomPainter {
  CrossPainter(this.color, this.stroke);

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = s.width;
    final h = s.height;
    final cx = w / 2;
    // Вертикальная перекладина
    canvas.drawLine(Offset(cx, h * 0.03), Offset(cx, h * 0.97), p);
    // Верхняя короткая перекладина (титло)
    canvas.drawLine(Offset(cx - w * 0.22, h * 0.15), Offset(cx + w * 0.22, h * 0.15), p);
    // Основная перекладина
    canvas.drawLine(Offset(cx - w * 0.48, h * 0.31), Offset(cx + w * 0.48, h * 0.31), p);
    // Нижняя наклонная перекладина (подножие)
    canvas.drawLine(Offset(cx - w * 0.28, h * 0.67), Offset(cx + w * 0.28, h * 0.77), p);
  }

  @override
  bool shouldRepaint(CrossPainter old) =>
      old.color != color || old.stroke != stroke;
}
