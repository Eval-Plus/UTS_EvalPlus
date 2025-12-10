import 'package:flutter/material.dart';

/// Modelo único para Question - Unifica data y API response
class QuestionModel {
  final int id;
  final int templateId;
  final String categoria;
  final String aspecto;
  final int nroPregunta;
  final String enunciado;
  final String tipoRespuesta;
  final int valorMinimo;
  final int valorMaximo;
  final bool esObligatoria;
  final int orden;
  final bool activo;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.templateId,
    required this.categoria,
    required this.aspecto,
    required this.nroPregunta,
    required this.enunciado,
    required this.tipoRespuesta,
    required this.valorMinimo,
    required this.valorMaximo,
    required this.esObligatoria,
    required this.orden,
    required this.activo,
    required this.createdAt,
  });

  // ==================== FACTORY CONSTRUCTORS ====================
  
  /// Crear desde respuesta del API
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      templateId: json['templateId'] as int? ?? 0,
      categoria: json['categoria'] as String,
      aspecto: json['aspecto'] as String,
      nroPregunta: json['nroPregunta'] as int,
      enunciado: json['enunciado'] as String,
      tipoRespuesta: json['tipoRespuesta'] as String? ?? 'escala',
      valorMinimo: json['valorMinimo'] as int? ?? 1,
      valorMaximo: json['valorMaximo'] as int? ?? 5,
      esObligatoria: json['esObligatoria'] as bool? ?? true,
      orden: json['orden'] as int? ?? 0,
      activo: json['activo'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // ==================== COMPUTED PROPERTIES ====================
  
  /// Obtiene el color del aspecto para UI
  Color get aspectColor {
    switch (aspecto.toLowerCase()) {
      case 'ético - social':
      case 'etico - social':
        return const Color(0xFF4CAF50); // Verde
      case 'formativo':
        return const Color(0xFF2196F3); // Azul
      case 'destrezas para desarrollar el proceso de enseñanza y aprendizaje':
        return const Color(0xFFFF9800); // Naranja
      case 'comunicación':
      case 'comunicacion':
        return const Color(0xFF9C27B0); // Púrpura
      default:
        return const Color(0xFFCAD225); // Verde lima (default)
    }
  }

  // ==================== SERIALIZATION ====================
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'categoria': categoria,
      'aspecto': aspecto,
      'nroPregunta': nroPregunta,
      'enunciado': enunciado,
      'tipoRespuesta': tipoRespuesta,
      'valorMinimo': valorMinimo,
      'valorMaximo': valorMaximo,
      'esObligatoria': esObligatoria,
      'orden': orden,
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ==================== UTILITY ====================
  
  @override
  String toString() => 'QuestionModel(id: $id, nroPregunta: $nroPregunta, categoria: $categoria)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
