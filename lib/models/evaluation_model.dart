import 'package:flutter/material.dart';

/// Modelo unificado para Evaluación - Reemplaza el EvaluationModel temporal
class EvaluationModel {
  final int evaluationId;
  final String teacherName;
  final String? teacherPhoto;
  final String subject;
  final String subjectCode;
  final String careerName;
  final String period;
  final DateTime? fechaInicio;
  final DateTime? fechaCierre;
  final bool isCompleted;
  final DateTime? completedDate;

  EvaluationModel({
    required this.evaluationId,
    required this.teacherName,
    this.teacherPhoto,
    required this.subject,
    required this.subjectCode,
    required this.careerName,
    required this.period,
    this.fechaInicio,
    this.fechaCierre,
    required this.isCompleted,
    this.completedDate,
  });

  // ==================== FACTORY CONSTRUCTORS ====================
  
  /// Crear desde respuesta del API
  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      evaluationId: json['evaluationId'] as int,
      teacherName: json['teacherName'] as String,
      teacherPhoto: json['teacherPhoto'] as String?,
      subject: json['subject'] as String,
      subjectCode: json['subjectCode'] as String,
      careerName: json['careerName'] as String,
      period: json['period'] as String,
      fechaInicio: json['fechaInicio'] != null 
          ? DateTime.parse(json['fechaInicio'] as String)
          : null,
      fechaCierre: json['fechaCierre'] != null
          ? DateTime.parse(json['fechaCierre'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================
  
  /// Verifica si la evaluación está activa (dentro del periodo)
  bool get isActive {
    if (isCompleted) return false;
    if (fechaInicio == null || fechaCierre == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(fechaInicio!) && now.isBefore(fechaCierre!);
  }

  /// Verifica si la evaluación ya cerró
  bool get isClosed {
    if (fechaCierre == null) return false;
    return DateTime.now().isAfter(fechaCierre!);
  }

  /// Verifica si la evaluación aún no ha iniciado
  bool get isUpcoming {
    if (fechaInicio == null) return false;
    return DateTime.now().isBefore(fechaInicio!);
  }

  /// Días restantes para completar (null si ya completada o cerrada)
  int? get daysRemaining {
    if (isCompleted || fechaCierre == null) return null;
    
    final now = DateTime.now();
    if (now.isAfter(fechaCierre!)) return 0;
    
    return fechaCierre!.difference(now).inDays;
  }

  /// Color del estado de la evaluación
  Color get statusColor {
    if (isCompleted) return Colors.green.shade700;
    if (isClosed) return Colors.red.shade700;
    if (daysRemaining != null && daysRemaining! <= 3) {
      return Colors.orange.shade700;
    }
    return Colors.blue.shade700;
  }

  /// Texto del estado de la evaluación
  String get statusText {
    if (isCompleted) return 'Completada';
    if (isClosed) return 'Cerrada';
    if (isUpcoming) return 'Próximamente';
    if (daysRemaining != null && daysRemaining! <= 3) {
      return 'Urgente (${daysRemaining}d)';
    }
    return 'Pendiente';
  }

  /// Icono del estado
  IconData get statusIcon {
    if (isCompleted) return Icons.check_circle;
    if (isClosed) return Icons.cancel;
    if (daysRemaining != null && daysRemaining! <= 3) {
      return Icons.warning;
    }
    return Icons.pending;
  }

  // ==================== SERIALIZATION ====================
  
  Map<String, dynamic> toJson() {
    return {
      'evaluationId': evaluationId,
      'teacherName': teacherName,
      'teacherPhoto': teacherPhoto,
      'subject': subject,
      'subjectCode': subjectCode,
      'careerName': careerName,
      'period': period,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  // ==================== UTILITY ====================
  
  @override
  String toString() => 
    'EvaluationModel(id: $evaluationId, subject: $subject, teacher: $teacherName)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationModel &&
          runtimeType == other.runtimeType &&
          evaluationId == other.evaluationId;

  @override
  int get hashCode => evaluationId.hashCode;

  /// Copia con modificaciones
  EvaluationModel copyWith({
    int? evaluationId,
    String? teacherName,
    String? teacherPhoto,
    String? subject,
    String? subjectCode,
    String? careerName,
    String? period,
    DateTime? fechaInicio,
    DateTime? fechaCierre,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return EvaluationModel(
      evaluationId: evaluationId ?? this.evaluationId,
      teacherName: teacherName ?? this.teacherName,
      teacherPhoto: teacherPhoto ?? this.teacherPhoto,
      subject: subject ?? this.subject,
      subjectCode: subjectCode ?? this.subjectCode,
      careerName: careerName ?? this.careerName,
      period: period ?? this.period,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}
