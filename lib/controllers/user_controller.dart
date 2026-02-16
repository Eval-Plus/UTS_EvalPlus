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
        debugPrint('❌ [UserController] No hay token disponible');
        return null;
      }

      // 2. Si se fuerza refresh, consultar API directamente
      if (forceRefresh) {
        debugPrint('🔄 [UserController] Forzando refresh desde API...');
        return await _fetchAndSaveProfile(token);
      }

      // 3. Intentar desde cache
      final cachedProfile = await UserStorageService.getUserProfile();
      if (cachedProfile != null) {
        debugPrint('⚡ [UserController] Usando perfil desde cache');
        debugPrint('   - Nombre: ${cachedProfile.nombreCompleto}');
        debugPrint('   - Email: ${cachedProfile.email}');
        
        // Actualizar en background sin bloquear
        _refreshProfileInBackground(token);
        return cachedProfile;
      }

      // 4. Si no hay cache, obtener desde API
      debugPrint('🌐 [UserController] No hay cache, consultando API...');
      return await _fetchAndSaveProfile(token);

    } catch (e) {
      debugPrint('💥 [UserController] Error cargando perfil: $e');

      // Fallback: intentar retornar cache
      final cachedProfile = await UserStorageService.getUserProfile();
      if (cachedProfile != null) {
        debugPrint('⚠️ [UserController] Usando cache como fallback');
        return cachedProfile;
      }

      return null;
    }
  }

  /// 🆕 Obtiene el perfil desde API y lo guarda
  static Future<UserModel?> _fetchAndSaveProfile(String token) async {
    try {
      final profile = await ProfileApiService.fetchUserProfile(token);

      if (profile != null) {
        await UserStorageService.saveUserProfile(profile);
        debugPrint('✅ [UserController] Perfil obtenido y guardado');
        debugPrint('   - Nombre: ${profile.nombreCompleto}');
        debugPrint('   - Email: ${profile.email}');
        return profile;
      }

      debugPrint('❌ [UserController] API no retornó perfil');
      return null;
    } catch (e) {
      debugPrint('💥 [UserController] Error obteniendo perfil: $e');
      return null;
    }
  }

  /// Actualiza el perfil en segundo plano
  static Future<void> _refreshProfileInBackground(String token) async {
    try {
      debugPrint('🔄 [UserController] Actualizando perfil en background...');
      final profile = await ProfileApiService.fetchUserProfile(token);

      if (profile != null) {
        await UserStorageService.saveUserProfile(profile);
        debugPrint('✅ [UserController] Perfil actualizado en background');
      }
    } catch (e) {
      debugPrint('⚠️ [UserController] Error actualizando en background: $e');
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
        debugPrint('❌ [UserController] No hay token disponible');
        return null;
      }

      final updatedProfile = await ProfileApiService.updateUserProfile(
        token: token,
        updates: updates,
      );

      if (updatedProfile != null) {
        // Guardar en cache
        await UserStorageService.saveUserProfile(updatedProfile);
        debugPrint('✅ [UserController] Perfil actualizado');
        return updatedProfile;
      }

      return null;
    } catch (e) {
      debugPrint('💥 [UserController] Error actualizando perfil: $e');
      return null;
    }
  }

  /// 🔧 MEJORADO: Limpia el perfil del usuario con logs detallados
  static Future<void> clearUserProfile() async {
    try {
      debugPrint('🗑️ [UserController] Limpiando perfil del usuario...');
      
      // Verificar si hay perfil antes de limpiar
      final currentProfile = await UserStorageService.getUserProfile();
      if (currentProfile != null) {
        debugPrint('   - Perfil a limpiar: ${currentProfile.nombreCompleto}');
      } else {
        debugPrint('   - No hay perfil para limpiar');
      }
      
      await UserStorageService.clearUserProfile();
      debugPrint('✅ [UserController] Perfil limpiado exitosamente');
      
      // Verificar limpieza
      final afterClear = await UserStorageService.getUserProfile();
      if (afterClear == null) {
        debugPrint('✅ [UserController] Verificación: perfil eliminado correctamente');
      } else {
        debugPrint('⚠️ [UserController] Advertencia: perfil aún existe después de limpiar');
      }
    } catch (e) {
      debugPrint('💥 [UserController] Error limpiando perfil: $e');
    }
  }
}