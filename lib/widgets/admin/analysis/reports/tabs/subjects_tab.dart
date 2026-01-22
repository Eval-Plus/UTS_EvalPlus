/// Tab de materias del reporte (Diseño Mejorado)
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/subjects_tab.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class SubjectsTab extends StatelessWidget {
  final List<SubjectData> subjects;
  final String careerName;

  const SubjectsTab({
    super.key,
    required this.subjects,
    required this.careerName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      children: subjects.map((subject) => _buildSubjectCard(subject)).toList(),
    );
  }

  Widget _buildSubjectCard(SubjectData subject) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);
    final completionRate = subject.students > 0
        ? (subject.completed / subject.students) * 100
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: ReportConstants.paddingLarge),
      elevation: ReportConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        side: BorderSide(
          color: _getProgressBorderColor(completionRate),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubjectHeader(subject, palette),
            const SizedBox(height: ReportConstants.paddingLarge),
            _buildStatsGrid(subject, completionRate),
            const SizedBox(height: ReportConstants.paddingLarge),
            _buildProgressSection(completionRate),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader(SubjectData subject, RoleColorPalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de materia
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: palette.avatarGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.book,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: ReportConstants.paddingLarge),
        // Información de la materia
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: ReportConstants.paddingSmall),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(
                        ReportConstants.chipBorderRadius,
                      ),
                    ),
                    child: Text(
                      subject.code,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      careerName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(SubjectData subject, double completionRate) {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(ReportConstants.containerBorderRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.groups,
              label: ReportConstants.totalLabel,
              value: '${subject.students}',
              color: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFFDEEBFF),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE5E7EB),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle,
              label: ReportConstants.evaluatedLabel,
              value: '${subject.completed}',
              color: const Color(0xFF10B981),
              backgroundColor: const Color(0xFFD1FAE5),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE5E7EB),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending,
              label: ReportConstants.pendingLabel,
              value: '${subject.pending}',
              color: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFFFEF3C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double completionRate) {
    final progressColor = _getProgressColor(completionRate);
    final progressStatus = _getProgressStatus(completionRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  progressStatus['icon'] as IconData,
                  size: 16,
                  color: progressColor,
                ),
                const SizedBox(width: 6),
                Text(
                  ReportConstants.progressLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: progressColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    progressStatus['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: ReportConstants.paddingMedium),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Barra de progreso base
                FractionallySizedBox(
                  widthFactor: completionRate / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getProgressGradient(completionRate),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Efecto de brillo
                FractionallySizedBox(
                  widthFactor: completionRate / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HELPERS DE COLOR Y ESTADO ====================

  Color _getProgressColor(double completionRate) {
    if (completionRate >= 80) return const Color(0xFF10B981); // Verde
    if (completionRate >= 40) return const Color(0xFFF59E0B); // Naranja
    return const Color(0xFFEF4444); // Rojo
  }

  Color _getProgressBorderColor(double completionRate) {
    if (completionRate >= 80) return const Color(0xFF10B981).withOpacity(0.3);
    if (completionRate >= 40) return const Color(0xFFF59E0B).withOpacity(0.3);
    return const Color(0xFFEF4444).withOpacity(0.3);
  }

  List<Color> _getProgressGradient(double completionRate) {
    if (completionRate >= 80) {
      return [const Color(0xFF10B981), const Color(0xFF059669)]; // Verde
    }
    if (completionRate >= 40) {
      return [const Color(0xFFF59E0B), const Color(0xFFD97706)]; // Naranja
    }
    return [const Color(0xFFEF4444), const Color(0xFFDC2626)]; // Rojo
  }

  Map<String, dynamic> _getProgressStatus(double completionRate) {
    if (completionRate >= 80) {
      return {
        'label': 'Excelente',
        'icon': Icons.trending_up,
      };
    }
    if (completionRate >= 40) {
      return {
        'label': 'En progreso',
        'icon': Icons.trending_flat,
      };
    }
    return {
      'label': 'Crítico',
      'icon': Icons.trending_down,
    };
  }
}
