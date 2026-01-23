/// Tab de análisis de IA del reporte (Rediseñado)
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
        const SizedBox(height: ReportConstants.paddingLarge),
        _buildEvaluationFeedbackCard(),
        const SizedBox(height: ReportConstants.paddingLarge),
        _buildCommentsFeedbackCard(),
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
        boxShadow: [
          BoxShadow(
            color: ReportConstants.profileGradientStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard() {
    return _buildInsightCard(
      title: ReportConstants.strengthsCardTitle,
      icon: ReportConstants.strengthIcon,
      color: ReportConstants.strengthsColor,
      items: insights.strengths,
      itemIcon: ReportConstants.checkIcon,
    );
  }

  Widget _buildImprovementsCard() {
    return _buildInsightCard(
      title: ReportConstants.improvementsCardTitle,
      icon: ReportConstants.improvementIcon,
      color: ReportConstants.improvementsColor,
      items: insights.improvements,
      itemIcon: ReportConstants.trendingUpIcon,
    );
  }

  Widget _buildRecommendationsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con color de acento
          Container(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            decoration: BoxDecoration(
              color: ReportConstants.recommendationsColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ReportConstants.recommendationsColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    ReportConstants.recommendationIcon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingMedium),
                const Text(
                  ReportConstants.recommendationsCardTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido con borde lateral
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: insights.recommendations.asMap().entries.map((entry) {
                final index = entry.key;
                final recommendation = entry.value;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < insights.recommendations.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea vertical de color
                      Container(
                        width: 3,
                        height: 60,
                        decoration: BoxDecoration(
                          color: ReportConstants.recommendationsColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      
                      // Número de recomendación
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: ReportConstants.recommendationsColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      
                      // Texto de la recomendación
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            recommendation,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationFeedbackCard() {
    // Datos hardcodeados
    final feedbackItems = [
      {
        'category': 'Competencia Disciplinaria',
        'score': 4.3,
        'feedback': 'El docente demuestra un excelente dominio y actualización en los temas del curso, manteniendo alta credibilidad académica.',
      },
      {
        'category': 'Estrategias Metodológicas',
        'score': 4.0,
        'feedback': 'Se observa buena capacidad para relacionar teoría con práctica, aunque podría diversificar más las metodologías activas.',
      },
      {
        'category': 'Dominio de Segunda Lengua',
        'score': 3.6,
        'feedback': 'Área de oportunidad identificada. Se recomienda incrementar gradualmente el uso de materiales en idioma extranjero.',
      },
    ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingMedium),
                const Text(
                  'Análisis de respuestas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: feedbackItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final score = item['score'] as double;
                final color = ReportConstants.getScoreColor(score);
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < feedbackItems.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea de color según puntuación
                      Container(
                        width: 3,
                        constraints: const BoxConstraints(minHeight: 80),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['category'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
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
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: color.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    score.toFixed(1),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: ReportConstants.paddingMedium),
                            Text(
                              item['feedback'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsFeedbackCard() {
    // Datos hardcodeados
    final feedbackItems = [
      {
        'sentiment': 'positive',
        'percentage': 60,
        'feedback': 'Los estudiantes valoran especialmente la claridad explicativa y la disponibilidad del docente para resolver dudas.',
      },
      {
        'sentiment': 'neutral',
        'percentage': 30,
        'feedback': 'Algunos estudiantes sugieren más ejemplos prácticos y mayor variedad en las actividades de clase.',
      },
      {
        'sentiment': 'negative',
        'percentage': 10,
        'feedback': 'Pocas menciones negativas, principalmente relacionadas con el ritmo de las clases y la retroalimentación de trabajos.',
      },
    ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.forum,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingMedium),
                const Text(
                  'Análisis de Comentarios',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: feedbackItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final sentimentConfig = _getSentimentConfig(item['sentiment'] as String);
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < feedbackItems.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea de color según sentimiento
                      Container(
                        width: 3,
                        constraints: const BoxConstraints(minHeight: 80),
                        decoration: BoxDecoration(
                          color: sentimentConfig['color'] as Color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  sentimentConfig['icon'] as IconData,
                                  size: 18,
                                  color: sentimentConfig['color'] as Color,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    sentimentConfig['label'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: sentimentConfig['color'] as Color,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (sentimentConfig['color'] as Color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: (sentimentConfig['color'] as Color).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${item['percentage']}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: sentimentConfig['color'] as Color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: ReportConstants.paddingMedium),
                            Text(
                              item['feedback'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required IconData itemIcon,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con color de acento
          Container(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: ReportConstants.paddingMedium),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido con borde lateral
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < items.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea vertical de color
                      Container(
                        width: 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      
                      // Icono del item
                      Icon(itemIcon, color: color, size: 18),
                      const SizedBox(width: ReportConstants.paddingMedium),
                      
                      // Texto del item
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getSentimentConfig(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return {
          'label': 'Comentarios Positivos',
          'color': const Color(0xFF10B981),
          'icon': Icons.sentiment_satisfied,
        };
      case 'negative':
        return {
          'label': 'Comentarios Negativos',
          'color': const Color(0xFFEF4444),
          'icon': Icons.sentiment_dissatisfied,
        };
      default:
        return {
          'label': 'Comentarios Neutrales',
          'color': const Color(0xFF6B7280),
          'icon': Icons.sentiment_neutral,
        };
    }
  }
}
