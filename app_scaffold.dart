import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Фон приложения: градиент + тонкий византийский орнамент из ромбов.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [AppColors.navy, AppColors.deepBlue]
              : const [Color(0xFFFFFFFF), Color(0xFFEFE6CF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PatternPainter(
                  dark
                      ? AppColors.gold.withAlpha(20)
                      : AppColors.deepBlue.withAlpha(14),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final dot = Paint()..color = color;
    const step = 56.0;
    const r = 11.0;
    var row = 0;
    for (double y = 0; y < size.height + step; y += step) {
      final shift = row.isEven ? 0.0 : step / 2;
      for (double x = -step; x < size.width + step; x += step) {
        final cx = x + shift;
        final path = Path()
          ..moveTo(cx, y - r)
          ..lineTo(cx + r, y)
          ..lineTo(cx, y + r)
          ..lineTo(cx - r, y)
          ..close();
        canvas.drawPath(path, line);
        canvas.drawCircle(Offset(cx, y), 1.8, dot);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.color != color;
}

/// Единый каркас экрана: фон, прозрачный AppBar, безопасные отступы.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, this.title, required this.body, this.actions});

  final String? title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final overlay = (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(statusBarColor: Colors.transparent);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: title == null ? null : AppBar(title: Text(title!), actions: actions),
          body: SafeArea(child: body),
        ),
      ),
    );
  }
}

/// Ограничивает ширину содержимого (планшеты, складные устройства).
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
