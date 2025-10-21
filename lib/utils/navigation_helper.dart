import 'package:flutter/material.dart';

// Screens
import 'package:eval_plus/screen/inside/careers_screen.dart';
import 'package:eval_plus/screen/inside/evaluations_screen.dart';
import 'package:eval_plus/screen/inside/profile_screen.dart';

class NavigationHelper {
  static const String careersRoute = 'CareersScreen';
  static const String evaluationsRoute = 'EvaluationsScreen';
  static const String profileRoute = 'ProfileScreen';

  static const List<String> routes = [
    careersRoute,
    evaluationsRoute,
    profileRoute,
  ];

  /// Navega con animación de deslizamiento
  static void navigateToIndex(BuildContext context, int index, int currentIndex) {
    if (index == currentIndex) return;
    
    if (index < 0 || index >= routes.length) {
      debugPrint('NavigationHelper: Índice inválido: $index');
      return;
    }

    // Determinar dirección del deslizamiento
    final bool isMovingRight = index > currentIndex;
    
    // Obtener la pantalla de destino
    final Widget destinationScreen = _getScreenWidget(routes[index]);

    Navigator.of(context).pushReplacement(
      _createSlideRoute(destinationScreen, isMovingRight),
    );
  }

  /// Crea la ruta con animación de deslizamiento
  static PageRouteBuilder _createSlideRoute(Widget screen, bool isMovingRight) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Dirección del movimiento
        final Offset beginOffset = isMovingRight
            ? const Offset(0.25, 0.0)
            : const Offset(-0.25, 0.0);

        final Offset endOffset = Offset.zero;

        // Animación de desplazamiento (entrada)
        final slideTween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: Curves.easeInOutCubic));

        // Animación de opacidad (fade)
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut));

        // Animación de escala sutil (zoom in)
        final scaleTween = Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Obtiene el widget de la pantalla según la ruta
  static Widget _getScreenWidget(String route) {
    switch (route) {
      case careersRoute:
        return CareersScreen();
      case evaluationsRoute:
        return EvaluationsScreen();
      case profileRoute:
        return ProfileScreen();
      default:
        return CareersScreen();
    }
  }

  static int getIndexFromRouteName(String? routeName) {
    if (routeName == null) return 0;
    final index = routes.indexOf(routeName);
    return index != -1 ? index : 0;
  }

  static bool isMainScreen(String? routeName) {
    if (routeName == null) return false;
    return routes.contains(routeName);
  }
}
