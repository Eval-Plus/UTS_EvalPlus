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
  
  /// Crear desde respuesta del API
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

  /// Convierte el string de status a enum
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
  
  /// Calcula el porcentaje de completitud
  double get completionPercentage {
    if (totalStudents == 0) return 0.0;
    return (completedEvaluations / totalStudents) * 100;
  }

  /// Color del progreso según porcentaje
  Color get progressColor {
    final percentage = completionPercentage;
    if (percentage >= 75) return Colors.green.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// Días restantes hasta el cierre
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
