/// Constantes para la configuración de administrador
/// Ubicación: lib/utils/admin_config_constants.dart
library;

import 'package:flutter/material.dart';

class AdminConfigConstants {
  AdminConfigConstants._();

  // ==================== COLORES DE SINCRONIZACIÓN ====================
  
  /// Verde esmeralda para estudiantes
  static const Color emeraldColor = Color(0xFF2ECC71);
  static const Color emeraldDark = Color(0xFF27AE60);
  
  /// Verde lima para docentes
  static const Color limeColor = Color(0xFF8BC34A);
  static const Color limeDark = Color(0xFF689F38);
  
  /// Verde azulado para evaluaciones
  static const Color tealColor = Color(0xFF009688);
  static const Color tealDark = Color(0xFF00796B);

  // ==================== GRADIENTES ====================
  
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [emeraldColor, emeraldDark],
  );
  
  static const LinearGradient limeGradient = LinearGradient(
    colors: [limeColor, limeDark],
  );
  
  static const LinearGradient tealGradient = LinearGradient(
    colors: [tealColor, tealDark],
  );

  // ==================== TEXTOS Y ETIQUETAS ====================
  
  static const String studentsTitle = 'Sincronizar Estudiantes';
  static const String studentsDescription = 
      'Asocia estudiantes registrados con sus respectivas materias del sistema académico';
  static const String studentsAction = 'Sincronizar Ahora';
  static const String studentsNoPending = 'Sin estudiantes pendientes';
  static const String studentsNoPendingMessage = 
      'Todos los estudiantes ya están sincronizados. No hay acciones pendientes por realizar.';
  
  static const String teachersTitle = 'Inscribir Docentes';
  static const String teachersDescription = 
      'Asigna docentes a las materias correspondientes según el registro académico';
  static const String teachersAction = 'Inscribir Ahora';
  static const String teachersNoPending = 'Sin docentes pendientes';
  static const String teachersNoPendingMessage = 
      'Todos los docentes ya están inscritos en sus materias. No hay acciones pendientes por realizar.';
  
  static const String evaluationsTitle = 'Generar Evaluaciones';
  static const String evaluationsDescription = 
      'Crea evaluaciones masivas para materias con docentes y estudiantes asignados';
  static const String evaluationsAction = 'Generar Ahora';
  static const String evaluationsAlreadyGenerated = 'Evaluaciones ya generadas';
  
  static String evaluationsAlreadyGeneratedMessage(int active) =>
      'Ya existen $active evaluaciones activas en el sistema. No es necesario generar nuevas en este momento.';

  // ==================== TIMEOUTS ====================
  
  static const Duration syncTimeout = Duration(seconds: 30);

  // ==================== MENSAJES DE ÉXITO ====================
  
  static String studentsSuccessMessage(int count) => 
      'Sincronización completada: $count estudiantes procesados';
  
  static String teachersSuccessMessage(int count) => 
      'Sincronización completada: $count profesores procesados';
  
  static String evaluationsSuccessMessage(int count) => 
      'Evaluaciones generadas: $count creadas';

  // ==================== ICONOS ====================
  
  static const IconData studentsIcon = Icons.people_rounded;
  static const IconData teachersIcon = Icons.school_rounded;
  static const IconData evaluationsIcon = Icons.assignment_rounded;
  static const IconData settingsIcon = Icons.settings;
  static const IconData layersIcon = Icons.layers_rounded;
  static const IconData playIcon = Icons.play_circle_rounded;
  static const IconData infoIcon = Icons.info_rounded;
  static const IconData checkIcon = Icons.check_circle_outline;
  static const IconData completedIcon = Icons.assignment_turned_in;

  // ==================== DIMENSIONES ====================
  
  static const double headerIconSize = 64.0;
  static const double headerIconContainerSize = 64.0;
  static const double actionIconSize = 24.0;
  static const double progressIconSize = 20.0;
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ==================== DURACIÓN DE CACHE ====================
  
  static const Duration cacheDuration = Duration(minutes: 5);

  // ==================== INFORMACIÓN DEL SISTEMA ====================
  
  static const String infoBannerTitle = 'Información importante';
  static const String infoBannerMessage = 
      'Las sincronizaciones pueden tardar varios minutos dependiendo del volumen de datos. '
      'Se recomienda ejecutar estas acciones en horarios de baja actividad del sistema.';
}
