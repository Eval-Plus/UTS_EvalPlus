/// Controlador para el análisis administrativo
/// Ubicación: lib/controllers/admin_analysis_controller.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/services/admin_analysis_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

class AdminAnalysisController extends ChangeNotifier {
  final AdminAnalysisService _analysisService;

  // Estado de datos
  List<TeacherData> _teachers = [];
  AnalysisStats? _globalStats;
  bool _isLoading = false;
  bool _isInitialLoad = true;
  String? _errorMessage;

  // Estado de búsqueda y filtros
  String _searchTerm = '';
  String _sortBy = 'name';
  int? _expandedTeacherId;
  
  final Map<String, dynamic> _filters = {
    'careers': ['all'],
    'period': '2025-1',
    'status': 'all',
  };

  // ==================== GETTERS ====================
  
  List<TeacherData> get teachers => _teachers;
  AnalysisStats? get globalStats => _globalStats;
  bool get isLoading => _isLoading;
  bool get isInitialLoad => _isInitialLoad;
  String? get errorMessage => _errorMessage;
  String get searchTerm => _searchTerm;
  String get sortBy => _sortBy;
  int? get expandedTeacherId => _expandedTeacherId;
  Map<String, dynamic> get filters => Map.unmodifiable(_filters);

  /// Docentes filtrados según búsqueda y filtros locales
  List<TeacherData> get filteredTeachers {
    return _teachers.where((teacher) {
      // Filtro de búsqueda
      final matchesSearch = teacher.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                            teacher.email.toLowerCase().contains(_searchTerm.toLowerCase());
      
      // Filtro de estado (se aplica localmente)
      final matchesStatus = _filters['status'] == 'all' ||
                           (_filters['status'] == 'active' && teacher.activeEvaluations > 0) ||
                           (_filters['status'] == 'none' && teacher.activeEvaluations == 0);
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ==================== CONSTRUCTOR ====================
  
  AdminAnalysisController({AdminAnalysisService? analysisService})
      : _analysisService = analysisService ?? AdminAnalysisService(
          getToken: () => AuthStorageService.getToken(),
        ) {
    _init();
  }

  // ==================== INICIALIZACIÓN ====================
  
  void _init() {
    debugPrint('🎯 [AnalysisController] Inicializando...');
    loadData();
  }

  // ==================== CARGA DE DATOS ====================
  
  Future<void> loadData() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📊 [AnalysisController] Cargando datos...');
      
      // Determinar carrera seleccionada
      final selectedCareers = _filters['careers'] as List<String>;
      final career = selectedCareers.contains('all') || selectedCareers.isEmpty
          ? null
          : selectedCareers.first;

      // Cargar datos en paralelo
      final results = await Future.wait([
        _analysisService.getTeachersAnalysis(
          periodo: _filters['period'] as String,
          career: career,
          sortBy: _sortBy,
        ),
        _analysisService.getAnalysisStats(
          periodo: _filters['period'] as String,
          career: career,
        ),
      ]);

      _teachers = (results[0] as TeachersAnalysisResponse).teachers;
      _globalStats = results[1] as AnalysisStats;
      _isLoading = false;
      _isInitialLoad = false;
      _errorMessage = null;
      
      debugPrint('✅ [AnalysisController] Datos cargados: ${_teachers.length} docentes');
      notifyListeners();
      
    } on UnauthorizedException catch (e) {
      debugPrint('💥 [AnalysisController] Error de autenticación: $e');
      _errorMessage = e.message;
      _isLoading = false;
      _isInitialLoad = false;
      notifyListeners();
      
    } on ForbiddenException catch (e) {
      debugPrint('💥 [AnalysisController] Error de permisos: $e');
      _errorMessage = e.message;
      _isLoading = false;
      _isInitialLoad = false;
      notifyListeners();
      
    } catch (e) {
      debugPrint('💥 [AnalysisController] Error general: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      _isInitialLoad = false;
      notifyListeners();
    }
  }

  // ==================== BÚSQUEDA ====================
  
  void setSearchTerm(String term) {
    if (_searchTerm != term) {
      _searchTerm = term;
      notifyListeners();
    }
  }

  void clearSearch() {
    if (_searchTerm.isNotEmpty) {
      _searchTerm = '';
      notifyListeners();
    }
  }

  // ==================== FILTROS ====================
  
  void toggleFilter(String category, String value) {
    bool shouldReload = false;
    
    if (category == 'careers') {
      final current = _filters[category] as List<String>;
      if (value == 'all') {
        _filters[category] = ['all'];
        shouldReload = true;
      } else {
        final newCareers = current.contains(value)
            ? current.where((c) => c != value).toList()
            : [...current.where((c) => c != 'all'), value];
        _filters[category] = newCareers.isEmpty ? ['all'] : newCareers;
        shouldReload = true;
      }
    } else if (category == 'period') {
      if (_filters[category] != value) {
        _filters[category] = value;
        shouldReload = true;
      }
    } else {
      _filters[category] = value;
      // 'status' es filtro local, no requiere recarga
      notifyListeners();
      return;
    }

    notifyListeners();
    
    if (shouldReload) {
      loadData();
    }
  }

  bool isFilterSelected(String category, String value) {
    if (category == 'careers') {
      return (_filters[category] as List).contains(value);
    }
    return _filters[category] == value;
  }

  // ==================== ORDENAMIENTO ====================
  
  void setSortBy(String newSortBy) {
    if (_sortBy != newSortBy) {
      _sortBy = newSortBy;
      notifyListeners();
      loadData();
    }
  }

  // ==================== EXPANSIÓN DE TARJETAS ====================
  
  void toggleTeacherExpansion(int teacherId) {
    if (_expandedTeacherId == teacherId) {
      _expandedTeacherId = null;
    } else {
      _expandedTeacherId = teacherId;
    }
    notifyListeners();
  }

  bool isTeacherExpanded(int teacherId) {
    return _expandedTeacherId == teacherId;
  }

  // ==================== HELPERS ====================
  
  String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
