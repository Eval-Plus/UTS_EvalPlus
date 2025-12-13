
// Funcionamiento de Estudiantes - V
// Funcionamiento de Docentes - X
// Funcionamiento Administrativo - X

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Config
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/config/navigation_config.dart';

// Layouts
import 'package:eval_plus/layouts/base_screen_layout.dart';

// Screens
import 'package:eval_plus/screen/home_screen.dart';

// Services
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/services/careers_service.dart';
import 'package:eval_plus/services/questions_service.dart';
import 'package:eval_plus/services/subjects_service.dart';

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
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<UserSessionController>();
      
      session.loadUserSession().then((_) {
        if (mounted) {
          setState(() {
            // 👇 Usar índice inicial seguro
            _currentIndex = NavigationConfig.getInitialIndex();
          });
        }
      });
    });
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _updateAnimations(isMovingRight: true);
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimations({required bool isMovingRight}) {
    final Offset beginOffset = isMovingRight
        ? const Offset(0.25, 0.0)
        : const Offset(-0.25, 0.0);
    
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _onNavIndexChanged(int newIndex) {
    final session = context.read<UserSessionController>();
    
    // 👇 Validación centralizada
    if (!NavigationConfig.isValidIndex(newIndex, session.currentRole)) {
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

  Future<void> _loadUserData() async {
    final user = await UserController.loadUserProfile();
    
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
        _welcomeMessage = 'Bienvenido, ${user.firstName}';
      });
    }
  }

  Future<void> _handleLogout() async {
    debugPrint('🔴 Logout initiated from InsideScreen');
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => MessageDialogWidget.warning(
        title: '¿Cerrar sesión?',
        message: '¿Estás seguro que deseas salir de tu cuenta?',
        onAccept: () async {
          Navigator.of(dialogContext).pop();
          _showLogoutProcessingDialog();
          
          try {
            debugPrint('🔴 Clearing auth data...');
            await AuthStorageService.clearAuthData();
            await UserController.clearUserProfile();

            CareersService().clearCache();
            QuestionsService().clearCache();
            SubjectsService().clearCache();
            
            debugPrint('🔴 Auth data cleared');
            
            await Future.delayed(const Duration(milliseconds: 800));
            
            if (mounted) {
              context.read<UserSessionController>().resetSession();
              Navigator.of(context).pop();
              
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
              Navigator.of(context).pop();
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

        // 👇 Obtener contenidos desde configuración centralizada
        final contents = NavigationConfig.getContentsForRole(
          session.currentRole,
          _currentUser,
        );
        
        // 👇 Validar índice actual
        final safeIndex = NavigationConfig.isValidIndex(_currentIndex, session.currentRole)
            ? _currentIndex
            : NavigationConfig.getInitialIndex();
        
        return BaseScreenLayout(
          topBarTitle: _welcomeMessage,
          topBarSubtitle: subtitle,
          currentNavIndex: safeIndex,
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
                      index: safeIndex,
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
