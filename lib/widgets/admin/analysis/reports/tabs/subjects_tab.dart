/// Tab de materias del reporte
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/subjects_tab.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';

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
    
    // Simular calificación basada en datos del subject
    final mockScore = 4.0 + ((subject.completed % 9) + 1) / 10;

    return Card(
      margin: const EdgeInsets.only(bottom: ReportConstants.paddingLarge),
      elevation: ReportConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSubjectInfo(subject, palette)),
                Text(
                  mockScore.toFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ReportConstants.getScoreColor(mockScore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReportConstants.paddingLarge),
            _buildStatsRow(subject),
            const SizedBox(height: ReportConstants.paddingLarge),
            _buildProgressBar(completionRate),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectInfo(SubjectData subject, RoleColorPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ReportConstants.paddingSmall),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: palette.chipBackground,
                borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
              ),
              child: Text(
                subject.code,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: palette.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ReportConstants.paddingSmall),
        Text(
          careerName,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(SubjectData subject) {
    return Row(
      children: [
        Expanded(
          child: _buildSubjectStat(
            ReportConstants.totalLabel,
            '${subject.students}',
            Colors.grey,
          ),
        ),
        Expanded(
          child: _buildSubjectStat(
            ReportConstants.evaluatedLabel,
            '${subject.completed}',
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildSubjectStat(
            ReportConstants.pendingLabel,
            '${subject.pending}',
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ReportConstants.containerBorderRadius),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double completionRate) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              ReportConstants.progressLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${completionRate.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: ReportConstants.containerBorderRadius),
        ClipRRect(
          borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
          child: LinearProgressIndicator(
            value: completionRate / 100,
            minHeight: ReportConstants.progressBarHeight,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      ],
    );
  }
}
