import 'package:flutter/material.dart';

/// Modelo único para Subject - Unifica data y API response
class SubjectModel {
  final int id;
  final String nombre;
  final String codigo;
  final String careerCodigo;
  final String professorName;
  final int semestre;
  final int? evaluationId;
  final bool hasActiveEvaluation;
  final String? evaluationPeriod;
  final bool activo;

  SubjectModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.careerCodigo,
    required this.professorName,
    this.semestre = 1,
    this.evaluationId,
    this.hasActiveEvaluation = false,
    this.evaluationPeriod,
    this.activo = true,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Crear desde respuesta del API
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      careerCodigo: json['careerCodigo'] as String,
      professorName: json['professorName'] as String? ?? json['teacher'] as String? ?? 'Sin profesor',
      semestre: json['semestre'] as int? ?? 1,
      evaluationId: json['evaluationId'] as int?,
      hasActiveEvaluation: json['hasActiveEvaluation'] as bool? ?? false,
      evaluationPeriod: json['evaluationPeriod'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Verifica si tiene profesor asignado
  bool get hasTeacher =>
      professorName.trim().isNotEmpty &&
      professorName.toLowerCase() != 'sin profesor';

  /// Verifica si puede ser evaluada
  bool get canBeEvaluated => hasTeacher && evaluationId != null;

  /// Verifica si la evaluación ya fue completada (por ahora siempre false)
  bool get isEvaluationCompleted => false; // TODO: Implementar lógica real

  /// Texto del estado de evaluación
  String get evaluationStatusText {
    if (!hasTeacher) return 'Sin profesor asignado';
    if (evaluationId == null) return 'Sin evaluación activa';
    if (isEvaluationCompleted) return 'Evaluación completada';
    return 'Evaluación disponible';
  }

  /// Icono del estado de evaluación
  IconData get evaluationStatusIcon {
    if (!hasTeacher) return Icons.person_off;
    if (evaluationId == null) return Icons.assignment_outlined;
    if (isEvaluationCompleted) return Icons.check_circle;
    return Icons.assignment;
  }

  // ==================== SERIALIZATION ====================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'careerCodigo': careerCodigo,
      'professorName': professorName,
      'semestre': semestre,
      'evaluationId': evaluationId,
      'hasActiveEvaluation': hasActiveEvaluation,
      'evaluationPeriod': evaluationPeriod,
      'activo': activo,
    };
  }

  // ==================== UTILITY ====================

  @override
  String toString() => 'SubjectModel(id: $id, codigo: $codigo, nombre: $nombre)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Copia con modificaciones
  SubjectModel copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? careerCodigo,
    String? professorName,
    int? semestre,
    int? evaluationId,
    bool? hasActiveEvaluation,
    String? evaluationPeriod,
    bool? activo,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      careerCodigo: careerCodigo ?? this.careerCodigo,
      professorName: professorName ?? this.professorName,
      semestre: semestre ?? this.semestre,
      evaluationId: evaluationId ?? this.evaluationId,
      hasActiveEvaluation: hasActiveEvaluation ?? this.hasActiveEvaluation,
      evaluationPeriod: evaluationPeriod ?? this.evaluationPeriod,
      activo: activo ?? this.activo,
    );
  }
}
