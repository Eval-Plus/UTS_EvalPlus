import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// Controllers
import 'package:eval_plus/controllers/user_session_controller.dart';

class CustomHeaderWave extends StatelessWidget {
  final double height;

  const CustomHeaderWave({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener la paleta actual del usuario
    final palette = context.watch<UserSessionController>().palette;
    
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: WavePainter(
          color: palette.primary, // Usar color dinámico
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  
  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Primera onda (principal)
    _drawWave(canvas, size, color, 0.7, 0.85, 0.55);
    
    // Segunda onda (más clara y desplazada)
    _drawWave(
      canvas, 
      size, 
      color.withOpacity(0.5), 
      0.75, // Desplazamiento vertical
      0.9, 
      0.6,
    );
  }

  void _drawWave(
    Canvas canvas, 
    Size size, 
    Color waveColor, 
    double baseHeight,
    double peakHeight,
    double valleyHeight,
  ) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [waveColor, waveColor.withOpacity(0.8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * baseHeight);
    
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * peakHeight,
      size.width * 0.5,
      size.height * baseHeight,
    );
    
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * valleyHeight,
      size.width,
      size.height * baseHeight,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
