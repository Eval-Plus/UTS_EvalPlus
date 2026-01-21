/// Tab de análisis de IA del reporte
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/ai_analysis_tab.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class AIAnalysisTab extends StatelessWidget {
  final AIInsights insights;

  const AIAnalysisTab({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      children: [
        _buildProfileCard(),
        const SizedBox(height: ReportConstants.paddingLarge),
        _buildStrengthsCard(),
        const SizedBox(height: ReportConstants.paddingLarge),
        _buildImprovementsCard(),
        const SizedBox(height: ReportConstants.paddingLarge),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ReportConstants.profileGradientStart,
            ReportConstants.profileGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(ReportConstants.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(ReportConstants.aiIcon, color: Colors.white, size: 24),
              SizedBox(width: ReportConstants.paddingMedium),
              Text(
                ReportConstants.profileCardTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: ReportConstants.paddingLarge),
          Text(
            insights.profile,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard() {
    return Card(
      elevation: ReportConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReportConstants.largeBorderRadius),
        side: const BorderSide(color: ReportConstants.strengthsColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  ReportConstants.strengthIcon,
                  color: ReportConstants.strengthsColor,
                  size: 18,
                ),
                SizedBox(width: ReportConstants.paddingMedium),
                Text(
                  ReportConstants.strengthsCardTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReportConstants.paddingLarge),
            ...insights.strengths.map((strength) => _buildListItem(
              strength,
              ReportConstants.checkIcon,
              ReportConstants.strengthsColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementsCard() {
    return Card(
      elevation: ReportConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReportConstants.largeBorderRadius),
        side: const BorderSide(color: ReportConstants.improvementsColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  ReportConstants.improvementIcon,
                  color: ReportConstants.improvementsColor,
                  size: 18,
                ),
                SizedBox(width: ReportConstants.paddingMedium),
                Text(
                  ReportConstants.improvementsCardTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReportConstants.paddingLarge),
            ...insights.improvements.map((improvement) => _buildListItem(
              improvement,
              ReportConstants.trendingUpIcon,
              ReportConstants.improvementsColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: ReportConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReportConstants.largeBorderRadius),
        side: const BorderSide(
          color: ReportConstants.recommendationsColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  ReportConstants.recommendationIcon,
                  color: ReportConstants.recommendationsColor,
                  size: 18,
                ),
                SizedBox(width: ReportConstants.paddingMedium),
                Text(
                  ReportConstants.recommendationsCardTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReportConstants.paddingLarge),
            ...insights.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              
              return _buildNumberedItem(
                recommendation,
                index + 1,
                ReportConstants.recommendationsColor,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ReportConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: ReportConstants.paddingMedium),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(String text, int number, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ReportConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: ReportConstants.paddingMedium),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
