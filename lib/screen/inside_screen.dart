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
  
  // 🆕 PageController para manejar el swipe
  late PageController _pageController;
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _loadUserData();

    // 🆕 Inicializar PageController
    _pageController = PageController(initialPage: 0);

    // Configuración de sesión
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<UserSessionController>();
      
      if (!session.isLoading && session.userRoles.isEmpty) {
        session.loadUserSession().then((_) {
          if (mounted) {
            final initialIndex = NavigationConfig.getInitialIndex();
            setState(() {
              _currentIndex = initialIndex;
            });
            // 🆕 Actualizar PageController
            _pageController.jumpToPage(initialIndex);
          }
        });
      } else {
        final initialIndex = NavigationConfig.getInitialIndex();
        setState(() {
          _currentIndex = initialIndex;
        });
        // 🆕 Actualizar PageController
        _pageController.jumpToPage(initialIndex);
      }
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
    _pageController.dispose(); // 🆕 Limpiar PageController
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

  // 🆕 Método para manejar cambios de página (swipe)
  void _onPageChanged(int newIndex) {
    final session = context.read<UserSessionController>();
    
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

  // Método para manejar navegación desde BottomNavBar (tap)
  void _onNavIndexChanged(int newIndex) {
    final session = context.read<UserSessionController>();
    
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
    
    // 🆕 Animar PageView al índice seleccionado
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    
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
      builder: (dialogContext) => _buildLogoutConfirmationDialog(dialogContext),
    );
  }

  Widget _buildLogoutConfirmationDialog(BuildContext dialogContext) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono animado
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          size: 64,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Título
                    const Text(
                      '¿Cerrar sesión?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Mensaje
                    Text(
                      '¿Estás seguro que deseas salir de tu cuenta?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Botones
                    Column(
                      children: [
                        // Botón de cerrar sesión (rojo)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              _executeLogout();
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Cerrar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Botón cancelar
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _executeLogout() async {
    // Mostrar loader elaborado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLogoutLoadingDialog(),
    );
    
    try {
      debugPrint('🔴 Clearing auth data...');
      
      // Simular un pequeño delay para mostrar la animación
      await Future.delayed(const Duration(milliseconds: 1500));
      
      await AuthStorageService.clearAuthData();
      await UserController.clearUserProfile();

      CareersService().clearCache();
      QuestionsService().clearCache();
      SubjectsService().clearCache();
      
      debugPrint('🔴 Auth data cleared');
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted) {
        context.read<UserSessionController>().resetSession();
        Navigator.of(context).pop(); // Cerrar el loader
        
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
        Navigator.of(context).pop(); // Cerrar el loader
        _showLogoutErrorDialog();
      }
    }
  }

  Widget _buildLogoutLoadingDialog() {
    final session = context.read<UserSessionController>();
    final palette = AppColors.getPaletteForRole(session.currentRole);
    
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loader con los colores del rol
              TweenAnimationBuilder<double>(
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
                          palette.primary.withOpacity(0.15),
                          palette.primaryDark.withOpacity(0.15),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: palette.primary.withOpacity(0.2),
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
                              palette.primary,
                            ),
                            backgroundColor: palette.primary.withOpacity(0.2),
                          ),
                        ),
                        // Icono central
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: palette.primaryGradient,
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
              ),
              
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
              _buildAnimatedDots(palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDots(RoleColorPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
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
                color: palette.primary.withOpacity(value * 0.8),
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
        // 🔥 CAMBIO: Mostrar loading mientras la sesión se carga
        if (session.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCAD225),
              ),
            ),
          );
        }

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

        final contents = NavigationConfig.getContentsForRole(
          session.currentRole,
          _currentUser,
        );
        
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
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: const BouncingScrollPhysics(), // 🆕 Física de scroll suave
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
