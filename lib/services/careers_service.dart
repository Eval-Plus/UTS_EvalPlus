/// Servicio UNIFICADO para manejar carreras
/// Ubicación: lib/services/careers_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/career_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

class CareersService {
  // ==================== SINGLETON ====================
  
  static final CareersService _instance = CareersService._internal();
  factory CareersService() => _instance;
  CareersService._internal();

  // Cache separado para cada tipo de consulta
  List<CareerModel>? _cachedAllCareers;
  List<CareerModel>? _cachedMyCareers;
  DateTime? _lastFetchAllTime;
  DateTime? _lastFetchMyTime;
  static const _cacheDuration = Duration(minutes: 30);

  // ==================== PUBLIC API ====================
  
  /// Obtiene TODAS las carreras activas del sistema
  /// Útil para administradores y filtros globales
  /// GET /api/careers
  Future<List<CareerModel>> getAllCareers({bool forceRefresh = false}) async {
    // Usar cache si es válido
    if (!forceRefresh && _isAllCareersValid()) {
      debugPrint('⚡ [CareersService] Usando cache de todas las carreras');
      return _cachedAllCareers!;
    }

    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ [CareersService] No hay token disponible');
        return _cachedAllCareers ?? [];
      }

      debugPrint('🌐 [CareersService] Consultando GET /api/careers...');
      final careers = await _fetchAllFromApi(token);

      if (careers != null) {
        _cachedAllCareers = careers;
        _lastFetchAllTime = DateTime.now();
        debugPrint('✅ [CareersService] ${careers.length} carreras obtenidas');
        return careers;
      }

      // Si API falla pero tenemos cache, usar cache
      if (_cachedAllCareers != null) {
        debugPrint('⚠️ [CareersService] API falló, usando cache');
        return _cachedAllCareers!;
      }

      return [];
      
    } catch (e) {
      debugPrint('💥 [CareersService] Error en getAllCareers: $e');
      return _cachedAllCareers ?? [];
    }
  }

  /// Obtiene las carreras del usuario autenticado
  /// Útil para estudiantes/profesores (sus carreras específicas)
  /// GET /api/careers/my
  Future<List<CareerModel>> getMyCareers({bool forceRefresh = false}) async {
    // Usar cache si es válido
    if (!forceRefresh && _isMyCareersValid()) {
      debugPrint('⚡ [CareersService] Usando cache de mis carreras');
      return _cachedMyCareers!;
    }

    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ [CareersService] No hay token disponible');
        return _cachedMyCareers ?? [];
      }

      debugPrint('🌐 [CareersService] Consultando GET /api/careers/my...');
      final careers = await _fetchMyFromApi(token);

      if (careers != null) {
        _cachedMyCareers = careers;
        _lastFetchMyTime = DateTime.now();
        debugPrint('✅ [CareersService] ${careers.length} carreras del usuario obtenidas');
        return careers;
      }

      // Si API falla pero tenemos cache, usar cache
      if (_cachedMyCareers != null) {
        debugPrint('⚠️ [CareersService] API falló, usando cache');
        return _cachedMyCareers!;
      }

      return [];
      
    } catch (e) {
      debugPrint('💥 [CareersService] Error en getMyCareers: $e');
      return _cachedMyCareers ?? [];
    }
  }

  /// Busca una carrera por código (en todas las carreras)
  Future<CareerModel?> getCareerByCode(String codigo) async {
    final careers = await getAllCareers();
    try {
      return careers.firstWhere(
        (career) => career.codigo.toUpperCase() == codigo.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Busca una carrera por ID (en todas las carreras)
  Future<CareerModel?> getCareerById(int id) async {
    final careers = await getAllCareers();
    try {
      return careers.firstWhere((career) => career.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Invalida el cache (útil para forzar recarga)
  void invalidateCache() {
    debugPrint('🗑️ [CareersService] Invalidando cache...');
    _lastFetchAllTime = null;
    _lastFetchMyTime = null;
  }

  /// Limpia completamente el cache (útil para logout)
  void clearCache() {
    _cachedAllCareers = null;
    _cachedMyCareers = null;
    _lastFetchAllTime = null;
    _lastFetchMyTime = null;
    debugPrint('🗑️ [CareersService] Cache limpiado completamente');
  }

  // ==================== PRIVATE METHODS ====================
  
  /// Verifica si el cache de todas las carreras es válido
  bool _isAllCareersValid() {
    if (_cachedAllCareers == null || _lastFetchAllTime == null) {
      return false;
    }
    final age = DateTime.now().difference(_lastFetchAllTime!);
    return age < _cacheDuration;
  }

  /// Verifica si el cache de mis carreras es válido
  bool _isMyCareersValid() {
    if (_cachedMyCareers == null || _lastFetchMyTime == null) {
      return false;
    }
    final age = DateTime.now().difference(_lastFetchMyTime!);
    return age < _cacheDuration;
  }

  /// Consulta GET /api/careers - Todas las carreras activas
  Future<List<CareerModel>?> _fetchAllFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/careers'),
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

      debugPrint('📡 [CareersService] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final careersList = (data['data'] as List)
              .map((json) => CareerModel.fromJson(json as Map<String, dynamic>))
              .where((career) => career.activo)
              .toList();
          
          return careersList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ [CareersService] No se encontraron carreras (404)');
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      }

      return null;
    } catch (e) {
      debugPrint('💥 [CareersService] Error en _fetchAllFromApi: $e');
      return null;
    }
  }

  /// Consulta GET /api/careers/my - Carreras del usuario
  Future<List<CareerModel>?> _fetchMyFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/careers/my'),
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

      debugPrint('📡 [CareersService] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final careersList = (data['data'] as List)
              .map((json) => CareerModel.fromJson(json as Map<String, dynamic>))
              .where((career) => career.activo)
              .toList();
          
          return careersList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ [CareersService] No se encontraron carreras del usuario (404)');
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      }

      return null;
    } catch (e) {
      debugPrint('💥 [CareersService] Error en _fetchMyFromApi: $e');
      return null;
    }
  }
}
