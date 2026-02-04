/// Tab de respuestas del reporte (Actualizado con datos reales)
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/responses_tab.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/question_card.dart';

class ResponsesTab extends StatefulWidget {
  final List<QuestionReport> questions;
  final double averageScore;
  final int totalResponses; // completedEvaluations
  final int expectedResponses; // totalEvaluations

  const ResponsesTab({
    super.key,
    required this.questions,
    required this.averageScore,
    required this.totalResponses,
    required this.expectedResponses,
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

  /// Calcula el porcentaje de completitud
  double get _completionRate {
    if (widget.expectedResponses == 0) return 0.0;
    return (widget.totalResponses / widget.expectedResponses) * 100;
  }

  /// Calcula cuántas respuestas faltan
  int get _pendingResponses {
    return (widget.expectedResponses - widget.totalResponses).clamp(0, widget.expectedResponses);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implementar refresh cuando se necesite
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildCategoryDivider('Preguntas de Evaluación'),
          const SizedBox(height: ReportConstants.paddingMedium),
          
          // Mostrar mensaje si no hay preguntas
          if (widget.questions.isEmpty)
            _buildEmptyState()
          else
            ...widget.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: ReportConstants.paddingMedium),
                child: QuestionCardReport(
                  question: question,
                  isExpanded: _expandedQuestionId == question.id,
                  onTap: () => _toggleQuestion(question.id),
                  categoryColor: _getCategoryColor(index),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildAverageCard()),
        const SizedBox(width: ReportConstants.paddingMedium),
        Expanded(child: _buildResponsesCard()),
        const SizedBox(width: ReportConstants.paddingMedium),
        Expanded(child: _buildCompletionCard()),
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
        boxShadow: [
          BoxShadow(
            color: ReportConstants.averageGradientStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          const Text(
            ReportConstants.averageLabel,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          Text(
            widget.averageScore.toFixed(1),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
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
        boxShadow: [
          BoxShadow(
            color: ReportConstants.responsesGradientStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_turned_in,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          const Text(
            ReportConstants.responsesLabel,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          Text(
            '${widget.totalResponses}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
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

  Widget _buildCompletionCard() {
    final completionData = _getCompletionData(_completionRate);
    
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completionData['colors'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: (completionData['colors'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            completionData['icon'] as IconData,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          const Text(
            'Completitud',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          Text(
            '${_completionRate.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            _pendingResponses == 0 
              ? 'Completo' 
              : '$_pendingResponses pendientes',
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDivider(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.help_outline,
            size: 18,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: ReportConstants.paddingMedium),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
            ),
          ),
          child: Text(
            '${widget.questions.length} preguntas',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay preguntas disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron respuestas para este docente',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color de categoría basado en el índice
  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF3B82F6), // Azul
      const Color(0xFF8B5CF6), // Púrpura
      const Color(0xFF10B981), // Verde
      const Color(0xFFF59E0B), // Naranja
      const Color(0xFFEC4899), // Rosa
    ];
    
    return colors[index % colors.length];
  }

  /// Obtiene la configuración visual según el porcentaje de completitud
  Map<String, dynamic> _getCompletionData(double rate) {
    if (rate >= 90) {
      return {
        'colors': [const Color(0xFF10B981), const Color(0xFF059669)],
        'icon': Icons.check_circle,
      };
    }
    if (rate >= 70) {
      return {
        'colors': [const Color(0xFF8BC34A), const Color(0xFF689F38)],
        'icon': Icons.trending_up,
      };
    }
    if (rate >= 50) {
      return {
        'colors': [const Color(0xFFFCD34D), const Color(0xFFF59E0B)],
        'icon': Icons.trending_flat,
      };
    }
    if (rate >= 30) {
      return {
        'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        'icon': Icons.trending_down,
      };
    }
    return {
      'colors': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      'icon': Icons.warning,
    };
  }
}
