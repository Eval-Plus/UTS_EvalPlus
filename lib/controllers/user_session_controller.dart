import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/services/api/roles_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Controlador para gestionar la sesión del usuario
/// Incluye: rol, tema, permisos y displayName
class UserSessionController extends ChangeNotifier {
  // ==================== ESTADO ====================
  
  UserRole _currentRole = UserRole.student;
  RoleColorPalette _currentPalette = AppColors.getPaletteForRole(UserRole.student);
  String _roleDisplayName = 'Estudiante';
  List<RoleInfo> _userRoles = [];
  bool _isLoading = false;
  
  // ==================== GETTERS ====================
  
  UserRole get currentRole => _currentRole;
  RoleColorPalette get palette => _currentPalette;
  String get roleDisplayName => _roleDisplayName;
  List<RoleInfo> get userRoles => _userRoles;
  bool get isLoading => _isLoading;
  
  // Getters de conveniencia para permisos
  bool get isStudent => _currentRole == UserRole.student;
  bool get isTeacher => _currentRole == UserRole.teacher;
  bool get isAdmin => _currentRole == UserRole.admin;
  
  // ==================== MÉTODOS PÚBLICOS ====================
  
  /// Carga los roles del usuario y configura la sesión
  Future<void> loadUserSession() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('📦 Cargando sesión de usuario...');
      
      final token = await AuthStorageService.getToken();
      if (token == null) {
        debugPrint('❌ No hay token disponible');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Obtener roles desde el API
      final roles = await RolesApiService.fetchMyRoles(token);
      
      if (roles != null && roles.isNotEmpty) {
        _userRoles = roles;
        
        // Determinar el rol principal basado en prioridad
        final mainRoleInfo = _determineMainRole(roles);
        
        // Configurar sesión
        _currentRole = mainRoleInfo.role;
        _roleDisplayName = mainRoleInfo.displayName;
        _currentPalette = AppColors.getPaletteForRole(mainRoleInfo.role);
        
        debugPrint('✅ Sesión cargada:');
        debugPrint('   - Rol: ${mainRoleInfo.role.name}');
        debugPrint('   - Display: $_roleDisplayName');
        debugPrint('   - Roles totales: ${roles.length}');
      } else {
        debugPrint('⚠️ No se encontraron roles, usando default');
      }
      
    } catch (e) {
      debugPrint('💥 Error cargando sesión: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Refresca la sesión (útil después de cambios de rol)
  Future<void> refreshSession() async {
    await loadUserSession();
  }
  
  /// Resetea la sesión (útil para logout)
  void resetSession() {
    _currentRole = UserRole.student;
    _currentPalette = AppColors.getPaletteForRole(UserRole.student);
    _roleDisplayName = 'Estudiante';
    _userRoles = [];
    _isLoading = false;
    notifyListeners();
    
    debugPrint('🔄 Sesión reseteada');
  }
  
  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String roleName) {
    return _userRoles.any((role) => role.name == roleName);
  }
  
  /// Obtiene todos los displayNames de los roles
  List<String> getAllRoleDisplayNames() {
    return _userRoles.map((r) => r.displayName).toList();
  }
  
  // ==================== MÉTODOS PRIVADOS ====================
  
  /// Determina el rol principal con prioridad ADMIN > TEACHER > STUDENT
  _RoleWithDisplay _determineMainRole(List<RoleInfo> roles) {
    // Buscar ADMIN
    for (var role in roles) {
      if (role.name == 'ADMIN') {
        return _RoleWithDisplay(
          UserRole.admin,
          role.displayName,
        );
      }
    }
    
    // Buscar TEACHER
    for (var role in roles) {
      if (role.name == 'TEACHER') {
        return _RoleWithDisplay(
          UserRole.teacher,
          role.displayName,
        );
      }
    }
    
    // Buscar STUDENT
    for (var role in roles) {
      if (role.name == 'STUDENT') {
        return _RoleWithDisplay(
          UserRole.student,
          role.displayName,
        );
      }
    }
    
    // Fallback al primer rol
    if (roles.isNotEmpty) {
      return _RoleWithDisplay(
        UserRole.student, // Default
        roles.first.displayName,
      );
    }
    
    return _RoleWithDisplay(UserRole.student, 'Estudiante');
  }
}

/// Clase auxiliar interna
class _RoleWithDisplay {
  final UserRole role;
  final String displayName;
  
  _RoleWithDisplay(this.role, this.displayName);
}
