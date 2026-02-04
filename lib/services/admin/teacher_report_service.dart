/// Servicio Singleton para reportes de docentes con caché
/// Ubicación: lib/services/teacher_report_service.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/services/api/teacher_report_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';

class TeacherReportService extends ChangeNotifier {
  // Singleton
  static final TeacherReportService _instance = TeacherReportService._internal();
  factory TeacherReportService() => _instance;
  TeacherReportService._internal();

  // ==================== CACHÉ ====================
  
  final Map<String, TeacherResponsesReport> _responsesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  static const Duration _cacheDuration = Duration(minutes: 5);

  // ==================== ESTADO ====================
  
  bool _isLoadingResponses = false;
  String? _responsesError;

  // ==================== GETTERS ====================

  bool get isLoadingResponses => _isLoadingResponses;
  String? get responsesError => _responsesError;

  // ==================== MÉTODOS PÚBLICOS ====================

  /// Obtiene el reporte de respuestas de un docente
  /// 
  /// [teacherId] - ID del docente
  /// [periodo] - Período académico
  /// [forceRefresh] - Fuerza recarga desde el servidor
  Future<TeacherResponsesReport?> getResponsesReport({
    required int teacherId,
    required String periodo,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCacheKey(teacherId, periodo);

    // Verificar caché si no se fuerza refresh
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('⚡ Usando caché de respuestas del docente $teacherId');
      return _responsesCache[cacheKey];
    }

    _isLoadingResponses = true;
    _responsesError = null;
    notifyListeners();

    try {
      final token = await AuthStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      }

      debugPrint('📊 Cargando reporte de respuestas desde API...');
      
      final report = await TeacherReportApiService.getResponsesReport(
        token: token,
        teacherId: teacherId,
        periodo: periodo,
      );

      // Guardar en caché
      _responsesCache[cacheKey] = report;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      _isLoadingResponses = false;
      _responsesError = null;
      
      debugPrint('✅ Reporte de respuestas cargado y cacheado');
      notifyListeners();

      return report;
    } catch (e) {
      debugPrint('💥 Error cargando reporte de respuestas: $e');
      
      _isLoadingResponses = false;
      _responsesError = e.toString();
      notifyListeners();

      return null;
    }
  }

  // ==================== GESTIÓN DE CACHÉ ====================

  /// Verifica si el caché es válido
  bool _isCacheValid(String cacheKey) {
    if (!_responsesCache.containsKey(cacheKey) || 
        !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }

    final timestamp = _cacheTimestamps[cacheKey]!;
    final now = DateTime.now();
    
    if (now.difference(timestamp) > _cacheDuration) {
      debugPrint('⏰ Caché expirado para $cacheKey');
      return false;
    }

    return true;
  }

  /// Construye la clave de caché
  String _buildCacheKey(int teacherId, String periodo) {
    return 'responses_${teacherId}_$periodo';
  }

  /// Invalida el caché de un docente específico
  void invalidateCache(int teacherId, String periodo) {
    final cacheKey = _buildCacheKey(teacherId, periodo);
    _responsesCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    debugPrint('❌ Caché invalidado para docente $teacherId');
    notifyListeners();
  }

  /// Limpia todo el caché
  void clearAllCache() {
    _responsesCache.clear();
    _cacheTimestamps.clear();
    debugPrint('🗑️ Todo el caché de reportes limpiado');
    notifyListeners();
  }

  /// Limpia el estado de error
  void clearError() {
    _responsesError = null;
    notifyListeners();
  }

  // ==================== MÉTODOS FUTUROS ====================
  
  // Future<SubjectsReport?> getSubjectsReport({...}) async { }
  // Future<AIAnalysisReport?> getAIAnalysisReport({...}) async { }
  // Future<CommentsReport?> getCommentsReport({...}) async { }
}
