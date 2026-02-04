import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/evaluation_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Servicio UNIFICADO para manejar evaluaciones del estudiante
class EvaluationsService {
  // ==================== SINGLETON ====================
  
  static final EvaluationsService _instance = EvaluationsService._internal();
  factory EvaluationsService() => _instance;
  EvaluationsService._internal();

  // Cache en memoria
  List<EvaluationModel>? _cachedEvaluations;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 2);

  // 🆕 Listeners para notificar cambios
  final List<VoidCallback> _listeners = [];

  // ==================== LISTENER MANAGEMENT ====================
  
  /// Agrega un listener que será notificado cuando las evaluaciones cambien
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      debugPrint('📢 Listener agregado. Total: ${_listeners.length}');
      debugPrint('🔍 Hash del servicio: ${hashCode}');
    }
  }

  /// Remueve un listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    debugPrint('📢 Listener removido. Total: ${_listeners.length}');
  }

  /// Notifica a todos los listeners que hubo un cambio
  void _notifyListeners() {
    debugPrint('📢 Notificando a ${_listeners.length} listeners...');
    for (final listener in _listeners) {
      listener();
    }
  }

  // ==================== PUBLIC API ====================
  
  /// Obtiene todas las evaluaciones del estudiante (pendientes + completadas)
  Future<Map<String, dynamic>> getMyEvaluations({
    bool forceRefresh = false,
  }) async {
    // Usar cache si es válido
    if (!forceRefresh && _isCacheValid()) {
      debugPrint('⚡ Usando cache de evaluaciones');
      return _buildResponse(_cachedEvaluations!);
    }

    try {
      // Obtener token
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ No hay token, usando fallback');
        return _getFallbackResponse();
      }

      // Consultar API
      debugPrint('🌐 Consultando API de evaluaciones...');
      final result = await _fetchFromApi(token);

      if (result != null) {
        // Actualizar cache
        _cachedEvaluations = result;
        _lastFetchTime = DateTime.now();
        debugPrint('✅ ${result.length} evaluaciones obtenidas');
        return _buildResponse(result);
      }

      // Fallback si API falla
      debugPrint('⚠️ API sin datos, usando fallback');
      return _getFallbackResponse();
      
    } catch (e) {
      debugPrint('💥 Error obteniendo evaluaciones: $e');
      
      // Retornar cache si existe, sino fallback
      if (_cachedEvaluations != null) {
        debugPrint('📦 Usando cache como fallback');
        return _buildResponse(_cachedEvaluations!);
      }
      
      return _getFallbackResponse();
    }
  }

  /// Obtiene solo evaluaciones pendientes
  Future<List<EvaluationModel>> getPendingEvaluations({
    bool forceRefresh = false,
  }) async {
    final response = await getMyEvaluations(forceRefresh: forceRefresh);
    final evaluations = response['evaluations'] as List<EvaluationModel>;
    return evaluations.where((e) => !e.isCompleted).toList();
  }

  /// Obtiene solo evaluaciones completadas
  Future<List<EvaluationModel>> getCompletedEvaluations({
    bool forceRefresh = false,
  }) async {
    final response = await getMyEvaluations(forceRefresh: forceRefresh);
    final evaluations = response['evaluations'] as List<EvaluationModel>;
    return evaluations.where((e) => e.isCompleted).toList();
  }

  /// Busca una evaluación por ID
  Future<EvaluationModel?> getEvaluationById(int evaluationId) async {
    final response = await getMyEvaluations();
    final evaluations = response['evaluations'] as List<EvaluationModel>;
    
    try {
      return evaluations.firstWhere((e) => e.evaluationId == evaluationId);
    } catch (e) {
      return null;
    }
  }

  /// 🆕 Invalida el cache y notifica a los listeners
  /// Se debe llamar cuando se completa una evaluación
  void invalidateCache() {
    debugPrint('🗑️ Invalidando cache de evaluaciones...');
    debugPrint('🔍 Hash del servicio: ${hashCode}');
    debugPrint('📢 Total listeners registrados: ${_listeners.length}');
    _cachedEvaluations = null;
    _lastFetchTime = null;
    _notifyListeners();
  }

  /// Limpia el cache (útil para logout o refresh manual)
  void clearCache() {
    _cachedEvaluations = null;
    _lastFetchTime = null;
    _listeners.clear();
    debugPrint('🗑️ Cache y listeners limpiados');
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
  Future<List<EvaluationModel>?> _fetchFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/evaluations/student/all'),
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

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final evaluationsList = (data['data']['evaluations'] as List)
              .map((json) => EvaluationModel.fromJson(json))
              .toList();
          
          return evaluationsList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron evaluaciones');
        return [];
      }

      return null;
    } catch (e) {
      debugPrint('💥 Error en _fetchFromApi: $e');
      return null;
    }
  }

  /// Construye la respuesta con estadísticas
  Map<String, dynamic> _buildResponse(List<EvaluationModel> evaluations) {
    final pending = evaluations.where((e) => !e.isCompleted).length;
    final completed = evaluations.where((e) => e.isCompleted).length;

    return {
      'evaluations': evaluations,
      'stats': {
        'total': evaluations.length,
        'pending': pending,
        'completed': completed,
      },
    };
  }

  /// Datos de respaldo estáticos
  Map<String, dynamic> _getFallbackResponse() {
    final fallbackData = [
      EvaluationModel(
        evaluationId: 1,
        teacherName: 'Dr. Carlos Méndez',
        subject: 'Cálculo Diferencial',
        subjectCode: 'MAT101',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        isCompleted: true,
        completedDate: DateTime(2024, 10, 15),
      ),
      EvaluationModel(
        evaluationId: 2,
        teacherName: 'Ing. María González',
        subject: 'Programación I',
        subjectCode: 'SIS102',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        fechaInicio: DateTime.now().subtract(const Duration(days: 7)),
        fechaCierre: DateTime.now().add(const Duration(days: 7)),
        isCompleted: false,
      ),
      EvaluationModel(
        evaluationId: 3,
        teacherName: 'Dra. Ana Rodríguez',
        subject: 'Física Mecánica',
        subjectCode: 'FIS103',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        isCompleted: true,
        completedDate: DateTime(2024, 10, 18),
      ),
      EvaluationModel(
        evaluationId: 4,
        teacherName: 'Mg. Luis Fernández',
        subject: 'Álgebra Lineal',
        subjectCode: 'MAT104',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        fechaInicio: DateTime.now().subtract(const Duration(days: 5)),
        fechaCierre: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
      ),
      EvaluationModel(
        evaluationId: 5,
        teacherName: 'Ing. Patricia Herrera',
        subject: 'Introducción a la Ingeniería',
        subjectCode: 'ING105',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        fechaInicio: DateTime.now().subtract(const Duration(days: 10)),
        fechaCierre: DateTime.now().add(const Duration(days: 5)),
        isCompleted: false,
      ),
      EvaluationModel(
        evaluationId: 6,
        teacherName: 'Dr. Roberto Sánchez',
        subject: 'Química General',
        subjectCode: 'QUI106',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        isCompleted: true,
        completedDate: DateTime(2024, 10, 12),
      ),
      EvaluationModel(
        evaluationId: 7,
        teacherName: 'Lic. Sandra Morales',
        subject: 'Comunicación Escrita',
        subjectCode: 'LET107',
        careerName: 'Ingeniería de Sistemas',
        period: '2024-2',
        fechaInicio: DateTime.now().subtract(const Duration(days: 3)),
        fechaCierre: DateTime.now().add(const Duration(days: 10)),
        isCompleted: false,
      ),
    ];

    return _buildResponse(fallbackData);
  }
}
