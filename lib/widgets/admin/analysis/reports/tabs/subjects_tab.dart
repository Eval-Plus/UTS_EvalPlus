/// Tab de materias del reporte (Diseño Elegante y Refinado)
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
    final progressColor = ReportConstants.getProgressColor(completionRate);
    final progressStatus = ReportConstants.getProgressStatus(completionRate);

    return Container(
      margin: const EdgeInsets.only(bottom: ReportConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ReportConstants.largeBorderRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubjectHeader(subject, palette, progressColor, progressStatus),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCareerBadge(),
                const SizedBox(height: ReportConstants.paddingLarge),
                _buildStatsGrid(subject, completionRate),
                const SizedBox(height: ReportConstants.paddingLarge),
                _buildProgressSection(completionRate, progressColor, progressStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectHeader(
    SubjectData subject,
    RoleColorPalette palette,
    Color progressColor,
    Map<String, dynamic> progressStatus,
  ) {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ReportConstants.getProgressGradient(
            subject.students > 0 ? (subject.completed / subject.students) * 100 : 0.0,
          ).map((color) => color.withOpacity(0.12)).toList(),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono de materia
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ReportConstants.getProgressGradient(
                  subject.students > 0 ? (subject.completed / subject.students) * 100 : 0.0,
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: progressColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.book,
              color: Colors.white,
              size: 28,
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
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    subject.code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.school,
            size: 16,
            color: Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            careerName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
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
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
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
            height: 50,
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
            height: 50,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
    double completionRate,
    Color progressColor,
    Map<String, dynamic> progressStatus,
  ) {
    // Calcular el valor visual de la barra de progreso
    final displayProgress = completionRate > 0 
        ? completionRate / 100 
        : ReportConstants.progressMinimumDisplay / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: 16,
                    color: progressColor,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  ReportConstants.progressLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: progressColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${completionRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ReportConstants.paddingLarge),
        // Barra de progreso completa
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              children: [
                // Barra de progreso completa (fondo gris ya está en el Container padre)
                
                // Barra de progreso llenada
                FractionallySizedBox(
                  widthFactor: displayProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ReportConstants.getProgressGradient(completionRate),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Efecto de brillo
                FractionallySizedBox(
                  widthFactor: displayProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
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
}
