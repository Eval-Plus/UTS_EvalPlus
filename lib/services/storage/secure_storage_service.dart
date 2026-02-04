import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio unificado de almacenamiento seguro que adapta el storage según la plataforma
/// - Windows: usa SharedPreferences (problemas con flutter_secure_storage en Windows 11)
/// - Android/iOS/Linux: usa FlutterSecureStorage
/// - Web: usa SharedPreferences
class SecureStorageService {
  static SecureStorageService? _instance;
  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _sharedPrefs;
  static bool _isWindows = false;

  SecureStorageService._();

  /// Inicializa el servicio de storage apropiado según la plataforma
  static Future<SecureStorageService> getInstance() async {
    if (_instance != null) return _instance!;

    _instance = SecureStorageService._();

    // Detectar plataforma
    if (kIsWeb) {
      _isWindows = false;
      _sharedPrefs = await SharedPreferences.getInstance();
      debugPrint('🌐 Storage: Usando SharedPreferences (Web)');
    } else {
      try {
        _isWindows = Platform.isWindows;
      } catch (e) {
        _isWindows = false;
      }

      if (_isWindows) {
        // Windows: usar SharedPreferences
        _sharedPrefs = await SharedPreferences.getInstance();
        debugPrint('🪟 Storage: Usando SharedPreferences (Windows)');
      } else {
        // Android/iOS/Linux: usar FlutterSecureStorage
        _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );
        debugPrint('🔐 Storage: Usando FlutterSecureStorage (${Platform.operatingSystem})');
      }
    }

    return _instance!;
  }

  /// Lee un valor del storage
  Future<String?> read({required String key}) async {
    try {
      if (_isWindows || kIsWeb) {
        return _sharedPrefs?.getString(key);
      } else {
        return await _secureStorage?.read(key: key);
      }
    } catch (e) {
      debugPrint('❌ Error leyendo $key: $e');
      return null;
    }
  }

  /// Escribe un valor en el storage
  Future<void> write({required String key, required String value}) async {
    try {
      if (_isWindows || kIsWeb) {
        await _sharedPrefs?.setString(key, value);
      } else {
        await _secureStorage?.write(key: key, value: value);
      }
    } catch (e) {
      debugPrint('❌ Error escribiendo $key: $e');
      rethrow;
    }
  }

  /// Elimina un valor del storage
  Future<void> delete({required String key}) async {
    try {
      if (_isWindows || kIsWeb) {
        await _sharedPrefs?.remove(key);
      } else {
        await _secureStorage?.delete(key: key);
      }
    } catch (e) {
      debugPrint('❌ Error eliminando $key: $e');
    }
  }

  /// Elimina todos los valores del storage
  Future<void> deleteAll() async {
    try {
      if (_isWindows || kIsWeb) {
        await _sharedPrefs?.clear();
      } else {
        await _secureStorage?.deleteAll();
      }
    } catch (e) {
      debugPrint('❌ Error limpiando storage: $e');
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
      debugPrint('❌ Error verificando existencia de $key: $e');
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
      debugPrint('❌ Error obteniendo claves: $e');
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