/// Modal de Informe Completo del Docente
/// Ubicación: lib/widgets/admin/analysis/reports/teacher_report_modal.dart
///
/// CAMBIOS:
///  - Eliminados datos hardcodeados de _aiInsights
///  - AIAnalysisTab ahora recibe teacherId, teacherName y periodo
///  - Se mantiene descarga PDF, carga de respuestas y comentarios
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/services/admin/teacher_report_service.dart';
import 'package:eval_plus/services/admin/ai_analysis_service.dart';
import 'package:eval_plus/services/pdf/teacher_report_pdf_service.dart';
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

  // Estado de carga
  bool _isLoadingResponses = true;
  bool _isLoadingComments = true;
  String? _responsesError;
  String? _commentsError;
  bool _isLoadingDialogShown = false;

  // Estado de generación del PDF
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadReportData(showLoadingDialog: true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Limpiar el estado del servicio de IA al cerrar el modal
    AIAnalysisService().reset();
    super.dispose();
  }

  // ==================== PDF DOWNLOAD ====================

  Future<void> _handleDownloadPdf() async {
    if (_isGeneratingPdf) return;

    if (_isLoadingResponses || _isLoadingComments) {
      _showSnackBar(
        'Los datos aún se están cargando. Espera un momento.',
        icon: Icons.hourglass_empty_rounded,
        color: const Color(0xFFF59E0B),
      );
      return;
    }

    setState(() => _isGeneratingPdf = true);

    try {
      debugPrint('📄 Iniciando generación del PDF...');

      // Obtener insights del servicio de IA para incluirlos en el PDF
      final aiService = AIAnalysisService();
      AIInsights? aiInsights;
      if (aiService.hasAnalysis && aiService.currentAnalysis != null) {
        final analysis = aiService.currentAnalysis!;
        aiInsights = AIInsights(
          profile: analysis.profile,
          strengths: analysis.strengths,
          improvements: analysis.improvements,
          recommendations: analysis.recommendations,
        );
      }

      await TeacherReportPdfService.generateAndDownload(
        teacher: widget.teacher,
        responsesReport: _responsesData,
        comments: _comments,
        aiInsights: aiInsights ?? const AIInsights(
          profile: '',
          strengths: [],
          improvements: [],
          recommendations: [],
        ),
      );

      if (mounted) {
        _showSnackBar(
          'Informe PDF listo.',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF10B981),
        );
      }
    } catch (e) {
      debugPrint('💥 Error generando PDF: $e');
      if (mounted) {
        _showSnackBar(
          'No se pudo generar el PDF. Intenta de nuevo.',
          icon: Icons.error_outline,
          color: const Color(0xFFEF4444),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _showSnackBar(String message,
      {required IconData icon, required Color color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==================== CARGA DE DATOS ====================

  Future<void> _loadReportData({bool showLoadingDialog = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoadingResponses = true;
      _isLoadingComments = true;
      _responsesError = null;
      _commentsError = null;
    });

    try {
      if (showLoadingDialog) {
        await _showLoadingDialog();
      }

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
        _responsesError =
            responsesData == null ? _reportService.responsesError : null;
        _commentsError = _reportService.commentsError;
      });
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
        if (mounted) _showErrorDialog(e.toString());
      });
    }
  }

  Future<void> _refreshResponses() async {
    if (!mounted) return;
    try {
      final report = await _reportService.getResponsesReport(
        teacherId: widget.teacher.id,
        periodo: widget.teacher.period,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _responsesData = report;
        _responsesError =
            report == null ? _reportService.responsesError : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _responsesError = e.toString());
    }
  }

  Future<void> _refreshSubjects() async {
    if (!mounted) return;
    await _loadReportData(showLoadingDialog: false);
  }

  Future<void> _refreshComments() async {
    if (!mounted) return;
    try {
      final comments = await _reportService.getTeacherComments(
        teacherId: widget.teacher.id,
        periodo: widget.teacher.period,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _commentsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _commentsError = e.toString());
    }
  }

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

  // ==================== CONVERSIÓN ====================

  List<QuestionReport> _convertToQuestionReports(
      List<QuestionResponseData> data) {
    return data.map((q) => QuestionReport(
      id: q.id,
      text: q.text,
      category: q.category,
      aspect: q.aspect,
      responses: q.responses,
      average: q.average,
    )).toList();
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    if (_responsesError != null &&
        _responsesData == null &&
        !_isLoadingResponses) {
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
                onDownloadPdf: _handleDownloadPdf,
                isGeneratingPdf: _isGeneratingPdf,
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
                            questions: _convertToQuestionReports(
                                _responsesData!.questions),
                            averageScore: _responsesData!.averageScore,
                            totalResponses:
                                _responsesData!.completedEvaluations,
                            expectedResponses:
                                _responsesData!.totalEvaluations,
                            onRefresh: _refreshResponses,
                          ),

                    // Tab 2: Materias
                    SubjectsTab(
                      subjects: widget.teacher.subjects,
                      careerName: widget.teacher.careerName,
                      onRefresh: _refreshSubjects,
                    ),

                    // Tab 3: Análisis IA — datos reales, sin hardcode
                    AIAnalysisTab(
                      teacherId: widget.teacher.id,
                      teacherName: widget.teacher.name,
                      periodo: widget.teacher.period,
                    ),

                    // Tab 4: Comentarios
                    CommentsTab(
                      comments: _comments,
                      isLoading: _isLoadingComments,
                      errorMessage: _commentsError,
                      onRefresh: _refreshComments,
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
                borderRadius:
                    BorderRadius.circular(ReportConstants.cardBorderRadius),
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
                  borderRadius: BorderRadius.circular(
                      ReportConstants.containerBorderRadius),
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
                    fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(
                    fontSize: showText ? 11 : 10,
                    fontWeight: FontWeight.w500),
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
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
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
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _responsesError ?? 'Error desconocido',
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF6B7280)),
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
                      if (mounted) {
                        _loadReportData(showLoadingDialog: true);
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
}