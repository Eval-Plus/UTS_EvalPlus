/// Widget de contenido animado con typewriter para análisis IA (Corregido)
/// Ubicación: lib/widgets/admin/analysis/reports/components/animated_ai_content.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/animations/admin/typewriter_text_animation.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class AnimatedAIContent extends StatefulWidget {
  final AIInsights insights;
  final bool animate;
  final Widget? refreshButton;

  const AnimatedAIContent({
    super.key,
    required this.insights,
    this.animate = true,
    this.refreshButton,
  });

  @override
  State<AnimatedAIContent> createState() => _AnimatedAIContentState();
}

class _AnimatedAIContentState extends State<AnimatedAIContent> {
  bool _animationStarted = false;
  bool _animationCompleted = false;
  
  bool _showProfileCard = false;
  bool _showStrengthsCard = false;
  bool _showImprovementsCard = false;
  bool _showRecommendationsCard = false;
  bool _showEvaluationCard = false;
  bool _showCommentsCard = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.animate && !_animationStarted) {
      _startAnimationSequence();
    } else {
      // Mostrar todo inmediatamente si no se anima
      _showProfileCard = true;
      _showStrengthsCard = true;
      _showImprovementsCard = true;
      _showRecommendationsCard = true;
      _showEvaluationCard = true;
      _showCommentsCard = true;
      _animationCompleted = true;
    }
  }

  void _startAnimationSequence() {
    if (_animationStarted) return;
    
    _animationStarted = true;
    
    // Mostrar perfil inmediatamente
    if (mounted) {
      setState(() => _showProfileCard = true);
    }
    
    // Secuencia de aparición de tarjetas
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showStrengthsCard = true);
    });
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showImprovementsCard = true);
    });
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showRecommendationsCard = true);
    });
    
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _showEvaluationCard = true);
    });
    
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _showCommentsCard = true);
    });
    
    // Marcar animación como completada después de 5 segundos
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) {
        setState(() => _animationCompleted = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si se debe usar animación typewriter
    final useTypewriter = widget.animate && !_animationCompleted;
    
    return ListView(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      children: [
        // Botón de refresh (si se proporciona)
        if (widget.refreshButton != null) widget.refreshButton!,
        
        // Contenido
        if (_showProfileCard) _buildProfileCard(useTypewriter),
        if (_showStrengthsCard) ...[
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildStrengthsCard(useTypewriter),
        ],
        if (_showImprovementsCard) ...[
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildImprovementsCard(useTypewriter),
        ],
        if (_showRecommendationsCard) ...[
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildRecommendationsCard(useTypewriter),
        ],
        if (_showEvaluationCard) ...[
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildEvaluationFeedbackCard(useTypewriter),
        ],
        if (_showCommentsCard) ...[
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildCommentsFeedbackCard(useTypewriter),
        ],
      ],
    );
  }

  Widget _buildProfileCard(bool useTypewriter) {
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
          useTypewriter
              ? TypewriterText(
                  text: widget.insights.profile,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  duration: const Duration(milliseconds: 30),
                )
              : Text(
                  widget.insights.profile,
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

  Widget _buildStrengthsCard(bool useTypewriter) {
    return _buildInsightCard(
      title: ReportConstants.strengthsCardTitle,
      icon: ReportConstants.strengthIcon,
      color: ReportConstants.strengthsColor,
      items: widget.insights.strengths,
      itemIcon: ReportConstants.checkIcon,
      delay: const Duration(milliseconds: 200),
      useTypewriter: useTypewriter,
    );
  }

  Widget _buildImprovementsCard(bool useTypewriter) {
    return _buildInsightCard(
      title: ReportConstants.improvementsCardTitle,
      icon: ReportConstants.improvementIcon,
      color: ReportConstants.improvementsColor,
      items: widget.insights.improvements,
      itemIcon: ReportConstants.trendingUpIcon,
      delay: const Duration(milliseconds: 400),
      useTypewriter: useTypewriter,
    );
  }

  Widget _buildRecommendationsCard(bool useTypewriter) {
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
          
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: widget.insights.recommendations.asMap().entries.map((entry) {
                final index = entry.key;
                final recommendation = entry.value;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < widget.insights.recommendations.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        height: 60,
                        decoration: BoxDecoration(
                          color: ReportConstants.recommendationsColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: useTypewriter
                              ? TypewriterText(
                                  text: recommendation,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Color(0xFF374151),
                                  ),
                                  delay: Duration(milliseconds: 600 + (index * 200)),
                                  duration: const Duration(milliseconds: 20),
                                )
                              : Text(
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

  Widget _buildEvaluationFeedbackCard(bool useTypewriter) {
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

    return _buildFeedbackCard(
      title: 'Análisis de respuestas',
      icon: Icons.assessment,
      color: const Color(0xFF3B82F6),
      items: feedbackItems,
      delay: const Duration(milliseconds: 800),
      useTypewriter: useTypewriter,
    );
  }

  Widget _buildCommentsFeedbackCard(bool useTypewriter) {
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

    return _buildSentimentCard(
      title: 'Análisis de Comentarios',
      icon: Icons.forum,
      color: const Color(0xFF8B5CF6),
      items: feedbackItems,
      delay: const Duration(milliseconds: 1000),
      useTypewriter: useTypewriter,
    );
  }

  Widget _buildInsightCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required IconData itemIcon,
    required Duration delay,
    required bool useTypewriter,
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
                  child: Icon(icon, color: Colors.white, size: 18),
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
                      Container(
                        width: 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      Icon(itemIcon, color: color, size: 18),
                      const SizedBox(width: ReportConstants.paddingMedium),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: useTypewriter
                              ? TypewriterText(
                                  text: item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Color(0xFF374151),
                                  ),
                                  delay: delay + Duration(milliseconds: index * 200),
                                  duration: const Duration(milliseconds: 20),
                                )
                              : Text(
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

  Widget _buildFeedbackCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> items,
    required Duration delay,
    required bool useTypewriter,
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
                  child: Icon(icon, color: Colors.white, size: 18),
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
          
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final score = item['score'] as double;
                final itemColor = ReportConstants.getScoreColor(score);
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < items.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        constraints: const BoxConstraints(minHeight: 80),
                        decoration: BoxDecoration(
                          color: itemColor,
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
                                    color: itemColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: itemColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    score.toFixed(1),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: itemColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: ReportConstants.paddingMedium),
                            useTypewriter
                                ? TypewriterText(
                                    text: item['feedback'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Color(0xFF6B7280),
                                    ),
                                    delay: delay + Duration(milliseconds: index * 300),
                                    duration: const Duration(milliseconds: 20),
                                  )
                                : Text(
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

  Widget _buildSentimentCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> items,
    required Duration delay,
    required bool useTypewriter,
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
                  child: Icon(icon, color: Colors.white, size: 18),
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
          
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final sentimentConfig = _getSentimentConfig(item['sentiment'] as String);
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < items.length - 1
                        ? ReportConstants.paddingLarge
                        : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            useTypewriter
                                ? TypewriterText(
                                    text: item['feedback'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Color(0xFF6B7280),
                                    ),
                                    delay: delay + Duration(milliseconds: index * 300),
                                    duration: const Duration(milliseconds: 20),
                                  )
                                : Text(
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