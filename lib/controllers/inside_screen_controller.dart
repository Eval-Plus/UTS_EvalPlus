/// Controlador para la pantalla principal (Inside Screen)
/// Ubicación: lib/controllers/inside_screen_controller.dart

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

class InsideScreenController extends ChangeNotifier {
  // ==================== ESTADO ====================
  
  int _currentIndex = 0;
  UserModel? _currentUser;
  String _welcomeMessage = 'Bienvenido';
  bool _isLoggingOut = false;
  
  // PageController para manejar el swipe
  late PageController _pageController;
  
  // AnimationController (se inicializa desde el widget)
  AnimationController? _animationController;
  
  // Animaciones
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 🆕 Controladores de Admin (lazy initialization)
  AdminAnalysisController? _adminAnalysisController;
  AdminConfigController? _adminConfigController;

  // ==================== GETTERS ====================
  
  int get currentIndex => _currentIndex;
  UserModel? get currentUser => _currentUser;
  String get welcomeMessage => _welcomeMessage;
  bool get isLoggingOut => _isLoggingOut;
  PageController get pageController => _pageController;
  
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;

  // 🆕 Getters para controladores de admin (lazy initialization)
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
  }

  void initialize(AnimationController animationController) {
    _animationController = animationController;
    _updateAnimations(isMovingRight: true);
    _animationController?.value = 1.0;
    _loadUserData();
  }

  @override
  void dispose() {
    debugPrint('🎯 [InsideScreenController] Disposing...');
    _pageController.dispose();
    
    // Dispose admin controllers si fueron creados
    _adminAnalysisController?.dispose();
    _adminConfigController?.dispose();
    
    super.dispose();
  }

  // ==================== CARGA DE DATOS ====================
  
  Future<void> _loadUserData() async {
    final user = await UserController.loadUserProfile();
    
    if (user != null) {
      _currentUser = user;
      _welcomeMessage = 'Bienvenido, ${user.firstName}';
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
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
      debugPrint('🔴 Clearing auth data...');
      
      // Delay para mostrar la animación
      await Future.delayed(const Duration(milliseconds: 1500));
      
      await AuthStorageService.clearAuthData();
      await UserController.clearUserProfile();

      // Limpiar cachés
      CareersService().clearCache();
      QuestionsService().clearCache();
      SubjectsService().clearCache();
      
      debugPrint('🔴 Auth data cleared');
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
    } catch (e) {
      debugPrint('🔴 ERROR during logout: $e');
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
