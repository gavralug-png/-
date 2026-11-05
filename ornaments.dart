import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'orthodox_cross.dart';

/// Золотой разделитель с крестом по центру.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, this.crossSize = 20});

  final double crossSize;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.goldFor(context);
    Widget line(bool reverse) => Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: reverse
                    ? [gold, gold.withAlpha(0)]
                    : [gold.withAlpha(0), gold],
              ),
            ),
          ),
        );
    return Row(
      children: [
        line(false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: OrthodoxCross(size: crossSize, color: gold),
        ),
        line(true),
      ],
    );
  }
}

/// Карточка с золотой рамкой.
class GoldCard extends StatelessWidget {
  const GoldCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = AppColors.goldFor(context);
    final bg = highlight
        ? (dark ? const Color(0xFF16406F) : const Color(0xFFFBF3DC))
        : (dark ? AppColors.deepBlue : AppColors.parchment);
    return Padding(
      padding: margin,
      child: Material(
        color: bg,
        elevation: dark ? 0 : 1.5,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: gold.withAlpha(highlight ? 255 : 150),
            width: highlight ? 1.6 : 1.1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
