import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:eval_plus/models/user_model.dart';

class UserStorageService {
  static const _storage = FlutterSecureStorage();
  static const _userProfileKey = 'user_profile';

  /// Guarda el perfil completo del usuario
  static Future<void> saveUserProfile(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: _userProfileKey, value: userJson);
      debugPrint('💾 Perfil guardado: ${user.nombreCompleto}');
    } catch (e) {
      debugPrint('💥 Error guardando perfil: $e');
      rethrow;
    }
  }

  /// Obtiene el perfil del usuario almacenado
  static Future<UserModel?> getUserProfile() async {
    try {
      final userJson = await _storage.read(key: _userProfileKey);

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
      await _storage.delete(key: _userProfileKey);
      debugPrint('🗑️ Perfil eliminado');
    } catch (e) {
      debugPrint('💥 Error eliminando perfil: $e');
    }
  }

  /// Verifica si existe un perfil almacenado
  static Future<bool> hasUserProfile() async {
    final profile = await getUserProfile();
    return profile != null;
  }
}
