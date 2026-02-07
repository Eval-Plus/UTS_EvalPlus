/// Tab de análisis de IA del reporte (Con regeneración y animaciones)
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/ai_analysis_tab.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/loading/ai_regeneration_loading.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/animated_ai_content.dart';

class AIAnalysisTab extends StatefulWidget {
  final AIInsights insights;

  const AIAnalysisTab({
    super.key,
    required this.insights,
  });

  @override
  State<AIAnalysisTab> createState() => _AIAnalysisTabState();
}

class _AIAnalysisTabState extends State<AIAnalysisTab> {
  bool _isRegenerating = false;
  bool _shouldAnimate = false;
  late AIInsights _currentInsights;
  int _regenerationCount = 0; // Contador para forzar reconstrucción completa

  @override
  void initState() {
    super.initState();
    _currentInsights = widget.insights;
  }

  // ==================== REGENERACIÓN DE ANÁLISIS ====================

  /// Simula la regeneración del análisis IA
  Future<void> _regenerateAnalysis() async {
    if (_isRegenerating) return;

    setState(() {
      _isRegenerating = true;
      _shouldAnimate = false;
    });

    // Simular tiempo de procesamiento (2.5 segundos)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Generar nuevo análisis simulado
    final newInsights = _generateSimulatedInsights();

    setState(() {
      _currentInsights = newInsights;
      _isRegenerating = false;
      _shouldAnimate = true; // Activar animación para el nuevo contenido
      _regenerationCount++; // Incrementar contador para nueva key única
    });
  }

  /// Genera insights simulados (hardcodeados con variaciones)
  AIInsights _generateSimulatedInsights() {
    // Lista de perfiles alternativos
    final profiles = [
      "Docente con excelente dominio técnico y fuerte compromiso con el aprendizaje estudiantil",
      "Profesional destacado en pedagogía activa y con gran capacidad de adaptación metodológica",
      "Educador experimentado con sólidas bases teóricas y enfoque centrado en el estudiante",
    ];

    // Listas de fortalezas alternativas
    final strengthsOptions = [
      [
        "Dominio excepcional de la materia y actualización constante",
        "Claridad en la orientación de conceptos y teorías",
        "Buena organización y presentación del plan de curso",
      ],
      [
        "Excelente capacidad para motivar y generar interés en los estudiantes",
        "Comunicación efectiva y retroalimentación oportuna",
        "Innovación en el uso de recursos didácticos",
      ],
      [
        "Alta disponibilidad y disposición para resolver dudas",
        "Fomenta el pensamiento crítico y la participación activa",
        "Evalúa de manera justa y constructiva",
      ],
    ];

    // Listas de mejoras alternativas
    final improvementsOptions = [
      [
        "Incrementar el uso de materiales en idioma extranjero",
        "Diversificar las estrategias metodológicas",
      ],
      [
        "Integrar más tecnologías educativas emergentes",
        "Fortalecer la retroalimentación individualizada",
      ],
      [
        "Aumentar las actividades prácticas y casos reales",
        "Mejorar la comunicación de expectativas y criterios de evaluación",
      ],
    ];

    // Listas de recomendaciones alternativas
    final recommendationsOptions = [
      [
        "Integrar más recursos multimedia en idioma inglés gradualmente",
        "Implementar metodologías activas como aprendizaje basado en proyectos",
      ],
      [
        "Explorar herramientas de gamificación para aumentar el engagement",
        "Establecer sesiones de mentoría individual con estudiantes en riesgo",
      ],
      [
        "Desarrollar guías de estudio más detalladas con ejemplos resueltos",
        "Organizar sesiones de peer feedback para enriquecer el aprendizaje",
      ],
    ];

    // Seleccionar aleatoriamente (basado en timestamp para variación)
    final now = DateTime.now();
    final index = now.second % 3;

    return AIInsights(
      profile: profiles[index],
      strengths: strengthsOptions[index],
      improvements: improvementsOptions[index],
      recommendations: recommendationsOptions[index],
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    // Si está regenerando, mostrar loading
    if (_isRegenerating) {
      return AIRegenerationLoading(palette: palette);
    }

    // Mostrar contenido con botón integrado en el scroll
    return AnimatedAIContent(
      key: ValueKey('ai_content_$_regenerationCount'), // Key única por regeneración
      insights: _currentInsights,
      animate: _shouldAnimate,
      refreshButton: _buildRefreshButton(palette),
    );
  }

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
          onPressed: _regenerateAnalysis,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text(
            'Actualizar Análisis',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: palette.primary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}