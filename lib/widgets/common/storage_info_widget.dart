import 'package:flutter/material.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

/// Widget informativo sobre el tipo de almacenamiento usado
/// Útil para desarrollo y debugging
class StorageInfoWidget extends StatelessWidget {
  final bool showInProduction;

  const StorageInfoWidget({
    Key? key,
    this.showInProduction = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // En producción, solo mostrar si showInProduction es true
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (!isDebug && !showInProduction) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _getStorageInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        final isSecure = info['isSecure'] as bool;
        final platform = info['platform'] as String;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSecure 
              ? Colors.green.shade50 
              : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSecure 
                ? Colors.green.shade200 
                : Colors.orange.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSecure ? Icons.lock : Icons.info_outline,
                color: isSecure ? Colors.green.shade700 : Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Almacenamiento: $platform',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSecure 
                          ? Colors.green.shade900 
                          : Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSecure 
                        ? 'Datos encriptados de forma segura'
                        : 'Almacenamiento local (desarrollo)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSecure 
                          ? Colors.green.shade700 
                          : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getStorageInfo() async {
    final isSecure = await AuthStorageService.isSecureStorage();
    final platform = await AuthStorageService.getPlatformName();

    return {
      'isSecure': isSecure,
      'platform': platform,
    };
  }
}