import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/user_model.dart';
import 'package:eval_plus/screen/content/careers_content.dart';
import 'package:eval_plus/screen/content/evaluations_content.dart';
import 'package:eval_plus/screen/content/profile_content.dart';

/// Configuración centralizada de navegación por rol
class NavigationConfig {
  // Definición de tabs disponibles
  static const NavTab careersTab = NavTab(
    icon: Icons.school,
    label: 'Carreras',
    roles: [UserRole.student],
  );

  static const NavTab evaluationsTab = NavTab(
    icon: Icons.assignment_turned_in,
    label: 'Evaluaciones',
    roles: [UserRole.student, UserRole.teacher, UserRole.admin],
  );

  static const NavTab profileTab = NavTab(
    icon: Icons.person,
    label: 'Perfil',
    roles: [UserRole.student, UserRole.teacher, UserRole.admin],
  );

  /// Lista maestra de todos los tabs
  static const List<NavTab> allTabs = [
    careersTab,
    evaluationsTab,
    profileTab,
  ];

  /// Obtiene los tabs visibles para un rol específico
  static List<NavTab> getTabsForRole(UserRole role) {
    return allTabs.where((tab) => tab.roles.contains(role)).toList();
  }

  /// Obtiene los widgets de contenido para un rol específico
  static List<Widget> getContentsForRole(UserRole role, UserModel? user) {
    final tabs = getTabsForRole(role);
    
    return tabs.map((tab) {
      if (tab == careersTab) return const CarrerasContent();
      if (tab == evaluationsTab) return const EvaluationsList();
      if (tab == profileTab) return ProfileContent(user: user);
      
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
