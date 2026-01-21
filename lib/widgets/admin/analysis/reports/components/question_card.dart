/// Tarjeta de pregunta para reportes
/// Ubicación: lib/widgets/admin/analysis/reports/components/question_card.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class QuestionCardReport extends StatefulWidget {
  final QuestionReport question;
  final bool isExpanded;
  final VoidCallback onTap;

  const QuestionCardReport({
    super.key,
    required this.question,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<QuestionCardReport> createState() => _QuestionCardReportState();
}

class _QuestionCardReportState extends State<QuestionCardReport> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: ReportConstants.paddingMedium),
      elevation: ReportConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildQuestionInfo()),
                const SizedBox(width: ReportConstants.paddingMedium),
                _buildScoreIndicator(),
              ],
            ),
            const SizedBox(width: ReportConstants.paddingMedium),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInfo() {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: palette.chipBackground,
                borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
              ),
              child: Text(
                '#${widget.question.id}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: palette.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.question.category,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.question.text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator() {
    return Column(
      children: [
        Text(
          widget.question.average.toFixed(1),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ReportConstants.getScoreColor(widget.question.average),
          ),
        ),
        Icon(
          widget.isExpanded
              ? ReportConstants.expandLessIcon
              : ReportConstants.expandMoreIcon,
          size: 16,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
      child: LinearProgressIndicator(
        value: widget.question.average / 5,
        minHeight: ReportConstants.progressBarHeight,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          ReportConstants.getScoreColor(widget.question.average),
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ReportConstants.getDistributionMessage(widget.question.totalResponses),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: ReportConstants.paddingMedium),
          ...ResponseScale.all.reversed.map((scale) => _buildResponseBar(scale)),
        ],
      ),
    );
  }

  Widget _buildResponseBar(ResponseScale scale) {
    final count = widget.question.responses[scale.value] ?? 0;
    final percentage = widget.question.getPercentage(scale.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: ReportConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scale.color,
              borderRadius: BorderRadius.circular(ReportConstants.containerBorderRadius),
            ),
            child: Center(
              child: Text(
                scale.label,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      scale.full,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$count (${percentage.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ReportConstants.paddingSmall),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: ReportConstants.progressBarHeight,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(scale.color),
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
