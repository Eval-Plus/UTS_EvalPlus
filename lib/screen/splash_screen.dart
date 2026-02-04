import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:eval_plus/screen/home_screen.dart';
import 'package:eval_plus/screen/inside_screen.dart';

import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/services/api/auth_api_service.dart';

import 'package:eval_plus/controllers/user_controller.dart';
import 'package:eval_plus/controllers/user_session_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isAuthenticated = false;
  bool _validationComplete = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    // Iniciar validación inmediatamente
    _validateStoredToken();
  }

  Future<void> _validateStoredToken() async {
    try {
      final token = await AuthStorageService.getToken();

      if (token == null) {
        setState(() {
          _isAuthenticated = false;
          _validationComplete = true;
        });
        _checkAndNavigate();
        return;
      }

      // ✅ VALIDACIÓN con el backend
      final validationResult = await AuthApiService.validateToken(token);

      if (validationResult['valid'] == true) {
        // Token válido → cargar perfil Y sesión
        await UserController.loadUserProfile();
        
        // 🔥 Cargar la sesión del usuario
        if (mounted) {
          final session = context.read<UserSessionController>();
          await session.loadUserSession();
        }
        
        setState(() {
          _isAuthenticated = true;
          _validationComplete = true;
        });
      } else {
        await _clearAndResetSession();
        
        setState(() {
          _isAuthenticated = false;
          _validationComplete = true;
        });
      }
      
      // ✅ Verificar si podemos navegar después de validar
      _checkAndNavigate();
      
    } catch (e) {
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
    // Mostrar diálogo de error de conexión
    // Por ahora, marcar como no autenticado para permitir navegación
    setState(() {
      _isAuthenticated = false;
      _validationComplete = true;
    });
    _checkAndNavigate();
  }

  /// ✅ NUEVA FUNCIÓN: Solo navega cuando AMBOS procesos están completos
  void _checkAndNavigate() {
    debugPrint('🔍 Verificando navegación:');
    debugPrint('   - Animation complete: $_animationComplete');
    debugPrint('   - Validation complete: $_validationComplete');
    
    if (_animationComplete && _validationComplete) {
      debugPrint('✅ Ambos procesos completos, navegando...');
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
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
            _controller.duration = composition.duration;
            
            await Future.delayed(const Duration(milliseconds: 500));
            await _controller.forward();
            await Future.delayed(const Duration(milliseconds: 500));
            
            // ✅ Marcar animación como completa
            setState(() {
              _animationComplete = true;
            });
            
            // ✅ Verificar si podemos navegar después de la animación
            _checkAndNavigate();
          },
        ),
      ),
    );
  }
}
