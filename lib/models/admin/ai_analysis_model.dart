/// Modelo para el análisis de IA generado por el backend
/// Ubicación: lib/models/admin/ai_analysis_model.dart
library;

// ==============================================
// MODELO PRINCIPAL DE ANÁLISIS DE IA
// ==============================================

class AIAnalysisModel {
  final int id;
  final int teacherId;
  final String periodo;

  // Contenido del análisis
  final String profile;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> recommendations;

  // Metadata
  final DateTime analysisDate;
  final String modelVersion;
  final int evaluationsCount;
  final int responsesCount;
  final double averageScore;

  final DateTime createdAt;
  final DateTime updatedAt;

  const AIAnalysisModel({
    required this.id,
    required this.teacherId,
    required this.periodo,
    required this.profile,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
    required this.analysisDate,
    required this.modelVersion,
    required this.evaluationsCount,
    required this.responsesCount,
    required this.averageScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AIAnalysisModel(
      id: json['id'] as int,
      teacherId: json['teacherId'] as int,
      periodo: json['periodo'] as String,
      profile: json['profile'] as String,
      strengths: _parseStringList(json['strengths']),
      improvements: _parseStringList(json['improvements']),
      recommendations: _parseStringList(json['recommendations']),
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      modelVersion: json['modelVersion'] as String? ?? '',
      evaluationsCount: json['evaluationsCount'] as int,
      responsesCount: json['responsesCount'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Parsea campos JSON que pueden ser List<dynamic> o ya List<String>
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}