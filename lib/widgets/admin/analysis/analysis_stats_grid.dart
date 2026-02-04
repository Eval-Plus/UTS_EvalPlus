/// Grid de estadísticas globales (con gradientes)
/// Ubicación: lib/widgets/admin/analysis/analysis_stats_grid.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
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
                  AdminAnalysisConstants.teachersGradient,
                ),
              ),
              const SizedBox(width: AdminAnalysisConstants.paddingSmall),
              Expanded(
                child: _buildStatCard(
                  AdminAnalysisConstants.evaluationsIcon,
                  AdminAnalysisConstants.statsEvaluationsLabel,
                  '${stats.totalEvaluations}',
                  AdminAnalysisConstants.evaluationsGradient,
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
                  AdminAnalysisConstants.completionGradient,
                ),
              ),
              const SizedBox(width: AdminAnalysisConstants.paddingSmall),
              Expanded(
                child: _buildStatCard(
                  AdminAnalysisConstants.studentsIcon,
                  AdminAnalysisConstants.statsStudentsLabel,
                  '${stats.totalStudents}',
                  AdminAnalysisConstants.studentsGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de estadística con gradiente
  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminAnalysisConstants.statsCardPadding),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
