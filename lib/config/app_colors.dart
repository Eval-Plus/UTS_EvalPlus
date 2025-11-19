import 'package:flutter/material.dart';

/// Paleta de colores centralizada de Eval+
/// Puedes cambiar fácilmente entre diferentes esquemas de color
class AppColors {
  // ==================== ESQUEMA ACTUAL (Amarillo/Verde) ====================
  
  // Colores primarios - Header Wave & Bottom Nav Bar
  static const Color primary = Color(0xFFCAD225);           // Amarillo-verde principal
  static const Color primaryDark = Color(0xFFB8BE20);       // Amarillo-verde oscuro
  static const Color primaryLight = Color(0xFFD9E02E);      // Amarillo-verde claro
  
  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);        // Gris muy claro
  static const Color surface = Color(0xFFFFFFFF);           // Blanco
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF2C2C2C);       // Gris carbón oscuro
  static const Color textSecondary = Color(0xFF4A4A4A);     // Gris medio
  static const Color textTertiary = Color(0xFF6B6B6B);      // Gris claro
  static const Color textOnPrimary = Color(0xFF1A1A1A);     // Negro suave (para usar sobre primary)
  
  // Colores de acento y funcionales
  static const Color accent = Color(0xFF6366F1);            // Índigo (botones, enlaces)
  static const Color success = Color(0xFF10B981);           // Verde éxito
  static const Color warning = Color(0xFFF59E0B);           // Amarillo advertencia
  static const Color error = Color(0xFFEF4444);             // Rojo error
  static const Color info = Color(0xFF3B82F6);              // Azul información
  
  // Colores para estados
  static const Color selected = Color(0xFF1A1A1A);          // Item seleccionado
  static const Color unselected = Color(0xFF4A4A4A);        // Item no seleccionado
  static const Color disabled = Color(0xFFBDBDBD);          // Deshabilitado
  
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
      Color(0xFFCAD225),  // primary
      Color(0xFFB8BE20),  // primaryDark
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
}

// ==================== ESQUEMAS ALTERNATIVOS ====================

/// Esquema Azul Profesional
class BlueThemeColors {
  static const Color primary = Color(0xFF2563EB);           // Azul
  static const Color primaryDark = Color(0xFF1E40AF);       // Azul oscuro
  static const Color primaryLight = Color(0xFF60A5FA);      // Azul claro
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
  );
}

/// Esquema Púrpura Moderno
class PurpleThemeColors {
  static const Color primary = Color(0xFF8B5CF6);           // Púrpura
  static const Color primaryDark = Color(0xFF7C3AED);       // Púrpura oscuro
  static const Color primaryLight = Color(0xFFA78BFA);      // Púrpura claro
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );
}

/// Esquema Verde Naturaleza
class GreenThemeColors {
  static const Color primary = Color(0xFF10B981);           // Verde
  static const Color primaryDark = Color(0xFF059669);       // Verde oscuro
  static const Color primaryLight = Color(0xFF34D399);      // Verde claro
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}

/// Esquema Naranja Energético
class OrangeThemeColors {
  static const Color primary = Color(0xFFF97316);           // Naranja
  static const Color primaryDark = Color(0xFFEA580C);       // Naranja oscuro
  static const Color primaryLight = Color(0xFFFB923C);      // Naranja claro
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
  );
}

/// Esquema Oscuro (Dark Mode)
class DarkThemeColors {
  static const Color primary = Color(0xFF1F2937);           // Gris oscuro
  static const Color primaryDark = Color(0xFF111827);       // Gris muy oscuro
  static const Color primaryLight = Color(0xFF374151);      // Gris medio
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
  );
}
