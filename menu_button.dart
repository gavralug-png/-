import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Кнопка главного меню (основная — залитая, остальные — с золотой рамкой).
class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.badge = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool badge;

  Widget _label() =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1));

  @override
  Widget build(BuildContext context) {
    final child = primary
        ? FilledButton.icon(
            onPressed: onPressed, icon: Icon(icon), label: _label())
        : OutlinedButton.icon(
            onPressed: onPressed, icon: Icon(icon), label: _label());
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(width: double.infinity, child: child),
          if (badge)
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.navy, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
