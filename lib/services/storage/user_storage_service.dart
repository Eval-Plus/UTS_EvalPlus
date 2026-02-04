import 'package:eval_plus/services/storage/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:eval_plus/models/user_model.dart';

class UserStorageService {
  static SecureStorageService? _storage;
  static const _userProfileKey = 'user_profile';

  /// Inicializa el servicio de storage
  static Future<void> _ensureInitialized() async {
    _storage ??= await SecureStorageService.getInstance();
  }

  /// Guarda el perfil completo del usuario
  static Future<void> saveUserProfile(UserModel user) async {
    try {
      await _ensureInitialized();
      final userJson = jsonEncode(user.toJson());
      await _storage!.write(key: _userProfileKey, value: userJson);
      debugPrint('💾 Perfil guardado: ${user.nombreCompleto}');
    } catch (e) {
      debugPrint('💥 Error guardando perfil: $e');
      rethrow;
    }
  }

  /// Obtiene el perfil del usuario almacenado
  static Future<UserModel?> getUserProfile() async {
    try {
      await _ensureInitialized();
      final userJson = await _storage!.read(key: _userProfileKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        debugPrint('📖 Perfil recuperado: ${user.nombreCompleto}');
        return user;
      }

      debugPrint('ℹ️ No hay perfil almacenado');
      return null;
    } catch (e) {
      debugPrint('💥 Error leyendo perfil: $e');
      return null;
    }
  }

  /// Actualiza campos específicos del perfil
  static Future<void> updateUserProfile(UserModel updatedUser) async {
    await saveUserProfile(updatedUser);
  }

  /// Elimina el perfil del usuario
  static Future<void> clearUserProfile() async {
    try {
      await _ensureInitialized();
      await _storage!.delete(key: _userProfileKey);
      debugPrint('🗑️ Perfil eliminado');
    } catch (e) {
      debugPrint('💥 Error eliminando perfil: $e');
    }
  }

  /// Verifica si existe un perfil almacenado
  static Future<bool> hasUserProfile() async {
    await _ensureInitialized();
    final profile = await getUserProfile();
    return profile != null;
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