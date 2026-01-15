/// Widget del header de configuración
/// Ubicación: lib/widgets/admin/config_header.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/admin_dashboard_model.dart';
import 'package:eval_plus/utils/admin_config_constants.dart';

class ConfigHeader extends StatelessWidget {
  final String periodo;
  final DashboardStats stats;

  const ConfigHeader({
    super.key,
    required this.periodo,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminConfigConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF388E3C),
          ],
        ),
        borderRadius: BorderRadius.circular(AdminConfigConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: AdminConfigConstants.paddingLarge),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          width: AdminConfigConstants.headerIconContainerSize,
          height: AdminConfigConstants.headerIconContainerSize,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AdminConfigConstants.borderRadiusMedium),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            AdminConfigConstants.settingsIcon,
            color: Colors.white,
            size: AdminConfigConstants.actionIconSize + 8,
          ),
        ),
        const SizedBox(width: AdminConfigConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Periodo: $periodo',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _HeaderStatCard(
                icon: AdminConfigConstants.studentsIcon,
                label: 'Estudiantes',
                value: '${stats.totalStudents}',
                subtitle: '${stats.syncedStudents} sincronizados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HeaderStatCard(
                icon: AdminConfigConstants.teachersIcon,
                label: 'Docentes',
                value: '${stats.totalTeachers}',
                subtitle: '${stats.enrolledTeachers} inscritos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HeaderStatCard(
                icon: AdminConfigConstants.evaluationsIcon,
                label: 'Evaluaciones',
                value: '${stats.totalEvaluations}',
                subtitle: '${stats.activeEvaluations} activas',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HeaderStatCard(
                icon: Icons.trending_up_rounded,
                label: 'Completadas',
                value: '${stats.completedEvaluations}',
                subtitle: '${stats.evaluationsCompletionRate.toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _HeaderStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AdminConfigConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
