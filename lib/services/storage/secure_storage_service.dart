import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio unificado de almacenamiento seguro que adapta el storage según la plataforma
/// - Windows: usa SharedPreferences (problemas con flutter_secure_storage en Windows 11)
/// - Android/iOS/Linux: usa FlutterSecureStorage
/// - Web: usa SharedPreferences
/// 
/// 🔧 MEJORADO: Manejo de archivos corruptos y reintentos
class SecureStorageService {
  static SecureStorageService? _instance;
  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _sharedPrefs;
  static bool _isWindows = false;
  static bool _hasHandledCorruption = false; // 🆕 Para evitar loops infinitos

  SecureStorageService._();

  /// Inicializa el servicio de storage apropiado según la plataforma
  static Future<SecureStorageService> getInstance() async {
    if (_instance != null) return _instance!;

    _instance = SecureStorageService._();

    // Detectar plataforma
    if (kIsWeb) {
      _isWindows = false;
      _sharedPrefs = await SharedPreferences.getInstance();
      debugPrint('🌐 [Storage] Usando SharedPreferences (Web)');
    } else {
      try {
        _isWindows = Platform.isWindows;
      } catch (e) {
        _isWindows = false;
      }

      if (_isWindows) {
        // Windows: usar SharedPreferences
        _sharedPrefs = await SharedPreferences.getInstance();
        debugPrint('🪟 [Storage] Usando SharedPreferences (Windows)');
      } else {
        // Android/iOS/Linux: usar FlutterSecureStorage
        _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );
        debugPrint('🔐 [Storage] Usando FlutterSecureStorage (${Platform.operatingSystem})');
      }
    }

    return _instance!;
  }

  /// 🔧 MEJORADO: Lee un valor del storage con manejo de corrupción
  Future<String?> read({required String key}) async {
    try {
      if (_isWindows || kIsWeb) {
        return _sharedPrefs?.getString(key);
      } else {
        return await _secureStorage?.read(key: key);
      }
    } catch (e) {
      debugPrint('❌ [Storage] Error leyendo $key: $e');
      
      // 🔥 Si es error de corrupción, intentar limpiar y reintentar
      if (e.toString().contains('decrypt') || 
          e.toString().contains('corrupt') ||
          e.toString().contains('CryptUnprotectData')) {
        debugPrint('🔧 [Storage] Detectada corrupción de datos, limpiando...');
        await _handleCorruptedStorage();
        return null;
      }
      
      return null;
    }
  }

  /// 🔧 MEJORADO: Escribe un valor en el storage con reintentos
  Future<void> write({required String key, required String value}) async {
    int retries = 0;
    const maxRetries = 3;
    
    while (retries < maxRetries) {
      try {
        if (_isWindows || kIsWeb) {
          await _sharedPrefs?.setString(key, value);
        } else {
          await _secureStorage?.write(key: key, value: value);
        }
        return; // Éxito
      } catch (e) {
        retries++;
        debugPrint('❌ [Storage] Error escribiendo $key (intento $retries/$maxRetries): $e');
        
        if (retries >= maxRetries) {
          debugPrint('💥 [Storage] Falló después de $maxRetries intentos');
          rethrow;
        }
        
        // Esperar antes de reintentar
        await Future.delayed(Duration(milliseconds: 100 * retries));
      }
    }
  }

  /// Lee un valor del storage
  Future<void> delete({required String key}) async {
    try {
      if (_isWindows || kIsWeb) {
        await _sharedPrefs?.remove(key);
      } else {
        await _secureStorage?.delete(key: key);
      }
      debugPrint('✅ [Storage] $key eliminado');
    } catch (e) {
      debugPrint('❌ [Storage] Error eliminando $key: $e');
    }
  }

  /// 🔧 MEJORADO: Elimina todos los valores del storage con manejo de errores
  Future<void> deleteAll() async {
    try {
      debugPrint('🗑️ [Storage] Limpiando todo el storage...');
      
      if (_isWindows || kIsWeb) {
        await _sharedPrefs?.clear();
      } else {
        await _secureStorage?.deleteAll();
      }
      
      debugPrint('✅ [Storage] Storage limpiado exitosamente');
    } catch (e) {
      debugPrint('❌ [Storage] Error limpiando storage: $e');
      
      // 🔥 Si falla el deleteAll, intentar eliminar archivo corrupto manualmente
      if (!_isWindows && !kIsWeb) {
        await _handleCorruptedStorage();
      }
    }
  }

  /// 🆕 Maneja archivos de storage corruptos
  Future<void> _handleCorruptedStorage() async {
    if (_hasHandledCorruption) {
      debugPrint('⚠️ [Storage] Ya se manejó la corrupción, evitando loop');
      return;
    }
    
    try {
      _hasHandledCorruption = true;
      debugPrint('🔧 [Storage] Intentando recuperar de corrupción...');
      
      // Intentar recrear el storage
      if (!_isWindows && !kIsWeb) {
        _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            resetOnError: true, // 🔥 Importante: resetear en error
          ),
        );
        
        debugPrint('✅ [Storage] Storage recreado exitosamente');
      }
      
      // Resetear flag después de un tiempo
      Future.delayed(const Duration(seconds: 5), () {
        _hasHandledCorruption = false;
      });
      
    } catch (e) {
      debugPrint('💥 [Storage] Error manejando corrupción: $e');
    }
  }

  /// Verifica si existe una clave en el storage
  Future<bool> containsKey({required String key}) async {
    try {
      if (_isWindows || kIsWeb) {
        return _sharedPrefs?.containsKey(key) ?? false;
      } else {
        final value = await _secureStorage?.read(key: key);
        return value != null;
      }
    } catch (e) {
      debugPrint('❌ [Storage] Error verificando existencia de $key: $e');
      return false;
    }
  }

  /// Obtiene todas las claves almacenadas
  Future<Set<String>> getAllKeys() async {
    try {
      if (_isWindows || kIsWeb) {
        return _sharedPrefs?.getKeys() ?? {};
      } else {
        final map = await _secureStorage?.readAll();
        return map?.keys.toSet() ?? {};
      }
    } catch (e) {
      debugPrint('❌ [Storage] Error obteniendo claves: $e');
      return {};
    }
  }

  /// Indica si está usando storage seguro (encrypted)
  bool get isSecure => !_isWindows && !kIsWeb;

  /// Indica la plataforma actual
  String get platformName {
    if (kIsWeb) return 'Web';
    if (_isWindows) return 'Windows';
    try {
      return Platform.operatingSystem;
    } catch (e) {
      return 'Unknown';
    }
  }
}