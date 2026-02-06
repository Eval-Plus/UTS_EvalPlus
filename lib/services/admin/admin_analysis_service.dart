// lib/services/admin_analysis_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

class AdminAnalysisService extends ChangeNotifier {
  // ==================== SINGLETON ====================
  
  static final AdminAnalysisService _instance = AdminAnalysisService._internal();
  factory AdminAnalysisService() => _instance;
  AdminAnalysisService._internal();

  // ==================== CACHÉ ====================
  
  TeachersAnalysisResponse? _cachedTeachers;
  AnalysisStats? _cachedStats;
  DateTime? _lastFetchTime;
  String? _cachedPeriodo;
  String? _cachedCareer;
  String? _cachedSortBy;
  
  static const Duration _cacheDuration = Duration(minutes: 5);

  // ==================== HELPERS DE CACHÉ ====================

  /// Verifica si el caché es válido
  bool _isCacheValid({
    String? periodo,
    String? career,
    String? sortBy,
  }) {
    if (_cachedTeachers == null || _cachedStats == null || _lastFetchTime == null) {
      return false;
    }

    // Verificar expiración
    final now = DateTime.now();
    if (now.difference(_lastFetchTime!) > _cacheDuration) {
      debugPrint('⏰ Caché expirado');
      return false;
    }

    // Verificar que los parámetros coincidan
    if (_cachedPeriodo != periodo ||
        _cachedCareer != career ||
        _cachedSortBy != sortBy) {
      debugPrint('🔄 Parámetros diferentes, caché inválido');
      return false;
    }

    return true;
  }

  /// Limpia el caché
  void clearCache() {
    _cachedTeachers = null;
    _cachedStats = null;
    _lastFetchTime = null;
    _cachedPeriodo = null;
    _cachedCareer = null;
    _cachedSortBy = null;
    debugPrint('🗑️ Caché de análisis limpiado');
    notifyListeners();
  }

  /// Invalida el caché (para forzar recarga)
  void invalidateCache() {
    _lastFetchTime = null;
    debugPrint('❌ Caché invalidado');
  }

  // ==================== HEADERS ====================

  /// Headers comunes para todas las peticiones
  Future<Map<String, String>> _buildHeaders() async {
    final token = await AuthStorageService.getToken();

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

  // ==================== ENDPOINTS ====================

  /// Obtener análisis de todos los docentes
  /// 
  /// [periodo] - Período académico (ej: '2025-1')
  /// [career] - Código de carrera (ej: 'ING-SIS', null o 'all' para todas)
  /// [sortBy] - Criterio de ordenamiento: 'name', 'evaluations', 'completion', 'activity'
  /// [forceRefresh] - Fuerza recarga desde el servidor
  Future<TeachersAnalysisResponse> getTeachersAnalysis({
    String? periodo,
    String? career,
    String sortBy = 'name',
    bool forceRefresh = false,
  }) async {
    // Verificar caché si no se fuerza refresh
    if (!forceRefresh && _isCacheValid(periodo: periodo, career: career, sortBy: sortBy)) {
      debugPrint('⚡ Usando caché de teachers');
      return _cachedTeachers!;
    }

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

      debugPrint('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: await _buildHeaders(),
      );

      // Manejar respuesta
      final result = _handleResponse<TeachersAnalysisResponse>(
        response,
        (data) => TeachersAnalysisResponse.fromJson(data),
      );

      // Guardar en caché
      _cachedTeachers = result;
      _cachedPeriodo = periodo;
      _cachedCareer = career;
      _cachedSortBy = sortBy;
      _lastFetchTime = DateTime.now();
      
      debugPrint('💾 Datos guardados en caché');
      notifyListeners();

      return result;
    } catch (e) {
      debugPrint('❌ Error en getTeachersAnalysis: $e');
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

      debugPrint('📡 GET $uri');

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
      debugPrint('❌ Error en getTeacherDetail: $e');
      rethrow;
    }
  }

  /// Obtener estadísticas globales del análisis
  /// 
  /// [periodo] - Período académico
  /// [career] - Código de carrera
  /// [forceRefresh] - Fuerza recarga desde el servidor
  Future<AnalysisStats> getAnalysisStats({
    String? periodo,
    String? career,
    bool forceRefresh = false,
  }) async {
    // Verificar caché si no se fuerza refresh
    if (!forceRefresh && _isCacheValid(periodo: periodo, career: career)) {
      debugPrint('⚡ Usando caché de stats');
      return _cachedStats!;
    }

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

      debugPrint('📡 GET $uri');

      // Hacer petición
      final response = await http.get(
        uri,
        headers: await _buildHeaders(),
      );

      // Manejar respuesta
      final result = _handleResponse<AnalysisStats>(
        response,
        (data) => AnalysisStats.fromJson(data),
      );

      // Guardar en caché
      _cachedStats = result;
      _lastFetchTime = DateTime.now();
      
      debugPrint('💾 Stats guardadas en caché');
      notifyListeners();

      return result;
    } catch (e) {
      debugPrint('❌ Error en getAnalysisStats: $e');
      rethrow;
    }
  }

  // ==================== MANEJO DE RESPUESTAS ====================

  /// Método privado para manejar respuestas HTTP
  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) {
    debugPrint('📥 Status: ${response.statusCode}');

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
