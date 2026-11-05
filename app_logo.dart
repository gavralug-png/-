import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'orthodox_cross.dart';

/// Логотип: золотой крест в круге с мягким свечением.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: v, child: child),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [AppColors.deepBlue, AppColors.navy],
          ),
          border: Border.all(color: AppColors.gold, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withAlpha(70),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: OrthodoxCross(size: size * 0.58, color: AppColors.gold),
        ),
      ),
    );
  }
}
