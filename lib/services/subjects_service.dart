import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/subject_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Servicio UNIFICADO para manejar materias con listeners
class SubjectsService extends ChangeNotifier {
  // ==================== SINGLETON ====================
  
  static final SubjectsService _instance = SubjectsService._internal();
  factory SubjectsService() => _instance;
  SubjectsService._internal();

  // Cache en memoria (por carrera)
  final Map<String, List<SubjectModel>> _cachedSubjects = {};
  final Map<String, DateTime> _lastFetchTimes = {};
  static const _cacheDuration = Duration(minutes: 5);

  // ==================== PUBLIC API ====================
  
  /// Obtiene las materias de una carrera específica
  /// Usa cache si está disponible, sino consulta API
  Future<List<SubjectModel>> getSubjectsByCareer({
    required String careerCodigo,
    required int careerId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${careerCodigo}_$careerId';

    // Usar cache si es válido
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('⚡ Usando cache de materias para $careerCodigo');
      return _cachedSubjects[cacheKey]!;
    }

    try {
      debugPrint('🌐 Consultando API de materias para $careerCodigo...');
      
      // Obtener token
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ No hay token, usando fallback');
        return _getFallbackSubjects(careerCodigo);
      }

      // Consultar API
      final subjects = await _fetchFromApi(
        token: token,
        careerId: careerId,
        careerCodigo: careerCodigo,
      );

      if (subjects != null && subjects.isNotEmpty) {
        // Actualizar cache
        _cachedSubjects[cacheKey] = subjects;
        _lastFetchTimes[cacheKey] = DateTime.now();
        debugPrint('✅ ${subjects.length} materias obtenidas para $careerCodigo');
        return subjects;
      }

      // Fallback si API falla
      debugPrint('⚠️ API sin datos, usando fallback');
      return _getFallbackSubjects(careerCodigo);
      
    } catch (e) {
      debugPrint('💥 Error obteniendo materias: $e');
      
      // Retornar cache si existe, sino fallback
      if (_cachedSubjects.containsKey(cacheKey)) {
        debugPrint('📦 Usando cache como fallback');
        return _cachedSubjects[cacheKey]!;
      }
      
      return _getFallbackSubjects(careerCodigo);
    }
  }

  /// 🆕 Invalida el cache y notifica a los listeners
  void invalidateCache({String? careerCodigo, int? careerId}) {
    if (careerCodigo != null && careerId != null) {
      // Invalidar cache específico
      final cacheKey = '${careerCodigo}_$careerId';
      _cachedSubjects.remove(cacheKey);
      _lastFetchTimes.remove(cacheKey);
      debugPrint('🗑️ Cache invalidado para $careerCodigo');
    } else {
      // Invalidar todo el cache
      _cachedSubjects.clear();
      _lastFetchTimes.clear();
      debugPrint('🗑️ Todo el cache de materias limpiado');
    }
    
    // Notificar a los listeners
    notifyListeners();
  }

  /// Busca una materia por código
  Future<SubjectModel?> getSubjectByCode({
    required String codigo,
    required String careerCodigo,
    required int careerId,
  }) async {
    final subjects = await getSubjectsByCareer(
      careerCodigo: careerCodigo,
      careerId: careerId,
    );
    
    try {
      return subjects.firstWhere(
        (subject) => subject.codigo.toUpperCase() == codigo.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Busca una materia por ID
  Future<SubjectModel?> getSubjectById({
    required int id,
    required String careerCodigo,
    required int careerId,
  }) async {
    final subjects = await getSubjectsByCareer(
      careerCodigo: careerCodigo,
      careerId: careerId,
    );
    
    try {
      return subjects.firstWhere((subject) => subject.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Limpia el cache
  void clearCache() {
    _cachedSubjects.clear();
    _lastFetchTimes.clear();
    debugPrint('🗑️ Cache de materias limpiado');
    notifyListeners();
  }

  /// Limpia cache de una carrera específica
  void clearCacheForCareer(String careerCodigo, int careerId) {
    final cacheKey = '${careerCodigo}_$careerId';
    _cachedSubjects.remove(cacheKey);
    _lastFetchTimes.remove(cacheKey);
    debugPrint('🗑️ Cache de materias limpiado para $careerCodigo');
    notifyListeners();
  }

  // ==================== PRIVATE METHODS ====================
  
  /// Verifica si el cache es válido
  bool _isCacheValid(String cacheKey) {
    if (!_cachedSubjects.containsKey(cacheKey) || 
        !_lastFetchTimes.containsKey(cacheKey)) {
      return false;
    }
    
    final age = DateTime.now().difference(_lastFetchTimes[cacheKey]!);
    return age < _cacheDuration;
  }

  /// Consulta real a la API
  Future<List<SubjectModel>?> _fetchFromApi({
    required String token,
    required int careerId,
    required String careerCodigo,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/subjects/my').replace(
        queryParameters: {'careerId': careerId.toString()},
      );

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

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];
          final subjectsList = (responseData['subjects'] as List)
              .map((json) {
                // Agregar careerCodigo al JSON antes de parsear
                json['careerCodigo'] = careerCodigo;
                return SubjectModel.fromJson(json);
              })
              .where((subject) => subject.activo)
              .toList();
          
          return subjectsList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron materias');
        return [];
      }

      return null;
    } catch (e) {
      debugPrint('💥 Error en _fetchFromApi: $e');
      return null;
    }
  }

  /// Datos de respaldo estáticos
  Future<List<SubjectModel>> _getFallbackSubjects(String careerCodigo) async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    final allSubjects = [
      // Materias de Ingeniería de Sistemas
      SubjectModel(
        id: 1,
        nombre: 'Programación Orientada a Objetos',
        codigo: 'B191',
        careerCodigo: 'ING-SIS',
        professorName: 'Dr. Juan Pérez',
        semestre: 3,
        evaluationId: 101,
        hasActiveEvaluation: true,
        isEvaluationCompleted: false,
      ),
      SubjectModel(
        id: 2,
        nombre: 'Bases de Datos',
        codigo: 'B192',
        careerCodigo: 'ING-SIS',
        professorName: 'Dra. María García',
        semestre: 4,
        evaluationId: 102,
        hasActiveEvaluation: true,
        isEvaluationCompleted: true, // Ya completada
      ),
      SubjectModel(
        id: 3,
        nombre: 'Estructuras de Datos',
        codigo: 'B193',
        careerCodigo: 'ING-SIS',
        professorName: 'Ing. Carlos Rodríguez',
        semestre: 2,
      ),
      SubjectModel(
        id: 4,
        nombre: 'Desarrollo Web',
        codigo: 'B194',
        careerCodigo: 'ING-SIS',
        professorName: 'Ing. Ana Martínez',
        semestre: 5,
        evaluationId: 103,
        hasActiveEvaluation: true,
        isEvaluationCompleted: false,
      ),
      
      // Materias de Administración de Empresas
      SubjectModel(
        id: 5,
        nombre: 'Contabilidad General',
        codigo: 'A101',
        careerCodigo: 'ADM-EMP',
        professorName: 'Lic. Pedro Sánchez',
        semestre: 1,
      ),
      SubjectModel(
        id: 6,
        nombre: 'Gestión Empresarial',
        codigo: 'A102',
        careerCodigo: 'ADM-EMP',
        professorName: 'MBA. Laura Torres',
        semestre: 3,
      ),
      SubjectModel(
        id: 7,
        nombre: 'Marketing Digital',
        codigo: 'A103',
        careerCodigo: 'ADM-EMP',
        professorName: 'Lic. Roberto Díaz',
        semestre: 4,
      ),
      
      // Materias de Derecho
      SubjectModel(
        id: 8,
        nombre: 'Derecho Constitucional',
        codigo: 'D201',
        careerCodigo: 'DER',
        professorName: 'Abg. Sofía Ramírez',
        semestre: 2,
      ),
      SubjectModel(
        id: 9,
        nombre: 'Derecho Civil',
        codigo: 'D202',
        careerCodigo: 'DER',
        professorName: 'Dr. Luis Herrera',
        semestre: 3,
      ),
      SubjectModel(
        id: 10,
        nombre: 'Derecho Penal',
        codigo: 'D203',
        careerCodigo: 'DER',
        professorName: 'Abg. Carmen López',
        semestre: 4,
      ),
    ];

    return allSubjects
        .where((subject) => subject.careerCodigo == careerCodigo)
        .toList();
  }
}
