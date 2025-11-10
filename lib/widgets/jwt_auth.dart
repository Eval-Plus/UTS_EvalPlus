import 'package:flutter/material.dart';

/// Estados posibles del widget
enum _JwtInputState {
  explanation,
  inputForm,
}

/// Widget para autenticación manual con JWT en plataformas no soportadas
class ManualJwtAuthWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final Future<void> Function(String token) onTokenSubmit;

  const ManualJwtAuthWidget({
    Key? key,
    required this.onCancel,
    required this.onTokenSubmit,
  }) : super(key: key);

  @override
  State<ManualJwtAuthWidget> createState() => _ManualJwtAuthWidgetState();
}

class _ManualJwtAuthWidgetState extends State<ManualJwtAuthWidget> {
  _JwtInputState _currentState = _JwtInputState.explanation;
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  /// Muestra un SnackBar de error
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Valida y envía el token JWT
  Future<void> _handleTokenSubmit() async {
    final token = _tokenController.text.trim();

    // Validaciones básicas
    if (token.isEmpty) {
      _showErrorSnackBar('El token no puede estar vacío');
      return;
    }

    if (!token.contains('.') || token.split('.').length != 3) {
      _showErrorSnackBar('El formato del token no es válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onTokenSubmit(token);
      if (mounted) {
        _showSuccessSnackBar('Token guardado correctamente');
      }
    } catch (e) {
      debugPrint('Error guardando token: $e');
      if (mounted) {
        _showErrorSnackBar('Error al guardar el token');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _currentState == _JwtInputState.explanation
          ? _buildExplanationView()
          : _buildInputFormView(),
    );
  }

  /// Vista de explicación inicial
  Widget _buildExplanationView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de advertencia
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Título
        const Text(
          'Plataforma no soportada',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Descripción
        Text(
          'La autenticación con Microsoft actualmente solo está disponible '
          'en dispositivos móviles (Android/iOS).\n\n'
          'Para desarrollo en desktop, puedes ingresar manualmente un JWT '
          'obtenido desde el navegador web.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Botones
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentState = _JwtInputState.inputForm;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ingresar JWT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Vista del formulario de entrada de JWT
  Widget _buildInputFormView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón para volver
        IconButton(
          onPressed: () {
            setState(() {
              _currentState = _JwtInputState.explanation;
              _tokenController.clear();
            });
          },
          icon: const Icon(Icons.arrow_back),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 16),

        // Título
        const Text(
          'Ingresar JWT',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),

        // Instrucciones
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pasos a seguir:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInstructionStep('1', 'Abre el navegador e ingresa a:'),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  'evalplus-api.emprenet.work/api/auth/microsoft',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildInstructionStep('2', 'Inicia sesión con Microsoft'),
              const SizedBox(height: 8),
              _buildInstructionStep('3', 'Copia el token JWT que aparece'),
              const SizedBox(height: 8),
              _buildInstructionStep('4', 'Pégalo en el campo de abajo'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Campo de texto para JWT
        TextField(
          controller: _tokenController,
          maxLines: 4,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'Token JWT',
            hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 20),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleTokenSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget helper para los pasos de las instrucciones
  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
