/// Widget de tarjeta de progreso para sincronizaciones
/// Ubicación: lib/widgets/admin/config_progress_card.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/utils/admin/admin_config_constants.dart';

class ConfigProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final double percentage;
  final IconData icon;
  final Color color;

  const ConfigProgressCard({
    super.key,
    required this.title,
    required this.current,
    required this.total,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      color.withOpacity(0.1),
      Colors.white,
    );
    final borderColor = Color.alphaBlend(
      color.withOpacity(0.3),
      Colors.white,
    );
    final textColor = Color.fromRGBO(
      (color.red * 0.7).toInt(),
      (color.green * 0.7).toInt(),
      (color.blue * 0.7).toInt(),
      1.0,
    );

    return Container(
      padding: const EdgeInsets.all(AdminConfigConstants.paddingMedium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AdminConfigConstants.borderRadiusMedium),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildHeader(textColor),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: AdminConfigConstants.paddingSmall),
          _buildFooter(textColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: textColor, size: AdminConfigConstants.progressIconSize),
            const SizedBox(width: AdminConfigConstants.paddingSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AdminConfigConstants.borderRadiusSmall),
      child: LinearProgressIndicator(
        value: percentage / 100,
        minHeight: 12,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildFooter(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$current de $total',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '${total - current} pendientes',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
