import 'package:flutter/material.dart';

enum MessageType {
  error,
  success,
  warning,
  info,
  noConnection,
}

class MessageDialogWidget extends StatelessWidget {
  final MessageType type;
  final String title;
  final String message;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final IconData? customIcon;
  final bool barrierDismissible;
  final Color? customColor; // 🎨 Color personalizado para el diálogo

  const MessageDialogWidget({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.customIcon,
    this.barrierDismissible = false,
    this.customColor, // 🎨 Nuevo parámetro
  });

  // Constructor para error de conexión (retrocompatibilidad)
  const MessageDialogWidget.connectionError({
    Key? key,
    String? title,
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
    String? retryButtonText,
    String? cancelButtonText,
  }) : this(
          key: key,
          type: MessageType.noConnection,
          title: title ?? 'Sin conexión a internet',
          message: message ?? 'No pudimos conectarnos al servidor. Verifica tu conexión e intenta nuevamente.',
          onPrimaryAction: onRetry,
          onSecondaryAction: onCancel,
          primaryButtonText: retryButtonText ?? 'Reintentar',
          secondaryButtonText: cancelButtonText,
        );

  // Constructor para errores generales
  const MessageDialogWidget.error({
    Key? key,
    required String title,
    required String message,
    VoidCallback? onAccept,
    String? acceptButtonText,
  }) : this(
          key: key,
          type: MessageType.error,
          title: title,
          message: message,
          onPrimaryAction: onAccept,
          primaryButtonText: acceptButtonText ?? 'Entendido',
        );

  // Constructor para éxito
  const MessageDialogWidget.success({
    Key? key,
    required String title,
    required String message,
    VoidCallback? onContinue,
    String? continueButtonText,
  }) : this(
          key: key,
          type: MessageType.success,
          title: title,
          message: message,
          onPrimaryAction: onContinue,
          primaryButtonText: continueButtonText ?? 'Continuar',
        );

  // Constructor para advertencia
  const MessageDialogWidget.warning({
    Key? key,
    required String title,
    required String message,
    VoidCallback? onAccept,
    VoidCallback? onCancel,
    String? acceptButtonText,
    String? cancelButtonText,
  }) : this(
          key: key,
          type: MessageType.warning,
          title: title,
          message: message,
          onPrimaryAction: onAccept,
          onSecondaryAction: onCancel,
          primaryButtonText: acceptButtonText ?? 'Aceptar',
          secondaryButtonText: cancelButtonText ?? 'Cancelar',
        );

  const MessageDialogWidget.info({
    Key? key,
    required String title,
    required String message,
    VoidCallback? onContinue,
    String? continueButtonText,
  }) : this(
          key: key,
          type: MessageType.info,
          title: title,
          message: message,
          onPrimaryAction: onContinue,
          primaryButtonText: continueButtonText ?? 'Entendido',
        );

  @override
  Widget build(BuildContext context) {
    final config = _getConfigForType();

    return WillPopScope(
      onWillPop: () async => barrierDismissible,
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
                          color: customColor?.withOpacity(0.15) ?? config.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          customIcon ?? config.icon,
                          size: 64,
                          color: customColor ?? config.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Título
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Mensaje
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Botones
                    _buildButtons(config),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(_MessageConfig config) {
    return Column(
      children: [
        // Botón primario
        if (onPrimaryAction != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPrimaryAction,
              icon: Icon(config.primaryButtonIcon),
              label: Text(primaryButtonText ?? config.defaultPrimaryText),
              style: ElevatedButton.styleFrom(
                backgroundColor: customColor ?? config.primaryButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        
        // Botón secundario
        if (secondaryButtonText != null && onSecondaryAction != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: Text(
                secondaryButtonText!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ],
    );
  }

  _MessageConfig _getConfigForType() {
    switch (type) {
      case MessageType.error:
        return _MessageConfig(
          icon: Icons.error_outline,
          iconColor: Colors.red[700]!,
          backgroundColor: Colors.red[50]!,
          primaryButtonColor: Colors.red[600]!,
          primaryButtonIcon: Icons.check,
          defaultPrimaryText: 'Entendido',
        );
      
      case MessageType.success:
        return _MessageConfig(
          icon: Icons.check_circle_outline,
          iconColor: Colors.green[700]!,
          backgroundColor: Colors.green[50]!,
          primaryButtonColor: Colors.green[600]!,
          primaryButtonIcon: Icons.arrow_forward,
          defaultPrimaryText: 'Continuar',
        );
      
      case MessageType.warning:
        return _MessageConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange[700]!,
          backgroundColor: Colors.orange[50]!,
          primaryButtonColor: Colors.orange[600]!,
          primaryButtonIcon: Icons.check,
          defaultPrimaryText: 'Aceptar',
        );
      
      case MessageType.info:
        return _MessageConfig(
          icon: Icons.info_outline,
          iconColor: Colors.blue[700]!,
          backgroundColor: Colors.blue[50]!,
          primaryButtonColor: Colors.blue[600]!,
          primaryButtonIcon: Icons.check,
          defaultPrimaryText: 'Entendido',
        );
      
      case MessageType.noConnection:
        return _MessageConfig(
          icon: Icons.wifi_off,
          iconColor: Colors.orange[700]!,
          backgroundColor: Colors.orange[50]!,
          primaryButtonColor: const Color(0xFF6366F1),
          primaryButtonIcon: Icons.refresh,
          defaultPrimaryText: 'Reintentar',
        );
    }
  }
}

class _MessageConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color primaryButtonColor;
  final IconData primaryButtonIcon;
  final String defaultPrimaryText;

  _MessageConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.primaryButtonColor,
    required this.primaryButtonIcon,
    required this.defaultPrimaryText,
  });
}
