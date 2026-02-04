import 'package:flutter/material.dart';
import 'package:eval_plus/services/api/auth_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/screen/inside_screen.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

class ManualJwtAuthWidget extends StatefulWidget {
  final VoidCallback? onCancel;
  final Function(String token)? onTokenSubmit;

  const ManualJwtAuthWidget({
    Key? key,
    this.onCancel,
    this.onTokenSubmit,
  }) : super(key: key);

  @override
  State<ManualJwtAuthWidget> createState() => _ManualJwtAuthWidgetState();
}

class _ManualJwtAuthWidgetState extends State<ManualJwtAuthWidget> {
  final _tokenController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final token = _tokenController.text.trim();

    // Validación básica
    if (token.isEmpty) {
      _showErrorDialog('El token no puede estar vacío');
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      print('🔐 Validando token...');

      final validationResult = await AuthApiService.validateToken(token);

      print('📋 Resultado: $validationResult');

      if (!mounted) return;

      if (validationResult['valid'] == true) {
        print('✅ Token válido');

        // Guardar token
        await AuthStorageService.saveToken(token: token);

        // Guardar usuario si viene
        if (validationResult['user'] != null) {
          await AuthStorageService.saveUser(
            user: validationResult['user'],
          );
        }

        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        // Token inválido
        print('❌ Token inválido');
        
        if (mounted) {
          _showErrorDialog(
            validationResult['message'] ?? 'Token inválido',
          );
        }
      }
    } catch (e) {
      print('💥 Error: $e');
      
      if (mounted) {
        _showErrorDialog(
          'Error al validar el token. Verifica tu conexión.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  // Nuevos métodos para mostrar diálogos
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MessageDialogWidget.error(
        title: 'Error de validación',
        message: message,
        onAccept: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MessageDialogWidget.success(
        title: 'Token validado',
        message: 'Tu token ha sido validado correctamente. Bienvenido a Eval+.',
        onContinue: () {
          Navigator.of(context).pop(); // Cerrar diálogo
          Navigator.of(context).pushReplacementNamed(
            InsideScreen.routename,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono y título
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 16),
            const Text(
              'Autenticación Manual',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pasos a seguir:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep(1, 'Abre tu navegador web'),
                  _buildStep(2, 'Ingresa a:\nevalplus-api.emprenet.work/api/auth/microsoft'),
                  _buildStep(3, 'Inicia sesión con tu cuenta Microsoft'),
                  _buildStep(4, 'Copia el token JWT que aparece'),
                  _buildStep(5, 'Pégalo en el campo de abajo'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Campo de texto
            TextField(
              controller: _tokenController,
              maxLines: 4,
              enabled: !_isValidating,
              decoration: InputDecoration(
                labelText: 'Token JWT',
                hintText: 'Pega aquí tu token...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 14),

            // Botones
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isValidating ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                // Botón Validar
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isValidating ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isValidating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Validar y Guardar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
