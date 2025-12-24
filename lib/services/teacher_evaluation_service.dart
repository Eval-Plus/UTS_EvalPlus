import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/teacher_evaluation_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Servicio para manejar evaluaciones de profesores
class TeacherEvaluationsService {
  // ==================== SINGLETON ====================
  
  static final TeacherEvaluationsService _instance = 
      TeacherEvaluationsService._internal();
  factory TeacherEvaluationsService() => _instance;
  TeacherEvaluationsService._internal();

  // Cache en memoria
  List<TeacherEvaluationModel>? _cachedEvaluations;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 2);

  // Listeners para notificar cambios
  final List<VoidCallback> _listeners = [];

  // ==================== LISTENER MANAGEMENT ====================
  
  /// Agrega un listener
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      debugPrint('📢 [Teacher] Listener agregado. Total: ${_listeners.length}');
    }
  }

  /// Remueve un listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    debugPrint('📢 [Teacher] Listener removido. Total: ${_listeners.length}');
  }

  /// Notifica cambios
  void _notifyListeners() {
    debugPrint('📢 [Teacher] Notificando a ${_listeners.length} listeners...');
    for (final listener in _listeners) {
      listener();
    }
  }

  // ==================== PUBLIC API ====================
  
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
      // Obtener token
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ [Teacher] No hay token disponible');
        throw Exception('Token no disponible');
      }

      // Consultar API
      debugPrint('🌐 [Teacher] Consultando API de evaluaciones...');
      final result = await _fetchFromApi(token);

      if (result != null) {
        // Actualizar cache
        _cachedEvaluations = result;
        _lastFetchTime = DateTime.now();
        debugPrint('✅ [Teacher] ${result.length} evaluaciones obtenidas');
        return _buildResponse(result);
      }

      throw Exception('No se pudieron obtener evaluaciones');
      
    } catch (e) {
      debugPrint('💥 [Teacher] Error obteniendo evaluaciones: $e');
      
      // Retornar cache si existe
      if (_cachedEvaluations != null) {
        debugPrint('📦 [Teacher] Usando cache como fallback');
        return _buildResponse(_cachedEvaluations!);
      }
      
      rethrow;
    }
  }

  /// Invalida el cache y notifica cambios
  void invalidateCache() {
    debugPrint('🗑️ [Teacher] Invalidando cache...');
    _cachedEvaluations = null;
    _lastFetchTime = null;
    _notifyListeners();
  }

  /// Limpia cache y listeners
  void clearCache() {
    _cachedEvaluations = null;
    _lastFetchTime = null;
    _listeners.clear();
    debugPrint('🗑️ [Teacher] Cache y listeners limpiados');
  }

  // ==================== PRIVATE METHODS ====================
  
  /// Verifica si el cache es válido
  bool _isCacheValid() {
    if (_cachedEvaluations == null || _lastFetchTime == null) {
      return false;
    }
    
    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  /// Consulta real a la API
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

  /// Construye la respuesta con estadísticas
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
}
