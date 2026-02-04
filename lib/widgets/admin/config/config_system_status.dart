/// Widget del estado del sistema
/// Ubicación: lib/widgets/admin/config_system_status.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/admin/admin_dashboard_model.dart';
import 'package:eval_plus/utils/admin/admin_config_constants.dart';
import 'package:eval_plus/widgets/admin/config/config_progress_card.dart';

class ConfigSystemStatus extends StatelessWidget {
  final DashboardStats stats;
  final RoleColorPalette palette;

  const ConfigSystemStatus({
    super.key,
    required this.stats,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminConfigConstants.paddingXLarge - 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminConfigConstants.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AdminConfigConstants.paddingXLarge - 4),
          ConfigProgressCard(
            title: 'Estudiantes Inscritos',
            current: stats.syncedStudents,
            total: stats.totalStudents,
            percentage: stats.studentsSyncRate,
            icon: AdminConfigConstants.studentsIcon,
            color: AdminConfigConstants.emeraldColor,
          ),
          const SizedBox(height: AdminConfigConstants.paddingMedium),
          ConfigProgressCard(
            title: 'Docentes Inscritos',
            current: stats.enrolledTeachers,
            total: stats.totalTeachers,
            percentage: stats.teachersEnrollRate,
            icon: AdminConfigConstants.teachersIcon,
            color: AdminConfigConstants.limeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          AdminConfigConstants.layersIcon,
          color: palette.primary,
          size: AdminConfigConstants.actionIconSize,
        ),
        const SizedBox(width: 12),
        const Text(
          'Estado del Sistema',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
