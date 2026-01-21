/// Modal de Informe Completo del Docente
/// Ubicación: lib/widgets/admin/analysis/teacher_report_modal.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';

// Escala de respuestas
class ResponseScale {
  final int value;
  final String label;
  final String full;
  final Color color;

  const ResponseScale({
    required this.value,
    required this.label,
    required this.full,
    required this.color,
  });

  static const scale1 = ResponseScale(
    value: 1,
    label: 'N',
    full: 'Nunca',
    color: Color(0xFFEF4444),
  );

  static const scale2 = ResponseScale(
    value: 2,
    label: 'CN',
    full: 'Casi nunca',
    color: Color(0xFFF59E0B),
  );

  static const scale3 = ResponseScale(
    value: 3,
    label: 'AV',
    full: 'Algunas veces',
    color: Color(0xFFFCD34D),
  );

  static const scale4 = ResponseScale(
    value: 4,
    label: 'CS',
    full: 'Casi siempre',
    color: Color(0xFF8BC34A),
  );

  static const scale5 = ResponseScale(
    value: 5,
    label: 'S',
    full: 'Siempre',
    color: Color(0xFF4CAF50),
  );

  static const List<ResponseScale> all = [scale1, scale2, scale3, scale4, scale5];

  static ResponseScale fromValue(int value) {
    switch (value) {
      case 1: return scale1;
      case 2: return scale2;
      case 3: return scale3;
      case 4: return scale4;
      case 5: return scale5;
      default: return scale3;
    }
  }
}

// Modelo de pregunta para el reporte
class QuestionReport {
  final int id;
  final String text;
  final String category;
  final String aspect;
  final Map<int, int> responses;
  final double average;

  QuestionReport({
    required this.id,
    required this.text,
    required this.category,
    required this.aspect,
    required this.responses,
    required this.average,
  });
}

// Modelo de comentario
class CommentReport {
  final int id;
  final String text;
  final String sentiment;
  final String subject;
  final String career;

  CommentReport({
    required this.id,
    required this.text,
    required this.sentiment,
    required this.subject,
    required this.career,
  });
}

// Modelo de insights de IA
class AIInsights {
  final String profile;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> recommendations;

  AIInsights({
    required this.profile,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
  });
}

class TeacherReportModal extends StatefulWidget {
  final TeacherData teacher;

  const TeacherReportModal({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherReportModal> createState() => _TeacherReportModalState();
}

class _TeacherReportModalState extends State<TeacherReportModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _expandedQuestionId;
  String _commentFilter = 'all';
  String _subjectFilter = 'all';

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
        subject: widget.teacher.subjects.isNotEmpty ? widget.teacher.subjects[0].code : "POO-101",
        career: widget.teacher.careerName,
      ),
      CommentReport(
        id: 2,
        text: "Debería usar más ejemplos prácticos en clase",
        sentiment: "neutral",
        subject: widget.teacher.subjects.isNotEmpty ? widget.teacher.subjects[0].code : "ED-201",
        career: widget.teacher.careerName,
      ),
      CommentReport(
        id: 3,
        text: "Muy buen dominio de la materia, pero a veces va muy rápido",
        sentiment: "positive",
        subject: widget.teacher.subjects.isNotEmpty ? widget.teacher.subjects[0].code : "POO-101",
        career: widget.teacher.careerName,
      ),
      CommentReport(
        id: 4,
        text: "Me gustaría más retroalimentación en los trabajos",
        sentiment: "neutral",
        subject: widget.teacher.subjects.length > 1 ? widget.teacher.subjects[1].code : "BD-301",
        career: widget.teacher.careerName,
      ),
      CommentReport(
        id: 5,
        text: "El mejor profesor que he tenido, muy dedicado",
        sentiment: "positive",
        subject: widget.teacher.subjects.isNotEmpty ? widget.teacher.subjects[0].code : "ED-201",
        career: widget.teacher.careerName,
      ),
      CommentReport(
        id: 6,
        text: "Las evaluaciones son muy teóricas",
        sentiment: "negative",
        subject: widget.teacher.subjects.length > 1 ? widget.teacher.subjects[1].code : "BD-301",
        career: widget.teacher.careerName,
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 4.5) return const Color(0xFF4CAF50);
    if (score >= 4.0) return const Color(0xFF8BC34A);
    if (score >= 3.5) return const Color(0xFFFCD34D);
    if (score >= 3.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  List<CommentReport> get _filteredComments {
    return _comments.where((comment) {
      final sentimentMatch = _commentFilter == 'all' || comment.sentiment == _commentFilter;
      final subjectMatch = _subjectFilter == 'all' || comment.subject == _subjectFilter;
      return sentimentMatch && subjectMatch;
    }).toList();
  }

  Map<String, int> get _sentimentCounts {
    return {
      'positive': _comments.where((c) => c.sentiment == 'positive').length,
      'neutral': _comments.where((c) => c.sentiment == 'neutral').length,
      'negative': _comments.where((c) => c.sentiment == 'negative').length,
    };
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
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildResponsesTab(),
                    _buildSubjectsTab(),
                    _buildAITab(),
                    _buildCommentsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPaletteForRole(UserRole.admin).primary,
            AppColors.getPaletteForRole(UserRole.admin).primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPaletteForRole(UserRole.admin).primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informe Completo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.teacher.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.getPaletteForRole(UserRole.admin).primary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(
            icon: Icon(Icons.trending_up, size: 16),
            text: 'Respuestas',
          ),
          Tab(
            icon: Icon(Icons.book, size: 16),
            text: 'Materias',
          ),
          Tab(
            icon: Icon(Icons.psychology, size: 16),
            text: 'Análisis IA',
          ),
          Tab(
            icon: Icon(Icons.comment, size: 16),
            text: 'Comentarios',
          ),
        ],
      ),
    );
  }

  // ==================== TAB: RESPUESTAS ====================

  Widget _buildResponsesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResponsesSummary(),
        const SizedBox(height: 12),
        ..._questions.map((q) => _buildQuestionCard(q)),
      ],
    );
  }

  Widget _buildResponsesSummary() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Text(
                  'Promedio',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                SizedBox(height: 4),
                Text(
                  '4.1',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '/ 5.0',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Text(
                  'Respuestas',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                SizedBox(height: 4),
                Text(
                  '119',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'evaluaciones',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionReport question) {
    final isExpanded = _expandedQuestionId == question.id;
    final totalResponses = question.responses.values.fold(0, (sum, count) => sum + count);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedQuestionId = isExpanded ? null : question.id;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.getPaletteForRole(UserRole.admin).chipBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '#${question.id}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.getPaletteForRole(UserRole.admin).primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    question.category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              question.text,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            question.average.toFixed(1),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(question.average),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: question.average / 5,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(question.average),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución ($totalResponses respuestas)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ResponseScale.all.reversed.map((scale) {
                    final count = question.responses[scale.value] ?? 0;
                    final percentage = totalResponses > 0 ? (count / totalResponses) * 100 : 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: scale.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                scale.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      scale.full,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$count (${percentage.toStringAsFixed(0)}%)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(scale.color),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== TAB: MATERIAS ====================

  Widget _buildSubjectsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.teacher.subjects.map((subject) {
        final completionRate = subject.students > 0
            ? (subject.completed / subject.students) * 100
            : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.getPaletteForRole(UserRole.admin).chipBackground,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  subject.code,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getPaletteForRole(UserRole.admin).primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.teacher.careerName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '4.${(subject.completed % 9) + 1}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(4.0 + ((subject.completed % 9) + 1) / 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubjectStat('Total', '${subject.students}', Colors.grey),
                    ),
                    Expanded(
                      child: _buildSubjectStat('Evaluados', '${subject.completed}', Colors.green),
                    ),
                    Expanded(
                      child: _buildSubjectStat('Pendientes', '${subject.pending}', Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${completionRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionRate / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB: ANÁLISIS IA ====================

  Widget _buildAITab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(),
        const SizedBox(height: 12),
        _buildStrengthsCard(),
        const SizedBox(height: 12),
        _buildImprovementsCard(),
        const SizedBox(height: 12),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Perfil Docente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiInsights.profile,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Color(0xFF4CAF50), size: 18),
                SizedBox(width: 8),
                Text(
                  'Fortalezas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._aiInsights.strengths.map((strength) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strength,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF59E0B), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 8),
                Text(
                  'Oportunidades de Mejora',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._aiInsights.improvements.map((improvement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      improvement,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF2196F3), size: 18),
                SizedBox(width: 8),
                Text(
                  'Recomendaciones',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._aiInsights.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==================== TAB: COMENTARIOS ====================

  Widget _buildCommentsTab() {
    return Column(
      children: [
        _buildCommentFilters(),
        _buildSentimentDistribution(),
        Expanded(
          child: _filteredComments.isEmpty
              ? _buildEmptyComments()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _filteredComments.map((comment) => _buildCommentCard(comment)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildCommentFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_list, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _commentFilter,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text('Todos (${_comments.length})'),
              ),
              DropdownMenuItem(
                value: 'positive',
                child: Text('Positivos (${_sentimentCounts['positive']})'),
              ),
              DropdownMenuItem(
                value: 'neutral',
                child: Text('Neutrales (${_sentimentCounts['neutral']})'),
              ),
              DropdownMenuItem(
                value: 'negative',
                child: Text('Negativos (${_sentimentCounts['negative']})'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _commentFilter = value!;
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _subjectFilter,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: 'all',
                child: Text('Todas las materias'),
              ),
              ...widget.teacher.subjects.map((subject) => DropdownMenuItem(
                value: subject.code,
                child: Text(subject.name),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _subjectFilter = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentDistribution() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildSentimentCard(
              'Positivos',
              _sentimentCounts['positive']!,
              const Color(0xFF4CAF50),
              Icons.sentiment_satisfied,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSentimentCard(
              'Neutrales',
              _sentimentCounts['neutral']!,
              Colors.grey,
              Icons.sentiment_neutral,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSentimentCard(
              'Negativos',
              _sentimentCounts['negative']!,
              const Color(0xFFEF4444),
              Icons.sentiment_dissatisfied,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentReport comment) {
    Color borderColor;
    Color chipColor;
    String chipLabel;

    switch (comment.sentiment) {
      case 'positive':
        borderColor = const Color(0xFF4CAF50);
        chipColor = const Color(0xFFE8F5E9);
        chipLabel = 'Positivo';
        break;
      case 'negative':
        borderColor = const Color(0xFFEF4444);
        chipColor = const Color(0xFFFFEBEE);
        chipLabel = 'Negativo';
        break;
      default:
        borderColor = Colors.grey;
        chipColor = Colors.grey[200]!;
        chipLabel = 'Neutral';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
                  ),
                ),
                Text(
                  comment.subject,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay comentarios',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension para formatear números
extension DoubleExtension on double {
  String toFixed(int decimals) {
    return toStringAsFixed(decimals);
  }
}
