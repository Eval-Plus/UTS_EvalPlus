/// Widget para el diálogo de carga de reportes
/// Ubicación: lib/widgets/admin/analysis/reports/loading/report_loading_dialog.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';

class ReportLoadingDialog extends StatefulWidget {
  final String teacherName;
  final RoleColorPalette palette;

  const ReportLoadingDialog({
    super.key,
    required this.teacherName,
    required this.palette,
  });

  @override
  State<ReportLoadingDialog> createState() => _ReportLoadingDialogState();
}

class _ReportLoadingDialogState extends State<ReportLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              // Animated loader
              _buildAnimatedLoader(),
              
              const SizedBox(height: 32),
              
              // Título
              const Text(
                'Generando Informe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Nombre del docente
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.teacherName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Mensaje de estado
              _buildStatusMessages(),
              
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
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
                // CircularProgressIndicator rotatorio
                Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: SizedBox(
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
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessages() {
    return Column(
      children: [
        _buildStatusItem('Obteniendo datos de evaluaciones', 0),
        const SizedBox(height: 8),
        _buildStatusItem('Calculando estadísticas', 300),
        const SizedBox(height: 8),
        _buildStatusItem('Preparando visualizaciones', 600),
      ],
    );
  }

  Widget _buildStatusItem(String text, int delay) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('status_$delay'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: widget.palette.primary.withOpacity(value),
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF).withOpacity(value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
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
            if (mounted) {
              setState(() {});
            }
          },
        );
      }),
    );
  }
}
