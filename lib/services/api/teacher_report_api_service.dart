/// Servicio API para reportes de docentes
/// Ubicación: lib/services/api/teacher_report_api_service.dart
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';

/// Respuesta genérica de la API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : null,
      timestamp: json['timestamp'] as String,
    );
  }
}

/// Servicio para consumir endpoints de reportes de docentes
class TeacherReportApiService {
  
  /// Obtiene el reporte de respuestas de un docente
  /// 
  /// [token] - Token de autenticación
  /// [teacherId] - ID del docente
  /// [periodo] - Período académico (ej: '2025-1')
  static Future<TeacherResponsesReport> getResponsesReport({
    required String token,
    required int teacherId,
    required String periodo,
  }) async {
    try {
      debugPrint('📊 Obteniendo reporte de respuestas...');
      debugPrint('   - Docente ID: $teacherId');
      debugPrint('   - Período: $periodo');

      // Construir URI
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/admin/reports/teachers/$teacherId/responses',
      ).replace(queryParameters: {
        'periodo': periodo,
      });

      debugPrint('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');

      // Decodificar JSON
      final Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Respuesta inválida del servidor');
      }

      // Manejar códigos de estado
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => TeacherResponsesReport.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          debugPrint('✅ Reporte obtenido exitosamente');
          debugPrint('   - Promedio: ${apiResponse.data!.averageScore}');
          debugPrint('   - Preguntas: ${apiResponse.data!.questions.length}');
          return apiResponse.data!;
        } else {
          throw Exception(apiResponse.message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para acceder a esta información.');
      } else if (response.statusCode == 404) {
        final message = jsonResponse['message'] as String? ?? 'Docente no encontrado';
        throw Exception(message);
      } else {
        throw Exception(
          'Error del servidor (${response.statusCode}): ${jsonResponse['message'] ?? 'Sin mensaje'}',
        );
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo reporte de respuestas: $e');
      rethrow;
    }
  }

  /// Obtiene todos los comentarios anónimos de un docente
  /// 
  /// [token] - Token de autenticación
  /// [teacherId] - ID del docente
  /// [periodo] - Período académico (ej: '2025-1', opcional)
  static Future<List<CommentReport>> getTeacherComments({
    required String token,
    required int teacherId,
    String? periodo,
  }) async {
    try {
      debugPrint('💬 Obteniendo comentarios del docente...');
      debugPrint('   - Docente ID: $teacherId');
      debugPrint('   - Período: ${periodo ?? 'todos'}');

      // Construir URI
      final queryParams = <String, String>{};
      if (periodo != null && periodo.isNotEmpty) {
        queryParams['periodo'] = periodo;
      }

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/admin/reports/teachers/$teacherId/comments',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      debugPrint('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');

      // Decodificar JSON
      final Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Respuesta inválida del servidor');
      }

      // Manejar códigos de estado
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => data, // Retornamos la data directamente (es una lista)
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Convertir lista de JSON a lista de CommentReport
          final commentsList = apiResponse.data as List<dynamic>;
          final comments = commentsList
              .map((json) => CommentReport.fromJson(json as Map<String, dynamic>))
              .toList();

          debugPrint('✅ Comentarios obtenidos exitosamente');
          debugPrint('   - Total: ${comments.length}');
          return comments;
        } else {
          throw Exception(apiResponse.message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para acceder a esta información.');
      } else if (response.statusCode == 404) {
        final message = jsonResponse['message'] as String? ?? 'Docente no encontrado';
        throw Exception(message);
      } else {
        throw Exception(
          'Error del servidor (${response.statusCode}): ${jsonResponse['message'] ?? 'Sin mensaje'}',
        );
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo comentarios: $e');
      rethrow;
    }
  }

  // Aquí se agregarán más métodos para otros endpoints:
  // - getSubjectsReport()
  // - getAIAnalysisReport()
}