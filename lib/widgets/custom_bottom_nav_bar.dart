import 'package:flutter/material.dart';

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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003C43),
            Color(0xFF004d56),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003C43).withOpacity(0.3),
            blurRadius: 25,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 8 : 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2) 
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
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
