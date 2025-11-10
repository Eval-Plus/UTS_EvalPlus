import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// WebViews
import 'package:eval_plus/webviews/microsoft_auth_webview.dart';

// Utils
import 'package:eval_plus/utils/auth_storage_service.dart';

// Screens
import 'package:eval_plus/screen/inside_screen.dart';

// Widgets
import 'package:eval_plus/widgets/jwt_auth.dart';

class AuthController {
  static const String _authUrl = 'https://evalplus-api.emprenet.work/api/auth/microsoft';

  /// Inicia el flujo de autenticación con Microsoft
  static Future<void> signInWithMicrosoft(BuildContext context) async {
    // Verificar si estamos en una plataforma que soporta WebView
    if (!_supportsWebView()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.grey.withOpacity(0.7),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ManualJwtAuthWidget(
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  onTokenSubmit: (token) async {
                    await AuthStorageService.saveToken(token: token);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(
                        InsideScreen.routename,
                      );
                    }
                  },
                ),
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

  /// Muestra mensaje para plataformas desktop
  static void _showDesktopNotSupported(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plataforma no soportada'),
        content: const Text(
          'La autenticación con Microsoft actualmente solo está disponible '
          'en dispositivos móviles (Android/iOS).\n\n'
          'Para desarrollo en desktop, puedes ingresar manualmente un JWT '
          'obtenido desde el navegador web.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showJwtInputDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ingresar JWT'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showJwtInputDialog(BuildContext context) async {
    final tokenController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // evita cerrar el diálogo tocando afuera
      builder: (context) => AlertDialog(
        title: const Text('Ingresar JWT'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pasos:\n'
                '1. Abre el navegador e ingresa a:\n'
                '   evalplus-api.emprenet.work/api/auth/microsoft\n'
                '2. Inicia sesión con Microsoft\n'
                '3. Copia el token JWT que aparece\n'
                '4. Pégalo aquí abajo\n',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tokenController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Token JWT',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
            onPressed: () async {
              final token = tokenController.text.trim();

              // Validaciones básicas
              if (token.isEmpty) {
                _showErrorSnackBar(context, 'El token no puede estar vacío');
                return;
              }

              if (!token.contains('.') || token.split('.').length != 3) {
                _showErrorSnackBar(context, 'El formato del token no es válido');
                return;
              }

              try {
                await AuthStorageService.saveToken(token: token);

                if (context.mounted) {
                  _showSuccessSnackBar(context, 'Token guardado correctamente');
                  Navigator.of(context).pop(); // cerrar diálogo
                  Navigator.of(context).pushReplacementNamed(InsideScreen.routename);
                }
              } catch (e) {
                debugPrint('Error guardando token: $e');
                if (context.mounted) {
                  _showErrorSnackBar(context, 'Error al guardar el token');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Errores al enviar el token JWT
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Maneja el éxito de la autenticación
  static Future<void> _handleAuthSuccess(
    BuildContext context,
    Map<String, dynamic> authData,
  ) async {
    try {
      debugPrint('Saving auth data...');
      debugPrint('Token exists: ${authData['token'] != null}');
      debugPrint('User exists: ${authData['user'] != null}');
      
      // Guardar los datos en secure storage
      await AuthStorageService.saveAuthData(
        token: authData['token'],
        user: authData['user'],
        isNewUser: authData['isNewUser'] ?? false,
      );
      
      debugPrint('Auth data saved successfully');
      
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
