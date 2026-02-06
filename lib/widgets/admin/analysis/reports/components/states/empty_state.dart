/// Componente reutilizable para estados vacíos
/// Ubicación: lib/widgets/admin/analysis/reports/components/states/empty_state.dart
library;

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double iconSize;
  final double padding;
  final Color? iconColor;
  final Color? titleColor;
  final Color? descriptionColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconSize = 64,
    this.padding = 48,
    this.iconColor,
    this.titleColor,
    this.descriptionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: titleColor ?? Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: descriptionColor ?? Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
