import 'package:eval_plus/services/storage/secure_storage_service.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Servicio para manejar tokens y datos básicos de autenticación
/// El perfil completo del usuario se maneja en UserStorageService
class AuthStorageService {
  static SecureStorageService? _storage;

  // Keys
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data'; // Datos básicos del auth (deprecated en favor de UserStorageService)
  static const _isNewUserKey = 'is_new_user';

  /// Inicializa el servicio de storage
  static Future<void> _ensureInitialized() async {
    _storage ??= await SecureStorageService.getInstance();
  }

  // ==================== TOKEN ====================

  /// Guarda el token JWT
  static Future<void> saveToken({required String token}) async {
    await _ensureInitialized();
    await _storage!.write(key: _tokenKey, value: token);
    debugPrint('🔑 Token guardado');
  }

  /// Obtiene el token JWT
  static Future<String?> getToken() async {
    await _ensureInitialized();
    return await _storage!.read(key: _tokenKey);
  }

  // ==================== DATOS BÁSICOS DE AUTH ====================

  /// Guarda datos básicos del usuario (solo para compatibilidad)
  /// Nota: Usa UserStorageService.saveUserProfile para datos completos
  static Future<void> saveUser({
    required Map<String, dynamic> user,
  }) async {
    await _ensureInitialized();
    await _storage!.write(
      key: _userKey,
      value: jsonEncode(user),
    );
    debugPrint('👤 Datos básicos de usuario guardados');
  }

  /// Obtiene datos básicos del usuario
  /// Nota: Usa UserStorageService.getUserProfile para datos completos
  static Future<Map<String, dynamic>?> getUserData() async {
    await _ensureInitialized();
    final userData = await _storage!.read(key: _userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // ==================== AUTENTICACIÓN MÓVIL ====================

  /// Guarda datos completos de autenticación (Móvil con WebView)
  static Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> user,
    required bool isNewUser,
  }) async {
    await _ensureInitialized();
    
    await Future.wait([
      _storage!.write(key: _tokenKey, value: token),
      _storage!.write(key: _userKey, value: jsonEncode(user)),
      _storage!.write(key: _isNewUserKey, value: isNewUser.toString()),
    ]);
    
    debugPrint('💾 Datos de autenticación guardados completos');
  }

  /// Verifica si el usuario es nuevo
  static Future<bool> isNewUser() async {
    await _ensureInitialized();
    final value = await _storage!.read(key: _isNewUserKey);
    return value == 'true';
  }

  // ==================== VERIFICACIÓN ====================

  /// Verifica si está autenticado (tiene token)
  static Future<bool> isAuthenticated() async {
    await _ensureInitialized();
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== LIMPIEZA ====================

  /// Limpia todos los datos de autenticación
  static Future<void> clearAuthData() async {
    await _ensureInitialized();
    await _storage!.deleteAll();
    debugPrint('🗑️ Todos los datos de autenticación eliminados');
  }

  /// Limpia solo el token (mantiene otros datos)
  static Future<void> clearToken() async {
    await _ensureInitialized();
    await _storage!.delete(key: _tokenKey);
    debugPrint('🗑️ Token eliminado');
  }

  // ==================== INFO DE PLATAFORMA ====================

  /// Indica si el storage es seguro (encriptado)
  static Future<bool> isSecureStorage() async {
    await _ensureInitialized();
    return _storage!.isSecure;
  }

  /// Obtiene el nombre de la plataforma
  static Future<String> getPlatformName() async {
    await _ensureInitialized();
    return _storage!.platformName;
  }
}