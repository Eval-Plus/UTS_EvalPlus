import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/config/navigation_config.dart';
import 'package:eval_plus/controllers/user_session_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSessionController>();
    final palette = session.palette;
    
    // 👇 Usar configuración centralizada
    final visibleTabs = NavigationConfig.getTabsForRole(session.currentRole);
    
    // ✅ USAR EL currentIndex QUE VIENE COMO PARÁMETRO (ya validado en el padre)
    // Este ya fue validado en BaseScreenLayout/InsideScreen
    final safeIndex = currentIndex.clamp(0, visibleTabs.length - 1);
    
    // 🔥 DEBUG
    debugPrint('🎯 [BottomNavBar] Renderizando con currentIndex: $currentIndex, safeIndex: $safeIndex');
    
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
              visibleTabs.length,
              (index) => _buildNavItem(
                icon: visibleTabs[index].icon,
                label: visibleTabs[index].label,
                isSelected: safeIndex == index, // ✅ Comparar con el índice del parámetro
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
