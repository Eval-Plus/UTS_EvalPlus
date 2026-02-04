/// Widget para el diálogo de loading durante logout
/// Ubicación: lib/widgets/inside_screen/logout_loading_dialog.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';

class LogoutLoadingDialog extends StatefulWidget {
  final RoleColorPalette palette;

  const LogoutLoadingDialog({
    super.key,
    required this.palette,
  });

  @override
  State<LogoutLoadingDialog> createState() => _LogoutLoadingDialogState();
}

class _LogoutLoadingDialogState extends State<LogoutLoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loader con los colores del rol
              _buildAnimatedLoader(),
              
              const SizedBox(height: 32),
              
              // Texto del estado
              Text(
                'Cerrando sesión...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtítulo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Espera un momento mientras limpiamos\ntu sesión de forma segura',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Indicador de puntos animados
              const SizedBox(height: 24),
              _buildAnimatedDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.palette.primary.withOpacity(0.15),
                widget.palette.primaryDark.withOpacity(0.15),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.palette.primary.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // CircularProgressIndicator
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.palette.primary,
                  ),
                  backgroundColor: widget.palette.primary.withOpacity(0.2),
                ),
              ),
              // Icono central
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.palette.primaryGradient,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('dot_$index'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.palette.primary.withOpacity(value * 0.8),
              ),
            );
          },
          onEnd: () {
            // Loop infinito
            if (mounted) {
              setState(() {});
            }
          },
        );
      }),
    );
  }
}
