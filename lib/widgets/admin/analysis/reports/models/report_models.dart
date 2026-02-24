/// Modelos para el sistema de reportes de docentes
/// Ubicación: lib/widgets/admin/analysis/reports/models/report_models.dart
library;

import 'package:flutter/material.dart';

// ==============================================
// ESCALA DE RESPUESTAS
// ==============================================

class ResponseScale {
  final int value;
  final String label;
  final String full;
  final Color color;

  const ResponseScale({
    required this.value,
    required this.label,
    required this.full,
    required this.color,
  });

  static const scale1 = ResponseScale(
    value: 1,
    label: 'N',
    full: 'Nunca',
    color: Color(0xFFEF4444),
  );

  static const scale2 = ResponseScale(
    value: 2,
    label: 'CN',
    full: 'Casi nunca',
    color: Color(0xFFF59E0B),
  );

  static const scale3 = ResponseScale(
    value: 3,
    label: 'AV',
    full: 'Algunas veces',
    color: Color(0xFFFCD34D),
  );

  static const scale4 = ResponseScale(
    value: 4,
    label: 'CS',
    full: 'Casi siempre',
    color: Color(0xFF8BC34A),
  );

  static const scale5 = ResponseScale(
    value: 5,
    label: 'S',
    full: 'Siempre',
    color: Color(0xFF4CAF50),
  );

  static const List<ResponseScale> all = [scale1, scale2, scale3, scale4, scale5];

  static ResponseScale fromValue(int value) {
    switch (value) {
      case 1: return scale1;
      case 2: return scale2;
      case 3: return scale3;
      case 4: return scale4;
      case 5: return scale5;
      default: return scale3;
    }
  }
}

// ==============================================
// MODELO DE PREGUNTA
// ==============================================

class QuestionReport {
  final int id;
  final String text;
  final String category;
  final String aspect;
  final Map<int, int> responses;
  final double average;

  QuestionReport({
    required this.id,
    required this.text,
    required this.category,
    required this.aspect,
    required this.responses,
    required this.average,
  });

  /// Total de respuestas
  int get totalResponses => responses.values.fold(0, (sum, count) => sum + count);

  /// Obtiene el porcentaje para un valor específico
  double getPercentage(int value) {
    if (totalResponses == 0) return 0;
    final count = responses[value] ?? 0;
    return (count / totalResponses) * 100;
  }
}

// ==============================================
// MODELO DE COMENTARIO (Con datos completos del backend)
// ==============================================

class CommentReport {
  final int id;
  final String text;
  final String sentiment;
  final double? sentimentScore;
  final DateTime? analyzedAt;
  final DateTime? completedAt;

  CommentReport({
    required this.id,
    required this.text,
    required this.sentiment,
    this.sentimentScore,
    this.analyzedAt,
    this.completedAt,
  });

  /// Factory constructor desde JSON del backend
  factory CommentReport.fromJson(Map<String, dynamic> json) {
    return CommentReport(
      id: json['id'] as int,
      text: json['text'] as String,
      sentiment: json['sentiment'] as String? ?? 'neutral',
      sentimentScore: json['sentimentScore'] != null
          ? (json['sentimentScore'] as num).toDouble()
          : null,
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sentiment': sentiment,
      'sentimentScore': sentimentScore,
      'analyzedAt': analyzedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Color del borde según el sentimiento
  Color get borderColor {
    switch (sentiment) {
      case 'positive': return const Color(0xFF4CAF50);
      case 'negative': return const Color(0xFFEF4444);
      default:         return Colors.grey;
    }
  }

  /// Color del chip según el sentimiento
  Color get chipColor {
    switch (sentiment) {
      case 'positive': return const Color(0xFFE8F5E9);
      case 'negative': return const Color(0xFFFFEBEE);
      default:         return Colors.grey.shade200;
    }
  }

  /// Etiqueta según el sentimiento
  String get chipLabel {
    switch (sentiment) {
      case 'positive': return 'Positivo';
      case 'negative': return 'Negativo';
      default:         return 'Neutral';
    }
  }

  /// Ícono según el sentimiento
  IconData get icon {
    switch (sentiment) {
      case 'positive': return Icons.sentiment_satisfied;
      case 'negative': return Icons.sentiment_dissatisfied;
      default:         return Icons.sentiment_neutral;
    }
  }

  /// Color del ícono según el sentimiento
  Color get iconColor {
    switch (sentiment) {
      case 'positive': return const Color(0xFF10B981);
      case 'negative': return const Color(0xFFEF4444);
      default:         return const Color(0xFF6B7280);
    }
  }
}

// ==============================================
// MODELO DE ANÁLISIS IA
// ==============================================

/// Insights completos generados por IA para un docente.
class AIInsights {
  final String profile;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> recommendations;

  /// Comentario general sobre las respuestas cuantitativas de las evaluaciones.
  /// Vacío si el backend aún no lo provee.
  final String responsesComment;

  /// Comentario general sobre los comentarios anónimos de los estudiantes.
  /// Vacío si el backend aún no lo provee.
  final String commentsComment;

  const AIInsights({
    required this.profile,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
    this.responsesComment = '',
    this.commentsComment = '',
  });
}

// ==============================================
// EXTENSIONES ÚTILES
// ==============================================

extension DoubleExtension on double {
  String toFixed(int decimals) => toStringAsFixed(decimals);
}