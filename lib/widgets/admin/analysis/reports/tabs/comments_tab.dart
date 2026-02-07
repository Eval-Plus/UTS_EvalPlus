/// Tab de comentarios del reporte (CON DATOS REALES DE LA API)
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/comments_tab.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/states/empty_state.dart';

class CommentsTab extends StatefulWidget {
  final List<CommentReport> comments;
  final bool isLoading;
  final String? errorMessage;

  const CommentsTab({
    super.key,
    required this.comments,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  String _commentFilter = 'all';

  List<CommentReport> get _filteredComments {
    return widget.comments.where((comment) {
      return _commentFilter == 'all' || comment.sentiment == _commentFilter;
    }).toList();
  }

  Map<String, int> get _sentimentCounts {
    return {
      'positive': widget.comments.where((c) => c.sentiment == 'positive').length,
      'neutral': widget.comments.where((c) => c.sentiment == 'neutral').length,
      'negative': widget.comments.where((c) => c.sentiment == 'negative').length,
    };
  }

  /// Calcula el porcentaje de satisfacción general
  /// Fórmula: (Positivos + 50% de Neutrales) / Total * 100
  double get _satisfactionRate {
    if (widget.comments.isEmpty) return 0.0;
    
    final positive = _sentimentCounts['positive']!;
    final neutral = _sentimentCounts['neutral']!;
    final total = widget.comments.length;
    
    return ((positive + (neutral * 0.5)) / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    // Estado de carga
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    // Estado de error
    if (widget.errorMessage != null) {
      return _buildErrorState(widget.errorMessage!);
    }

    // Estado vacío (sin comentarios)
    if (widget.comments.isEmpty) {
      return _buildEmptyState();
    }

    // Estado normal con datos
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implementar refresh cuando sea necesario
        await Future.delayed(const Duration(seconds: 1));
      },
      child: _filteredComments.isEmpty
          ? _buildFilteredEmptyState()
          : ListView(
              padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
              children: [
                _buildFiltersPanel(),
                const SizedBox(height: ReportConstants.paddingLarge),
                _buildSatisfactionSection(),
                const SizedBox(height: ReportConstants.paddingLarge),
                _buildSentimentDistribution(),
                const SizedBox(height: ReportConstants.paddingLarge),
                _buildCommentsHeader(),
                const SizedBox(height: ReportConstants.paddingMedium),
                ..._filteredComments.map((comment) => _buildCommentCard(comment)),
              ],
            ),
    );
  }

  // ==================== ESTADOS ====================

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando comentarios...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar comentarios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.comment_outlined,
      title: 'Sin comentarios',
      description: 'Este docente aún no tiene comentarios de evaluaciones completadas',
    );
  }

  Widget _buildFilteredEmptyState() {
    return EmptyState(
      icon: Icons.filter_list_off,
      title: 'Sin resultados',
      description: 'No se encontraron comentarios con el filtro "$_commentFilter"',
    );
  }

  // ==================== COMPONENTES PRINCIPALES ====================

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  ReportConstants.filterIcon,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: ReportConstants.paddingMedium),
              const Text(
                ReportConstants.filtersTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildSentimentFilter(),
        ],
      ),
    );
  }

  Widget _buildSentimentFilter() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<String>(
        value: _commentFilter,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
        dropdownColor: Colors.white,
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Text('${ReportConstants.allCommentsLabel} (${widget.comments.length})'),
          ),
          DropdownMenuItem(
            value: 'positive',
            child: Row(
              children: [
                const Icon(Icons.sentiment_satisfied, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text('${ReportConstants.positiveCommentsLabel} (${_sentimentCounts['positive']})'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'neutral',
            child: Row(
              children: [
                const Icon(Icons.sentiment_neutral, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text('${ReportConstants.neutralCommentsLabel} (${_sentimentCounts['neutral']})'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'negative',
            child: Row(
              children: [
                const Icon(Icons.sentiment_dissatisfied, size: 16, color: Color(0xFFEF4444)),
                const SizedBox(width: 6),
                Text('${ReportConstants.negativeCommentsLabel} (${_sentimentCounts['negative']})'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _commentFilter = value!;
          });
        },
      ),
    );
  }

  Widget _buildSatisfactionSection() {
    final satisfactionData = _getSatisfactionData(_satisfactionRate);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de Satisfacción
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: satisfactionData['colors'] as List<Color>,
                ),
                borderRadius: BorderRadius.circular(
                  ReportConstants.largeBorderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (satisfactionData['colors'] as List<Color>)[0]
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Satisfacción',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: ReportConstants.paddingXLarge),
                  Text(
                    '${_satisfactionRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    satisfactionData['label'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: ReportConstants.paddingLarge),

          // Tarjeta Informativa
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ReportConstants.largeBorderRadius,
                ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '¿Cómo se calcula?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ReportConstants.paddingMedium),
                  const Text(
                    'Ponderando los comentarios:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCalculationItem(
                    icon: Icons.sentiment_satisfied,
                    color: const Color(0xFF10B981),
                    label: 'Positivos',
                    value: '100%',
                  ),
                  const SizedBox(height: 4),
                  _buildCalculationItem(
                    icon: Icons.sentiment_neutral,
                    color: const Color(0xFF6B7280),
                    label: 'Neutrales',
                    value: '50%',
                  ),
                  const SizedBox(height: 4),
                  _buildCalculationItem(
                    icon: Icons.sentiment_dissatisfied,
                    color: const Color(0xFFEF4444),
                    label: 'Negativos',
                    value: '0%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentDistribution() {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
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
          const Text(
            'Distribución de Sentimientos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: ReportConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: _buildSentimentCard(
                  ReportConstants.positiveCommentsLabel,
                  _sentimentCounts['positive']!,
                  const Color(0xFF10B981),
                  ReportConstants.positiveIcon,
                ),
              ),
              const SizedBox(width: ReportConstants.paddingMedium),
              Expanded(
                child: _buildSentimentCard(
                  ReportConstants.neutralCommentsLabel,
                  _sentimentCounts['neutral']!,
                  const Color(0xFF6B7280),
                  ReportConstants.neutralIcon,
                ),
              ),
              const SizedBox(width: ReportConstants.paddingMedium),
              Expanded(
                child: _buildSentimentCard(
                  ReportConstants.negativeCommentsLabel,
                  _sentimentCounts['negative']!,
                  const Color(0xFFEF4444),
                  ReportConstants.negativeIcon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: ReportConstants.paddingMedium),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.comment,
            size: 18,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: ReportConstants.paddingMedium),
        const Expanded(
          child: Text(
            'Comentarios Anónimos',
            style: TextStyle(
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
            '${_filteredComments.length} comentarios',
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

  Widget _buildCommentCard(CommentReport comment) {
    final sentimentConfig = _getSentimentConfig(comment.sentiment);
    
    return Container(
      margin: const EdgeInsets.only(bottom: ReportConstants.paddingLarge),
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
          // Header del comentario
          Container(
            padding: const EdgeInsets.all(ReportConstants.paddingLarge),
            decoration: BoxDecoration(
              color: sentimentConfig['backgroundColor'] as Color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: sentimentConfig['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sentimentConfig['icon'] as IconData,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingMedium),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (sentimentConfig['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    sentimentConfig['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sentimentConfig['color'] as Color,
                    ),
                  ),
                ),
                const Spacer(),
                // Indicador anónimo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Anónimo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido del comentario
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sentimentConfig['color'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingLarge),
                Expanded(
                  child: Text(
                    comment.text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF374151),
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

  // ==================== HELPERS ====================

  Map<String, dynamic> _getSentimentConfig(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return {
          'label': 'Positivo',
          'color': const Color(0xFF10B981),
          'backgroundColor': const Color(0xFFD1FAE5),
          'icon': Icons.sentiment_satisfied,
        };
      case 'negative':
        return {
          'label': 'Negativo',
          'color': const Color(0xFFEF4444),
          'backgroundColor': const Color(0xFFFEE2E2),
          'icon': Icons.sentiment_dissatisfied,
        };
      default:
        return {
          'label': 'Neutral',
          'color': const Color(0xFF6B7280),
          'backgroundColor': const Color(0xFFF3F4F6),
          'icon': Icons.sentiment_neutral,
        };
    }
  }

  Map<String, dynamic> _getSatisfactionData(double rate) {
    if (rate >= 80) {
      return {
        'colors': [const Color(0xFF10B981), const Color(0xFF059669)], // Verde
        'label': 'Excelente',
        'icon': Icons.sentiment_very_satisfied,
      };
    }
    if (rate >= 60) {
      return {
        'colors': [const Color(0xFF8BC34A), const Color(0xFF689F38)], // Verde claro
        'label': 'Bueno',
        'icon': Icons.sentiment_satisfied,
      };
    }
    if (rate >= 40) {
      return {
        'colors': [const Color(0xFFFCD34D), const Color(0xFFF59E0B)], // Amarillo
        'label': 'Regular',
        'icon': Icons.sentiment_neutral,
      };
    }
    if (rate >= 20) {
      return {
        'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Naranja
        'label': 'Bajo',
        'icon': Icons.sentiment_dissatisfied,
      };
    }
    return {
      'colors': [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Rojo
      'label': 'Muy bajo',
      'icon': Icons.sentiment_very_dissatisfied,
    };
  }
}