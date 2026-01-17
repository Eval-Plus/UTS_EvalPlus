/// Contenido de configuración para ADMINISTRADORES (Refactorizado v3)
/// Panel de sincronización y gestión del sistema
/// Ubicación: lib/screen/content/admin/config_content.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Config
import 'package:eval_plus/config/app_colors.dart';

// Controllers
import 'package:eval_plus/controllers/admin/admin_config_controller.dart';
import 'package:eval_plus/controllers/inside_screen_controller.dart';

// Utils
import 'package:eval_plus/utils/admin/admin_config_constants.dart';
import 'package:eval_plus/utils/admin/admin_sync_validator.dart';

// Widgets
import 'package:eval_plus/widgets/admin/config/config_header.dart';
import 'package:eval_plus/widgets/admin/config/config_system_status.dart';
import 'package:eval_plus/widgets/admin/config/config_action_card.dart';
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

class ConfigContent extends StatefulWidget {
  const ConfigContent({super.key});

  @override
  State<ConfigContent> createState() => _ConfigContentState();
}

class _ConfigContentState extends State<ConfigContent> {
  final _adminPalette = AppColors.getPaletteForRole(UserRole.admin);

  // ==================== MANEJO DE ACCIONES ====================

  Future<void> _handleAction(String actionKey) async {
    final controller = context.read<InsideScreenController>().adminConfigController;
    final result = await controller.executeAction(actionKey);

    if (!mounted) return;

    // Si hay resultado de validación con diálogo, mostrarlo
    if (!result.success && 
        result.validationResult != null && 
        result.validationResult!.showDialog) {
      _showValidationDialog(result.validationResult!);
      return;
    }

    // Mostrar mensaje de éxito o error
    if (result.success) {
      _showSuccessDialog(result.message, actionKey);
    } else {
      _showErrorDialog(result.message);
    }
  }

  void _showValidationDialog(SyncValidationResult validation) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MessageDialogWidget(
        type: MessageType.info,
        title: validation.dialogTitle!,
        message: validation.dialogMessage!,
        customIcon: validation.dialogIcon,
        customColor: validation.dialogColor,
        onPrimaryAction: () => Navigator.of(context).pop(),
        primaryButtonText: 'Entendido',
        barrierDismissible: true,
      ),
    );
  }

  void _showSuccessDialog(String message, String actionKey) {
    final metadata = _getActionMetadata(actionKey);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MessageDialogWidget(
        type: MessageType.success,
        title: 'Sincronización exitosa',
        message: message,
        customIcon: metadata.icon,
        customColor: metadata.color,
        onPrimaryAction: () => Navigator.of(context).pop(),
        primaryButtonText: 'Entendido',
        barrierDismissible: true,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MessageDialogWidget.error(
        title: 'Error en sincronización',
        message: message,
        onAccept: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ==================== HELPERS ==================== 

  _SyncActionMetadata _getActionMetadata(String actionKey) {
    switch (actionKey) {
      case 'sync-students':
        return _SyncActionMetadata(
          color: AdminConfigConstants.emeraldColor,
          icon: AdminConfigConstants.studentsIcon,
        );
      case 'enroll-teachers':
        return _SyncActionMetadata(
          color: AdminConfigConstants.limeColor,
          icon: AdminConfigConstants.teachersIcon,
        );
      case 'generate-evaluations':
        return _SyncActionMetadata(
          color: AdminConfigConstants.tealColor,
          icon: AdminConfigConstants.evaluationsIcon,
        );
      default:
        return _SyncActionMetadata(
          color: _adminPalette.primary,
          icon: Icons.check_circle_outline,
        );
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    // Obtener el controlador del InsideScreenController
    final screenController = context.watch<InsideScreenController>();
    final controller = screenController.adminConfigController;

    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AdminConfigController>(
        builder: (context, ctrl, child) {
          return RefreshIndicator(
            onRefresh: () => ctrl.loadDashboard(forceRefresh: true),
            color: _adminPalette.primary,
            child: _buildContent(ctrl),
          );
        },
      ),
    );
  }

  Widget _buildContent(AdminConfigController controller) {
    if (controller.isLoading) {
      return _buildLoadingState();
    }

    if (controller.errorMessage != null) {
      return _buildErrorState(controller, controller.errorMessage!);
    }

    if (controller.dashboard == null) {
      return const SizedBox.shrink();
    }

    final stats = controller.stats!;
    final periodo = controller.periodo!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            ConfigHeader(periodo: periodo, stats: stats),
            const SizedBox(height: 24),
            ConfigSystemStatus(stats: stats, palette: _adminPalette),
            const SizedBox(height: 24),
            _buildMainActions(controller, stats),
            const SizedBox(height: 20),
            _buildInfoBanner(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActions(AdminConfigController controller, stats) {
    // Obtener disponibilidad de acciones
    final availability = controller.getActionsAvailability();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AdminConfigConstants.playIcon,
                color: _adminPalette.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Acciones de Sincronización',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConfigActionCard(
            icon: AdminConfigConstants.studentsIcon,
            title: AdminConfigConstants.studentsTitle,
            description: AdminConfigConstants.studentsDescription,
            actionLabel: AdminConfigConstants.studentsAction,
            gradient: AdminConfigConstants.emeraldGradient,
            stats: [
              ActionStat(label: 'Total', value: stats.totalStudents),
              ActionStat(label: 'Sincronizados', value: stats.syncedStudents),
              ActionStat(label: 'Pendientes', value: stats.pendingStudents),
            ],
            isLoading: controller.isActionLoading('sync-students'),
            isDisabled: !(availability['sync-students'] ?? false),
            onPressed: () => _handleAction('sync-students'),
          ),
          const SizedBox(height: 16),
          ConfigActionCard(
            icon: AdminConfigConstants.teachersIcon,
            title: AdminConfigConstants.teachersTitle,
            description: AdminConfigConstants.teachersDescription,
            actionLabel: AdminConfigConstants.teachersAction,
            gradient: AdminConfigConstants.limeGradient,
            stats: [
              ActionStat(label: 'Total', value: stats.totalTeachers),
              ActionStat(label: 'Inscritos', value: stats.enrolledTeachers),
              ActionStat(label: 'Pendientes', value: stats.pendingTeachers),
            ],
            isLoading: controller.isActionLoading('enroll-teachers'),
            isDisabled: !(availability['enroll-teachers'] ?? false),
            onPressed: () => _handleAction('enroll-teachers'),
          ),
          const SizedBox(height: 16),
          ConfigActionCard(
            icon: AdminConfigConstants.evaluationsIcon,
            title: AdminConfigConstants.evaluationsTitle,
            description: AdminConfigConstants.evaluationsDescription,
            actionLabel: AdminConfigConstants.evaluationsAction,
            gradient: AdminConfigConstants.tealGradient,
            stats: [
              ActionStat(label: 'Existentes', value: stats.totalEvaluations),
              ActionStat(label: 'Activas', value: stats.activeEvaluations),
              ActionStat(label: 'Cerradas', value: stats.closedEvaluations),
            ],
            isLoading: controller.isActionLoading('generate-evaluations'),
            isDisabled: !(availability['generate-evaluations'] ?? false),
            onPressed: () => _handleAction('generate-evaluations'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _adminPalette.chipBackground,
        border: Border.all(color: _adminPalette.borderColor(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AdminConfigConstants.infoIcon,
            color: _adminPalette.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AdminConfigConstants.infoBannerTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _adminPalette.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AdminConfigConstants.infoBannerMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: _adminPalette.primaryDark.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ESTADOS DE CARGA Y ERROR ====================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _adminPalette.primary),
          const SizedBox(height: 16),
          const Text(
            'Cargando dashboard...',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminConfigController controller, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.loadDashboard(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _adminPalette.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Metadatos visuales para cada tipo de sincronización
class _SyncActionMetadata {
  final Color color;
  final IconData icon;

  _SyncActionMetadata({
    required this.color,
    required this.icon,
  });
}
