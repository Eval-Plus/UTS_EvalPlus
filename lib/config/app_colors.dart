import 'package:flutter/material.dart';

/// Enum para los diferentes roles de usuario
enum UserRole {
  student,
  teacher,
  admin,
}

/// Paleta de colores centralizada de Eval+
class AppColors {
  // ==================== COLORES POR ROL ====================
  
  /// Obtiene la paleta de colores según el rol del usuario
  static RoleColorPalette getPaletteForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return _studentPalette;
      case UserRole.teacher:
        return _teacherPalette;
      case UserRole.admin:
        return _adminPalette;
    }
  }
  
  // Paleta para ESTUDIANTES (Amarillo-Verde actual)
  static final RoleColorPalette _studentPalette = RoleColorPalette(
    primary: const Color(0xFFCAD225),           // Amarillo-verde principal
    primaryDark: const Color(0xFFB8BE20),       // Amarillo-verde oscuro
    primaryLight: const Color(0xFFD9E02E),      // Amarillo-verde claro
    accent: const Color(0xFFA8B820),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFCAD225), Color(0xFFB8BE20)],
    ),
  );
  
  // Paleta para PROFESORES (Verde más oscuro)
  static final RoleColorPalette _teacherPalette = RoleColorPalette(
    primary: const Color(0xFF8BC34A),           // Verde medio
    primaryDark: const Color(0xFF689F38),       // Verde oscuro
    primaryLight: const Color(0xFF9CCC65),      // Verde claro
    accent: const Color(0xFF7CB342),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
    ),
  );
  
  // Paleta para ADMINISTRADORES (Verde muy oscuro)
  static final RoleColorPalette _adminPalette = RoleColorPalette(
    primary: const Color(0xFF4CAF50),           // Verde fuerte
    primaryDark: const Color(0xFF388E3C),       // Verde muy oscuro
    primaryLight: const Color(0xFF66BB6A),      // Verde medio
    accent: const Color(0xFF43A047),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    ),
  );

  // ==================== COLORES DE CARRERAS ====================
  
  /// Mapeo de colores por código de carrera
  static Color getCareerColor(String careerCode) {
    switch (careerCode.toUpperCase()) {
      case 'ING-SIS':
        return const Color(0xFF2196F3); // Azul
      case 'ADM-EMP':
        return const Color(0xFF4CAF50); // Verde
      case 'DER':
        return const Color(0xFFF44336); // Rojo
      default:
        return const Color(0xFFA8B820); // Amarillo-verde (default)
    }
  }

  /// Obtiene un color desde string hexadecimal (ej: "0xFF2196F3")
  static Color parseColorString(String colorString) {
    try {
      final hexColor = colorString.replaceAll('0x', '').replaceAll('#', '');
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      return const Color(0xFFA8B820); // Color por defecto
    }
  }
  
  // ==================== COLORES COMPARTIDOS ====================
  
  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Color(0xFF1A1A1A);
  
  // Colores de acento y funcionales
  static const Color accent = Color(0xFF6366F1);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Colores para estados
  static const Color selected = Color(0xFF1A1A1A);
  static const Color unselected = Color(0xFF4A4A4A);
  static const Color disabled = Color(0xFFBDBDBD);
  
  // Sombras y overlays
  static Color shadowLight = const Color(0xFFCAD225).withOpacity(0.3);
  static Color overlayDark = const Color(0xFF1A1A1A).withOpacity(0.15);
  static Color overlayLight = const Color(0xFF1A1A1A).withOpacity(0.08);
  
  // ==================== GRADIENTES ====================
  
  /// Gradiente principal para Header Wave y Bottom Nav Bar
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCAD225),
      Color(0xFFB8BE20),
    ],
  );
  
  /// Gradiente para botones primarios
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF4F46E5),
    ],
  );
  
  /// Gradiente suave para cards seleccionados
  static LinearGradient selectedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF1A1A1A).withOpacity(0.15),
      const Color(0xFF1A1A1A).withOpacity(0.10),
    ],
  );

  static Color? get primary => null;
}

/// Clase que encapsula una paleta de colores para un rol específico
class RoleColorPalette {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final LinearGradient primaryGradient;
  
  RoleColorPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.primaryGradient,
  });
  
  /// Genera sombra basada en el color primario
  Color get shadowLight => primary.withOpacity(0.3);

  /// 🔥 NUEVO: Gradiente para avatar/elementos destacados
  LinearGradient get avatarGradient => LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 🔥 NUEVO: Color de borde con opacidad
  Color borderColor([double opacity = 0.4]) => accent.withOpacity(opacity);
  
  /// 🔥 NUEVO: Color de fondo suave para chips/tags
  Color get chipBackground => primary.withOpacity(0.15);
}
