import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/career_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Servicio UNIFICADO para manejar carreras
/// Combina lógica de API + caching (SIN fallback)
class CareersService {
  // ==================== SINGLETON ====================
  
  static final CareersService _instance = CareersService._internal();
  factory CareersService() => _instance;
  CareersService._internal();

  // Cache en memoria (opcional, mejora performance)
  List<CareerModel>? _cachedCareers;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  // ==================== PUBLIC API ====================
  
  /// Obtiene las carreras del usuario
  /// Usa cache si está disponible, sino consulta API
  /// Retorna lista vacía si no hay carreras (sin fallback ficticio)
  Future<List<CareerModel>> getMyCareers({
    bool forceRefresh = false,
  }) async {
    // Usar cache si es válido
    if (!forceRefresh && _isCacheValid()) {
      debugPrint('⚡ Usando cache de carreras');
      return _cachedCareers!;
    }

    try {
      // Obtener token
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ No hay token disponible');
        return [];
      }

      // Consultar API
      debugPrint('🌐 Consultando API de carreras...');
      final careers = await _fetchFromApi(token);

      // Si la API retorna datos (incluso si es lista vacía)
      if (careers != null) {
        // Actualizar cache
        _cachedCareers = careers;
        _lastFetchTime = DateTime.now();
        debugPrint('✅ ${careers.length} carreras obtenidas desde API');
        return careers;
      }

      // Si API falla pero tenemos cache, usar cache
      if (_cachedCareers != null) {
        debugPrint('⚠️ API falló, usando cache como fallback');
        return _cachedCareers!;
      }

      // Sin cache y sin datos de API: retornar vacío
      debugPrint('❌ Sin datos de API ni cache disponible');
      return [];
      
    } catch (e) {
      debugPrint('💥 Error obteniendo carreras: $e');
      
      // Retornar cache si existe, sino lista vacía
      if (_cachedCareers != null) {
        debugPrint('📦 Usando cache como fallback por error');
        return _cachedCareers!;
      }
      
      return [];
    }
  }

  /// Busca una carrera por código
  Future<CareerModel?> getCareerByCode(String codigo) async {
    final careers = await getMyCareers();
    try {
      return careers.firstWhere(
        (career) => career.codigo.toUpperCase() == codigo.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Busca una carrera por ID
  Future<CareerModel?> getCareerById(int id) async {
    final careers = await getMyCareers();
    try {
      return careers.firstWhere((career) => career.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Limpia el cache (útil para logout)
  void clearCache() {
    _cachedCareers = null;
    _lastFetchTime = null;
    debugPrint('🗑️ Cache de carreras limpiado');
  }

  // ==================== PRIVATE METHODS ====================
  
  /// Verifica si el cache es válido
  bool _isCacheValid() {
    if (_cachedCareers == null || _lastFetchTime == null) {
      return false;
    }
    
    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  /// Consulta real a la API
  Future<List<CareerModel>?> _fetchFromApi(String token) async {
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

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final careersList = (data['data'] as List)
              .map((json) => CareerModel.fromJson(json))
              .where((career) => career.activo)
              .toList();
          
          return careersList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron carreras (404)');
        return []; // ← Lista vacía explícita
      }

      return null; // API falló o respuesta inesperada
    } catch (e) {
      debugPrint('💥 Error en _fetchFromApi: $e');
      return null; // Error de red/timeout
    }
  }
}
