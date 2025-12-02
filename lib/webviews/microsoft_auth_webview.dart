import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

// Webviews
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

class MicrosoftAuthWebView extends StatefulWidget {
  final String authUrl;
  final Function(Map<String, dynamic> authData) onAuthSuccess;
  final VoidCallback onAuthError;

  const MicrosoftAuthWebView({
    Key? key,
    required this.authUrl,
    required this.onAuthSuccess,
    required this.onAuthError,
  }) : super(key: key);

  @override
  State<MicrosoftAuthWebView> createState() => _MicrosoftAuthWebViewState();
}

class _MicrosoftAuthWebViewState extends State<MicrosoftAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _authProcessed = false; // Evitar procesamiento múltiple

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Flutter EvalPlus Mobile App')
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            debugPrint('Page started: $url');
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            debugPrint('Page finished: $url');
            
            // Verificar si hay respuesta de autenticación
            await _checkForAuthResponse();
          },
          onNavigationRequest: (request) {
            debugPrint('Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (!_authProcessed) {
              widget.onAuthError();
            }
          },
        ),
      );

    // Cargar la URL inicial
    _loadAuthUrl();
  }

  Future<void> _loadAuthUrl() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.authUrl));
    } on SocketException {
      // Error de conexión
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

      if (content == null) return;

      String contentString = content.toString().trim();

      // Algunos controladores agregan comillas al string completo
      if (contentString.startsWith('"') && contentString.endsWith('"')) {
        contentString = contentString.substring(1, contentString.length - 1);
      }

      // Decodificar secuencias escapadas tipo \" o \\n
      contentString = contentString
          .replaceAll(r'\n', '')
          .replaceAll(r'\t', '')
          .replaceAll(r'\"', '"')
          .replaceAll(r'\\', '\\');

      debugPrint(
        'Page content preview: ${contentString.substring(0, contentString.length > 100 ? 100 : contentString.length)}'
      );

      // A veces el backend retorna texto plano tipo JSON.stringify(obj)
      if (contentString.startsWith('{') && contentString.contains('token')) {
        _authProcessed = true;
        setState(() => _isLoading = true);

        try {
          // Si falla una vez, intentar doble decode
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar con Microsoft'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            /*if (!_authProcessed) {
              widget.onAuthError();
            }*/
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _authProcessed 
                          ? 'Procesando autenticación...' 
                          : 'Cargando...',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 16,
                      ),
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
