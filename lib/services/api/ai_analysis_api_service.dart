/// Servicio API para análisis de IA de docentes
/// Ubicación: lib/services/api/ai_analysis_api_service.dart
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/admin/ai_analysis_model.dart';

class AIAnalysisApiService {
  // Timeout extendido: la IA puede tardar hasta 90 segundos en responder
  static const Duration _aiTimeout = Duration(seconds: 90);
  static const Duration _defaultTimeout = Duration(seconds: 15);

  // ─────────────────────────────────────────
  // GET — Obtener análisis existente
  // ─────────────────────────────────────────

  /// Obtiene el análisis de IA existente de un docente en un período.
  /// Retorna null si no existe análisis (404).
  /// Lanza excepción en cualquier otro error.
  static Future<AIAnalysisModel?> getAnalysis({
    required String token,
    required int teacherId,
    required String periodo,
  }) async {
    try {
      debugPrint('🤖 [AIAnalysisAPI] Obteniendo análisis IA...');
      debugPrint('   - Docente ID: $teacherId | Período: $periodo');

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/admin/ai-analysis/teachers/$teacherId',
      ).replace(queryParameters: {'periodo': periodo});

      debugPrint('📡 GET $uri');

      final response = await http.get(
        uri,
        headers: _buildHeaders(token),
      ).timeout(_defaultTimeout, onTimeout: () {
        throw Exception('Tiempo de espera agotado');
      });

      debugPrint('📥 Status: ${response.statusCode}');

      // Sin análisis — no es un error, es empty state
      if (response.statusCode == 404) {
        debugPrint('ℹ️ [AIAnalysisAPI] No existe análisis para este período');
        return null;
      }

      final jsonResponse = _decodeResponse(response.body);

      if (response.statusCode == 200) {
        final apiResponse = jsonResponse;
        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          final analysis = AIAnalysisModel.fromJson(
            apiResponse['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ [AIAnalysisAPI] Análisis existente obtenido');
          return analysis;
        }
        throw Exception(apiResponse['message'] ?? 'Respuesta inesperada');
      }

      _handleErrorStatus(response.statusCode, jsonResponse);
      return null; // unreachable, _handleErrorStatus siempre lanza
    } catch (e) {
      debugPrint('💥 [AIAnalysisAPI] Error obteniendo análisis: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // POST — Generar análisis
  // ─────────────────────────────────────────

  /// Genera (o regenera) el análisis de IA para un docente.
  /// Este endpoint puede tardar hasta 90 segundos (LLM en HuggingFace).
  static Future<AIAnalysisModel> generateAnalysis({
    required String token,
    required int teacherId,
    required String periodo,
    required String teacherName,
  }) async {
    try {
      debugPrint('🚀 [AIAnalysisAPI] Generando análisis IA...');
      debugPrint('   - Docente: $teacherName (ID: $teacherId)');
      debugPrint('   - Período: $periodo');

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/admin/ai-analysis/teachers/$teacherId/generate',
      );

      debugPrint('📡 POST $uri');

      final response = await http.post(
        uri,
        headers: _buildHeaders(token),
        body: json.encode({
          'periodo': periodo,
          'teacherName': teacherName,
        }),
      ).timeout(_aiTimeout, onTimeout: () {
        throw Exception(
          'La IA tardó demasiado. Por favor intenta nuevamente.',
        );
      });

      debugPrint('📥 Status: ${response.statusCode}');

      final jsonResponse = _decodeResponse(response.body);

      if (response.statusCode == 200) {
        final apiResponse = jsonResponse;
        if (apiResponse['success'] == true && apiResponse['data'] != null) {
          final analysis = AIAnalysisModel.fromJson(
            apiResponse['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ [AIAnalysisAPI] Análisis generado exitosamente');
          return analysis;
        }
        throw Exception(apiResponse['message'] ?? 'Respuesta inesperada');
      }

      // Error de datos insuficientes — backend retorna 400
      if (response.statusCode == 400) {
        final message = jsonResponse['message'] as String? ??
            'El docente no tiene suficientes datos para generar un análisis';
        throw Exception(message);
      }

      _handleErrorStatus(response.statusCode, jsonResponse);
      throw Exception('Error inesperado'); // unreachable
    } catch (e) {
      debugPrint('💥 [AIAnalysisAPI] Error generando análisis: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  static Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Respuesta inválida del servidor');
    }
  }

  static void _handleErrorStatus(
    int statusCode,
    Map<String, dynamic> jsonResponse,
  ) {
    final message = jsonResponse['message'] as String? ?? 'Error desconocido';
    switch (statusCode) {
      case 401:
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      case 403:
        throw Exception('No tienes permisos para acceder a esta información.');
      case 500:
        throw Exception('Error del servidor. Intenta nuevamente más tarde.');
      default:
        throw Exception('Error ($statusCode): $message');
    }
  }
}