import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Contenido
import 'package:eval_plus/screen/content/careers_content.dart';
import 'package:eval_plus/screen/content/evaluations_content.dart';
import 'package:eval_plus/screen/content/profile_content.dart';

// Layouts
import 'package:eval_plus/layouts/base_screen_layout.dart';

// Screens
import 'package:eval_plus/screen/home_screen.dart';

// Services
import 'package:eval_plus/services/storage/auth_storage_service.dart';

// Controllers
import 'package:eval_plus/controllers/user_controller.dart';

// Models
import 'package:eval_plus/models/user_model.dart';

class InsideScreen extends StatefulWidget {
  static const String routename = 'InsideScreen';
  const InsideScreen({super.key});

  @override
  State<InsideScreen> createState() => _InsideScreenState();
}

class _InsideScreenState extends State<InsideScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  UserModel? _currentUser;
  String _welcomeMessage = 'Bienvenido';
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Lista de los diferentes contenidos
  List<Widget> get _contents => [
    const CarrerasContent(),
    const EvaluationsList(),
    ProfileContent(user: _currentUser),
  ];

  @override
  void initState() {
    super.initState();

    // Cargar datos del usuario
    _loadUserData();
    
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

  // Cargar Estudiante
  Future<void> _loadUserData() async {
    final user = await UserController.loadUserProfile();
    
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
        _welcomeMessage = 'Bienvenido, ${user.firstName}';
      });
    }
  }

  // Función de logout
  Future<void> _handleLogout() async {
    debugPrint('🔴 Logout initiated from InsideScreen');
    
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        debugPrint('🔴 Clearing auth data...');
        await AuthStorageService.clearAuthData();
        debugPrint('🔴 Auth data cleared');
        
        if (mounted) {
          debugPrint('🔴 Navigating to HomeScreen...');
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routename,
            (route) => false,
          );
          debugPrint('🔴 Navigation completed');
        }
      } catch (e) {
        debugPrint('🔴 ERROR: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cerrar sesión'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      topBarTitle: _welcomeMessage,
      topBarSubtitle: '@Panel de estudiante',
      currentNavIndex: _currentIndex,
      centerContent: false,
      paddingTop: 80.0,
      paddingBottom: 20.0,
      onLogoutPressed: _handleLogout,
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
