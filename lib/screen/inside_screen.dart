import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Contenido
import 'package:eval_plus/screen/content/careers_content.dart';
import 'package:eval_plus/screen/content/evaluations_content.dart';
import 'package:eval_plus/screen/content/profile_content.dart';

// Layouts
import 'package:eval_plus/layouts/base_screen_layout.dart';

class InsideScreen extends StatefulWidget {
  static const String routename = 'InsideScreen';
  const InsideScreen({super.key});

  @override
  State<InsideScreen> createState() => _InsideScreenState();
}

class _InsideScreenState extends State<InsideScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Lista de los diferentes contenidos
  final List<Widget> _contents = const [
    CarrerasContent(),
    EvaluationsList(),
    ProfileContent(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Configurar el AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // Inicializar animaciones
    _updateAnimations(isMovingRight: true);
    
    // Completar la animación inicial
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimations({required bool isMovingRight}) {
    // Dirección del movimiento
    final Offset beginOffset = isMovingRight
        ? const Offset(0.25, 0.0)
        : const Offset(-0.25, 0.0);
    
    // Animación de desplazamiento
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // Animación de opacidad
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animación de escala
    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _onNavIndexChanged(int newIndex) {
    if (newIndex == _currentIndex) return;
    
    // Determinar dirección del movimiento
    final bool isMovingRight = newIndex > _currentIndex;
    
    // Actualizar animaciones con la nueva dirección
    _updateAnimations(isMovingRight: isMovingRight);
    
    // Actualizar el índice y reiniciar la animación
    setState(() {
      _currentIndex = newIndex;
    });
    
    // Reiniciar y ejecutar la animación
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      topBarTitle: 'Hola, Luis Lozano',
      topBarSubtitle: '@Unidades Tecnológicas de Santander',
      currentNavIndex: _currentIndex,
      centerContent: false,
      paddingTop: 100.0,
      paddingBottom: 20.0,
      onLogoutPressed: () {
        // Cierre de sesión
        Navigator.pop(context);
      },
      onNavIndexChanged: _onNavIndexChanged,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _contents,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
