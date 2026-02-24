/// Servicio Singleton para análisis de IA de docentes con caché
/// Ubicación: lib/services/admin/ai_analysis_service.dart
library;

import 'package:flutter/foundation.dart';
import 'package:eval_plus/services/api/ai_analysis_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/models/admin/ai_analysis_model.dart';

// ─────────────────────────────────────────
// ESTADO DEL ANÁLISIS
// ─────────────────────────────────────────

enum AIAnalysisStatus {
  idle,       // Estado inicial, aún no se ha intentado cargar
  loading,    // Cargando análisis existente desde la API
  generating, // Generando nuevo análisis con IA
  loaded,     // Análisis cargado correctamente
  empty,      // No existe análisis para este período
  error,      // Error al cargar o generar
}

class AIAnalysisService extends ChangeNotifier {
  // Singleton
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  // ─────────────────────────────────────────
  // CACHÉ
  // ─────────────────────────────────────────

  final Map<String, AIAnalysisModel> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 10);

  // ─────────────────────────────────────────
  // ESTADO
  // ─────────────────────────────────────────

  AIAnalysisStatus _status = AIAnalysisStatus.idle;
  AIAnalysisModel? _currentAnalysis;
  String? _errorMessage;

  AIAnalysisStatus get status => _status;
  AIAnalysisModel? get currentAnalysis => _currentAnalysis;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AIAnalysisStatus.loading;
  bool get isGenerating => _status == AIAnalysisStatus.generating;
  bool get hasAnalysis => _status == AIAnalysisStatus.loaded && _currentAnalysis != null;
  bool get isEmpty => _status == AIAnalysisStatus.empty;
  bool get hasError => _status == AIAnalysisStatus.error;

  // ─────────────────────────────────────────
  // MÉTODOS PÚBLICOS
  // ─────────────────────────────────────────

  /// Carga el análisis existente de un docente en un período.
  /// Si no existe, pone el estado en [AIAnalysisStatus.empty].
  Future<void> loadAnalysis({
    required int teacherId,
    required String periodo,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCacheKey(teacherId, periodo);

    // Usar caché si está disponible y no se fuerza refresh
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('⚡ [AIAnalysisService] Usando caché para docente $teacherId');
      _currentAnalysis = _cache[cacheKey];
      _setStatus(AIAnalysisStatus.loaded);
      return;
    }

    _setStatus(AIAnalysisStatus.loading);

    try {
      final token = await _requireToken();

      final analysis = await AIAnalysisApiService.getAnalysis(
        token: token,
        teacherId: teacherId,
        periodo: periodo,
      );

      if (analysis != null) {
        _cache[cacheKey] = analysis;
        _cacheTimestamps[cacheKey] = DateTime.now();
        _currentAnalysis = analysis;
        _setStatus(AIAnalysisStatus.loaded);
        debugPrint('✅ [AIAnalysisService] Análisis cargado');
      } else {
        _currentAnalysis = null;
        _setStatus(AIAnalysisStatus.empty);
        debugPrint('ℹ️ [AIAnalysisService] Sin análisis — mostrando empty state');
      }
    } catch (e) {
      debugPrint('💥 [AIAnalysisService] Error cargando análisis: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AIAnalysisStatus.error);
    }
  }

  /// Genera (o regenera) el análisis de IA para un docente.
  /// Actualiza el estado a [AIAnalysisStatus.generating] durante el proceso.
  Future<void> generateAnalysis({
    required int teacherId,
    required String periodo,
    required String teacherName,
  }) async {
    _setStatus(AIAnalysisStatus.generating);

    try {
      final token = await _requireToken();

      final analysis = await AIAnalysisApiService.generateAnalysis(
        token: token,
        teacherId: teacherId,
        periodo: periodo,
        teacherName: teacherName,
      );

      // Actualizar caché con el nuevo análisis
      final cacheKey = _buildCacheKey(teacherId, periodo);
      _cache[cacheKey] = analysis;
      _cacheTimestamps[cacheKey] = DateTime.now();

      _currentAnalysis = analysis;
      _setStatus(AIAnalysisStatus.loaded);
      debugPrint('✅ [AIAnalysisService] Análisis generado y guardado en caché');
    } catch (e) {
      debugPrint('💥 [AIAnalysisService] Error generando análisis: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      // Volver a empty en lugar de error para que el botón de generar siga visible
      _setStatus(AIAnalysisStatus.empty);
    }
  }

  /// Invalida el caché de un docente y resetea el estado
  void invalidateCache(int teacherId, String periodo) {
    final cacheKey = _buildCacheKey(teacherId, periodo);
    _cache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    _currentAnalysis = null;
    _status = AIAnalysisStatus.idle;
    debugPrint('❌ [AIAnalysisService] Caché invalidado para docente $teacherId');
    notifyListeners();
  }

  /// Resetea completamente el estado (útil al cerrar el modal)
  void reset() {
    _status = AIAnalysisStatus.idle;
    _currentAnalysis = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // HELPERS PRIVADOS
  // ─────────────────────────────────────────

  void _setStatus(AIAnalysisStatus status) {
    _status = status;
    if (status != AIAnalysisStatus.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  String _buildCacheKey(int teacherId, String periodo) {
    return 'ai_analysis_${teacherId}_$periodo';
  }

  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamps.containsKey(cacheKey)) return false;
    return DateTime.now().difference(_cacheTimestamps[cacheKey]!) < _cacheDuration;
  }

  Future<String> _requireToken() async {
    final token = await AuthStorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
    }
    return token;
  }
}