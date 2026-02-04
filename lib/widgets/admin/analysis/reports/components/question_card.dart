/// Tarjeta de pregunta para reportes (Actualizada)
/// Ubicación: lib/widgets/admin/analysis/reports/components/question_card.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class QuestionCardReport extends StatefulWidget {
  final QuestionReport question;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color? categoryColor; // Color para diferenciar categorías

  const QuestionCardReport({
    super.key,
    required this.question,
    required this.isExpanded,
    required this.onTap,
    this.categoryColor,
  });

  @override
  State<QuestionCardReport> createState() => _QuestionCardReportState();
}

class _QuestionCardReportState extends State<QuestionCardReport> {
  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.categoryColor ?? const Color(0xFF6B7280);
    
    return Container(
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
        children: [
          _buildHeader(categoryColor),
          if (widget.isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildExpandedContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Color categoryColor) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(ReportConstants.largeBorderRadius),
      child: Column(
        children: [
          // Header con color de categoría
          Container(
            padding: const EdgeInsets.all(ReportConstants.paddingLarge),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: widget.isExpanded 
                  ? Radius.zero 
                  : const Radius.circular(12),
                bottomRight: widget.isExpanded 
                  ? Radius.zero 
                  : const Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Indicador de categoría
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingLarge),
                
                // Información de la pregunta
                Expanded(child: _buildQuestionInfo(categoryColor)),
                
                const SizedBox(width: ReportConstants.paddingMedium),
                
                // Score y expansión
                _buildScoreIndicator(categoryColor),
              ],
            ),
          ),
          
          // Barra de progreso (solo si no está expandida)
          if (!widget.isExpanded)
            Padding(
              padding: const EdgeInsets.all(ReportConstants.paddingLarge),
              child: _buildProgressBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ID y categoría
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '#${widget.question.id}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.question.category,
                style: TextStyle(
                  fontSize: 11,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: ReportConstants.paddingMedium),
        
        // Texto de la pregunta
        Text(
          widget.question.text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator(Color categoryColor) {
    final scoreColor = ReportConstants.getScoreColor(widget.question.average);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scoreColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            widget.question.average.toFixed(1),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          widget.isExpanded
              ? ReportConstants.expandLessIcon
              : ReportConstants.expandMoreIcon,
          size: 18,
          color: categoryColor,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final scoreColor = ReportConstants.getScoreColor(widget.question.average);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.question.totalResponses} respuestas',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${((widget.question.average / 5) * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                color: scoreColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
          child: LinearProgressIndicator(
            value: widget.question.average / 5,
            minHeight: ReportConstants.progressBarHeight,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ReportConstants.getDistributionMessage(widget.question.totalResponses),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: ReportConstants.paddingLarge),
          
          // Barras de respuesta
          ...ResponseScale.all.reversed.map((scale) => _buildResponseBar(scale)),
        ],
      ),
    );
  }

  Widget _buildResponseBar(ResponseScale scale) {
    final count = widget.question.responses[scale.value] ?? 0;
    final percentage = widget.question.getPercentage(scale.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: ReportConstants.paddingLarge),
      child: Row(
        children: [
          // Indicador de escala
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scale.color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: scale.color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                scale.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: ReportConstants.paddingLarge),
          
          // Barra de progreso y datos
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scale.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: scale.color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$count (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: scale.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 10,
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
