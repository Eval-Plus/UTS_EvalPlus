import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';

// Screens
import 'package:eval_plus/screen/inside_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routename = 'HomeScreen';
  const HomeScreen({super.key});

  // Método para mostrar el modal de selección
  void _showRoleSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador superior
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título del modal
                const Text(
                  "Selecciona tu rol",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "¿Cómo deseas ingresar?",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Botón Estudiante
                _RoleButton(
                  icon: Icons.school,
                  title: "Estudiante",
                  description: "Evaluar a mis docentes",
                  color: const Color(0xFF4285F4),
                  onTap: () {
                    Navigator.pop(context); // Cerrar modal
                    Navigator.pushNamed(context, InsideScreen.routename);
                  },
                ),
                const SizedBox(height: 12),
                
                // Botón Docente
                _RoleButton(
                  icon: Icons.person,
                  title: "Docente",
                  description: "Ver mis evaluaciones",
                  color: const Color(0xFF34A853),
                  onTap: () {
                    Navigator.pop(context); // Cerrar modal
                    Navigator.pushNamed(context, InsideScreen.routename);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
  
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
                      onPressed: () {
                        _showRoleSelectionModal(context);
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

// Widget personalizado para los botones de rol
class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icono circular
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Icono de flecha
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
