import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';

/// Excepción personalizada para evaluación ya completada
class EvaluationAlreadyCompletedException implements Exception {
  final String message;
  EvaluationAlreadyCompletedException(this.message);
  
  @override
  String toString() => message;
}

/// Respuesta del endpoint /start
class StartEvaluationResponse {
  final int id;
  final int evaluationId;
  final int studentId;
  final bool completada;
  final DateTime fechaInicio;
  final EvaluationDetails? evaluation; // ← Ahora es opcional

  StartEvaluationResponse({
    required this.id,
    required this.evaluationId,
    required this.studentId,
    required this.completada,
    required this.fechaInicio,
    this.evaluation, // ← Opcional
  });

  factory StartEvaluationResponse.fromJson(Map<String, dynamic> json) {
    return StartEvaluationResponse(
      id: json['id'] as int,
      evaluationId: json['evaluationId'] as int,
      studentId: json['studentId'] as int,
      completada: json['completada'] as bool,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      // Manejar cuando evaluation es null
      evaluation: json['evaluation'] != null 
          ? EvaluationDetails.fromJson(json['evaluation'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Detalles de la evaluación
class EvaluationDetails {
  final SubjectInfo subject;
  final TeacherInfo teacher;

  EvaluationDetails({
    required this.subject,
    required this.teacher,
  });

  factory EvaluationDetails.fromJson(Map<String, dynamic> json) {
    return EvaluationDetails(
      subject: SubjectInfo.fromJson(json['subject']),
      teacher: TeacherInfo.fromJson(json['teacher']),
    );
  }
}

class SubjectInfo {
  final String nombre;
  final String codigo;

  SubjectInfo({required this.nombre, required this.codigo});

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
    );
  }
}

class TeacherInfo {
  final String nombreCompleto;

  TeacherInfo({required this.nombreCompleto});

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      nombreCompleto: json['nombreCompleto'] as String,
    );
  }
}

/// Servicio para manejar evaluaciones de estudiantes
class StudentEvaluationApiService {
  /// Inicia una evaluación para el estudiante
  /// POST /api/student-evaluations/start
  static Future<StartEvaluationResponse?> startEvaluation({
    required String token,
    required int evaluationId,
  }) async {
    try {
      debugPrint('🚀 Iniciando evaluación ID: $evaluationId...');

      final uri = Uri.parse('${AppConstants.baseUrl}/student-evaluations/start');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'evaluationId': evaluationId,
        }),
      ).timeout(
        AppConstants.apiTimeout,
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📡 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final responseData = StartEvaluationResponse.fromJson(data['data']);
          debugPrint('✅ Evaluación iniciada: Student Evaluation ID = ${responseData.id}');
          return responseData;
        } else {
          debugPrint('❌ Respuesta sin datos válidos');
          return null;
        }
      } else if (response.statusCode == 403) {
        // El estudiante no puede responder esta evaluación
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'No tienes permiso para esta evaluación';
        debugPrint('🚫 Prohibido: $message');
        throw Exception(message);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Solicitud inválida';
        debugPrint('⚠️ Bad Request: $message');
        throw Exception(message);
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('💥 Error iniciando evaluación: $e');
      
      // Detectar si es evaluación ya completada
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('ya completaste') || 
          errorMessage.contains('already completed')) {
        throw EvaluationAlreadyCompletedException(
          'Ya completaste esta evaluación. No puedes modificar tus respuestas.'
        );
      }
      
      rethrow;
    }
  }

  /// Verifica si el estudiante puede continuar una evaluación
  /// GET /api/student-evaluations/:id/can-continue
  static Future<Map<String, dynamic>?> canContinueEvaluation({
    required String token,
    required int studentEvaluationId,
  }) async {
    try {
      debugPrint('🔍 Verificando continuidad de evaluación ID: $studentEvaluationId...');

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/student-evaluations/$studentEvaluationId/can-continue',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.apiTimeout);

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ Verificación exitosa');
          return data['data'] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      debugPrint('💥 Error verificando continuidad: $e');
      return null;
    }
  }

  /// Envía las respuestas de la evaluación
  /// POST /api/student-evaluations/:id/submit
  static Future<bool> submitEvaluation({
    required String token,
    required int studentEvaluationId,
    required List<Map<String, dynamic>> responses,
    String? comentario,
  }) async {
    try {
      debugPrint('📤 Enviando evaluación ID: $studentEvaluationId...');

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/student-evaluations/$studentEvaluationId/submit',
      );

      final body = {
        'responses': responses,
        if (comentario != null && comentario.isNotEmpty) 'comentario': comentario,
      };

      debugPrint('📦 Body: ${jsonEncode(body)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al enviar evaluación');
        },
      );

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📡 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Evaluación enviada exitosamente');
          return true;
        }
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Error de validación';
        debugPrint('⚠️ Bad Request: $message');
        throw Exception(message);
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'No autorizado';
        debugPrint('🚫 Prohibido: $message');
        throw Exception(message);
      } else if (response.statusCode == 409) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Evaluación ya completada';
        debugPrint('⚠️ Conflicto: $message');
        throw Exception(message);
      }

      throw Exception('Error al enviar evaluación');
    } catch (e) {
      debugPrint('💥 Error enviando evaluación: $e');
      rethrow;
    }
  }

  /// Guarda respuestas parciales (progreso)
  /// PUT /api/student-evaluations/:id/responses
  static Future<bool> savePartialResponses({
    required String token,
    required int studentEvaluationId,
    required List<Map<String, dynamic>> responses,
  }) async {
    try {
      debugPrint('💾 Guardando progreso de evaluación ID: $studentEvaluationId...');

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/student-evaluations/$studentEvaluationId/responses',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'responses': responses,
        }),
      ).timeout(AppConstants.apiTimeout);

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Progreso guardado');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('💥 Error guardando progreso: $e');
      return false;
    }
  }
}
