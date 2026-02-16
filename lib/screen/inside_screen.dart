/// Pantalla principal después del login (Refactorizada)
/// Ubicación: lib/screen/inside_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Config
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/config/navigation_config.dart';

// Layouts
import 'package:eval_plus/layouts/base_screen_layout.dart';

// Screens
import 'package:eval_plus/screen/home_screen.dart';

// Controllers
import 'package:eval_plus/controllers/user_session_controller.dart';
import 'package:eval_plus/controllers/inside_screen_controller.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';
import 'package:eval_plus/widgets/inside_screen/logout_confirmation_dialog.dart';
import 'package:eval_plus/widgets/inside_screen/logout_loading_dialog.dart';
import 'package:eval_plus/widgets/inside_screen/content_page_view.dart';

class InsideScreen extends StatefulWidget {
  static const String routename = 'InsideScreen';
  
  const InsideScreen({super.key});

  @override
  State<InsideScreen> createState() => _InsideScreenState();
}

class _InsideScreenState extends State<InsideScreen> 
    with SingleTickerProviderStateMixin {
  
  late InsideScreenController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    debugPrint('🎬 [InsideScreen] initState llamado');

    // Crear el controlador del screen
    _controller = InsideScreenController();

    // Crear el AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // Inicializar el controlador con el AnimationController
    _controller.initialize(_animationController);

    // Configurar la sesión
    _setupSession();
  }

  @override
  void dispose() {
    debugPrint('🎬 [InsideScreen] dispose llamado');
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Configura la sesión del usuario
  void _setupSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎬 [InsideScreen] Configurando sesión...');
      
      final session = context.read<UserSessionController>();
      
      if (!session.isLoading && session.userRoles.isEmpty) {
        debugPrint('🎬 [InsideScreen] Cargando roles de usuario...');
        session.loadUserSession().then((_) {
          if (mounted) {
            final initialIndex = NavigationConfig.getInitialIndex();
            _controller.setInitialIndex(initialIndex);
            debugPrint('🎬 [InsideScreen] Sesión configurada, índice inicial: $initialIndex');
          }
        });
      } else {
        final initialIndex = NavigationConfig.getInitialIndex();
        _controller.setInitialIndex(initialIndex);
        debugPrint('🎬 [InsideScreen] Usando sesión existente, índice inicial: $initialIndex');
      }
    });
  }

  /// Maneja el logout
  void _handleLogout() {
    debugPrint('🔴 [InsideScreen] Logout iniciado');
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => LogoutConfirmationDialog(
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          _executeLogout();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  /// Ejecuta el logout
  Future<void> _executeLogout() async {
    final session = context.read<UserSessionController>();
    final palette = AppColors.getPaletteForRole(session.currentRole);
    
    // Mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutLoadingDialog(palette: palette),
    );
    
    try {
      debugPrint('🔴 [InsideScreen] Ejecutando logout...');
      await _controller.executeLogout();
      
      if (mounted) {
        // Resetear sesión
        context.read<UserSessionController>().resetSession();
        
        // Cerrar el loader
        Navigator.of(context).pop();
        
        debugPrint('🔴 [InsideScreen] Navegando a HomeScreen...');
        
        // Navegar a HomeScreen
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routename,
          (route) => false,
        );
        
        debugPrint('🔴 [InsideScreen] Navegación completada');
      }
    } catch (e) {
      debugPrint('🔴 [InsideScreen] ERROR durante logout: $e');
      
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar el loader
        _showLogoutErrorDialog();
      }
    }
  }

  /// Muestra el diálogo de error de logout
  void _showLogoutErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => MessageDialogWidget.error(
        title: 'Error al cerrar sesión',
        message: 'Ocurrió un error al intentar cerrar tu sesión. '
                 'Por favor, intenta nuevamente.',
        onAccept: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionController>(
      builder: (context, session, child) {
        // Mostrar loading mientras la sesión se carga
        if (session.isLoading) {
          debugPrint('🎬 [InsideScreen] Mostrando loading de sesión...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCAD225),
              ),
            ),
          );
        }

        debugPrint('🎬 [InsideScreen] Sesión cargada, construyendo UI...');

        // 🆕 Proveer el controlador para que los widgets hijos puedan acceder
        return ChangeNotifierProvider.value(
          value: _controller,
          child: _buildScreenContent(session),
        );
      },
    );
  }

  Widget _buildScreenContent(UserSessionController session) {
    // 🔥 USAR Consumer PARA ESCUCHAR CAMBIOS DEL CONTROLLER Y PASAR EL USUARIO ACTUALIZADO
    return Consumer<InsideScreenController>(
      builder: (context, controller, child) {
        // 🔥 Mostrar loading mientras se carga el usuario
        if (controller.isLoadingUserData) {
          debugPrint('🎬 [InsideScreen] Cargando datos de usuario...');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: session.palette.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando tu perfil...',
                    style: TextStyle(
                      color: session.palette.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        debugPrint('🎯 [InsideScreen] Renderizando con:');
        debugPrint('   - Índice: ${controller.currentIndex}');
        debugPrint('   - Usuario: ${controller.currentUser?.nombreCompleto ?? "null"}');
        debugPrint('   - Email: ${controller.currentUser?.email ?? "null"}');
        debugPrint('   - Welcome: ${controller.welcomeMessage}');
        
        // Obtener contenidos según el rol CON EL USUARIO ACTUALIZADO
        final contents = NavigationConfig.getContentsForRole(
          session.currentRole,
          controller.currentUser, // 🔥 Pasar el usuario del controller
        );
        
        // Obtener subtítulo según el rol
        final subtitle = controller.getSubtitleForRole(session.currentRole);
        
        // Validar índice
        final safeIndex = NavigationConfig.isValidIndex(
          controller.currentIndex, 
          session.currentRole,
        ) ? controller.currentIndex : NavigationConfig.getInitialIndex();
        
        return BaseScreenLayout(
          topBarTitle: controller.welcomeMessage, // 🔥 Esto debería mostrar "Bienvenido, [Nombre]"
          topBarSubtitle: subtitle,
          currentNavIndex: safeIndex,
          centerContent: false,
          paddingTop: 80.0,
          paddingBottom: 20.0,
          onLogoutPressed: _handleLogout,
          onNavIndexChanged: (index) {
            debugPrint('🎯 [InsideScreen] onNavIndexChanged: $index');
            controller.onNavIndexChanged(index, session.currentRole);
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ContentPageView(
                pageController: controller.pageController,
                contents: contents,
                onPageChanged: (index) {
                  debugPrint('🎯 [InsideScreen] onPageChanged: $index');
                  controller.onPageChanged(index, session.currentRole);
                },
                slideAnimation: controller.slideAnimation,
                fadeAnimation: controller.fadeAnimation,
                scaleAnimation: controller.scaleAnimation,
              );
            },
          ),
        );
      },
    );
  }
}