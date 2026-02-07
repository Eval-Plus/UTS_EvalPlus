/// Servicio Singleton para reportes de docentes con caché
/// Ubicación: lib/services/admin/teacher_report_service.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/services/api/teacher_report_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';

class TeacherReportService extends ChangeNotifier {
  // Singleton
  static final TeacherReportService _instance = TeacherReportService._internal();
  factory TeacherReportService() => _instance;
  TeacherReportService._internal();

  // ==================== CACHÉ ====================
  
  final Map<String, TeacherResponsesReport> _responsesCache = {};
  final Map<String, List<CommentReport>> _commentsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  static const Duration _cacheDuration = Duration(minutes: 5);

  // ==================== ESTADO ====================
  
  bool _isLoadingResponses = false;
  bool _isLoadingComments = false;
  String? _responsesError;
  String? _commentsError;

  // ==================== GETTERS ====================

  bool get isLoadingResponses => _isLoadingResponses;
  bool get isLoadingComments => _isLoadingComments;
  String? get responsesError => _responsesError;
  String? get commentsError => _commentsError;

  // ==================== MÉTODOS PÚBLICOS - RESPUESTAS ====================

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
    final cacheKey = _buildResponsesCacheKey(teacherId, periodo);

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

  // ==================== MÉTODOS PÚBLICOS - COMENTARIOS ====================

  /// Obtiene todos los comentarios anónimos de un docente
  /// 
  /// [teacherId] - ID del docente
  /// [periodo] - Período académico (opcional)
  /// [forceRefresh] - Fuerza recarga desde el servidor
  Future<List<CommentReport>> getTeacherComments({
    required int teacherId,
    String? periodo,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCommentsCacheKey(teacherId, periodo);

    // Verificar caché si no se fuerza refresh
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('⚡ Usando caché de comentarios del docente $teacherId');
      return _commentsCache[cacheKey] ?? [];
    }

    _isLoadingComments = true;
    _commentsError = null;
    notifyListeners();

    try {
      final token = await AuthStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      }

      debugPrint('💬 Cargando comentarios desde API...');
      
      final comments = await TeacherReportApiService.getTeacherComments(
        token: token,
        teacherId: teacherId,
        periodo: periodo,
      );

      // Guardar en caché
      _commentsCache[cacheKey] = comments;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      _isLoadingComments = false;
      _commentsError = null;
      
      debugPrint('✅ Comentarios cargados y cacheados: ${comments.length}');
      notifyListeners();

      return comments;
    } catch (e) {
      debugPrint('💥 Error cargando comentarios: $e');
      
      _isLoadingComments = false;
      _commentsError = e.toString();
      notifyListeners();

      return [];
    }
  }

  // ==================== GESTIÓN DE CACHÉ ====================

  /// Verifica si el caché es válido
  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamps.containsKey(cacheKey)) {
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

  /// Construye la clave de caché para respuestas
  String _buildResponsesCacheKey(int teacherId, String periodo) {
    return 'responses_${teacherId}_$periodo';
  }

  /// Construye la clave de caché para comentarios
  String _buildCommentsCacheKey(int teacherId, String? periodo) {
    return 'comments_${teacherId}_${periodo ?? 'all'}';
  }

  /// Invalida el caché de respuestas de un docente específico
  void invalidateResponsesCache(int teacherId, String periodo) {
    final cacheKey = _buildResponsesCacheKey(teacherId, periodo);
    _responsesCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    debugPrint('❌ Caché de respuestas invalidado para docente $teacherId');
    notifyListeners();
  }

  /// Invalida el caché de comentarios de un docente específico
  void invalidateCommentsCache(int teacherId, String? periodo) {
    final cacheKey = _buildCommentsCacheKey(teacherId, periodo);
    _commentsCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    debugPrint('❌ Caché de comentarios invalidado para docente $teacherId');
    notifyListeners();
  }

  /// Invalida todo el caché de un docente
  void invalidateTeacherCache(int teacherId, String periodo) {
    invalidateResponsesCache(teacherId, periodo);
    invalidateCommentsCache(teacherId, periodo);
    invalidateCommentsCache(teacherId, null); // También invalidar "todos"
    debugPrint('❌ Todo el caché invalidado para docente $teacherId');
  }

  /// Limpia todo el caché
  void clearAllCache() {
    _responsesCache.clear();
    _commentsCache.clear();
    _cacheTimestamps.clear();
    debugPrint('🗑️ Todo el caché de reportes limpiado');
    notifyListeners();
  }

  /// Limpia el estado de error de respuestas
  void clearResponsesError() {
    _responsesError = null;
    notifyListeners();
  }

  /// Limpia el estado de error de comentarios
  void clearCommentsError() {
    _commentsError = null;
    notifyListeners();
  }

  /// Limpia todos los errores
  void clearAllErrors() {
    _responsesError = null;
    _commentsError = null;
    notifyListeners();
  }

  // ==================== MÉTODOS FUTUROS ====================
  
  // Future<SubjectsReport?> getSubjectsReport({...}) async { }
  // Future<AIAnalysisReport?> getAIAnalysisReport({...}) async { }
}