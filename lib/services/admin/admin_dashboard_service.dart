/// Servicio para el dashboard de administración
/// Ubicación: lib/services/admin_dashboard_service.dart
library;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/admin/admin_dashboard_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

class AdminDashboardService {
  // ==================== SINGLETON ====================
  
  static final AdminDashboardService _instance = 
      AdminDashboardService._internal();
  factory AdminDashboardService() => _instance;
  AdminDashboardService._internal();

  // Cache en memoria para el dashboard
  AdminDashboardModel? _cachedDashboard;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5); // Cache más largo para admin

  // Listeners para notificar cambios
  final List<VoidCallback> _listeners = [];

  // ==================== LISTENER MANAGEMENT ====================
  
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      debugPrint('📢 [AdminDashboard] Listener agregado. Total: ${_listeners.length}');
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    debugPrint('📢 [AdminDashboard] Listener removido. Total: ${_listeners.length}');
  }

  void _notifyListeners() {
    debugPrint('📢 [AdminDashboard] Notificando a ${_listeners.length} listeners...');
    for (final listener in _listeners) {
      listener();
    }
  }

  // ==================== PUBLIC API ====================
  
  /// Obtiene el dashboard del administrador
  /// GET /api/admin/dashboard?periodo=2025-1
  Future<AdminDashboardModel> getDashboard({
    String? periodo,
    bool forceRefresh = false,
  }) async {
    // Usar cache si es válido
    if (!forceRefresh && _isCacheValid()) {
      debugPrint('⚡ [AdminDashboard] Usando cache');
      return _cachedDashboard!;
    }

    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ [AdminDashboard] No hay token disponible');
        throw Exception('Token no disponible');
      }

      debugPrint('🌐 [AdminDashboard] Consultando API...');
      final dashboard = await _fetchFromApi(token, periodo);

      // Guardar en cache
      _cachedDashboard = dashboard;
      _lastFetchTime = DateTime.now();
      
      debugPrint('✅ [AdminDashboard] Dashboard obtenido correctamente');
      return dashboard;
      
    } catch (e) {
      debugPrint('💥 [AdminDashboard] Error obteniendo dashboard: $e');
      
      // Si hay cache disponible, retornarlo como fallback
      if (_cachedDashboard != null) {
        debugPrint('📦 [AdminDashboard] Usando cache como fallback');
        return _cachedDashboard!;
      }
      
      rethrow;
    }
  }

  /// Invalida el cache
  void invalidateCache() {
    debugPrint('🗑️ [AdminDashboard] Invalidando cache...');
    _cachedDashboard = null;
    _lastFetchTime = null;
    _notifyListeners();
  }

  /// Limpia completamente el servicio
  void clearCache() {
    _cachedDashboard = null;
    _lastFetchTime = null;
    _listeners.clear();
    debugPrint('🗑️ [AdminDashboard] Cache y listeners limpiados');
  }

  // ==================== ACCIONES DE SINCRONIZACIÓN ====================
  
  /// Sincroniza estudiantes
  /// POST /api/admin/sync/students
  Future<Map<String, dynamic>> syncStudents({bool force = false}) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      debugPrint('🔄 [AdminDashboard] Sincronizando estudiantes...');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/sync/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'force': force}),
      ).timeout(
        const Duration(seconds: 30), // Timeout más largo para sincronización
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📡 [AdminDashboard] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ [AdminDashboard] Estudiantes sincronizados');
          
          // Invalidar cache para refrescar estadísticas
          invalidateCache();
          
          return data['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Error al sincronizar estudiantes');
    } catch (e) {
      debugPrint('💥 [AdminDashboard] Error sincronizando estudiantes: $e');
      rethrow;
    }
  }

  /// Sincroniza profesores
  /// POST /api/admin/sync/teachers
  Future<Map<String, dynamic>> syncTeachers({bool force = false}) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      debugPrint('🔄 [AdminDashboard] Sincronizando profesores...');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/sync/teachers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'force': force}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📡 [AdminDashboard] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ [AdminDashboard] Profesores sincronizados');
          
          // Invalidar cache
          invalidateCache();
          
          return data['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Error al sincronizar profesores');
    } catch (e) {
      debugPrint('💥 [AdminDashboard] Error sincronizando profesores: $e');
      rethrow;
    }
  }

  /// Genera evaluaciones masivas
  /// POST /api/admin/evaluations/generate
  Future<Map<String, dynamic>> generateEvaluations({
    required String periodo,
    required DateTime fechaInicio,
    required DateTime fechaCierre,
    int? templateId,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      debugPrint('🔄 [AdminDashboard] Generando evaluaciones...');

      final body = {
        'periodo': periodo,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaCierre': fechaCierre.toIso8601String(),
        if (templateId != null) 'templateId': templateId,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/evaluations/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📡 [AdminDashboard] Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ [AdminDashboard] Evaluaciones generadas');
          
          // Invalidar cache
          invalidateCache();
          
          return data['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Error al generar evaluaciones');
    } catch (e) {
      debugPrint('💥 [AdminDashboard] Error generando evaluaciones: $e');
      rethrow;
    }
  }

  // ==================== PRIVATE METHODS ====================
  
  bool _isCacheValid() {
    if (_cachedDashboard == null || _lastFetchTime == null) {
      return false;
    }
    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  Future<AdminDashboardModel> _fetchFromApi(String token, String? periodo) async {
    try {
      // Construir URL con periodo opcional
      final uri = periodo != null
          ? Uri.parse('${AppConstants.baseUrl}/admin/dashboard?periodo=$periodo')
          : Uri.parse('${AppConstants.baseUrl}/admin/dashboard');

      final response = await http.get(
        uri,
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

      debugPrint('📡 [AdminDashboard] Status Code: ${response.statusCode}');
      debugPrint('📦 [AdminDashboard] Response Body: ${response.body}'); // 🔍 DEBUG

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          // 🔍 DEBUG: Imprimir la estructura del data
          debugPrint('🔍 [AdminDashboard] Data keys: ${(responseData['data'] as Map).keys.toList()}');
          debugPrint('🔍 [AdminDashboard] Stats: ${responseData['data']['stats']}');
          
          return AdminDashboardModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos de administrador');
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      }

      throw Exception('Error al obtener dashboard: ${response.statusCode}');
    } catch (e) {
      debugPrint('💥 [AdminDashboard] Error en _fetchFromApi: $e');
      debugPrint('💥 [AdminDashboard] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
