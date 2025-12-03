import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/controllers/user_session_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });
  
  // 👇 NUEVO: Configuración completa de items con restricciones de rol
  static const List<_NavBarItem> _allItems = [
    _NavBarItem(
      icon: Icons.school,
      label: 'Carreras',
      roles: [UserRole.student], // Solo estudiantes
    ),
    _NavBarItem(
      icon: Icons.assignment_turned_in,
      label: 'Evaluaciones',
      roles: [UserRole.student, UserRole.teacher, UserRole.admin], // Todos
    ),
    _NavBarItem(
      icon: Icons.person,
      label: 'Perfil',
      roles: [UserRole.student, UserRole.teacher, UserRole.admin], // Todos
    ),
  ];
  
  /// Filtra los items según el rol del usuario
  static List<_NavBarItem> _getItemsForRole(UserRole role) {
    return _allItems.where((item) => item.roles.contains(role)).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtener la sesión del usuario
    final session = context.watch<UserSessionController>();
    final palette = session.palette;
    
    // 👇 Filtrar items según el rol
    final visibleItems = _getItemsForRole(session.currentRole);
    
    return Container(
      decoration: BoxDecoration(
        gradient: palette.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: palette.shadowLight,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              visibleItems.length,
              (index) => _buildNavItem(
                icon: visibleItems[index].icon,
                label: visibleItems[index].label,
                isSelected: currentIndex == index,
                onTap: () => onTap?.call(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          splashColor: AppColors.overlayDark,
          highlightColor: AppColors.overlayLight,
          child: AnimatedContainer(
            duration: AppConstants.animationDuration,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppConstants.animationDuration,
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(isSelected ? 8 : 4),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.selectedGradient : null,
                    color: isSelected ? null : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.overlayDark,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.95,
                    duration: AppConstants.animationDuration,
                    curve: Curves.easeInOut,
                    child: Icon(
                      icon,
                      color: isSelected 
                          ? AppColors.selected
                          : AppColors.unselected,
                      size: isSelected ? 26 : 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: AppConstants.animationDuration,
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.selected
                        : AppColors.unselected,
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 👇 Clase privada actualizada con roles permitidos
class _NavBarItem {
  final IconData icon;
  final String label;
  final List<UserRole> roles; // 👈 NUEVO: roles que pueden ver este item
  
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.roles,
  });
}
