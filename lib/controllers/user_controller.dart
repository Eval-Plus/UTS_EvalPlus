import 'package:flutter/foundation.dart';
import 'package:eval_plus/models/user_model.dart';
import 'package:eval_plus/services/api/profile_api_service.dart';
import 'package:eval_plus/services/storage/user_storage_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

class UserController {
  /// Obtiene y guarda el perfil del usuario
  /// Primero intenta desde el backend, luego desde cache
  static Future<UserModel?> loadUserProfile({
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Obtener token
      final token = await AuthStorageService.getToken();

      if (token == null) {
        debugPrint('❌ No hay token disponible');
        return null;
      }

      // 2. Si no se fuerza refresh, intentar desde cache
      if (!forceRefresh) {
        final cachedProfile = await UserStorageService.getUserProfile();
        if (cachedProfile != null) {
          debugPrint('⚡ Usando perfil desde cache');
          // Actualizar en background sin bloquear
          _refreshProfileInBackground(token);
          return cachedProfile;
        }
      }

      // 3. Obtener desde API
      debugPrint('🌐 Consultando perfil desde API...');
      final profile = await ProfileApiService.fetchUserProfile(token);

      if (profile != null) {
        // Guardar en cache
        await UserStorageService.saveUserProfile(profile);
        debugPrint('✅ Perfil obtenido y guardado');
        return profile;
      }

      debugPrint('❌ No se pudo obtener el perfil');
      return null;
    } catch (e) {
      debugPrint('💥 Error cargando perfil: $e');

      // Fallback: intentar retornar cache
      final cachedProfile = await UserStorageService.getUserProfile();
      if (cachedProfile != null) {
        debugPrint('⚠️ Usando cache como fallback');
        return cachedProfile;
      }

      return null;
    }
  }

  /// Actualiza el perfil en segundo plano
  static Future<void> _refreshProfileInBackground(String token) async {
    try {
      debugPrint('🔄 Actualizando perfil en background...');
      final profile = await ProfileApiService.fetchUserProfile(token);

      if (profile != null) {
        await UserStorageService.saveUserProfile(profile);
        debugPrint('✅ Perfil actualizado en background');
      }
    } catch (e) {
      debugPrint('⚠️ Error actualizando en background: $e');
      // No hacer nada, el usuario ya tiene datos del cache
    }
  }

  /// Refresca el perfil forzando una llamada al API
  static Future<UserModel?> refreshProfile() async {
    return await loadUserProfile(forceRefresh: true);
  }

  /// Actualiza el perfil del usuario (PUT)
  static Future<UserModel?> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      final token = await AuthStorageService.getToken();

      if (token == null) {
        debugPrint('❌ No hay token disponible');
        return null;
      }

      final updatedProfile = await ProfileApiService.updateUserProfile(
        token: token,
        updates: updates,
      );

      if (updatedProfile != null) {
        // Guardar en cache
        await UserStorageService.saveUserProfile(updatedProfile);
        debugPrint('✅ Perfil actualizado');
        return updatedProfile;
      }

      return null;
    } catch (e) {
      debugPrint('💥 Error actualizando perfil: $e');
      return null;
    }
  }

  /// Limpia el perfil del usuario (logout)
  static Future<void> clearUserProfile() async {
    await UserStorageService.clearUserProfile();
    debugPrint('🗑️ Perfil limpiado');
  }
}
