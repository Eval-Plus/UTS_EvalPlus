import 'package:flutter/material.dart';

// Widgets
import 'package:eval_plus/widgets/custom_bottom_nav_bar.dart';
import 'package:eval_plus/widgets/custom_header_wave.dart';
import 'package:eval_plus/widgets/custom_top_bar.dart';

/// Layout base reutilizable para las pantallas de la aplicación
/// 
/// Este widget encapsula la estructura común de las pantallas:
/// - Fondo con onda decorativa
/// - Barra superior con información del usuario
/// - Navegación inferior
/// - Contenido principal configurable

class BaseScreenLayout extends StatelessWidget {
  /// Título principal mostrado en la barra superior
  final String topBarTitle;
  
  /// Subtítulo mostrado en la barra superior
  final String topBarSubtitle;
  
  /// Contenido principal de la pantalla
  final Widget child;
  
  /// Índice actual en la barra de navegación inferior
  final int currentNavIndex;
  
  /// Callback cuando se presiona el botón de cerrar sesión
  final VoidCallback? onLogoutPressed;
  
  /// Callback cuando se toca un elemento de la navegación inferior
  final Function(int)? onNavTap;
  
  /// Padding superior del contenido (por defecto 120.0)
  final double paddingTop;
  
  /// Padding inferior del contenido (por defecto 20.0)
  final double paddingBottom;
  
  /// Si es true, centra el contenido verticalmente usando Spacer
  /// Si es false, usa padding fijo
  final bool centerContent;
  
  /// Factor de flex para el Spacer superior cuando centerContent = true
  final int topSpacerFlex;
  
  /// Factor de flex para el contenido cuando centerContent = true
  final int contentFlex;
  
  /// Factor de flex para el Spacer inferior cuando centerContent = true
  final int bottomSpacerFlex;

  const BaseScreenLayout({
    super.key,
    required this.topBarTitle,
    required this.topBarSubtitle,
    required this.child,
    this.currentNavIndex = 0,
    this.onLogoutPressed,
    this.onNavTap,
    this.paddingTop = 120.0,
    this.paddingBottom = 20.0,
    this.centerContent = false,
    this.topSpacerFlex = 1,
    this.contentFlex = 3,
    this.bottomSpacerFlex = 1,
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
        onTap: onNavTap ?? (index) {
          // Implementar lógica de navegación posteriormente
          debugPrint('Tap en índice: $index');
        },
      ),
    );
  }
}
