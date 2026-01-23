/// Validador de reglas de negocio para sincronizaciones de administrador
/// Ubicación: lib/utils/admin/admin_sync_validator.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/admin/admin_dashboard_model.dart';
import 'package:eval_plus/utils/admin/admin_config_constants.dart';

/// Resultado de una validación de sincronización
class SyncValidationResult {
  final bool canProceed;
  final bool showDialog;
  final String? dialogTitle;
  final String? dialogMessage;
  final IconData? dialogIcon;
  final Color? dialogColor;
  final String? internalMessage; // Para logs/debugging

  const SyncValidationResult({
    required this.canProceed,
    this.showDialog = false,
    this.dialogTitle,
    this.dialogMessage,
    this.dialogIcon,
    this.dialogColor,
    this.internalMessage,
  });

  /// Validación exitosa - se puede proceder
  const SyncValidationResult.success()
      : canProceed = true,
        showDialog = false,
        dialogTitle = null,
        dialogMessage = null,
        dialogIcon = null,
        dialogColor = null,
        internalMessage = null;

  /// Validación fallida con diálogo informativo
  const SyncValidationResult.blocked({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    String? internalMessage,
  })  : canProceed = false,
        showDialog = true,
        dialogTitle = title,
        dialogMessage = message,
        dialogIcon = icon,
        dialogColor = color,
        internalMessage = internalMessage;

  /// Validación fallida silenciosa (sin diálogo)
  const SyncValidationResult.fail({
    String? message,
  })  : canProceed = false,
        showDialog = false,
        dialogTitle = null,
        dialogMessage = null,
        dialogIcon = null,
        dialogColor = null,
        internalMessage = message;
}

/// Validador centralizado de sincronizaciones
class AdminSyncValidator {
  AdminSyncValidator._();

  // ==================== VALIDACIÓN DE ESTUDIANTES ====================

  /// Valida si se pueden sincronizar estudiantes
  static SyncValidationResult validateStudentsSync(DashboardStats stats) {
    // Regla 1: No hay estudiantes registrados en el sistema
    if (stats.totalStudents == 0) {
      return SyncValidationResult.blocked(
        title: 'Sin estudiantes registrados',
        message: 'No se ha registrado ningún estudiante aún. '
            'Es necesario que haya estudiantes en el sistema académico '
            'antes de poder sincronizarlos.',
        icon: AdminConfigConstants.infoIcon,
        color: AdminConfigConstants.emeraldColor,
        internalMessage: 'Total students = 0',
      );
    }

    // Regla 2: No hay estudiantes pendientes (todos están sincronizados)
    if (stats.pendingStudents == 0) {
      return SyncValidationResult.blocked(
        title: 'Estudiantes sincronizados',
        message: 'Ya se han sincronizado todos los estudiantes que estaban pendientes. '
            'No hay acciones por realizar en este momento.',
        icon: AdminConfigConstants.checkIcon,
        color: AdminConfigConstants.emeraldColor,
        internalMessage: 'Pending students = 0, Synced students = ${stats.syncedStudents}',
      );
    }

    // ✅ Validación exitosa
    return const SyncValidationResult.success();
  }

  // ==================== VALIDACIÓN DE DOCENTES ====================

  /// Valida si se pueden sincronizar docentes
  static SyncValidationResult validateTeachersSync(DashboardStats stats) {
    // Regla 1: No hay estudiantes sincronizados (prerequisito)
    if (stats.syncedStudents == 0) {
      return SyncValidationResult.blocked(
        title: 'Estudiantes no sincronizados',
        message: 'Aún no se ha sincronizado ningún estudiante. '
            'Es necesario sincronizar estudiantes primero para tener '
            'las materias disponibles y poder asignarles docentes.',
        icon: AdminConfigConstants.studentsIcon,
        color: AdminConfigConstants.limeColor,
        internalMessage: 'Synced students = 0',
      );
    }

    // Regla 2: No hay docentes registrados en el sistema
    if (stats.totalTeachers == 0) {
      return SyncValidationResult.blocked(
        title: 'Sin docentes registrados',
        message: 'No se ha registrado ningún docente aún. '
            'Es necesario que haya docentes en el sistema académico '
            'antes de poder inscribirlos.',
        icon: AdminConfigConstants.infoIcon,
        color: AdminConfigConstants.limeColor,
        internalMessage: 'Total teachers = 0',
      );
    }

    // Regla 3: No hay docentes pendientes (todos están inscritos)
    if (stats.pendingTeachers == 0) {
      return SyncValidationResult.blocked(
        title: 'Docentes inscritos',
        message: 'Ya se han sincronizado todos los docentes que estaban pendientes. '
            'No hay acciones por realizar en este momento.',
        icon: AdminConfigConstants.checkIcon,
        color: AdminConfigConstants.limeColor,
        internalMessage: 'Pending teachers = 0, Enrolled teachers = ${stats.enrolledTeachers}',
      );
    }

    // 🆕 Regla 4: Docentes completamente asignados (igual cantidad de estudiantes y docentes)
    if (stats.syncedStudents == stats.enrolledTeachers) {
      return SyncValidationResult.blocked(
        title: 'Docentes completamente asignados',
        message: 'Todas las materias con estudiantes ya tienen docente asignado. '
            'No es necesario realizar más sincronizaciones en este momento.',
        icon: AdminConfigConstants.checkIcon,
        color: AdminConfigConstants.limeColor,
        internalMessage: 'Synced students (${stats.syncedStudents}) == Enrolled teachers (${stats.enrolledTeachers})',
      );
    }

    // ✅ Validación exitosa
    return const SyncValidationResult.success();
  }

  // ==================== VALIDACIÓN DE EVALUACIONES ====================

  /// Valida si se pueden generar evaluaciones
  static SyncValidationResult validateEvaluationsGeneration(DashboardStats stats) {
    // Regla única: No hay docentes sincronizados (prerequisito)
    if (stats.enrolledTeachers == 0) {
      return SyncValidationResult.blocked(
        title: 'Docentes no sincronizados',
        message: 'Aún no se ha sincronizado ningún docente. '
            'Es necesario sincronizar docentes primero porque no se asignan '
            'evaluaciones en materias sin docente.',
        icon: AdminConfigConstants.teachersIcon,
        color: AdminConfigConstants.tealColor,
        internalMessage: 'Enrolled teachers = 0',
      );
    }

    // ✅ Validación exitosa - El backend manejará validaciones adicionales
    return const SyncValidationResult.success();
  }

  // ==================== HELPERS ====================

  /// Valida una acción específica por su clave
  static SyncValidationResult validateAction(
    String actionKey,
    DashboardStats stats,
  ) {
    switch (actionKey) {
      case 'sync-students':
        return validateStudentsSync(stats);
      
      case 'enroll-teachers':
        return validateTeachersSync(stats);
      
      case 'generate-evaluations':
        return validateEvaluationsGeneration(stats);
      
      default:
        return SyncValidationResult.fail(
          message: 'Acción no reconocida: $actionKey',
        );
    }
  }

  /// Verifica si una acción específica está disponible
  static bool isActionAvailable(String actionKey, DashboardStats stats) {
    final validation = validateAction(actionKey, stats);
    return validation.canProceed;
  }

  /// Obtiene un resumen del estado de las validaciones
  static Map<String, bool> getActionsAvailability(DashboardStats stats) {
    return {
      'sync-students': validateStudentsSync(stats).canProceed,
      'enroll-teachers': validateTeachersSync(stats).canProceed,
      'generate-evaluations': validateEvaluationsGeneration(stats).canProceed,
    };
  }
}
