import 'package:flutter/material.dart';

/// Helper class para manejar la navegación entre las pantallas principales
class NavigationHelper {
  // Rutas de las pantallas principales
  static const String careersRoute = 'CareersScreen';
  static const String evaluationsRoute = 'EvaluationsScreen';
  static const String profileRoute = 'ProfileScreen';

  // Lista de rutas en orden según el índice del NavBar
  static const List<String> routes = [
    careersRoute,
    evaluationsRoute,
    profileRoute,
  ];

  /// Navega a la pantalla correspondiente según el índice del NavBar
  /// Si ya estamos en esa pantalla, no hace nada
  static void navigateToIndex(BuildContext context, int index, int currentIndex) {
    // No navegar si ya estamos en la pantalla actual
    if (index == currentIndex) return;

    // Validar que el índice sea válido
    if (index < 0 || index >= routes.length) {
      debugPrint('NavigationHelper: Índice inválido: $index');
      return;
    }

    // Navegar usando pushReplacementNamed para evitar acumulación de rutas
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  /// Obtiene el índice actual basado en el nombre de la ruta
  static int getIndexFromRouteName(String? routeName) {
    if (routeName == null) return 0;
    
    final index = routes.indexOf(routeName);
    return index != -1 ? index : 0;
  }

  /// Verifica si estamos en una de las pantallas principales
  static bool isMainScreen(String? routeName) {
    if (routeName == null) return false;
    return routes.contains(routeName);
  }
}
