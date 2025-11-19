import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/config/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });
  
  // Configuración de los items del NavBar
  static const List<_NavBarItem> _items = [
    _NavBarItem(icon: Icons.school, label: 'Carreras'),
    _NavBarItem(icon: Icons.assignment_turned_in, label: 'Evaluaciones'),
    _NavBarItem(icon: Icons.person, label: 'Perfil'),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient, // Usando gradiente centralizado
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight, // Usando sombra centralizada
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
              _items.length,
              (index) => _buildNavItem(
                icon: _items[index].icon,
                label: _items[index].label,
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
          splashColor: AppColors.overlayDark, // Usando overlay centralizado
          highlightColor: AppColors.overlayLight, // Usando overlay centralizado
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
                    gradient: isSelected ? AppColors.selectedGradient : null, // 🎨
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
                          ? AppColors.selected   // Color seleccionado
                          : AppColors.unselected, // Color no seleccionado
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
                        ? AppColors.selected   // 
                        : AppColors.unselected, // 
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

// Clase privada para representar un item del NavBar
class _NavBarItem {
  final IconData icon;
  final String label;
  
  const _NavBarItem({
    required this.icon,
    required this.label,
  });
}
