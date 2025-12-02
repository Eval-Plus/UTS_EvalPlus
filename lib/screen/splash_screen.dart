import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:eval_plus/screen/home_screen.dart';
import 'package:eval_plus/screen/inside_screen.dart';

import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/services/api/auth_api_service.dart';

import 'package:eval_plus/controllers/user_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isAuthenticated = false;
  bool _validationComplete = false;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de animación
    _controller = AnimationController(vsync: this);
    // Inicia la validación del token en paralelo
    _validateStoredToken();
  }

  Future<void> _validateStoredToken() async {
    try {
      final token = await AuthStorageService.getToken();

      if (token == null) {
        // Sin token → ir a login
        setState(() {
          _isAuthenticated = false;
          _validationComplete = true;
        });
        return;
      }

      // ✅ VALIDACIÓN OBLIGATORIA con el backend
      final validationResult = await AuthApiService.validateToken(token);

      if (validationResult['valid'] == true) {
        // Token válido → cargar perfil y continuar
        await UserController.loadUserProfile();
        
        setState(() {
          _isAuthenticated = true;
          _validationComplete = true;
        });
      } else {
        // Token inválido → limpiar y enviar a login
        await _clearAndResetSession();
        
        setState(() {
          _isAuthenticated = false;
          _validationComplete = true;
        });
      }
      
    } catch (e) {
      // ❌ ERROR DE RED → mostrar mensaje y permitir reintentar
      debugPrint('💥 Error de conexión: $e');
      
      if (mounted) {
        _showConnectionError();
      }
    }
  }

  Future<void> _clearAndResetSession() async {
    await AuthStorageService.clearAuthData();
    await UserController.clearUserProfile();
  }

  void _showConnectionError() {
    // Mostrar un diálogo o pantalla de error
    // con opción de "Reintentar" o "Continuar sin conexión" (opcional)
  }

  void _navigateToNextScreen() {
    if (!_validationComplete) {
      // Si la validación aún no termina, esperar
      return;
    }

    if (mounted) {
      final targetScreen = _isAuthenticated ? const InsideScreen() : const HomeScreen();
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/animations/eval_uts_animation.json',
          controller: _controller,
          onLoaded: (composition) async {
            // Ajusta la duración
            _controller.duration = composition.duration;
            
            // Pausa de 0.5 segundos antes de reproducir
            await Future.delayed(const Duration(milliseconds: 500));
            
            // Reproduce la animación
            await _controller.forward();
            
            // Pausa de 0.5 segundos al final
            await Future.delayed(const Duration(milliseconds: 500));
            
            // Navegar a la pantalla correspondiente
            _navigateToNextScreen();
          },
        ),
      ),
    );
  }
}
