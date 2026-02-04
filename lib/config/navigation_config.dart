import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/user_model.dart';

// Student Content
import 'package:eval_plus/screen/content/student/careers_content.dart';
import 'package:eval_plus/screen/content/student/evaluations_content.dart';

// Teacher Content
import 'package:eval_plus/screen/content/teacher/teacher_evaluations_content.dart';

// Admin Content
import 'package:eval_plus/screen/content/admin/config_content.dart';
import 'package:eval_plus/screen/content/admin/analysis_content.dart';

// Shared Content
import 'package:eval_plus/screen/content/profile_content.dart';

/// Configuración centralizada de navegación por rol
class NavigationConfig {

  // ==================== TABS PARA ESTUDIANTES ====================
  
  static const NavTab studentCareersTab = NavTab(
    icon: Icons.school,
    label: 'Carreras',
    roles: [UserRole.student],
  );

  static const NavTab studentEvaluationsTab = NavTab(
    icon: Icons.assignment_turned_in,
    label: 'Evaluaciones',
    roles: [UserRole.student],
  );

  // ==================== TABS PARA DOCENTES ====================
  
  static const NavTab teacherEvaluationsTab = NavTab(
    icon: Icons.analytics,
    label: 'Mis Evaluaciones',
    roles: [UserRole.teacher],
  );

  // ==================== TABS PARA ADMINISTRADORES ====================
  
  static const NavTab adminSettingsTab = NavTab(
    icon: Icons.settings,
    label: 'Configuración',
    roles: [UserRole.admin],
  );

  static const NavTab adminPanelTab = NavTab(
    icon: Icons.dashboard,
    label: 'Análisis',
    roles: [UserRole.admin],
  );

  // ==================== TAB COMPARTIDO ====================
  
  static const NavTab profileTab = NavTab(
    icon: Icons.person,
    label: 'Perfil',
    roles: [UserRole.student, UserRole.teacher, UserRole.admin],
  );

  // ==================== MÉTODOS PRINCIPALES ====================

  /// Obtiene los tabs visibles para un rol específico
  static List<NavTab> getTabsForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [
          studentCareersTab,
          studentEvaluationsTab,
          profileTab,
        ];
      
      case UserRole.teacher:
        return [
          teacherEvaluationsTab,
          profileTab,
        ];
      
      case UserRole.admin:
        return [
          adminSettingsTab,
          adminPanelTab,
          profileTab,
        ];
    }
  }

  /// Obtiene los widgets de contenido para un rol específico
  static List<Widget> getContentsForRole(UserRole role, UserModel? user) {
    final tabs = getTabsForRole(role);
    
    return tabs.map((tab) {
      // Student tabs
      if (tab == studentCareersTab) {
        return const CarrerasContent();
      }
      if (tab == studentEvaluationsTab) {
        return const EvaluationsList();
      }
      
      // Teacher tabs
      if (tab == teacherEvaluationsTab) {
        return const TeacherEvaluationsContent();
      }
      
      // Admin tabs
      if (tab == adminSettingsTab) {
        return const ConfigContent();
      }

      if (tab == adminPanelTab) {
        return const AnalysisContent();
      }
      
      // Shared tabs
      if (tab == profileTab) {
        return ProfileContent(user: user);
      }
      
      throw Exception('Tab no reconocido: ${tab.label}');
    }).toList();
  }

  /// Valida que un índice sea válido para el rol actual
  static bool isValidIndex(int index, UserRole role) {
    final tabs = getTabsForRole(role);
    return index >= 0 && index < tabs.length;
  }

  /// Obtiene el índice inicial seguro (siempre 0)
  static int getInitialIndex() => 0;

}

/// Clase inmutable que representa un tab de navegación
class NavTab {
  final IconData icon;
  final String label;
  final List<UserRole> roles;

  const NavTab({
    required this.icon,
    required this.label,
    required this.roles,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavTab &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          label == other.label;

  @override
  int get hashCode => icon.hashCode ^ label.hashCode;
}
