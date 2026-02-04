/// Widget del header de análisis
/// Ubicación: lib/widgets/admin/analysis_header.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/utils/admin/admin_analysis_constants.dart';

class AnalysisHeader extends StatelessWidget {
  const AnalysisHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminAnalysisConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF388E3C),
          ],
        ),
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius + 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AdminAnalysisConstants.headerContainerSize,
            height: AdminAnalysisConstants.headerContainerSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              AdminAnalysisConstants.headerIcon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AdminAnalysisConstants.paddingMedium),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AdminAnalysisConstants.headerTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AdminAnalysisConstants.headerSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
