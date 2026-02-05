import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

// Config
import 'package:eval_plus/config/app_colors.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

class MicrosoftAuthWebView extends StatefulWidget {
  final String authUrl;
  final Function(Map<String, dynamic> authData) onAuthSuccess;
  final VoidCallback onAuthError;

  const MicrosoftAuthWebView({
    super.key,
    required this.authUrl,
    required this.onAuthSuccess,
    required this.onAuthError,
  });

  @override
  State<MicrosoftAuthWebView> createState() => _MicrosoftAuthWebViewState();
}

class _MicrosoftAuthWebViewState extends State<MicrosoftAuthWebView> 
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  late final AnimationController _animationController;
  bool _isLoading = true;
  bool _authProcessed = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _initializeWebView();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Flutter EvalPlus Mobile App')
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
            debugPrint('Page started: $url');
          },
          onPageFinished: (url) async {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            debugPrint('Page finished: $url');
            
            // 🔧 MEJORA: Inyectar CSS y JS para mejorar el comportamiento de inputs
            await _injectInputFixes();
            
            await _checkForAuthResponse();
          },
          onNavigationRequest: (request) {
            debugPrint('Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (!_authProcessed && mounted) {
              widget.onAuthError();
            }
          },
        ),
      );

    _loadAuthUrl();
  }

  /// 🔧 NUEVO: Inyecta mejoras de CSS y JavaScript para los inputs
  Future<void> _injectInputFixes() async {
    try {
      // JavaScript para mejorar el comportamiento de los inputs
      const String jsCode = '''
        (function() {
          // Mejorar todos los inputs de tipo text, email, password
          const inputs = document.querySelectorAll('input[type="text"], input[type="email"], input[type="password"]');
          
          inputs.forEach(function(input) {
            // Forzar comportamiento nativo del input
            input.setAttribute('autocomplete', 'off');
            input.setAttribute('autocorrect', 'off');
            input.setAttribute('autocapitalize', 'off');
            input.setAttribute('spellcheck', 'false');
            
            // Agregar listeners para mejorar respuesta
            input.addEventListener('input', function(e) {
              // Forzar actualización del valor
              this.value = this.value;
            }, true);
            
            // Mejorar el borrado
            input.addEventListener('keydown', function(e) {
              if (e.key === 'Backspace' || e.keyCode === 8) {
                // Permitir propagación natural del evento
                return true;
              }
            }, true);
          });
          
          console.log('Input fixes injected successfully');
        })();
      ''';
      
      await _controller.runJavaScript(jsCode);
      debugPrint('✅ Input fixes injected');
    } catch (e) {
      debugPrint('⚠️ Error injecting input fixes: $e');
    }
  }

  Future<void> _loadAuthUrl() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.authUrl));
    } on SocketException {
      if (mounted && !_authProcessed) {
        _showConnectionErrorDialog();
      }
    } catch (e) {
      debugPrint('Error loading auth URL: $e');
      if (mounted && !_authProcessed) {
        widget.onAuthError();
      }
    }
  }

  void _showConnectionErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => MessageDialogWidget.connectionError(
        onRetry: () {
          Navigator.of(context).pop();
          _loadAuthUrl();
        },
        onCancel: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        cancelButtonText: 'Volver',
      ),
    );
  }

  Future<void> _checkForAuthResponse() async {
    if (_authProcessed) return;

    try {
      final content = await _controller.runJavaScriptReturningResult(
        'document.body.innerText'
      );

      String contentString = content.toString().trim();

      if (contentString.startsWith('"') && contentString.endsWith('"')) {
        contentString = contentString.substring(1, contentString.length - 1);
      }

      contentString = contentString
          .replaceAll(r'\n', '')
          .replaceAll(r'\t', '')
          .replaceAll(r'\"', '"')
          .replaceAll(r'\\', '\\');

      debugPrint(
        'Page content preview: ${contentString.substring(0, contentString.length > 100 ? 100 : contentString.length)}'
      );

      if (contentString.startsWith('{') && contentString.contains('token')) {
        _authProcessed = true;
        
        if (mounted) {
          setState(() => _isLoading = true);
        }

        try {
          Map<String, dynamic> authData;
          try {
            authData = jsonDecode(contentString);
          } catch (_) {
            authData = jsonDecode(jsonDecode(contentString));
          }

          debugPrint('Auth data parsed: ${authData.keys}');

          Map<String, dynamic>? actualData;
          if (authData['data'] != null) {
            actualData = authData['data'];
          } else if (authData['token'] != null) {
            actualData = authData;
          }

          if (actualData != null && actualData['token'] != null) {
            debugPrint('Authentication successful, processing...');
            await Future.delayed(const Duration(milliseconds: 100));
            widget.onAuthSuccess(actualData);
          } else {
            debugPrint('Invalid auth data structure');
            widget.onAuthError();
          }
        } catch (e) {
          debugPrint('Error parsing auth data: $e');
          debugPrint('Content that failed to parse: $contentString');
          widget.onAuthError();
        }
      }
    } catch (e) {
      debugPrint('Error checking auth response: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de colores del rol estudiante (amarillo-verde)
    final palette = AppColors.getPaletteForRole(UserRole.student);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ingresar con Microsoft',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: palette.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Cerrar',
        ),
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: _buildLoadingState(palette),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(RoleColorPalette palette) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated loader con los colores del rol estudiante
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
                    child: Icon(
                      _authProcessed 
                          ? Icons.check_circle_rounded 
                          : Icons.login_rounded,
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _authProcessed 
                ? 'Procesando autenticación...' 
                : 'Cargando Microsoft Login...',
            key: ValueKey<bool>(_authProcessed),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Subtítulo
        if (!_authProcessed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Espera un momento mientras cargamos\nla página de inicio de sesión',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        // Indicador de puntos animados
        if (!_authProcessed) ...[
          const SizedBox(height: 24),
          _buildAnimatedDots(palette),
        ],
      ],
    );
  }

  Widget _buildAnimatedDots(RoleColorPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_animationController.value - delay) % 1.0;
            final opacity = (value * 2).clamp(0.3, 1.0);
            final scale = 0.7 + (value * 0.6).clamp(0.0, 0.3);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.primary.withOpacity(opacity),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}