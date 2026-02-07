/// Constantes para el análisis administrativo
/// Ubicación: lib/utils/admin_analysis_constants.dart
library;

import 'package:flutter/material.dart';

class AdminAnalysisConstants {
  AdminAnalysisConstants._();

  // ==================== COLORES DE ESTADO ====================
  
  static const Color urgentColor = Colors.red;
  static const Color urgentLight = Color(0xFFFFEBEE);
  static const Color urgentBorder = Color(0xFFFFCDD2);
  
  static const Color warningColor = Colors.orange;
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningBorder = Color(0xFFFFE0B2);
  
  static const Color successColor = Colors.green;
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successBorder = Color(0xFFC8E6C9);
  
  // ==================== COLORES DE MÉTRICAS ====================

  /// 👨‍🏫 Docentes
  static const Color teachersColor = Color(0xFF9C27B0);
  static const Color teachersDark  = Color(0xFF6A1B9A);

  /// 📝 Evaluaciones
  static const Color evaluationsColor = Color(0xFF4CAF50);
  static const Color evaluationsDark  = Color.fromARGB(255, 20, 99, 24);

  /// ✅ Completitud
  static const Color completionColor = Color(0xFF26C6DA);
  static const Color completionDark  = Color.fromARGB(255, 1, 131, 146);

  /// 🎓 Estudiantes
  static const Color studentsColor = Color(0xFF3DA9FC);
  static const Color studentsDark  = Color.fromARGB(255, 14, 123, 220);

  // ==================== GRADIENTES DE MÉTRICAS ====================

  static const LinearGradient teachersGradient = LinearGradient(
    colors: [teachersColor, teachersDark],
  );

  static const LinearGradient evaluationsGradient = LinearGradient(
    colors: [evaluationsColor, evaluationsDark],
  );

  static const LinearGradient completionGradient = LinearGradient(
    colors: [completionColor, completionDark],
  );

  static const LinearGradient studentsGradient = LinearGradient(
    colors: [studentsColor, studentsDark],
  );

  // ==================== TEXTOS Y ETIQUETAS ====================
  
  static const String headerTitle = 'Análisis';
  static const String headerSubtitle = 'Analiza los resultados de evaluaciones';
  
  static const String searchHint = 'Nombre';
  static const String filtersButton = 'Filtros';
  
  static const String careerFilterLabel = 'Carrera';
  static const String periodFilterLabel = 'Período';
  static const String statusFilterLabel = 'Estado';
  
  static const String sortByLabel = 'Ordenar por:';
  
  static const String emptyStateTitle = 'No se encontraron docentes';
  static const String emptyStateMessage = 'Intenta ajustar los filtros o el término de búsqueda';
  
  static const String errorTitle = 'Error al cargar datos';
  static const String retryButton = 'Reintentar';
  
  static const String loadingMessage = 'Cargando análisis...';

  // ==================== OPCIONES DE FILTROS ====================
  
  static const Map<String, String> periodOptions = {
    '2025-1': '2025-1 (actual)',
    '2024-2': '2024-2',
    'all': 'Todos',
  };
  
  static const Map<String, String> statusOptions = {
    'all': 'Todos',
    'active': 'Con evaluaciones activas',
    'none': 'Sin evaluaciones',
  };
  
  static const Map<String, String> sortOptions = {
    'name': 'Nombre (A-Z)',
    'evaluations': 'Evaluaciones activas',
    'completion': 'Completitud (urgentes primero)',
    'activity': 'Última actividad',
  };

  // ==================== UMBRALES DE COMPLETITUD ====================
  
  static const int urgentThreshold = 50;
  static const int warningThreshold = 80;

  // ==================== ICONOS ====================
  
  static const IconData headerIcon = Icons.analytics;
  static const IconData searchIcon = Icons.search;
  static const IconData clearIcon = Icons.clear;
  static const IconData filterIcon = Icons.filter_list;
  static const IconData teachersIcon = Icons.people;
  static const IconData evaluationsIcon = Icons.book;
  static const IconData completionIcon = Icons.trending_up;
  static const IconData studentsIcon = Icons.school;
  static const IconData emailIcon = Icons.email;
  static const IconData downloadIcon = Icons.download;
  static const IconData shareIcon = Icons.share;
  static const IconData expandMoreIcon = Icons.expand_more;
  static const IconData expandLessIcon = Icons.expand_less;
  static const IconData urgentIcon = Icons.warning;
  static const IconData warningIcon = Icons.trending_up;
  static const IconData successIcon = Icons.check_circle;
  static const IconData emptyIcon = Icons.people_outline;
  static const IconData errorIcon = Icons.error_outline;
  static const IconData chartIcon = Icons.bar_chart;
  static const IconData bookIcon = Icons.book;

  // ==================== DIMENSIONES ====================
  
  static const double avatarSize = 48.0;
  static const double avatarBorderRadius = 12.0;
  
  static const double cardBorderRadius = 12.0;
  static const double chipBorderRadius = 4.0;
  static const double buttonBorderRadius = 8.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double iconSizeSmall = 12.0;
  static const double iconSizeMedium = 16.0;
  static const double iconSizeLarge = 20.0;
  
  static const double progressBarHeight = 8.0;
  static const double statsCardPadding = 12.0;
  static const double headerContainerSize = 64.0;

  // ==================== DURACIONES ====================
  
  static const Duration filterDebounce = Duration(milliseconds: 500);
  static const Duration loadingDelay = Duration(milliseconds: 300);

  // ==================== MENSAJES ====================
  
  static String teachersFoundMessage(int count) => 
      count == 1 ? '1 docente encontrado' : '$count docentes encontrados';
  
  static String evaluationsMessage(int active) => 
      '$active activas';
  
  static String responsesMessage(int completed, int total, int rate) => 
      '$completed/$total ($rate%)';
  
  static String studentsMessage(int count) => 
      count == 1 ? '1 estudiante' : '$count estudiantes';

  // ==================== LABELS DE ESTADÍSTICAS ====================
  
  static const String statsTeachersLabel = 'Docentes';
  static const String statsEvaluationsLabel = 'Evaluaciones';
  static const String statsCompletionLabel = 'Completitud';
  static const String statsStudentsLabel = 'Estudiantes';

  // ==================== ESTADO DE DOCENTES ====================
  
  static Map<String, dynamic> getTeacherStatus(int completionRate) {
    if (completionRate < urgentThreshold) {
      return {
        'color': urgentLight,
        'borderColor': urgentBorder,
        'textColor': urgentColor,
        'icon': urgentIcon,
        'text': 'Atención requerida',
      };
    } else if (completionRate < warningThreshold) {
      return {
        'color': warningLight,
        'borderColor': warningBorder,
        'textColor': warningColor,
        'icon': warningIcon,
        'text': 'En progreso',
      };
    } else {
      return {
        'color': successLight,
        'borderColor': successBorder,
        'textColor': successColor,
        'icon': successIcon,
        'text': 'Excelente',
      };
    }
  }

  // ==================== COLORES DE PROGRESO ====================
  
  static Color getCompletionColor(int rate) {
    if (rate < urgentThreshold) return urgentColor;
    if (rate < warningThreshold) return warningColor;
    return successColor;
  }
}
