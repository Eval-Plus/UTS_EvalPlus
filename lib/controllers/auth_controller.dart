import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// WebViews
import 'package:eval_plus/webviews/microsoft_auth_webview.dart';

// Services
import 'package:eval_plus/services/api/auth_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

// Screens
import 'package:eval_plus/screen/inside_screen.dart';

// Widgets
import 'package:eval_plus/widgets/auth/jwt_auth.dart';

class AuthController {
  static const String _authUrl = 'https://evalplus-api.emprenet.work/api/auth/microsoft';

  /// Inicia el flujo de autenticación con Microsoft
  static Future<void> signInWithMicrosoft(BuildContext context) async {
    // Verificar si estamos en una plataforma que soporta WebView
    if (!_supportsWebView()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: ManualJwtAuthWidget(
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          fullscreenDialog: true,
        ),
      );
      return;
    }

    // Usar WebView para Android/iOS
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MicrosoftAuthWebView(
          authUrl: _authUrl,
          onAuthSuccess: (authData) async {
            await _handleAuthSuccess(context, authData);
          },
          onAuthError: () {
            _handleAuthError(context);
          },
        ),
      ),
    );
  }

  /// Verifica si la plataforma soporta WebView
  static bool _supportsWebView() {
    if (kIsWeb) return false;
    
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Maneja el éxito de la autenticación
  static Future<void> _handleAuthSuccess(
    BuildContext context,
    Map<String, dynamic> authData,
  ) async {
    try {
      print('Saving auth data...');
      print('Token exists: ${authData['token'] != null}');
      print('User exists: ${authData['user'] != null}');
      
      // Guardar los datos en secure storage
      await AuthStorageService.saveAuthData(
        token: authData['token'],
        user: authData['user'],
        isNewUser: authData['isNewUser'] ?? false,
      );
      
      print('Auth data saved successfully');
      
      if (context.mounted) {
        // Cerrar el WebView
        Navigator.of(context).pop();
        
        // Mostrar mensaje de éxito
        _showSuccessSnackBar(
          context,
          authData['isNewUser'] == true
              ? '¡Cuenta creada exitosamente!'
              : '¡Inicio de sesión exitoso!',
        );
        
        // Navegar a la pantalla principal
        Navigator.of(context).pushReplacementNamed(InsideScreen.routename);
      }
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      if (context.mounted) {
        _handleAuthError(context);
      }
    }
  }

  /// Maneja errores en la autenticación
  static void _handleAuthError(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión. Por favor, intenta nuevamente.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Muestra un mensaje de éxito
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Cierra sesión
  static Future<void> signOut(BuildContext context) async {
    await AuthStorageService.clearAuthData();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  /// Verifica si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    return await AuthStorageService.isAuthenticated();
  }
}
