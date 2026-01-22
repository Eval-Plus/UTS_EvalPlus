/// Modal de Informe Completo del Docente (Actualizado con expectedResponses)
/// Ubicación: lib/widgets/admin/analysis/reports/teacher_report_modal.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/components/report_header.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/responses_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/subjects_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/ai_analysis_tab.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/tabs/comments_tab.dart';

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

  // Datos hardcodeados (después se obtendrán del backend)
  late List<QuestionReport> _questions;
  late List<CommentReport> _comments;
  late AIInsights _aiInsights;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeHardcodedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeHardcodedData() {
    _questions = [
      QuestionReport(
        id: 1,
        text: "Demuestra dominio y actualización en la presentación de los temas del curso",
        category: "Competencia Disciplinaria",
        aspect: "Formativo",
        responses: {1: 2, 2: 3, 3: 8, 4: 45, 5: 61},
        average: 4.3,
      ),
      QuestionReport(
        id: 2,
        text: "Orienta de manera clara los conceptos y teorías del curso",
        category: "Conocimiento y dominio de la materia",
        aspect: "Formativo",
        responses: {1: 1, 2: 4, 3: 12, 4: 38, 5: 64},
        average: 4.4,
      ),
      QuestionReport(
        id: 3,
        text: "Promueve el uso de textos u otros materiales en idioma extranjero",
        category: "Dominio de una segunda lengua",
        aspect: "Formativo",
        responses: {1: 8, 2: 15, 3: 32, 4: 41, 5: 23},
        average: 3.6,
      ),
      QuestionReport(
        id: 4,
        text: "Presenta el plan de curso y explica su importancia para la formación profesional",
        category: "Planeación y organización del trabajo pedagógico",
        aspect: "Destrezas para desarrollar el proceso de enseñanza y aprendizaje",
        responses: {1: 3, 2: 5, 3: 15, 4: 48, 5: 48},
        average: 4.1,
      ),
      QuestionReport(
        id: 5,
        text: "Relaciona el contenido del curso con experiencias y problemas reales",
        category: "Estrategias metodológicas",
        aspect: "Destrezas para desarrollar el proceso de enseñanza y aprendizaje",
        responses: {1: 2, 2: 6, 3: 18, 4: 52, 5: 41},
        average: 4.0,
      ),
    ];

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
      CommentReport(
        id: 4,
        text: "Me gustaría más retroalimentación en los trabajos",
        sentiment: "neutral",
      ),
      CommentReport(
        id: 5,
        text: "El mejor profesor que he tenido, muy dedicado",
        sentiment: "positive",
      ),
      CommentReport(
        id: 6,
        text: "Las evaluaciones son muy teóricas",
        sentiment: "negative",
      ),
      CommentReport(
        id: 7,
        text: "Excelente metodología, se nota su experiencia",
        sentiment: "positive",
      ),
      CommentReport(
        id: 8,
        text: "Clases dinámicas y participativas",
        sentiment: "positive",
      ),
      CommentReport(
        id: 9,
        text: "A veces no responde las dudas a tiempo",
        sentiment: "negative",
      ),
      CommentReport(
        id: 10,
        text: "Buen profesor en general",
        sentiment: "neutral",
      ),
    ];

    _aiInsights = AIInsights(
      profile: "Docente con excelente dominio técnico y fuerte compromiso con el aprendizaje estudiantil",
      strengths: [
        "Dominio excepcional de la materia y actualización constante",
        "Claridad en la orientación de conceptos y teorías",
        "Buena organización y presentación del plan de curso",
        "Capacidad para relacionar teoría con práctica",
      ],
      improvements: [
        "Incrementar el uso de materiales en idioma extranjero",
        "Diversificar las estrategias metodológicas",
        "Fortalecer la retroalimentación individualizada",
      ],
      recommendations: [
        "Integrar más recursos multimedia en idioma inglés gradualmente",
        "Implementar metodologías activas como aprendizaje basado en proyectos",
        "Crear espacios de consulta personalizada adicionales",
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              ReportHeader(
                teacherName: widget.teacher.name,
                onClose: () => Navigator.pop(context),
              ),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ResponsesTab(
                      questions: _questions,
                      averageScore: 4.1,
                      totalResponses: 119,
                      expectedResponses: 150, // Hardcodeado: 150 respuestas esperadas
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
}
