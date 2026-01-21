/// Tab de respuestas del reporte
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/responses_tab.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/question_card.dart';

class ResponsesTab extends StatefulWidget {
  final List<QuestionReport> questions;
  final double averageScore;
  final int totalResponses;

  const ResponsesTab({
    super.key,
    required this.questions,
    required this.averageScore,
    required this.totalResponses,
  });

  @override
  State<ResponsesTab> createState() => _ResponsesTabState();
}

class _ResponsesTabState extends State<ResponsesTab> {
  int? _expandedQuestionId;

  void _toggleQuestion(int questionId) {
    setState(() {
      _expandedQuestionId = _expandedQuestionId == questionId ? null : questionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: ReportConstants.paddingLarge),
        ...widget.questions.map((question) {
          return QuestionCardReport(
            question: question,
            isExpanded: _expandedQuestionId == question.id,
            onTap: () => _toggleQuestion(question.id),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildAverageCard()),
        const SizedBox(width: ReportConstants.paddingMedium),
        Expanded(child: _buildResponsesCard()),
      ],
    );
  }

  Widget _buildAverageCard() {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ReportConstants.averageGradientStart,
            ReportConstants.averageGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
      ),
      child: Column(
        children: [
          const Text(
            ReportConstants.averageLabel,
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          Text(
            widget.averageScore.toFixed(1),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            '/ 5.0',
            style: TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesCard() {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ReportConstants.responsesGradientStart,
            ReportConstants.responsesGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
      ),
      child: Column(
        children: [
          const Text(
            ReportConstants.responsesLabel,
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          Text(
            '${widget.totalResponses}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            ReportConstants.evaluationsLabel,
            style: TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
