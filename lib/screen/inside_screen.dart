import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Config
import 'package:eval_plus/config/app_colors.dart';

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
import 'package:eval_plus/controllers/user_session_controller.dart';

// Models
import 'package:eval_plus/models/user_model.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

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
  String _panelSubtittle = '@Panel de ...';
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Obtener contenidos segun rol
  List<Widget> _getContentsForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        // Estudiantes ven: Carreras, Evaluaciones, Perfil
        return [
          const CarrerasContent(),
          const EvaluationsList(),
          ProfileContent(user: _currentUser),
        ];
      
      case UserRole.teacher:
      case UserRole.admin:
        // Profesores y admins ven: Evaluaciones, Perfil
        return [
          const EvaluationsList(),
          ProfileContent(user: _currentUser),
        ];
    }
  }

  @override
  void initState() {
    super.initState();

    // Cargar datos del usuario
    _loadUserData();

    // Cargar sesión del usuario (roles y tema)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<UserSessionController>();
      
      // Cargar sesión
      session.loadUserSession().then((_) {
        // Resetear índice después de cargar el rol
        if (mounted) {
          setState(() {
            _currentIndex = 0; // Siempre empezar en la primera pestaña
          });
        }
      });
    });
    
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
    // Validar que el índice sea válido para el rol actual
    final session = context.read<UserSessionController>();
    final contents = _getContentsForRole(session.currentRole);
    
    if (newIndex >= contents.length) {
      debugPrint('⚠️ Índice inválido: $newIndex para rol ${session.currentRole.name}');
      return;
    }
    
    if (newIndex == _currentIndex) return;
    
    final bool isMovingRight = newIndex > _currentIndex;
    
    _updateAnimations(isMovingRight: isMovingRight);
    
    setState(() {
      _currentIndex = newIndex;
    });
    
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
    
    // Mostrar diálogo de confirmación con el nuevo widget
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => MessageDialogWidget.warning(
        title: '¿Cerrar sesión?',
        message: '¿Estás seguro que deseas salir de tu cuenta?',
        onAccept: () async {
          Navigator.of(dialogContext).pop(); // Cerrar diálogo de confirmación
          
          // Mostrar diálogo de procesamiento
          _showLogoutProcessingDialog();
          
          try {
            debugPrint('🔴 Clearing auth data...');
            await AuthStorageService.clearAuthData();
            await UserController.clearUserProfile();
            debugPrint('🔴 Auth data cleared');
            
            // Pequeña pausa para que el usuario vea el proceso
            await Future.delayed(const Duration(milliseconds: 800));
            
            if (mounted) {
              // Resetear tema al cerrar sesión
              context.read<UserSessionController>().resetSession();
              Navigator.of(context).pop(); // Cerrar diálogo de procesamiento
              
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
              Navigator.of(context).pop(); // Cerrar diálogo de procesamiento
              
              // Mostrar error con el nuevo widget
              _showLogoutErrorDialog();
            }
          }
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
        acceptButtonText: 'Cerrar sesión',
        cancelButtonText: 'Cancelar',
      ),
    );
  }

  // Nuevo método: Mostrar diálogo de procesamiento
  void _showLogoutProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cerrando sesión...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Nuevo método: Mostrar error de logout
  void _showLogoutErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => MessageDialogWidget.error(
        title: 'Error al cerrar sesión',
        message: 'Ocurrió un error al intentar cerrar tu sesión. Por favor, intenta nuevamente.',
        onAccept: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionController>(
      builder: (context, session, child) {
        // Generar subtítulo dinámicamente basado en el rol
        String subtitle;
        switch (session.currentRole) {
          case UserRole.student:
            subtitle = '@Panel de estudiante';
            break;
          case UserRole.teacher:
            subtitle = '@Panel de docente';
            break;
          case UserRole.admin:
            subtitle = '@Panel de administrador';
            break;
        }

        // Obtener contenidos según el rol
        final contents = _getContentsForRole(session.currentRole);
        
        return BaseScreenLayout(
          topBarTitle: _welcomeMessage,
          topBarSubtitle: subtitle,
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
                      children: contents,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
