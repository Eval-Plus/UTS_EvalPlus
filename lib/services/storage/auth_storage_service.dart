import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Servicio para manejar tokens y datos básicos de autenticación
/// El perfil completo del usuario se maneja en UserStorageService
class AuthStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data'; // Datos básicos del auth (deprecated en favor de UserStorageService)
  static const _isNewUserKey = 'is_new_user';

  // ==================== TOKEN ====================

  /// Guarda el token JWT
  static Future<void> saveToken({required String token}) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Obtiene el token JWT
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // ==================== DATOS BÁSICOS DE AUTH ====================

  /// Guarda datos básicos del usuario (solo para compatibilidad)
  /// Nota: Usa UserStorageService.saveUserProfile para datos completos
  static Future<void> saveUser({
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user),
    );
  }

  /// Obtiene datos básicos del usuario
  /// Nota: Usa UserStorageService.getUserProfile para datos completos
  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: _userKey);
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
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userKey, value: jsonEncode(user)),
      _storage.write(key: _isNewUserKey, value: isNewUser.toString()),
    ]);
  }

  /// Verifica si el usuario es nuevo
  static Future<bool> isNewUser() async {
    final value = await _storage.read(key: _isNewUserKey);
    return value == 'true';
  }

  // ==================== VERIFICACIÓN ====================

  /// Verifica si está autenticado (tiene token)
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== LIMPIEZA ====================

  /// Limpia todos los datos de autenticación
  static Future<void> clearAuthData() async {
    await _storage.deleteAll();
  }

  /// Limpia solo el token (mantiene otros datos)
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
