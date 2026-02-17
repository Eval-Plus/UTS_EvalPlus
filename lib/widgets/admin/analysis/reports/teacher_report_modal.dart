/// Modal de Informe Completo del Docente (Con datos reales de API + Comentarios)
/// Ubicación: lib/widgets/admin/analysis/reports/teacher_report_modal.dart
library;

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
  List<CommentReport> _comments = [];

  // Datos hardcodeados (temporalmente para IA)
  late AIInsights _aiInsights;

  // Estado de carga
  bool _isLoadingResponses = true;
  bool _isLoadingComments = true;
  String? _responsesError;
  String? _commentsError;
  bool _isLoadingDialogShown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeHardcodedData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadReportData(showLoadingDialog: true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==================== CARGA DE DATOS ====================

  /// Carga los datos del reporte desde la API.
  /// [showLoadingDialog] controla si se muestra el fullscreen loading (carga inicial)
  /// o si se deja que cada tab maneje su propio splash (pull-to-refresh).
  Future<void> _loadReportData({bool showLoadingDialog = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoadingResponses = true;
      _isLoadingComments = true;
      _responsesError = null;
      _commentsError = null;
    });

    try {
      debugPrint('📊 Cargando datos del reporte para docente ${widget.teacher.id}...');

      if (showLoadingDialog) {
        await _showLoadingDialog();
      }

      // Siempre forzar refresh cuando se llama desde pull-to-refresh
      final forceRefresh = !showLoadingDialog;

      final results = await Future.wait([
        _reportService.getResponsesReport(
          teacherId: widget.teacher.id,
          periodo: widget.teacher.period,
          forceRefresh: forceRefresh,
        ),
        _reportService.getTeacherComments(
          teacherId: widget.teacher.id,
          periodo: widget.teacher.period,
          forceRefresh: forceRefresh,
        ),
      ]);

      if (!mounted) return;

      // Cerrar loading dialog si estaba mostrado
      if (_isLoadingDialogShown) {
        Navigator.of(context).pop();
        _isLoadingDialogShown = false;
      }

      final responsesData = results[0] as TeacherResponsesReport?;
      final comments = results[1] as List<CommentReport>;

      setState(() {
        _responsesData = responsesData;
        _comments = comments;
        _isLoadingResponses = false;
        _isLoadingComments = false;
        _responsesError = responsesData == null ? _reportService.responsesError : null;
        _commentsError = _reportService.commentsError;
      });

      debugPrint('✅ Datos del reporte cargados exitosamente');
      debugPrint('   - Respuestas: ${responsesData != null ? "OK" : "Error"}');
      debugPrint('   - Comentarios: ${comments.length}');
    } catch (e) {
      debugPrint('💥 Error cargando datos del reporte: $e');

      if (!mounted) return;

      if (_isLoadingDialogShown) {
        Navigator.of(context).pop();
        _isLoadingDialogShown = false;
      }

      setState(() {
        _isLoadingResponses = false;
        _isLoadingComments = false;
        _responsesError = e.toString();
        _commentsError = e.toString();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorDialog(e.toString());
        }
      });
    }
  }

  /// Callback para pull-to-refresh en el tab de Respuestas
  Future<void> _refreshResponses() async {
    if (!mounted) return;

    try {
      final report = await _reportService.getResponsesReport(
        teacherId: widget.teacher.id,
        periodo: widget.teacher.period,
        forceRefresh: true, // 🔑 Siempre desde la API
      );

      if (!mounted) return;

      setState(() {
        _responsesData = report;
        _responsesError = report == null ? _reportService.responsesError : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _responsesError = e.toString();
      });
    }
  }

  /// Callback para pull-to-refresh en el tab de Comentarios
  Future<void> _refreshComments() async {
    if (!mounted) return;

    try {
      final comments = await _reportService.getTeacherComments(
        teacherId: widget.teacher.id,
        periodo: widget.teacher.period,
        forceRefresh: true, // 🔑 Siempre desde la API
      );

      if (!mounted) return;

      setState(() {
        _comments = comments;
        _commentsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _commentsError = e.toString();
      });
    }
  }

  /// Muestra el diálogo de carga fullscreen (solo en carga inicial)
  Future<void> _showLoadingDialog() async {
    if (!mounted || _isLoadingDialogShown) return;

    final palette = AppColors.getPaletteForRole(UserRole.admin);
    _isLoadingDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportLoadingDialog(
        teacherName: widget.teacher.name,
        palette: palette,
      ),
    );

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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pop();
              _loadReportData(showLoadingDialog: true);
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ==================== DATOS HARDCODEADOS (TEMPORAL) ====================

  void _initializeHardcodedData() {
    _aiInsights = AIInsights(
      profile:
          "Docente con excelente dominio técnico y fuerte compromiso con el aprendizaje estudiantil",
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
    if (_responsesError != null && _responsesData == null && !_isLoadingResponses) {
      return _buildErrorScreen();
    }

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
                  if (mounted) Navigator.pop(context);
                },
              ),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Respuestas
                    _isLoadingResponses || _responsesData == null
                        ? _buildLoadingTab()
                        : ResponsesTab(
                            questions:
                                _convertToQuestionReports(_responsesData!.questions),
                            averageScore: _responsesData!.averageScore,
                            totalResponses: _responsesData!.completedEvaluations,
                            expectedResponses: _responsesData!.totalEvaluations,
                            onRefresh: _refreshResponses, // 🆕 Callback real
                          ),

                    // Tab 2: Materias
                    SubjectsTab(
                      subjects: widget.teacher.subjects,
                      careerName: widget.teacher.careerName,
                    ),

                    // Tab 3: Análisis IA
                    AIAnalysisTab(insights: _aiInsights),

                    // Tab 4: Comentarios
                    CommentsTab(
                      comments: _comments,
                      isLoading: _isLoadingComments,
                      errorMessage: _commentsError,
                      onRefresh: _refreshComments, // 🆕 Callback real
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
                  borderRadius:
                      BorderRadius.circular(ReportConstants.containerBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelStyle: TextStyle(
                    fontSize: showText ? 11 : 10, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(
                    fontSize: showText ? 11 : 10, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.responsesIcon,
                        size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.responsesTabLabel : null,
                    child: !showText
                        ? const Text('Resp.',
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                  ),
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.subjectsIcon,
                        size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.subjectsTabLabel : null,
                    child: !showText
                        ? const Text('Mat.',
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                  ),
                  Tab(
                    height: 44,
                    icon: const Icon(ReportConstants.aiIcon,
                        size: ReportConstants.tabIconSize),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.aiTabLabel : null,
                    child: !showText
                        ? const Text('IA',
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                  ),
                  Tab(
                    height: 44,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(ReportConstants.commentsIcon,
                            size: ReportConstants.tabIconSize),
                        if (_comments.isNotEmpty && !_isLoadingComments)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 16, minHeight: 16),
                              child: Text(
                                '${_comments.length}',
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    iconMargin: EdgeInsets.only(bottom: showText ? 4 : 2),
                    text: showText ? ReportConstants.commentsTabLabel : null,
                    child: !showText
                        ? const Text('Com.',
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
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

  Widget _buildLoadingTab() {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: palette.primary),
          const SizedBox(height: 16),
          const Text(
            'Cargando datos...',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el informe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _responsesError ?? 'Error desconocido',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) _loadReportData(showLoadingDialog: true);
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
}