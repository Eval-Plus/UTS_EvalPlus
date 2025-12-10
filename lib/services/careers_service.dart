import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/career_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Servicio UNIFICADO para manejar carreras
/// Combina lógica de API + fallback + caching
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
        debugPrint('❌ No hay token, usando fallback');
        return _getFallbackCareers();
      }

      // Consultar API
      debugPrint('🌐 Consultando API de carreras...');
      final careers = await _fetchFromApi(token);

      if (careers != null && careers.isNotEmpty) {
        // Actualizar cache
        _cachedCareers = careers;
        _lastFetchTime = DateTime.now();
        debugPrint('✅ ${careers.length} carreras obtenidas');
        return careers;
      }

      // Fallback si API falla
      debugPrint('⚠️ API sin datos, usando fallback');
      return _getFallbackCareers();
      
    } catch (e) {
      debugPrint('💥 Error obteniendo carreras: $e');
      
      // Retornar cache si existe, sino fallback
      if (_cachedCareers != null) {
        debugPrint('📦 Usando cache como fallback');
        return _cachedCareers!;
      }
      
      return _getFallbackCareers();
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
        debugPrint('ℹ️ No se encontraron carreras');
        return [];
      }

      return null;
    } catch (e) {
      debugPrint('💥 Error en _fetchFromApi: $e');
      return null;
    }
  }

  /// Datos de respaldo estáticos
  Future<List<CareerModel>> _getFallbackCareers() async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      CareerModel(
        id: 1,
        nombre: 'Ingeniería de Sistemas',
        codigo: 'ING-SIS',
        icon: 'computer',
        color: '0xFF2196F3',
        descripcion: 'Carrera enfocada en el desarrollo de software',
      ),
      CareerModel(
        id: 2,
        nombre: 'Administración de Empresas',
        codigo: 'ADM-EMP',
        icon: 'business_center',
        color: '0xFF4CAF50',
        descripcion: 'Formación integral en gestión empresarial',
      ),
      CareerModel(
        id: 3,
        nombre: 'Derecho',
        codigo: 'DER',
        icon: 'gavel',
        color: '0xFFF44336',
        descripcion: 'Carrera enfocada en ciencias jurídicas',
      ),
    ];
  }
}
