import 'package:flutter/foundation.dart';
import 'package:eval_plus/models/user_model.dart';
import 'package:eval_plus/services/api/profile_api_service.dart';
import 'package:eval_plus/services/storage/user_storage_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

class UserController {
  /// Obtiene y guarda el perfil del usuario - MEJORADO
  /// Primero intenta desde el backend, luego desde cache
  static Future<UserModel?> loadUserProfile({
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('🔍 [UserController] ==== INICIO loadUserProfile ====');
      debugPrint('🔍 [UserController] forceRefresh: $forceRefresh');
      
      // 1. Obtener token
      final token = await AuthStorageService.getToken();

      if (token == null) {
        debugPrint('❌ [UserController] No hay token disponible');
        return null;
      }
      
      debugPrint('✅ [UserController] Token disponible');

      // 2. Si se fuerza refresh, consultar API directamente
      if (forceRefresh) {
        debugPrint('🔄 [UserController] Forzando refresh desde API...');
        final profile = await _fetchAndSaveProfile(token);
        debugPrint('🔍 [UserController] ==== FIN loadUserProfile (API) ====');
        return profile;
      }

      // 3. Intentar desde cache
      debugPrint('📦 [UserController] Intentando cargar desde storage...');
      final cachedProfile = await UserStorageService.getUserProfile();
      
      if (cachedProfile != null) {
        debugPrint('⚡ [UserController] Perfil encontrado en storage:');
        debugPrint('   - Nombre: ${cachedProfile.nombreCompleto}');
        debugPrint('   - Email: ${cachedProfile.email}');
        debugPrint('   - ID: ${cachedProfile.id}');
        
        // 🔥 IMPORTANTE: No actualizar en background si venimos de storage
        // para evitar múltiples llamadas concurrentes
        debugPrint('🔍 [UserController] ==== FIN loadUserProfile (Cache) ====');
        return cachedProfile;
      }

      // 4. Si no hay cache, obtener desde API
      debugPrint('📡 [UserController] No hay cache, consultando API...');
      final profile = await _fetchAndSaveProfile(token);
      debugPrint('🔍 [UserController] ==== FIN loadUserProfile (API fallback) ====');
      return profile;

    } catch (e, stackTrace) {
      debugPrint('💥 [UserController] Error cargando perfil: $e');
      debugPrint('💥 [UserController] Stack trace: $stackTrace');

      // Fallback: intentar retornar cache
      try {
        final cachedProfile = await UserStorageService.getUserProfile();
        if (cachedProfile != null) {
          debugPrint('⚠️ [UserController] Usando cache como fallback');
          return cachedProfile;
        }
      } catch (cacheError) {
        debugPrint('💥 [UserController] Error accediendo al cache: $cacheError');
      }

      return null;
    }
  }

  /// 🆕 Obtiene el perfil desde API y lo guarda - CON LOGS MEJORADOS
  static Future<UserModel?> _fetchAndSaveProfile(String token) async {
    try {
      debugPrint('📡 [UserController] Consultando API...');
      
      final profile = await ProfileApiService.fetchUserProfile(token);

      if (profile != null) {
        debugPrint('✅ [UserController] Perfil obtenido de API:');
        debugPrint('   - Nombre: ${profile.nombreCompleto}');
        debugPrint('   - Email: ${profile.email}');
        debugPrint('   - ID: ${profile.id}');
        
        // Guardar en storage
        debugPrint('💾 [UserController] Guardando perfil en storage...');
        await UserStorageService.saveUserProfile(profile);
        debugPrint('✅ [UserController] Perfil guardado exitosamente');
        
        // 🔥 Verificar que se guardó correctamente
        final verification = await UserStorageService.getUserProfile();
        if (verification != null) {
          debugPrint('✅ [UserController] Verificación: perfil guardado OK');
          debugPrint('   - Nombre verificado: ${verification.nombreCompleto}');
        } else {
          debugPrint('⚠️ [UserController] Advertencia: verificación falló');
        }
        
        return profile;
      }

      debugPrint('❌ [UserController] API no retornó perfil');
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 [UserController] Error obteniendo perfil: $e');
      debugPrint('💥 [UserController] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Refresca el perfil forzando una llamada al API
  static Future<UserModel?> refreshProfile() async {
    debugPrint('🔄 [UserController] Refresh manual solicitado');
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
      debugPrint('🗑️ [UserController] ==== INICIO LIMPIEZA DE PERFIL ====');
      
      // Verificar si hay perfil antes de limpiar
      final currentProfile = await UserStorageService.getUserProfile();
      if (currentProfile != null) {
        debugPrint('📋 [UserController] Perfil a limpiar:');
        debugPrint('   - Nombre: ${currentProfile.nombreCompleto}');
        debugPrint('   - Email: ${currentProfile.email}');
        debugPrint('   - ID: ${currentProfile.id}');
      } else {
        debugPrint('ℹ️ [UserController] No hay perfil para limpiar');
      }
      
      await UserStorageService.clearUserProfile();
      debugPrint('✅ [UserController] Perfil limpiado');
      
      // Verificar limpieza
      final afterClear = await UserStorageService.getUserProfile();
      if (afterClear == null) {
        debugPrint('✅ [UserController] Verificación: perfil eliminado OK');
      } else {
        debugPrint('⚠️ [UserController] Advertencia: perfil aún existe después de limpiar');
        debugPrint('   - Datos residuales: ${afterClear.nombreCompleto}');
      }
      
      debugPrint('🗑️ [UserController] ==== FIN LIMPIEZA DE PERFIL ====');
    } catch (e, stackTrace) {
      debugPrint('💥 [UserController] Error limpiando perfil: $e');
      debugPrint('💥 [UserController] Stack trace: $stackTrace');
    }
  }
}