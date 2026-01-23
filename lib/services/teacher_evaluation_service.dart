import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/teacher/teacher_evaluation_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Servicio para manejar evaluaciones de profesores
class TeacherEvaluationsService {
  // ==================== SINGLETON ====================
  
  static final TeacherEvaluationsService _instance = 
      TeacherEvaluationsService._internal();
  factory TeacherEvaluationsService() => _instance;
  TeacherEvaluationsService._internal();

  // Cache en memoria para evaluaciones
  List<TeacherEvaluationModel>? _cachedEvaluations;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 2);

  // 🆕 Cache para comentarios por evaluación
  final Map<int, List<CommentModel>> _commentsCache = {};
  final Map<int, DateTime> _commentsFetchTime = {};

  // Listeners para notificar cambios
  final List<VoidCallback> _listeners = [];

  // ==================== LISTENER MANAGEMENT ====================
  
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      debugPrint('📢 [Teacher] Listener agregado. Total: ${_listeners.length}');
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    debugPrint('📢 [Teacher] Listener removido. Total: ${_listeners.length}');
  }

  void _notifyListeners() {
    debugPrint('📢 [Teacher] Notificando a ${_listeners.length} listeners...');
    for (final listener in _listeners) {
      listener();
    }
  }

  // ==================== PUBLIC API - EVALUACIONES ====================
  
  /// Obtiene todas las evaluaciones del profesor
  Future<Map<String, dynamic>> getMyEvaluations({
    bool forceRefresh = false,
  }) async {
    // Usar cache si es válido
    if (!forceRefresh && _isCacheValid()) {
      debugPrint('⚡ [Teacher] Usando cache de evaluaciones');
      return _buildResponse(_cachedEvaluations!);
    }

    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ [Teacher] No hay token disponible');
        throw Exception('Token no disponible');
      }

      debugPrint('🌐 [Teacher] Consultando API de evaluaciones...');
      final result = await _fetchFromApi(token);

      if (result != null) {
        _cachedEvaluations = result;
        _lastFetchTime = DateTime.now();
        debugPrint('✅ [Teacher] ${result.length} evaluaciones obtenidas');
        return _buildResponse(result);
      }

      throw Exception('No se pudieron obtener evaluaciones');
      
    } catch (e) {
      debugPrint('💥 [Teacher] Error obteniendo evaluaciones: $e');
      
      if (_cachedEvaluations != null) {
        debugPrint('📦 [Teacher] Usando cache como fallback');
        return _buildResponse(_cachedEvaluations!);
      }
      
      rethrow;
    }
  }

  void invalidateCache() {
    debugPrint('🗑️ [Teacher] Invalidando cache...');
    _cachedEvaluations = null;
    _lastFetchTime = null;
    _notifyListeners();
  }

  void clearCache() {
    _cachedEvaluations = null;
    _lastFetchTime = null;
    _commentsCache.clear();
    _commentsFetchTime.clear();
    _listeners.clear();
    debugPrint('🗑️ [Teacher] Cache y listeners limpiados');
  }

  // ==================== 🆕 PUBLIC API - COMENTARIOS ====================
  
  /// Obtiene comentarios anónimos de una evaluación
  /// 
  /// Endpoint: GET /api/student-evaluations/evaluation/:evaluationId/comments
  /// Respuesta: { comments: [...], total: number }
  Future<Map<String, dynamic>> getEvaluationComments({
    required int evaluationId,
    bool forceRefresh = false,
  }) async {
    // Verificar cache
    if (!forceRefresh && _isCommentsCacheValid(evaluationId)) {
      debugPrint('⚡ [Teacher] Usando cache de comentarios para evaluación $evaluationId');
      return _buildCommentsResponse(_commentsCache[evaluationId]!);
    }

    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ [Teacher] No hay token disponible');
        throw Exception('Token no disponible');
      }

      debugPrint('🌐 [Teacher] Consultando comentarios de evaluación $evaluationId...');
      final comments = await _fetchCommentsFromApi(token, evaluationId);

      // Guardar en cache
      _commentsCache[evaluationId] = comments;
      _commentsFetchTime[evaluationId] = DateTime.now();
      
      debugPrint('✅ [Teacher] ${comments.length} comentarios obtenidos');
      return _buildCommentsResponse(comments);
      
    } catch (e) {
      debugPrint('💥 [Teacher] Error obteniendo comentarios: $e');
      
      // Retornar cache si existe
      if (_commentsCache.containsKey(evaluationId)) {
        debugPrint('📦 [Teacher] Usando cache de comentarios como fallback');
        return _buildCommentsResponse(_commentsCache[evaluationId]!);
      }
      
      rethrow;
    }
  }

  /// Invalida cache de comentarios de una evaluación específica
  void invalidateCommentsCache(int evaluationId) {
    debugPrint('🗑️ [Teacher] Invalidando cache de comentarios para evaluación $evaluationId');
    _commentsCache.remove(evaluationId);
    _commentsFetchTime.remove(evaluationId);
  }

  // ==================== PRIVATE METHODS ====================
  
  bool _isCacheValid() {
    if (_cachedEvaluations == null || _lastFetchTime == null) {
      return false;
    }
    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  bool _isCommentsCacheValid(int evaluationId) {
    if (!_commentsCache.containsKey(evaluationId) || 
        !_commentsFetchTime.containsKey(evaluationId)) {
      return false;
    }
    final age = DateTime.now().difference(_commentsFetchTime[evaluationId]!);
    return age < _cacheDuration;
  }

  Future<List<TeacherEvaluationModel>?> _fetchFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/evaluations/my-evaluations'),
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

      debugPrint('📡 [Teacher] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final evaluationsList = (data['data'] as List)
              .map((json) => TeacherEvaluationModel.fromJson(json))
              .toList();
          
          return evaluationsList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ [Teacher] No se encontraron evaluaciones');
        return [];
      }

      return null;
    } catch (e) {
      debugPrint('💥 [Teacher] Error en _fetchFromApi: $e');
      return null;
    }
  }

  /// 🆕 Consulta comentarios desde el API
  Future<List<CommentModel>> _fetchCommentsFromApi(String token, int evaluationId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/student-evaluations/evaluation/$evaluationId/comments'),
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

      debugPrint('📡 [Teacher Comments] Status Code: ${response.statusCode}');
      debugPrint('📦 [Teacher Comments] Response Body: ${response.body}'); // 🔍 DEBUG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          // 🔍 Verificar la estructura de la respuesta
          final responseData = data['data'];
          
          debugPrint('🔍 [Teacher Comments] Tipo de data: ${responseData.runtimeType}');
          
          // El backend puede retornar:
          // 1. { comments: [...], total: number } ← Estructura esperada
          // 2. Directamente el array [...]
          
          List<dynamic> commentsData;
          
          if (responseData is Map<String, dynamic> && responseData.containsKey('comments')) {
            // Estructura con objeto { comments: [...] }
            commentsData = responseData['comments'] as List;
            debugPrint('📦 [Teacher Comments] Estructura: Objeto con "comments" (${commentsData.length} items)');
          } else if (responseData is List) {
            // Estructura directa como array
            commentsData = responseData;
            debugPrint('📦 [Teacher Comments] Estructura: Array directo (${commentsData.length} items)');
          } else {
            debugPrint('⚠️ [Teacher Comments] Estructura desconocida');
            debugPrint('⚠️ [Teacher Comments] Data keys: ${responseData is Map ? (responseData as Map).keys.toList() : 'No es Map'}');
            throw Exception('Estructura de respuesta no reconocida');
          }
          
          debugPrint('✅ [Teacher Comments] Parseando ${commentsData.length} comentarios...');
          
          return commentsData
              .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ [Teacher Comments] No se encontraron comentarios');
        return [];
      }

      throw Exception('Error al obtener comentarios: Status ${response.statusCode}');
    } catch (e) {
      debugPrint('💥 [Teacher Comments] Error completo: $e');
      debugPrint('💥 [Teacher Comments] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Map<String, dynamic> _buildResponse(List<TeacherEvaluationModel> evaluations) {
    final totalSubjects = evaluations.length;
    final totalStudents = evaluations.fold<int>(
      0, 
      (sum, eval) => sum + eval.totalStudents,
    );
    final totalCompleted = evaluations.fold<int>(
      0, 
      (sum, eval) => sum + eval.completedEvaluations,
    );
    final totalPending = evaluations.fold<int>(
      0, 
      (sum, eval) => sum + eval.pendingEvaluations,
    );

    return {
      'evaluations': evaluations,
      'stats': {
        'totalSubjects': totalSubjects,
        'totalStudents': totalStudents,
        'totalCompleted': totalCompleted,
        'totalPending': totalPending,
      },
    };
  }

  /// 🆕 Construye respuesta de comentarios con estadísticas
  Map<String, dynamic> _buildCommentsResponse(List<CommentModel> comments) {
    final stats = CommentStats.fromComments(comments);
    
    return {
      'comments': comments,
      'stats': {
        'total': stats.total,
        'positive': stats.positive,
        'neutral': stats.neutral,
        'negative': stats.negative,
      },
    };
  }
}
