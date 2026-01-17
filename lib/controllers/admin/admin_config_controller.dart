/// Controlador para la configuración de administrador (Refactorizado)
/// Ubicación: lib/controllers/admin/admin_config_controller.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/admin_dashboard_model.dart';
import 'package:eval_plus/services/admin_dashboard_service.dart';
import 'package:eval_plus/utils/admin/admin_config_constants.dart';
import 'package:eval_plus/utils/admin/admin_sync_validator.dart';

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
  
  /// Valida si se puede ejecutar una acción de sincronización
  SyncValidationResult validateAction(String actionKey) {
    if (_dashboard == null || stats == null) {
      return SyncValidationResult.fail(
        message: 'No hay datos del dashboard disponibles',
      );
    }

    // Usar el validador centralizado
    return AdminSyncValidator.validateAction(actionKey, stats!);
  }

  /// Obtiene el estado de disponibilidad de todas las acciones
  Map<String, bool> getActionsAvailability() {
    if (stats == null) {
      return {
        'sync-students': false,
        'enroll-teachers': false,
        'generate-evaluations': false,
      };
    }

    return AdminSyncValidator.getActionsAvailability(stats!);
  }

  /// Verifica si una acción específica está disponible
  bool isActionAvailable(String actionKey) {
    if (stats == null) return false;
    return AdminSyncValidator.isActionAvailable(actionKey, stats!);
  }

  // ==================== ACCIONES ====================
  
  /// Ejecuta una acción de sincronización
  Future<ActionResult> executeAction(String actionKey) async {
    if (_dashboard == null || stats == null) {
      return ActionResult(
        success: false,
        message: 'No hay datos disponibles',
      );
    }

    // Validar antes de ejecutar
    final validation = validateAction(actionKey);

    if (!validation.canProceed) {
      debugPrint('⚠️ [ConfigController] Acción bloqueada: ${validation.internalMessage}');
      
      return ActionResult(
        success: false,
        message: validation.internalMessage ?? 'No se puede proceder con la acción',
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

/// Resultado de acción
class ActionResult {
  final bool success;
  final String message;
  final SyncValidationResult? validationResult;

  ActionResult({
    required this.success,
    required this.message,
    this.validationResult,
  });
}
