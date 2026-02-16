import 'package:eval_plus/services/storage/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:eval_plus/models/user_model.dart';

/// Servicio para almacenar el perfil del usuario - MEJORADO PARA WINDOWS
class UserStorageService {
  static SecureStorageService? _storage;
  static const _userProfileKey = 'user_profile';

  /// Inicializa el servicio de storage
  static Future<void> _ensureInitialized() async {
    if (_storage == null) {
      debugPrint('🔧 [UserStorage] Inicializando storage...');
      _storage = await SecureStorageService.getInstance();
      debugPrint('✅ [UserStorage] Storage inicializado: ${_storage!.platformName}');
    }
  }

  /// Guarda el perfil completo del usuario - MEJORADO CON VERIFICACIÓN
  static Future<void> saveUserProfile(UserModel user) async {
    try {
      await _ensureInitialized();
      
      debugPrint('💾 [UserStorage] ==== INICIO GUARDADO DE PERFIL ====');
      debugPrint('💾 [UserStorage] Perfil a guardar:');
      debugPrint('   - Nombre: ${user.nombreCompleto}');
      debugPrint('   - Email: ${user.email}');
      debugPrint('   - ID: ${user.id}');
      
      // Convertir a JSON
      final userJson = jsonEncode(user.toJson());
      debugPrint('💾 [UserStorage] JSON generado (primeros 100 chars): ${userJson.substring(0, userJson.length > 100 ? 100 : userJson.length)}...');
      
      // Guardar
      await _storage!.write(key: _userProfileKey, value: userJson);
      debugPrint('✅ [UserStorage] Perfil guardado en storage');
      
      // 🔥 VERIFICACIÓN INMEDIATA: Leer para confirmar
      debugPrint('🔍 [UserStorage] Verificando guardado...');
      final verification = await _storage!.read(key: _userProfileKey);
      
      if (verification != null) {
        try {
          final verifiedUser = UserModel.fromJson(jsonDecode(verification));
          debugPrint('✅ [UserStorage] Verificación exitosa:');
          debugPrint('   - Nombre verificado: ${verifiedUser.nombreCompleto}');
          debugPrint('   - Email verificado: ${verifiedUser.email}');
          
          if (verifiedUser.id == user.id && 
              verifiedUser.email == user.email &&
              verifiedUser.nombreCompleto == user.nombreCompleto) {
            debugPrint('✅ [UserStorage] Datos coinciden 100%');
          } else {
            debugPrint('⚠️ [UserStorage] Advertencia: datos no coinciden exactamente');
          }
        } catch (e) {
          debugPrint('❌ [UserStorage] Error en verificación: $e');
        }
      } else {
        debugPrint('❌ [UserStorage] ERROR: No se pudo verificar el guardado');
      }
      
      debugPrint('💾 [UserStorage] ==== FIN GUARDADO DE PERFIL ====');
    } catch (e, stackTrace) {
      debugPrint('💥 [UserStorage] Error guardando perfil: $e');
      debugPrint('💥 [UserStorage] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el perfil del usuario almacenado - MEJORADO CON LOGS
  static Future<UserModel?> getUserProfile() async {
    try {
      await _ensureInitialized();
      
      debugPrint('📖 [UserStorage] ==== INICIO LECTURA DE PERFIL ====');
      debugPrint('📖 [UserStorage] Leyendo desde storage...');
      
      final userJson = await _storage!.read(key: _userProfileKey);

      if (userJson != null) {
        debugPrint('📖 [UserStorage] JSON encontrado (primeros 100 chars): ${userJson.substring(0, userJson.length > 100 ? 100 : userJson.length)}...');
        
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          final user = UserModel.fromJson(userMap);
          
          debugPrint('✅ [UserStorage] Perfil recuperado:');
          debugPrint('   - Nombre: ${user.nombreCompleto}');
          debugPrint('   - Email: ${user.email}');
          debugPrint('   - ID: ${user.id}');
          debugPrint('📖 [UserStorage] ==== FIN LECTURA DE PERFIL ====');
          
          return user;
        } catch (e) {
          debugPrint('💥 [UserStorage] Error parseando JSON: $e');
          debugPrint('💥 [UserStorage] JSON problemático: $userJson');
          return null;
        }
      }

      debugPrint('ℹ️ [UserStorage] No hay perfil almacenado');
      debugPrint('📖 [UserStorage] ==== FIN LECTURA DE PERFIL (vacío) ====');
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 [UserStorage] Error leyendo perfil: $e');
      debugPrint('💥 [UserStorage] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Actualiza campos específicos del perfil
  static Future<void> updateUserProfile(UserModel updatedUser) async {
    debugPrint('🔄 [UserStorage] Actualizando perfil...');
    await saveUserProfile(updatedUser);
  }

  /// Elimina el perfil del usuario - MEJORADO CON VERIFICACIÓN
  static Future<void> clearUserProfile() async {
    try {
      await _ensureInitialized();
      
      debugPrint('🗑️ [UserStorage] ==== INICIO LIMPIEZA DE PERFIL ====');
      
      // Verificar si existe antes de eliminar
      final exists = await _storage!.containsKey(key: _userProfileKey);
      debugPrint('🗑️ [UserStorage] Perfil existe: $exists');
      
      if (exists) {
        // Mostrar qué se va a eliminar
        final current = await getUserProfile();
        if (current != null) {
          debugPrint('📋 [UserStorage] Perfil a eliminar:');
          debugPrint('   - Nombre: ${current.nombreCompleto}');
          debugPrint('   - Email: ${current.email}');
        }
      }
      
      // Eliminar
      await _storage!.delete(key: _userProfileKey);
      debugPrint('✅ [UserStorage] Perfil eliminado de storage');
      
      // 🔥 VERIFICACIÓN: Confirmar eliminación
      final stillExists = await _storage!.containsKey(key: _userProfileKey);
      if (!stillExists) {
        debugPrint('✅ [UserStorage] Verificación: perfil eliminado correctamente');
      } else {
        debugPrint('⚠️ [UserStorage] Advertencia: perfil aún existe después de eliminar');
      }
      
      debugPrint('🗑️ [UserStorage] ==== FIN LIMPIEZA DE PERFIL ====');
    } catch (e, stackTrace) {
      debugPrint('💥 [UserStorage] Error eliminando perfil: $e');
      debugPrint('💥 [UserStorage] Stack trace: $stackTrace');
    }
  }

  /// Verifica si existe un perfil almacenado
  static Future<bool> hasUserProfile() async {
    try {
      await _ensureInitialized();
      final exists = await _storage!.containsKey(key: _userProfileKey);
      debugPrint('🔍 [UserStorage] ¿Tiene perfil?: $exists');
      return exists;
    } catch (e) {
      debugPrint('💥 [UserStorage] Error verificando perfil: $e');
      return false;
    }
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
  
  // ==================== 🆕 MÉTODO DE DIAGNÓSTICO ====================
  
  /// Diagnóstico completo del storage (útil para debugging)
  static Future<Map<String, dynamic>> diagnose() async {
    try {
      await _ensureInitialized();
      
      debugPrint('🔍 [UserStorage] ==== DIAGNÓSTICO DE STORAGE ====');
      
      final platform = await getPlatformName();
      final isSecure = await isSecureStorage();
      final hasProfile = await hasUserProfile();
      final profile = await getUserProfile();
      
      final result = {
        'platform': platform,
        'isSecure': isSecure,
        'hasProfile': hasProfile,
        'profileData': profile != null ? {
          'nombre': profile.nombreCompleto,
          'email': profile.email,
          'id': profile.id,
        } : null,
      };
      
      debugPrint('📊 [UserStorage] Diagnóstico:');
      debugPrint('   - Plataforma: $platform');
      debugPrint('   - Seguro: $isSecure');
      debugPrint('   - Tiene perfil: $hasProfile');
      debugPrint('   - Perfil: ${profile?.nombreCompleto ?? "null"}');
      debugPrint('🔍 [UserStorage] ==== FIN DIAGNÓSTICO ====');
      
      return result;
    } catch (e) {
      debugPrint('💥 [UserStorage] Error en diagnóstico: $e');
      return {'error': e.toString()};
    }
  }
}