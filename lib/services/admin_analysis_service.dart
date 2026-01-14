// lib/services/admin_analysis_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';

class AdminAnalysisService {
  final Future<String?> Function() getToken;

  AdminAnalysisService({
    required this.getToken,
  });

  /// Headers comunes para todas las peticiones
  Future<Map<String, String>> _buildHeaders() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw UnauthorizedException(
        'Sesión expirada. Por favor inicia sesión nuevamente.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Obtener análisis de todos los docentes
  /// 
  /// [periodo] - Período académico (ej: '2025-1')
  /// [career] - Código de carrera (ej: 'ING-SIS', null o 'all' para todas)
  /// [sortBy] - Criterio de ordenamiento: 'name', 'evaluations', 'completion', 'activity'
  Future<TeachersAnalysisResponse> getTeachersAnalysis({
    String? periodo,
    String? career,
    String sortBy = 'name',
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};
      if (periodo != null && periodo.isNotEmpty) {
        queryParams['periodo'] = periodo;
      }
      if (career != null && career.isNotEmpty && career != 'all') {
        queryParams['career'] = career;
      }
      queryParams['sortBy'] = sortBy;

      // Construir URI
      final uri = Uri.parse('${AppConstants.baseUrl}/admin/analysis/teachers')
          .replace(queryParameters: queryParams);

      print('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: await _buildHeaders(),
      );

      // Manejar respuesta
      return _handleResponse<TeachersAnalysisResponse>(
        response,
        (data) => TeachersAnalysisResponse.fromJson(data),
      );
    } catch (e) {
      print('❌ Error en getTeachersAnalysis: $e');
      rethrow;
    }
  }

  /// Obtener análisis detallado de un docente específico
  /// 
  /// [teacherId] - ID del docente
  /// [periodo] - Período académico
  Future<TeacherDetailResponse> getTeacherDetail({
    required int teacherId,
    String? periodo,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};
      if (periodo != null && periodo.isNotEmpty) {
        queryParams['periodo'] = periodo;
      }

      // Construir URI
      final uri = Uri.parse('${AppConstants.baseUrl}/admin/analysis/teachers/$teacherId')
          .replace(queryParameters: queryParams);

      print('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: await _buildHeaders(),
      );

      // Manejar respuesta
      return _handleResponse<TeacherDetailResponse>(
        response,
        (data) => TeacherDetailResponse.fromJson(data),
      );
    } catch (e) {
      print('❌ Error en getTeacherDetail: $e');
      rethrow;
    }
  }

  /// Obtener estadísticas globales del análisis
  /// 
  /// [periodo] - Período académico
  /// [career] - Código de carrera
  Future<AnalysisStats> getAnalysisStats({
    String? periodo,
    String? career,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};
      if (periodo != null && periodo.isNotEmpty) {
        queryParams['periodo'] = periodo;
      }
      if (career != null && career.isNotEmpty && career != 'all') {
        queryParams['career'] = career;
      }

      // Construir URI
      final uri = Uri.parse('${AppConstants.baseUrl}/admin/analysis/stats')
          .replace(queryParameters: queryParams);

      print('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: await _buildHeaders(),
      );

      // Manejar respuesta
      return _handleResponse<AnalysisStats>(
        response,
        (data) => AnalysisStats.fromJson(data),
      );
    } catch (e) {
      print('❌ Error en getAnalysisStats: $e');
      rethrow;
    }
  }

  /// Método privado para manejar respuestas HTTP
  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) {
    print('📥 Status: ${response.statusCode}');

    // Decodificar JSON
    final Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Respuesta inválida del servidor');
    }

    // Manejar códigos de estado
    switch (response.statusCode) {
      case 200:
      case 201:
        final apiResponse = ApiResponse.fromJson(
          jsonResponse,
          (data) => fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception(apiResponse.message);
        }

      case 400:
        final message = jsonResponse['message'] as String? ?? 
                        'Petición inválida';
        throw BadRequestException(message);

      case 401:
        throw UnauthorizedException(
          'Sesión expirada. Por favor inicia sesión nuevamente.',
        );

      case 403:
        throw ForbiddenException(
          'No tienes permisos para acceder a esta información.',
        );

      case 404:
        final message = jsonResponse['message'] as String? ?? 
                        'Recurso no encontrado';
        throw NotFoundException(message);

      case 500:
        throw ServerException(
          'Error interno del servidor. Por favor intenta más tarde.',
        );

      default:
        throw Exception(
          'Error inesperado (${response.statusCode}): ${jsonResponse['message'] ?? 'Sin mensaje'}',
        );
    }
  }
}

// ==============================================
// EXCEPCIONES PERSONALIZADAS
// ==============================================

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
