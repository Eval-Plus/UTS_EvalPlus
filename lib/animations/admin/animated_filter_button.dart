/// Botón animado para toggle de filtros
/// Ubicación: lib/animations/admin/animated_filter_button.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';

class AnimatedFilterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final RoleColorPalette palette;
  final Duration duration;
  final Curve curve;

  const AnimatedFilterButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.palette,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: isActive ? palette.primary : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: palette.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: isActive ? 0.5 : 0.0,
                  duration: duration,
                  curve: curve,
                  child: Icon(
                    Icons.filter_list,
                    size: 18,
                    color: isActive ? Colors.white : Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: curve,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  child: const Text('Filtros'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
