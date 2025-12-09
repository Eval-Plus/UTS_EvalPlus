import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';

/// Respuesta del API para una materia
class SubjectApiResponse {
  final int id;
  final String nombre;
  final String codigo;
  final int semestre;
  final bool activo;
  final String teacher;
  final int? evaluationId;
  final bool hasActiveEvaluation;
  final String? evaluationPeriod;

  SubjectApiResponse({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.semestre,
    required this.activo,
    required this.teacher,
    this.evaluationId,
    this.hasActiveEvaluation = false,
    this.evaluationPeriod,
  });

  factory SubjectApiResponse.fromJson(Map<String, dynamic> json) {
    return SubjectApiResponse(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      semestre: json['semestre'] as int,
      activo: json['activo'] as bool? ?? true,
      teacher: json['teacher'] as String,
      evaluationId: json['evaluationId'] as int?,
      hasActiveEvaluation: json['hasActiveEvaluation'] as bool? ?? false,
      evaluationPeriod: json['evaluationPeriod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'semestre': semestre,
      'activo': activo,
      'teacher': teacher,
      'evaluationId': evaluationId,
      'hasActiveEvaluation': hasActiveEvaluation,
      'evaluationPeriod': evaluationPeriod,
    };
  }
}

/// Respuesta completa del endpoint /subjects/my
class SubjectsCareerResponse {
  final CareerInfo career;
  final List<SubjectApiResponse> subjects;
  final int total;

  SubjectsCareerResponse({
    required this.career,
    required this.subjects,
    required this.total,
  });

  factory SubjectsCareerResponse.fromJson(Map<String, dynamic> json) {
    return SubjectsCareerResponse(
      career: CareerInfo.fromJson(json['career']),
      subjects: (json['subjects'] as List)
          .map((subject) => SubjectApiResponse.fromJson(subject))
          .toList(),
      total: json['total'] as int,
    );
  }
}

/// Información de la carrera (viene en la respuesta)
class CareerInfo {
  final int id;
  final String nombre;
  final String codigo;
  final String icon;
  final String color;

  CareerInfo({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.icon,
    required this.color,
  });

  factory CareerInfo.fromJson(Map<String, dynamic> json) {
    return CareerInfo(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}

/// Servicio para manejar el endpoint de materias
class SubjectsApiService {
  /// Obtiene las materias del usuario filtradas por carrera
  static Future<SubjectsCareerResponse?> fetchSubjectsByCareer({
    required String token,
    required int careerId,
  }) async {
    try {
      debugPrint('🔍 Consultando materias para carrera ID: $careerId...');

      final uri = Uri.parse('${AppConstants.baseUrl}/subjects/my').replace(
        queryParameters: {'careerId': careerId.toString()},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        AppConstants.apiTimeout,
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final responseData = SubjectsCareerResponse.fromJson(data['data']);
          
          debugPrint('✅ Materias obtenidas: ${responseData.total}');
          return responseData;
        } else {
          debugPrint('❌ Respuesta sin datos válidos');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron materias para esta carrera');
        // Retornar una respuesta vacía en lugar de null
        return null;
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo materias: $e');
      return null;
    }
  }
}
