/// Panel de filtros para el análisis
/// Ubicación: lib/widgets/admin/analysis_filters_panel.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/utils/admin/admin_analysis_constants.dart';

class AnalysisFiltersPanel extends StatelessWidget {
  final String searchTerm;
  final bool showFilters;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchClear;
  final VoidCallback onToggleFilters;
  final Function(String, String) onFilterToggle;
  final Function(String, String) isFilterSelected;

  const AnalysisFiltersPanel({
    super.key,
    required this.searchTerm,
    required this.showFilters,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onToggleFilters,
    required this.onFilterToggle,
    required this.isFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

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
      child: Column(
        children: [
          _buildSearchBar(palette),
          if (showFilters) ...[
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            const Divider(),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            _buildFiltersContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(RoleColorPalette palette) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: AdminAnalysisConstants.searchHint,
              prefixIcon: const Icon(
                AdminAnalysisConstants.searchIcon,
                size: AdminAnalysisConstants.iconSizeLarge,
              ),
              suffixIcon: searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        AdminAnalysisConstants.clearIcon,
                        size: AdminAnalysisConstants.iconSizeLarge,
                      ),
                      onPressed: onSearchClear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AdminAnalysisConstants.statsCardPadding,
              ),
            ),
          ),
        ),
        const SizedBox(width: AdminAnalysisConstants.statsCardPadding),
        ElevatedButton(
          onPressed: onToggleFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: showFilters ? palette.primary : Colors.grey[100],
            foregroundColor: showFilters ? Colors.white : Colors.grey[700],
            padding: const EdgeInsets.symmetric(
              horizontal: AdminAnalysisConstants.paddingLarge - 4,
              vertical: AdminAnalysisConstants.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
            ),
          ),
          child: const Row(
            children: [
              Icon(AdminAnalysisConstants.filterIcon, size: 18),
              SizedBox(width: AdminAnalysisConstants.paddingSmall),
              Text(AdminAnalysisConstants.filtersButton),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          AdminAnalysisConstants.careerFilterLabel,
          AdminAnalysisConstants.careerOptions,
          'careers',
        ),
        const SizedBox(height: AdminAnalysisConstants.paddingMedium),
        _buildFilterSection(
          AdminAnalysisConstants.periodFilterLabel,
          AdminAnalysisConstants.periodOptions,
          'period',
        ),
        const SizedBox(height: AdminAnalysisConstants.paddingMedium),
        _buildFilterSection(
          AdminAnalysisConstants.statusFilterLabel,
          AdminAnalysisConstants.statusOptions,
          'status',
        ),
      ],
    );
  }

  Widget _buildFilterSection(
    String label,
    Map<String, String> options,
    String category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AdminAnalysisConstants.paddingSmall),
        Wrap(
          spacing: AdminAnalysisConstants.paddingSmall,
          runSpacing: AdminAnalysisConstants.paddingSmall,
          children: options.entries.map((entry) {
            return _buildFilterChip(entry.key, entry.value, category);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, String category) {
    final isSelected = isFilterSelected(category, value);
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterToggle(category, value),
      selectedColor: palette.primary.withOpacity(0.2),
      checkmarkColor: palette.primary,
    );
  }
}
