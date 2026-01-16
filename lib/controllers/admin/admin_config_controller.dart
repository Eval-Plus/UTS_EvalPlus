/// Controlador para la configuración de administrador
/// Ubicación: lib/controllers/admin_config_controller.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/admin_dashboard_model.dart';
import 'package:eval_plus/services/admin_dashboard_service.dart';
import 'package:eval_plus/utils/admin/admin_config_constants.dart';

class AdminConfigController extends ChangeNotifier {
  final AdminDashboardService _dashboardService;

  AdminDashboardModel? _dashboard;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Estado de carga para cada acción
  final Map<String, bool> _loadingStates = {
    'sync-students': false,
    'enroll-teachers': false,
    'generate-evaluations': false,
  };

  // ==================== GETTERS ====================
  
  AdminDashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, bool> get loadingStates => _loadingStates;
  
  DashboardStats? get stats => _dashboard?.stats;
  String? get periodo => _dashboard?.periodo;

  // ==================== CONSTRUCTOR ====================
  
  AdminConfigController({AdminDashboardService? dashboardService})
      : _dashboardService = dashboardService ?? AdminDashboardService() {
    _init();
  }

  // ==================== INICIALIZACIÓN ====================
  
  void _init() {
    debugPrint('🎯 [ConfigController] Inicializando...');
    _dashboardService.addListener(_onDashboardChanged);
    loadDashboard();
  }

  @override
  void dispose() {
    debugPrint('🎯 [ConfigController] Desuscribiéndose del servicio...');
    _dashboardService.removeListener(_onDashboardChanged);
    super.dispose();
  }

  // ==================== CARGA DE DATOS ====================
  
  void _onDashboardChanged() {
    debugPrint('🔔 [ConfigController] Notificación recibida: Recargando dashboard...');
    loadDashboard(forceRefresh: true);
  }

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📊 [ConfigController] Cargando dashboard...');
      
      final dashboard = await _dashboardService.getDashboard(
        forceRefresh: forceRefresh,
      );

      _dashboard = dashboard;
      _isLoading = false;
      _errorMessage = null;
      
      debugPrint('✅ [ConfigController] Dashboard cargado exitosamente');
      notifyListeners();
      
    } catch (e) {
      debugPrint('💥 [ConfigController] Error cargando dashboard: $e');
      
      _errorMessage = 'Error al cargar dashboard: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== VALIDACIONES ====================
  
  /// Valida si se pueden sincronizar estudiantes
  ValidationResult canSyncStudents() {
    if (_dashboard == null) {
      return ValidationResult(
        canProceed: false,
        message: 'No hay datos del dashboard disponibles',
      );
    }

    final pendingCount = _dashboard!.stats.pendingStudents;
    
    if (pendingCount == 0) {
      return ValidationResult(
        canProceed: false,
        showDialog: true,
        title: AdminConfigConstants.studentsNoPending,
        message: AdminConfigConstants.studentsNoPendingMessage,
        icon: AdminConfigConstants.checkIcon,
        color: AdminConfigConstants.emeraldColor,
      );
    }

    return ValidationResult(canProceed: true);
  }

  /// Valida si se pueden inscribir docentes
  ValidationResult canEnrollTeachers() {
    if (_dashboard == null) {
      return ValidationResult(
        canProceed: false,
        message: 'No hay datos del dashboard disponibles',
      );
    }

    final pendingCount = _dashboard!.stats.pendingTeachers;
    
    if (pendingCount == 0) {
      return ValidationResult(
        canProceed: false,
        showDialog: true,
        title: AdminConfigConstants.teachersNoPending,
        message: AdminConfigConstants.teachersNoPendingMessage,
        icon: AdminConfigConstants.checkIcon,
        color: AdminConfigConstants.limeColor,
      );
    }

    return ValidationResult(canProceed: true);
  }

  /// Valida si se pueden generar evaluaciones
  ValidationResult canGenerateEvaluations() {
    if (_dashboard == null) {
      return ValidationResult(
        canProceed: false,
        message: 'No hay datos del dashboard disponibles',
      );
    }

    final activeCount = _dashboard!.stats.activeEvaluations;
    
    if (activeCount > 0) {
      return ValidationResult(
        canProceed: false,
        showDialog: true,
        title: AdminConfigConstants.evaluationsAlreadyGenerated,
        message: AdminConfigConstants.evaluationsAlreadyGeneratedMessage(activeCount),
        icon: AdminConfigConstants.completedIcon,
        color: AdminConfigConstants.tealColor,
      );
    }

    return ValidationResult(canProceed: true);
  }

  // ==================== ACCIONES ====================
  
  /// Ejecuta una acción de sincronización
  Future<ActionResult> executeAction(String actionKey) async {
    if (_dashboard == null) {
      return ActionResult(
        success: false,
        message: 'No hay datos disponibles',
      );
    }

    // Validar antes de ejecutar
    ValidationResult validation;
    
    switch (actionKey) {
      case 'sync-students':
        validation = canSyncStudents();
        break;
      case 'enroll-teachers':
        validation = canEnrollTeachers();
        break;
      case 'generate-evaluations':
        validation = canGenerateEvaluations();
        break;
      default:
        return ActionResult(
          success: false,
          message: 'Acción no reconocida: $actionKey',
        );
    }

    if (!validation.canProceed) {
      return ActionResult(
        success: false,
        message: validation.message ?? 'No se puede proceder con la acción',
        validationResult: validation,
      );
    }

    // Ejecutar acción
    _loadingStates[actionKey] = true;
    notifyListeners();

    try {
      String message;
      
      switch (actionKey) {
        case 'sync-students':
          final result = await _dashboardService.syncStudents();
          message = AdminConfigConstants.studentsSuccessMessage(
            result['exitosos'] ?? 0,
          );
          break;
          
        case 'enroll-teachers':
          final result = await _dashboardService.syncTeachers();
          message = AdminConfigConstants.teachersSuccessMessage(
            result['exitosos'] ?? 0,
          );
          break;
          
        case 'generate-evaluations':
          final now = DateTime.now();
          final fechaCierre = now.add(const Duration(days: 90));
          
          final result = await _dashboardService.generateEvaluations(
            periodo: _dashboard!.periodo,
            fechaInicio: now,
            fechaCierre: fechaCierre,
          );
          message = AdminConfigConstants.evaluationsSuccessMessage(
            result['creadas'] ?? 0,
          );
          break;
          
        default:
          message = 'Acción no implementada';
      }

      // Recargar dashboard después de la acción
      await loadDashboard(forceRefresh: true);

      return ActionResult(
        success: true,
        message: message,
      );
      
    } catch (e) {
      debugPrint('💥 [ConfigController] Error en acción $actionKey: $e');
      
      return ActionResult(
        success: false,
        message: 'Error: $e',
      );
      
    } finally {
      _loadingStates[actionKey] = false;
      notifyListeners();
    }
  }

  /// Verifica si una acción está en progreso
  bool isActionLoading(String actionKey) {
    return _loadingStates[actionKey] ?? false;
  }
}

// ==================== CLASES AUXILIARES ====================

/// Resultado de validación
class ValidationResult {
  final bool canProceed;
  final String? message;
  final bool showDialog;
  final String? title;
  final IconData? icon;
  final Color? color;

  ValidationResult({
    required this.canProceed,
    this.message,
    this.showDialog = false,
    this.title,
    this.icon,
    this.color,
  });
}

/// Resultado de acción
class ActionResult {
  final bool success;
  final String message;
  final ValidationResult? validationResult;

  ActionResult({
    required this.success,
    required this.message,
    this.validationResult,
  });
}
