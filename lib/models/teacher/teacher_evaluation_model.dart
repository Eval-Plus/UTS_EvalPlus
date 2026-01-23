import 'package:flutter/material.dart';

/// Modelo para las evaluaciones de un profesor (datos del backend)
class TeacherEvaluationModel {
  final int id;
  final String subjectName;
  final String subjectCode;
  final String careerName;
  final int totalStudents;
  final int completedEvaluations;
  final int pendingEvaluations;
  final String period;
  final EvaluationStatus status;
  final DateTime fechaInicio;
  final DateTime fechaCierre;
  final int templateId;
  final String templateName;

  TeacherEvaluationModel({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.careerName,
    required this.totalStudents,
    required this.completedEvaluations,
    required this.pendingEvaluations,
    required this.period,
    required this.status,
    required this.fechaInicio,
    required this.fechaCierre,
    required this.templateId,
    required this.templateName,
  });

  // ==================== FACTORY CONSTRUCTORS ====================
  
  factory TeacherEvaluationModel.fromJson(Map<String, dynamic> json) {
    return TeacherEvaluationModel(
      id: json['id'] as int,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,
      careerName: json['careerName'] as String,
      totalStudents: json['totalStudents'] as int,
      completedEvaluations: json['completedEvaluations'] as int,
      pendingEvaluations: json['pendingEvaluations'] as int,
      period: json['period'] as String,
      status: _parseStatus(json['status'] as String),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaCierre: DateTime.parse(json['fechaCierre'] as String),
      templateId: json['templateId'] as int,
      templateName: json['templateName'] as String,
    );
  }

  static EvaluationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return EvaluationStatus.active;
      case 'closed':
        return EvaluationStatus.closed;
      case 'upcoming':
        return EvaluationStatus.upcoming;
      default:
        return EvaluationStatus.active;
    }
  }

  // ==================== COMPUTED PROPERTIES ====================
  
  double get completionPercentage {
    if (totalStudents == 0) return 0.0;
    return (completedEvaluations / totalStudents) * 100;
  }

  Color get progressColor {
    final percentage = completionPercentage;
    if (percentage >= 75) return Colors.green.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(fechaCierre)) return 0;
    return fechaCierre.difference(now).inDays;
  }

  // ==================== SERIALIZATION ====================
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'careerName': careerName,
      'totalStudents': totalStudents,
      'completedEvaluations': completedEvaluations,
      'pendingEvaluations': pendingEvaluations,
      'period': period,
      'status': status.toString().split('.').last,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaCierre': fechaCierre.toIso8601String(),
      'templateId': templateId,
      'templateName': templateName,
    };
  }

  // ==================== UTILITY ====================
  
  @override
  String toString() => 
    'TeacherEvaluationModel(id: $id, subject: $subjectName, status: $status)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherEvaluationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Enum para el estado de la evaluación
enum EvaluationStatus {
  active,
  closed,
  upcoming,
}

// ==================== 🆕 MODELO DE COMENTARIO ====================

/// Modelo para comentarios anónimos de evaluaciones
class CommentModel {
  final int id;
  final String text;
  final DateTime date;
  final CommentSentiment sentiment;

  CommentModel({
    required this.id,
    required this.text,
    required this.date,
    required this.sentiment,
  });

  /// Factory desde JSON del backend
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      text: json['comentario'] as String, // Backend usa 'comentario'
      date: DateTime.parse(json['fechaCompleta'] as String),
      sentiment: _parseSentiment(json['sentiment'] as String? ?? 'neutral'),
    );
  }

  static CommentSentiment _parseSentiment(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return CommentSentiment.positive;
      case 'neutral':
        return CommentSentiment.neutral;
      case 'negative':
        return CommentSentiment.negative;
      default:
        return CommentSentiment.neutral;
    }
  }

  /// Formatea la fecha en español
  String get formattedDate {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Color según el sentiment
  Color get sentimentColor {
    switch (sentiment) {
      case CommentSentiment.positive:
        return Colors.green.shade700;
      case CommentSentiment.neutral:
        return Colors.blue.shade700;
      case CommentSentiment.negative:
        return Colors.red.shade700;
    }
  }

  /// Color de fondo según el sentiment
  Color get sentimentBackgroundColor {
    switch (sentiment) {
      case CommentSentiment.positive:
        return Colors.green.shade100;
      case CommentSentiment.neutral:
        return Colors.blue.shade100;
      case CommentSentiment.negative:
        return Colors.red.shade100;
    }
  }

  /// Color de borde según el sentiment
  Color get sentimentBorderColor {
    switch (sentiment) {
      case CommentSentiment.positive:
        return Colors.green.shade300;
      case CommentSentiment.neutral:
        return Colors.blue.shade300;
      case CommentSentiment.negative:
        return Colors.red.shade300;
    }
  }

  /// Etiqueta en español según el sentiment
  String get sentimentLabel {
    switch (sentiment) {
      case CommentSentiment.positive:
        return '😊 Positivo';
      case CommentSentiment.neutral:
        return '😐 Neutral';
      case CommentSentiment.negative:
        return '😕 Negativo';
    }
  }
}

/// Enum para el sentimiento del comentario
enum CommentSentiment {
  positive,
  neutral,
  negative,
}

/// Estadísticas de comentarios
class CommentStats {
  final int total;
  final int positive;
  final int neutral;
  final int negative;

  CommentStats({
    required this.total,
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  factory CommentStats.fromComments(List<CommentModel> comments) {
    return CommentStats(
      total: comments.length,
      positive: comments.where((c) => c.sentiment == CommentSentiment.positive).length,
      neutral: comments.where((c) => c.sentiment == CommentSentiment.neutral).length,
      negative: comments.where((c) => c.sentiment == CommentSentiment.negative).length,
    );
  }
}
