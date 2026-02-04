/// Header del modal de reporte
/// Ubicación: lib/widgets/admin/analysis/reports/components/report_header.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class ReportHeader extends StatelessWidget {
  final String teacherName;
  final VoidCallback onClose;

  const ReportHeader({
    super.key,
    required this.teacherName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Row(
          children: [
            Container(
              width: ReportConstants.headerIconSize,
              height: ReportConstants.headerIconSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  ReportConstants.headerIconContainerSize,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                ReportConstants.reportIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: ReportConstants.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ReportConstants.modalTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    teacherName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(
                ReportConstants.closeIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
