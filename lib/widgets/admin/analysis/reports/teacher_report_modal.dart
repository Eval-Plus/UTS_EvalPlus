/// Modal de Informe Completo del Docente (Con datos reales de API) - FIXED
/// Ubicación: lib/widgets/admin/analysis/reports/teacher_report_modal.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/services/admin/teacher_report_service.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/report_header.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/responses_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/subjects_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/ai_analysis_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/comments_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/loading/report_loading_dialog.dart';

class TeacherReportModal extends StatefulWidget {
  final TeacherData teacher;

  const TeacherReportModal({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherReportModal> createState() => _TeacherReportModalState();
}

class _TeacherReportModalState extends State<TeacherReportModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TeacherReportService _reportService = TeacherReportService();

  // Datos de la API
  TeacherResponsesReport? _responsesData;
  
  // Datos hardcodeados (temporalmente para otras tabs)
  late List<CommentReport> _comments;
  late AIInsights _aiInsights;

  // Estado de carga
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoadingDialogShown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeHardcodedData();
    
    // Cargar datos después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadReportData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==================== CARGA DE DATOS ====================

  /// Carga los datos del reporte desde la API
  Future<void> _loadReportData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📊 Cargando datos del reporte para docente ${widget.teacher.id}...');

      // Mostrar diálogo de carga
      await _showLoadingDialog();

      // Cargar datos de respuestas desde la API
      final responsesData = await _reportService.getResponsesReport(
        teacherId: widget.teacher.id,
        periodo: widget.teacher.period,
        forceRefresh: false,
      );

      if (!mounted) return;

      // Cerrar loading dialog
      if (_isLoadingDialogShown) {
        Navigator.of(context).pop();
        _isLoadingDialogShown = false;
      }

      if (responsesData == null) {
        throw Exception(_reportService.responsesError ?? 'Error al cargar datos');
      }

      setState(() {
        _responsesData = responsesData;
        _isLoading = false;
        _errorMessage = null;
      });
      
      debugPrint('✅ Datos del reporte cargados exitosamente');
    } catch (e) {
      debugPrint('💥 Error cargando datos del reporte: $e');
      
      if (!mounted) return;

      // Cerrar loading dialog si está abierto
      if (_isLoadingDialogShown) {
        Navigator.of(context).pop();
        _isLoadingDialogShown = false;
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      // Esperar un frame antes de mostrar el error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorDialog(e.toString());
        }
      });
    }
  }

  /// Muestra el diálogo de carga
  Future<void> _showLoadingDialog() async {
    if (!mounted || _isLoadingDialogShown) return;
    
    final palette = AppColors.getPaletteForRole(UserRole.admin);
    
    _isLoadingDialogShown = true;
    
    // Mostrar el diálogo sin await completo para no bloquear
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportLoadingDialog(
        teacherName: widget.teacher.name,
        palette: palette,
      ),
    );

    // Dar tiempo para que el diálogo se muestre
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Muestra un diálogo de error
  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error al Cargar Informe'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pop(); // Cerrar diálogo de error
              Navigator.of(context).pop(); // Cerrar el modal completo
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pop(); // Cerrar diálogo de error
              _loadReportData(); // Reintentar
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ==================== DATOS HARDCODEADOS (TEMPORAL) ====================

  void _initializeHardcodedData() {
    _comments = [
      CommentReport(
        id: 1,
        text: "Excelente profesor, explica muy bien y siempre está dispuesto a ayudar",
        sentiment: "positive",
      ),
      CommentReport(
        id: 2,
        text: "Debería usar más ejemplos prácticos en clase",
        sentiment: "neutral",
      ),
      CommentReport(
        id: 3,
        text: "Muy buen dominio de la materia, pero a veces va muy rápido",
        sentiment: "positive",
      ),
    ];

    _aiInsights = AIInsights(
      profile: "Docente con excelente dominio técnico y fuerte compromiso con el aprendizaje estudiantil",
      strengths: [
        "Dominio excepcional de la materia y actualización constante",
        "Claridad en la orientación de conceptos y teorías",
        "Buena organización y presentación del plan de curso",
      ],
      improvements: [
        "Incrementar el uso de materiales en idioma extranjero",
        "Diversificar las estrategias metodológicas",
      ],
      recommendations: [
        "Integrar más recursos multimedia en idioma inglés gradualmente",
        "Implementar metodologías activas como aprendizaje basado en proyectos",
      ],
    );
  }

  // ==================== CONVERSIÓN DE DATOS ====================

  /// Convierte QuestionResponseData a QuestionReport para la UI
  List<QuestionReport> _convertToQuestionReports(List<QuestionResponseData> data) {
    return data.map((q) {
      return QuestionReport(
        id: q.id,
        text: q.text,
        category: q.category,
        aspect: q.aspect,
        responses: q.responses,
        average: q.average,
      );
    }).toList();
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    // Si hay error y no hay datos, mostrar pantalla de error
    if (_errorMessage != null && _responsesData == null && !_isLoading) {
      return _buildErrorScreen();
    }

    // Si está cargando y no hay datos, mostrar pantalla de carga
    if (_isLoading && _responsesData == null) {
      return _buildLoadingScreen();
    }

    // Mostrar contenido normal
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              ReportHeader(
                teacherName: widget.teacher.name,
                onClose: () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              _buildTabs(),
              Expanded(
                child: _responsesData == null
                    ? _buildEmptyState()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          ResponsesTab(
                            questions: _convertToQuestionReports(_responsesData!.questions),
                            averageScore: _responsesData!.averageScore,
                            totalResponses: _responsesData!.completedEvaluations,
                            expectedResponses: _responsesData!.totalEvaluations,
                          ),
                          SubjectsTab(
                            subjects: widget.teacher.subjects,
                            careerName: widget.teacher.careerName,
                          ),
                          AIAnalysisTab(
                            insights: _aiInsights,
                          ),
                          CommentsTab(
                            comments: _comments,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: ReportConstants.paddingXLarge,
        vertical: ReportConstants.paddingLarge,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showText = constraints.maxWidth > 500;
          
          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(ReportConstants.containerBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelStyle: TextStyle(
                  fontSize: showText ? 11 : 10,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: showText ? 11 : 10,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.responsesIcon, size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.responsesTabLabel : null,
                    child: !showText ? const Text('Resp.', maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  ),
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.subjectsIcon, size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.subjectsTabLabel : null,
                    child: !showText ? const Text('Mat.', maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  ),
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.aiIcon, size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.aiTabLabel : null,
                    child: !showText ? const Text('IA', maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  ),
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.commentsIcon, size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.commentsTabLabel : null,
                    child: !showText ? const Text('Com.', maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== ESTADOS ====================

  Widget _buildLoadingScreen() {
    final palette = AppColors.getPaletteForRole(UserRole.admin);
    
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: palette.primary),
            const SizedBox(height: 16),
            const Text(
              'Cargando informe...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el informe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Error desconocido',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        _loadReportData();
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No hay datos disponibles',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}
