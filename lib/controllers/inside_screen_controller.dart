/// Controlador para la pantalla principal (Inside Screen) - MEJORADO
/// Ubicación: lib/controllers/inside_screen_controller.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/config/navigation_config.dart';
import 'package:eval_plus/controllers/user_controller.dart';
import 'package:eval_plus/controllers/admin/admin_analysis_controller.dart';
import 'package:eval_plus/controllers/admin/admin_config_controller.dart';
import 'package:eval_plus/models/user_model.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/services/careers_service.dart';
import 'package:eval_plus/services/questions_service.dart';
import 'package:eval_plus/services/subjects_service.dart';
import 'package:eval_plus/services/admin/admin_dashboard_service.dart';
import 'package:eval_plus/services/admin/admin_analysis_service.dart';
import 'package:eval_plus/services/admin/teacher_report_service.dart';

class InsideScreenController extends ChangeNotifier {
  // ==================== ESTADO ====================
  
  int _currentIndex = 0;
  UserModel? _currentUser;
  String _welcomeMessage = 'Bienvenido';
  bool _isLoggingOut = false;
  bool _isLoadingUserData = true;
  bool _hasLoadedOnce = false;
  
  // PageController para manejar el swipe
  late PageController _pageController;
  
  // AnimationController (se inicializa desde el widget)
  AnimationController? _animationController;
  
  // Animaciones
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Controladores de Admin (lazy initialization)
  AdminAnalysisController? _adminAnalysisController;
  AdminConfigController? _adminConfigController;

  // ==================== GETTERS ====================
  
  int get currentIndex => _currentIndex;
  UserModel? get currentUser => _currentUser;
  String get welcomeMessage => _welcomeMessage;
  bool get isLoggingOut => _isLoggingOut;
  bool get isLoadingUserData => _isLoadingUserData;
  bool get hasLoadedOnce => _hasLoadedOnce;
  PageController get pageController => _pageController;
  
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;

  // Getters para controladores de admin (lazy initialization)
  AdminAnalysisController get adminAnalysisController {
    _adminAnalysisController ??= AdminAnalysisController();
    return _adminAnalysisController!;
  }

  AdminConfigController get adminConfigController {
    _adminConfigController ??= AdminConfigController();
    return _adminConfigController!;
  }

  // ==================== INICIALIZACIÓN ====================
  
  InsideScreenController() {
    _pageController = PageController(initialPage: 0);
    debugPrint('🎯 [Controller] Constructor ejecutado');
  }

  void initialize(AnimationController animationController) {
    debugPrint('🎯 [Controller] Initialize llamado');
    
    _animationController = animationController;
    _updateAnimations(isMovingRight: true);
    _animationController?.value = 1.0;
    
    // 🔥 CAMBIO CLAVE: Cargar datos inmediatamente y de forma síncrona
    if (!_hasLoadedOnce) {
      debugPrint('🎯 [Controller] Iniciando carga de usuario...');
      _loadUserData();
    } else {
      debugPrint('⚠️ [Controller] Usuario ya cargado previamente');
    }
  }

  @override
  void dispose() {
    debugPrint('🎯 [Controller] Disposing...');
    _pageController.dispose();
    
    // Dispose admin controllers si fueron creados
    _adminAnalysisController?.dispose();
    _adminConfigController?.dispose();
    
    super.dispose();
  }

  // ==================== CARGA DE DATOS ====================
  
  /// 🔧 MEJORADO: Carga con logs detallados y manejo de errores robusto
  Future<void> _loadUserData() async {
    if (_hasLoadedOnce) {
      debugPrint('⚠️ [Controller] Ya se cargó el usuario, saltando...');
      return;
    }
    
    try {
      debugPrint('📥 [Controller] ==== INICIO CARGA DE USUARIO ====');
      
      _isLoadingUserData = true;
      notifyListeners();
      
      // 🔥 Verificar token primero
      final token = await AuthStorageService.getToken();
      debugPrint('📥 [Controller] Token disponible: ${token != null ? "SÍ" : "NO"}');
      
      if (token == null) {
        debugPrint('❌ [Controller] No hay token, no se puede cargar usuario');
        _welcomeMessage = 'Bienvenido';
        _isLoadingUserData = false;
        notifyListeners();
        return;
      }
      
      // 🔥 Intentar cargar desde storage primero (más rápido)
      debugPrint('📥 [Controller] Intentando cargar desde storage local...');
      UserModel? user = await UserController.loadUserProfile(forceRefresh: false);
      
      if (user != null) {
        debugPrint('✅ [Controller] Usuario cargado desde storage:');
        debugPrint('   - Nombre: ${user.nombreCompleto}');
        debugPrint('   - Email: ${user.email}');
        debugPrint('   - ID: ${user.id}');
        
        _currentUser = user;
        _welcomeMessage = 'Bienvenido, ${user.firstName}';
        _hasLoadedOnce = true;
        
        // Actualizar UI inmediatamente
        _isLoadingUserData = false;
        notifyListeners();
        
        // 🔥 Refrescar en background desde API
        debugPrint('🔄 [Controller] Refrescando desde API en background...');
        _refreshUserInBackground();
        
      } else {
        // Si no hay en storage, forzar carga desde API
        debugPrint('⚠️ [Controller] No hay datos en storage, cargando desde API...');
        user = await UserController.loadUserProfile(forceRefresh: true);
        
        if (user != null) {
          debugPrint('✅ [Controller] Usuario cargado desde API:');
          debugPrint('   - Nombre: ${user.nombreCompleto}');
          debugPrint('   - Email: ${user.email}');
          debugPrint('   - ID: ${user.id}');
          
          _currentUser = user;
          _welcomeMessage = 'Bienvenido, ${user.firstName}';
          _hasLoadedOnce = true;
        } else {
          debugPrint('❌ [Controller] No se pudo cargar el usuario desde API');
          _welcomeMessage = 'Bienvenido';
        }
      }
      
      debugPrint('📥 [Controller] ==== FIN CARGA DE USUARIO ====');
      
    } catch (e, stackTrace) {
      debugPrint('💥 [Controller] ERROR cargando usuario: $e');
      debugPrint('💥 [Controller] Stack trace: $stackTrace');
      _welcomeMessage = 'Bienvenido';
    } finally {
      _isLoadingUserData = false;
      notifyListeners();
    }
  }

  /// 🆕 Refresca el usuario en background sin bloquear la UI
  Future<void> _refreshUserInBackground() async {
    try {
      debugPrint('🔄 [Controller] Refrescando usuario en background...');
      
      final user = await UserController.loadUserProfile(forceRefresh: true);
      
      if (user != null && user.id != _currentUser?.id) {
        debugPrint('🔄 [Controller] Usuario actualizado en background');
        _currentUser = user;
        _welcomeMessage = 'Bienvenido, ${user.firstName}';
        notifyListeners();
      } else {
        debugPrint('ℹ️ [Controller] Usuario sin cambios');
      }
      
    } catch (e) {
      debugPrint('⚠️ [Controller] Error refrescando en background: $e');
      // No hacer nada, ya tenemos datos del storage
    }
  }

  /// 🆕 Método público para refrescar datos del usuario (fuerza recarga completa)
  Future<void> refreshUserData() async {
    debugPrint('🔄 [Controller] Refresh manual solicitado');
    _hasLoadedOnce = false; // Permitir recarga
    await _loadUserData();
  }

  /// 🆕 Método para limpiar datos del usuario (útil después de logout)
  void clearUserData() {
    debugPrint('🗑️ [Controller] Limpiando datos de usuario...');
    _currentUser = null;
    _welcomeMessage = 'Bienvenido';
    _hasLoadedOnce = false;
    _isLoadingUserData = false;
    notifyListeners();
    debugPrint('✅ [Controller] Datos de usuario limpiados');
  }

  // ==================== NAVEGACIÓN ====================
  
  void setInitialIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      _pageController.jumpToPage(index);
      notifyListeners();
    }
  }

  void onPageChanged(int newIndex, UserRole currentRole) {
    if (!NavigationConfig.isValidIndex(newIndex, currentRole)) {
      debugPrint('⚠️ Índice inválido: $newIndex para rol ${currentRole.name}');
      return;
    }
    
    if (newIndex == _currentIndex) return;
    
    final bool isMovingRight = newIndex > _currentIndex;
    
    _updateAnimations(isMovingRight: isMovingRight);
    
    _currentIndex = newIndex;
    notifyListeners();
    
    _animationController?.reset();
    _animationController?.forward();
  }

  void onNavIndexChanged(int newIndex, UserRole currentRole) {
    if (!NavigationConfig.isValidIndex(newIndex, currentRole)) {
      debugPrint('⚠️ Índice inválido: $newIndex para rol ${currentRole.name}');
      return;
    }
    
    if (newIndex == _currentIndex) return;
    
    final bool isMovingRight = newIndex > _currentIndex;
    
    _updateAnimations(isMovingRight: isMovingRight);
    
    _currentIndex = newIndex;
    notifyListeners();
    
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    
    _animationController?.reset();
    _animationController?.forward();
  }

  // ==================== ANIMACIONES ====================
  
  void _updateAnimations({required bool isMovingRight}) {
    if (_animationController == null) return;
    
    final Offset beginOffset = isMovingRight
        ? const Offset(0.25, 0.0)
        : const Offset(-0.25, 0.0);
    
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));
  }

  // ==================== LOGOUT ====================
  
  Future<void> executeLogout() async {
    if (_isLoggingOut) return;
    
    _isLoggingOut = true;
    notifyListeners();

    try {
      debugPrint('🔴 [Controller] Iniciando logout...');
      
      // Delay para mostrar la animación
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // 🔥 Limpiar datos del usuario primero
      clearUserData();
      
      await AuthStorageService.clearAuthData();
      await UserController.clearUserProfile();

      // Limpiar cachés generales
      CareersService().clearCache();
      QuestionsService().clearCache();
      SubjectsService().clearCache();

      // Limpiar cachés de servicios admin
      AdminDashboardService().clearCache();
      AdminAnalysisService().clearCache();
      TeacherReportService().clearAllCache();
      
      debugPrint('✅ [Controller] Logout completado');
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
    } catch (e) {
      debugPrint('💥 [Controller] ERROR durante logout: $e');
      rethrow;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  // ==================== HELPERS ====================
  
  String getSubtitleForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '@Panel de estudiante';
      case UserRole.teacher:
        return '@Panel de docente';
      case UserRole.admin:
        return '@Panel de administrador';
    }
  }
}