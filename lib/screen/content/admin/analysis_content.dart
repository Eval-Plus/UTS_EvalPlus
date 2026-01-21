/// Contenido de análisis administrativo (Refactorizado - v2)
/// Ubicación: lib/screen/content/admin/analysis_content.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Config
import 'package:eval_plus/config/app_colors.dart';

// Controllers
import 'package:eval_plus/controllers/admin/admin_analysis_controller.dart';
import 'package:eval_plus/controllers/inside_screen_controller.dart';

// Utils
import 'package:eval_plus/utils/admin/admin_analysis_constants.dart';

// Widgets
import 'package:eval_plus/widgets/admin/analysis/analysis_header.dart';
import 'package:eval_plus/widgets/admin/analysis/analysis_filters_panel.dart';
import 'package:eval_plus/widgets/admin/analysis/analysis_stats_grid.dart';
import 'package:eval_plus/widgets/admin/analysis/analysis_teacher_card.dart';

class AnalysisContent extends StatefulWidget {
  const AnalysisContent({super.key});

  @override
  State<AnalysisContent> createState() => _AnalysisContentState();
}

class _AnalysisContentState extends State<AnalysisContent> {
  final _adminPalette = AppColors.getPaletteForRole(UserRole.admin);
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== MANEJO DE EVENTOS ====================

  void _onSearchChanged(String value) {
    final controller = context.read<InsideScreenController>().adminAnalysisController;
    controller.setSearchTerm(value);
  }

  void _onSearchClear() {
    _searchController.clear();
    final controller = context.read<InsideScreenController>().adminAnalysisController;
    controller.clearSearch();
  }

  void _onToggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AdminAnalysisConstants.retryButton,
          textColor: Colors.white,
          onPressed: () {
            final controller = context.read<InsideScreenController>().adminAnalysisController;
            controller.loadData(forceRefresh: true);
          },
        ),
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    // Obtener el controlador del InsideScreenController
    final screenController = context.watch<InsideScreenController>();
    final controller = screenController.adminAnalysisController;

    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AdminAnalysisController>(
        builder: (context, ctrl, child) {
          // Mostrar error si existe
          if (ctrl.errorMessage != null && !ctrl.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorSnackBar(ctrl.errorMessage!);
            });
          }

          return Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    // 🔥 FIX 1: Color verde del admin (igual que config_content)
                    color: _adminPalette.primary,
                    backgroundColor: Colors.white,
                    // 🔥 FIX 2: Forzar refresh real (no usar caché)
                    onRefresh: () async {
                      debugPrint('🔄 [AnalysisContent] Pull to refresh - Forzando recarga desde API');
                      await ctrl.refreshData();
                    },
                    child: ctrl.isInitialLoad
                        ? _buildInitialLoadingState()
                        : _buildContent(ctrl),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AdminAnalysisController controller) {
    return ListView(
      padding: const EdgeInsets.all(AdminAnalysisConstants.paddingMedium),
      children: [
        const AnalysisHeader(),
        const SizedBox(height: AdminAnalysisConstants.paddingMedium),
        
        // 🔥 FIX 3: Pasar opciones dinámicas de carreras
        AnalysisFiltersPanel(
          searchTerm: controller.searchTerm,
          showFilters: _showFilters,
          careerOptions: controller.careerOptions,
          onSearchChanged: _onSearchChanged,
          onSearchClear: _onSearchClear,
          onToggleFilters: _onToggleFilters,
          onFilterToggle: (category, value) => controller.toggleFilter(category, value),
          isFilterSelected: (category, value) => controller.isFilterSelected(category, value),
        ),
        const SizedBox(height: AdminAnalysisConstants.paddingMedium),

        if (controller.globalStats != null) ...[
          AnalysisStatsGrid(stats: controller.globalStats!),
          const SizedBox(height: AdminAnalysisConstants.paddingMedium),
        ],

        _buildSortingBar(controller),
        const SizedBox(height: AdminAnalysisConstants.paddingMedium),

        if (controller.isLoading)
          _buildLoadingOverlay()
        else if (controller.errorMessage != null)
          _buildErrorState(controller.errorMessage!)
        else if (controller.filteredTeachers.isEmpty)
          _buildEmptyState()
        else
          ...controller.filteredTeachers.map((teacher) {
            return AnalysisTeacherCard(
              teacher: teacher,
              isExpanded: controller.isTeacherExpanded(teacher.id),
              palette: _adminPalette,
              onTap: () => controller.toggleTeacherExpansion(teacher.id),
              initials: controller.getInitials(teacher.name),
            );
          }),
      ],
    );
  }

  Widget _buildSortingBar(AdminAnalysisController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AdminAnalysisConstants.paddingMedium),
      child: Row(
        children: [
          const Text(
            AdminAnalysisConstants.sortByLabel,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: AdminAnalysisConstants.statsCardPadding),
          Expanded(
            child: DropdownButton<String>(
              value: controller.sortBy,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  controller.setSortBy(value);
                }
              },
              items: AdminAnalysisConstants.sortOptions.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ESTADOS ====================

  Widget _buildInitialLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _adminPalette.primary),
          const SizedBox(height: AdminAnalysisConstants.paddingMedium),
          const Text(
            AdminAnalysisConstants.loadingMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(color: _adminPalette.primary),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminAnalysisConstants.avatarSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              AdminAnalysisConstants.errorIcon,
              size: AdminAnalysisConstants.headerContainerSize,
              color: Colors.red,
            ),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            const Text(
              AdminAnalysisConstants.errorTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AdminAnalysisConstants.paddingSmall),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                final controller = context.read<InsideScreenController>().adminAnalysisController;
                controller.loadData(forceRefresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text(AdminAnalysisConstants.retryButton),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminAnalysisConstants.avatarSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AdminAnalysisConstants.emptyIcon,
              size: AdminAnalysisConstants.headerContainerSize,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            Text(
              AdminAnalysisConstants.emptyStateTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AdminAnalysisConstants.paddingSmall),
            Text(
              AdminAnalysisConstants.emptyStateMessage,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
