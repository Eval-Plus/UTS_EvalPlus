import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';

// Screens
import 'package:eval_plus/screen/inside_screen.dart';

// Utils
import 'package:eval_plus/utils/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  static const String routename = 'HomeScreen';
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          _ImageBoxSuperior(size: size),
          _BoxInferior(),
          Positioned(
            top: size.height * 0.55,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.04),
              child: Column(
                children: [
                  // Título principal
                  Text(
                    "Inicio de Sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Descripción del propósito
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text(
                      "Tu opinión es indispensable. "
                      "Accede con tu correo institucional.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Botón de inicio de sesión con Microsoft
                  Container(
                    height: size.height * 0.065,
                    width: size.width * 0.75,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [  // Agregar sombra sutil
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: () async {
                        await AuthController.signInWithMicrosoft(context);
                        //Navigator.pushNamed(context, InsideScreen.routename);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icono de Microsoft
                          Image.asset(
                            'assets/icon/microsoft_icon.png', // Asegúrate de agregar este asset
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback si no existe la imagen
                              return const Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Ingresar",
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Texto informativo adicional
                  Text(
                    "Usa tu correo @uts.edu.co",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxInferior extends StatelessWidget {
  const _BoxInferior({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: CustomPaint(
            painter: _BoxPainter(),
          ),
        );
  }
}

class _ImageBoxSuperior extends StatelessWidget {
  const _ImageBoxSuperior({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: size.width * 0.1,
      top: size.height * 0.1,
      right: size.width * 0.1,
      child: SizedBox(
        height: size.height * 0.35,
        width: size.width * 0.8,
        child: SvgPicture.asset(
          'assets/illustrations/uts_green.svg',
          height: size.height * 0.2,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _BoxPainter extends CustomPainter{

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF818284)
      ..strokeWidth = 50
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(0, size.height * 0.5, size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.quadraticBezierTo(size.width, size.height * 0.5, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
