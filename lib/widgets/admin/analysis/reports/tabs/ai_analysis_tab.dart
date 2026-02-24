/// Tab de análisis de IA del reporte
/// Conectado a la API real — sin datos hardcodeados
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/ai_analysis_tab.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/admin/ai_analysis_model.dart';
import 'package:eval_plus/services/admin/ai_analysis_service.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/loading/ai_regeneration_loading.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/animated_ai_content.dart';

class AIAnalysisTab extends StatefulWidget {
  final int teacherId;
  final String teacherName;
  final String periodo;

  const AIAnalysisTab({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.periodo,
  });

  @override
  State<AIAnalysisTab> createState() => _AIAnalysisTabState();
}

class _AIAnalysisTabState extends State<AIAnalysisTab> {
  late final AIAnalysisService _service;

  // Controla si el contenido debe animarse (solo en generación nueva)
  bool _animateContent = false;

  // Key para forzar reconstrucción de AnimatedAIContent al regenerar
  int _contentKey = 0;

  @override
  void initState() {
    super.initState();
    _service = AIAnalysisService();
    _service.addListener(_onServiceChanged);

    // Cargar análisis al abrir el tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service.loadAnalysis(
        teacherId: widget.teacherId,
        periodo: widget.periodo,
      );
    });
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────
  // ACCIONES
  // ─────────────────────────────────────────

  Future<void> _generateAnalysis() async {
    setState(() {
      _animateContent = true;
      _contentKey++;
    });

    await _service.generateAnalysis(
      teacherId: widget.teacherId,
      periodo: widget.periodo,
      teacherName: widget.teacherName,
    );

    // Si hubo error en la generación, mostrar snackbar
    if (_service.hasError && mounted) {
      _showErrorSnackbar(_service.errorMessage ?? 'Error al generar análisis');
    }
  }

  Future<void> _refreshAnalysis() async {
    setState(() {
      _animateContent = true;
      _contentKey++;
    });

    await _service.generateAnalysis(
      teacherId: widget.teacherId,
      periodo: widget.periodo,
      teacherName: widget.teacherName,
    );

    if (_service.hasError && mounted) {
      _showErrorSnackbar(_service.errorMessage ?? 'Error al actualizar análisis');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return switch (_service.status) {
      AIAnalysisStatus.idle || AIAnalysisStatus.loading => _buildLoadingTab(palette),
      AIAnalysisStatus.generating                       => AIRegenerationLoading(palette: palette),
      AIAnalysisStatus.empty                            => _buildEmptyState(palette),
      AIAnalysisStatus.error                            => _buildErrorState(palette),
      AIAnalysisStatus.loaded                           => _buildAnalysisContent(palette),
    };
  }

  // ─────────────────────────────────────────
  // ESTADOS
  // ─────────────────────────────────────────

  Widget _buildLoadingTab(RoleColorPalette palette) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: palette.primary),
          const SizedBox(height: 16),
          const Text(
            'Verificando análisis...',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(RoleColorPalette palette) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono decorativo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary.withOpacity(0.08),
                border: Border.all(
                  color: palette.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 48,
                color: palette.primary.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Sin análisis generado',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Aún no existe un análisis de IA para este docente '
              'en el período ${widget.periodo}.\n'
              'Genera el análisis inicial para obtener fortalezas, '
              'áreas de mejora y recomendaciones.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Mostrar error de generación si existe
            if (_service.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _service.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Botón de generar
            ElevatedButton.icon(
              onPressed: _generateAnalysis,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                'Generar análisis inicial',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: palette.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(RoleColorPalette palette) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el análisis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _service.errorMessage ?? 'Error desconocido',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _service.loadAnalysis(
                teacherId: widget.teacherId,
                periodo: widget.periodo,
                forceRefresh: true,
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.primary,
                side: BorderSide(color: palette.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(RoleColorPalette palette) {
    final analysis = _service.currentAnalysis!;
    final insights = _mapToAIInsights(analysis);

    return AnimatedAIContent(
      key: ValueKey('ai_content_$_contentKey'),
      insights: insights,
      animate: _animateContent,
      refreshButton: _buildRefreshButton(palette),
    );
  }

  // ─────────────────────────────────────────
  // BOTÓN DE ACTUALIZAR
  // ─────────────────────────────────────────

  Widget _buildRefreshButton(RoleColorPalette palette) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _refreshAnalysis,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text(
            'Actualizar Análisis',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: palette.primary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // CONVERSIÓN DE MODELO
  // ─────────────────────────────────────────

  /// Convierte AIAnalysisModel (backend) → AIInsights (widgets)
  AIInsights _mapToAIInsights(AIAnalysisModel analysis) {
    return AIInsights(
      profile: analysis.profile,
      strengths: analysis.strengths,
      improvements: analysis.improvements,
      recommendations: analysis.recommendations,
      // evaluationFeedback y sentimentFeedback no vienen del backend por ahora
      evaluationFeedback: const [],
      sentimentFeedback: const [],
    );
  }
}