/// Widget de contenido animado con typewriter para análisis IA
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

    if (mounted) setState(() => _showProfileCard = true);

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
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _animationCompleted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final useTypewriter = widget.animate && !_animationCompleted;

    return ListView(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      children: [
        if (widget.refreshButton != null) widget.refreshButton!,

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
          _buildEvaluationCommentCard(useTypewriter),
        ],
        if (_showCommentsCard) ...[
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildCommentsCommentCard(useTypewriter),
        ],
        // Espacio inferior para que el último card no quede pegado al borde
        const SizedBox(height: ReportConstants.paddingXLarge),
      ],
    );
  }

  // ─────────────────────────────────────────
  // TARJETA: PERFIL DOCENTE
  // ─────────────────────────────────────────

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

  // ─────────────────────────────────────────
  // TARJETA: FORTALEZAS
  // ─────────────────────────────────────────

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

  // ─────────────────────────────────────────
  // TARJETA: OPORTUNIDADES DE MEJORA
  // ─────────────────────────────────────────

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

  // ─────────────────────────────────────────
  // TARJETA: RECOMENDACIONES
  // ─────────────────────────────────────────

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
          _buildCardHeader(
            title: ReportConstants.recommendationsCardTitle,
            icon: ReportConstants.recommendationIcon,
            color: ReportConstants.recommendationsColor,
          ),
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: Column(
              children:
                  widget.insights.recommendations.asMap().entries.map((entry) {
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
                        decoration: const BoxDecoration(
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
                                  delay: Duration(
                                      milliseconds: 600 + (index * 200)),
                                  duration:
                                      const Duration(milliseconds: 20),
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

  // ─────────────────────────────────────────
  // TARJETA: ANÁLISIS DE RESPUESTAS (comentario general)
  // ─────────────────────────────────────────

  Widget _buildEvaluationCommentCard(bool useTypewriter) {
    const color = Color(0xFF3B82F6);
    const emptyText =
        'No hay un análisis general de respuestas disponible para este período.';
    final text = widget.insights.responsesComment.isNotEmpty
        ? widget.insights.responsesComment
        : emptyText;
    final isEmpty = widget.insights.responsesComment.isEmpty;

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
          _buildCardHeader(
            title: 'Análisis de Respuestas',
            icon: Icons.assessment_outlined,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: isEmpty
                ? _buildEmptyCommentPlaceholder(color)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea lateral de color
                      Container(
                        width: 3,
                        constraints: const BoxConstraints(minHeight: 40),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      Expanded(
                        child: useTypewriter
                            ? TypewriterText(
                                text: text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Color(0xFF374151),
                                ),
                                delay:
                                    const Duration(milliseconds: 800),
                                duration:
                                    const Duration(milliseconds: 20),
                              )
                            : Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
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

  // ─────────────────────────────────────────
  // TARJETA: ANÁLISIS DE COMENTARIOS (comentario general)
  // ─────────────────────────────────────────

  Widget _buildCommentsCommentCard(bool useTypewriter) {
    const color = Color(0xFF8B5CF6);
    const emptyText =
        'No hay un análisis general de comentarios disponible para este período.';
    final text = widget.insights.commentsComment.isNotEmpty
        ? widget.insights.commentsComment
        : emptyText;
    final isEmpty = widget.insights.commentsComment.isEmpty;

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
          _buildCardHeader(
            title: 'Análisis de Comentarios',
            icon: Icons.forum_outlined,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
            child: isEmpty
                ? _buildEmptyCommentPlaceholder(color)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea lateral de color
                      Container(
                        width: 3,
                        constraints: const BoxConstraints(minHeight: 40),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: ReportConstants.paddingLarge),
                      Expanded(
                        child: useTypewriter
                            ? TypewriterText(
                                text: text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Color(0xFF374151),
                                ),
                                delay:
                                    const Duration(milliseconds: 1000),
                                duration:
                                    const Duration(milliseconds: 20),
                              )
                            : Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
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

  // ─────────────────────────────────────────
  // HELPERS DE CONSTRUCCIÓN
  // ─────────────────────────────────────────

  /// Encabezado reutilizable para tarjetas con ícono y color
  Widget _buildCardHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
    );
  }

  /// Placeholder cuando no hay comentario disponible
  Widget _buildEmptyCommentPlaceholder(Color color) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: color.withOpacity(0.5)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Sin información disponible para este período.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  /// Tarjeta genérica de lista con ítems (fortalezas / mejoras)
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
          _buildCardHeader(title: title, icon: icon, color: color),
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
                                  delay: delay +
                                      Duration(milliseconds: index * 200),
                                  duration:
                                      const Duration(milliseconds: 20),
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
}