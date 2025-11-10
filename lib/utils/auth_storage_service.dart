import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  static const _isNewUserKey = 'is_new_user';

  // Guardar Token JWT (PC)
  static Future<void> saveToken({
    required String token,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
    ]);
  }

  // Guardar datos de autenticación (Movil)
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

  // Obtener token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Obtener datos de usuario
  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Verificar si el usuario es nuevo
  static Future<bool> isNewUser() async {
    final value = await _storage.read(key: _isNewUserKey);
    return value == 'true';
  }

  // Verificar si está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Limpiar datos de autenticación
  static Future<void> clearAuthData() async {
    await _storage.deleteAll();
  }
}
