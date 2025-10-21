import 'package:flutter/material.dart';

class CustomHeaderWave extends StatelessWidget {
  final double height;
  final Color color;

  const CustomHeaderWave({
    super.key,
    this.height = 200,
    this.color = const Color(0xFF003C43),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: WavePainter(color: color),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({this.color = const Color(0xFF003C43)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.7);
    
    // Onda suave
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.7,
    );
    
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.55,
      size.width,
      size.height * 0.7,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
