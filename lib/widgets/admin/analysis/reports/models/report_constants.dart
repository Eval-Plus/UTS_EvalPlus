/// Constantes para el sistema de reportes
/// Ubicación: lib/widgets/admin/analysis/reports/models/report_constants.dart

import 'package:flutter/material.dart';

class ReportConstants {
  ReportConstants._();

  // ==================== COLORES ====================
  
  static const Color averageGradientStart = Color(0xFF4CAF50);
  static const Color averageGradientEnd = Color(0xFF388E3C);
  
  static const Color responsesGradientStart = Color(0xFF2196F3);
  static const Color responsesGradientEnd = Color(0xFF1976D2);
  
  static const Color profileGradientStart = Color(0xFF9C27B0);
  static const Color profileGradientEnd = Color(0xFF7B1FA2);

  static const Color strengthsColor = Color(0xFF4CAF50);
  static const Color improvementsColor = Color(0xFFF59E0B);
  static const Color recommendationsColor = Color(0xFF2196F3);

  // ==================== UMBRALES DE CALIFICACIÓN ====================
  
  static const double excellentThreshold = 4.5;
  static const double goodThreshold = 4.0;
  static const double averageThreshold = 3.5;
  static const double belowAverageThreshold = 3.0;

  // ==================== ICONOS ====================
  
  static const IconData reportIcon = Icons.bar_chart;
  static const IconData closeIcon = Icons.close;
  static const IconData responsesIcon = Icons.trending_up;
  static const IconData subjectsIcon = Icons.book;
  static const IconData aiIcon = Icons.psychology;
  static const IconData commentsIcon = Icons.comment;
  static const IconData filterIcon = Icons.filter_list;
  static const IconData expandMoreIcon = Icons.expand_more;
  static const IconData expandLessIcon = Icons.expand_less;
  
  static const IconData strengthIcon = Icons.emoji_events;
  static const IconData checkIcon = Icons.check_circle;
  static const IconData improvementIcon = Icons.info_outline;
  static const IconData trendingUpIcon = Icons.trending_up;
  static const IconData recommendationIcon = Icons.lightbulb_outline;
  
  static const IconData positiveIcon = Icons.sentiment_satisfied;
  static const IconData neutralIcon = Icons.sentiment_neutral;
  static const IconData negativeIcon = Icons.sentiment_dissatisfied;
  static const IconData emptyCommentIcon = Icons.comment_outlined;

  // ==================== TEXTOS ====================
  
  static const String modalTitle = 'Informe Completo';
  
  static const String responsesTabLabel = 'Respuestas';
  static const String subjectsTabLabel = 'Materias';
  static const String aiTabLabel = 'Análisis IA';
  static const String commentsTabLabel = 'Comentarios';
  
  static const String averageLabel = 'Promedio';
  static const String responsesLabel = 'Respuestas';
  static const String evaluationsLabel = 'evaluaciones';
  static const String distributionLabel = 'Distribución';
  
  static const String profileCardTitle = 'Perfil Docente';
  static const String strengthsCardTitle = 'Fortalezas';
  static const String improvementsCardTitle = 'Oportunidades de Mejora';
  static const String recommendationsCardTitle = 'Recomendaciones';
  
  static const String filtersTitle = 'Filtros';
  static const String allCommentsLabel = 'Todos';
  static const String positiveCommentsLabel = 'Positivos';
  static const String neutralCommentsLabel = 'Neutrales';
  static const String negativeCommentsLabel = 'Negativos';
  static const String allSubjectsLabel = 'Todas las materias';
  
  static const String emptyCommentsMessage = 'No hay comentarios';
  
  static const String totalLabel = 'Total';
  static const String evaluatedLabel = 'Evaluados';
  static const String pendingLabel = 'Pendientes';
  static const String progressLabel = 'Progreso';

  // ==================== DIMENSIONES ====================
  
  static const double headerIconSize = 48.0;
  static const double headerIconContainerSize = 12.0;
  static const double tabIconSize = 16.0;
  
  static const double cardElevation = 1.0;
  static const double cardBorderRadius = 8.0;
  static const double chipBorderRadius = 4.0;
  static const double containerBorderRadius = 6.0;
  static const double largeBorderRadius = 12.0;
  
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingLarge = 12.0;
  static const double paddingXLarge = 16.0;
  
  static const double progressBarHeight = 8.0;
  static const double emptyIconSize = 64.0;

  // ==================== DURACIONES ====================
  
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // ==================== HELPERS ====================
  
  /// Obtiene el color según la calificación
  static Color getScoreColor(double score) {
    if (score >= excellentThreshold) return const Color(0xFF4CAF50);
    if (score >= goodThreshold) return const Color(0xFF8BC34A);
    if (score >= averageThreshold) return const Color(0xFFFCD34D);
    if (score >= belowAverageThreshold) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  /// Genera el mensaje de respuestas con formato
  static String getResponsesMessage(int total) {
    return '$total $evaluationsLabel';
  }

  /// Genera el mensaje de distribución con formato
  static String getDistributionMessage(int total) {
    return '$distributionLabel ($total respuestas)';
  }
}
