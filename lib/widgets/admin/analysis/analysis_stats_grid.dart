/// Grid de estadísticas globales
/// Ubicación: lib/widgets/admin/analysis_stats_grid.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/utils/admin/admin_analysis_constants.dart';

class AnalysisStatsGrid extends StatelessWidget {
  final AnalysisStats stats;

  const AnalysisStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AdminAnalysisConstants.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AdminAnalysisConstants.teachersIcon,
                  AdminAnalysisConstants.statsTeachersLabel,
                  '${stats.totalTeachers}',
                  AdminAnalysisConstants.teachersColor,
                ),
              ),
              const SizedBox(width: AdminAnalysisConstants.paddingSmall),
              Expanded(
                child: _buildStatCard(
                  AdminAnalysisConstants.evaluationsIcon,
                  AdminAnalysisConstants.statsEvaluationsLabel,
                  '${stats.totalEvaluations}',
                  AdminAnalysisConstants.evaluationsColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminAnalysisConstants.statsCardPadding),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AdminAnalysisConstants.completionIcon,
                  AdminAnalysisConstants.statsCompletionLabel,
                  '${stats.avgCompletion}%',
                  AdminAnalysisConstants.completionColor,
                ),
              ),
              const SizedBox(width: AdminAnalysisConstants.paddingSmall),
              Expanded(
                child: _buildStatCard(
                  AdminAnalysisConstants.studentsIcon,
                  AdminAnalysisConstants.statsStudentsLabel,
                  '${stats.totalStudents}',
                  AdminAnalysisConstants.studentsColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AdminAnalysisConstants.statsCardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
