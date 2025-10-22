import 'package:flutter/material.dart';

// Widgets
import 'package:eval_plus/widgets/custom_bottom_nav_bar.dart';
import 'package:eval_plus/widgets/custom_header_wave.dart';
import 'package:eval_plus/widgets/custom_top_bar.dart';

class BaseScreenLayout extends StatelessWidget {
  final String topBarTitle;
  final String topBarSubtitle;
  final int currentNavIndex;
  final Widget child;
  final VoidCallback? onLogoutPressed;
  final ValueChanged<int>? onNavIndexChanged;
  
  // Opciones de layout
  final bool centerContent;
  final double paddingTop;
  final double paddingBottom;
  final int topSpacerFlex;
  final int contentFlex;
  final int bottomSpacerFlex;
  
  const BaseScreenLayout({
    super.key,
    required this.topBarTitle,
    required this.topBarSubtitle,
    required this.currentNavIndex,
    required this.child,
    this.onLogoutPressed,
    this.onNavIndexChanged,
    this.centerContent = false,
    this.paddingTop = 120.0,
    this.paddingBottom = 20.0,
    this.topSpacerFlex = 2,
    this.contentFlex = 3,
    this.bottomSpacerFlex = 2,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Fondo blanco
          Container(color: Colors.grey[50]),
          
          // Header con onda
          const CustomHeaderWave(),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Barra superior con info del usuario
                CustomTopBar(
                  title: topBarTitle,
                  subtitle: topBarSubtitle,
                  onLogoutPressed: onLogoutPressed ?? () {
                    Navigator.pop(context);
                  },
                ),
                
                // Opción 1: Padding fijo
                if (!centerContent)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: paddingTop,
                        bottom: paddingBottom,
                      ),
                      child: child,
                    ),
                  ),
                
                // Opción 2: Centrado con spacer
                if (centerContent) ...[
                  Spacer(flex: topSpacerFlex),
                  Flexible(
                    flex: contentFlex,
                    child: child,
                  ),
                  Spacer(flex: bottomSpacerFlex),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentNavIndex,
        onTap: (index) {
          // Notificar el cambio de indice
          onNavIndexChanged?.call(index);
        },
      ),
    );
  }
}
