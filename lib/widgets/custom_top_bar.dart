import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onLogoutPressed;
  final bool showLogoutButton;
  final Color titleColor;
  final Color subtitleColor;
  final Color? logoutIconColor;

  const CustomTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onLogoutPressed,
    this.showLogoutButton = true,
    this.titleColor = Colors.white,
    this.subtitleColor = Colors.white70,
    this.logoutIconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Textos del lado izquierdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Botón de cerrar sesión (condicional)
          if (showLogoutButton)
            IconButton(
              onPressed: onLogoutPressed ?? () => Navigator.pop(context),
              icon: Icon(Icons.logout, color: logoutIconColor),
              tooltip: 'Cerrar sesión',
            ),
        ],
      ),
    );
  }
}
