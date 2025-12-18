import 'package:flutter/material.dart';
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

/// Contenido de evaluaciones para DOCENTES
/// Muestra las materias que imparte y estadísticas de evaluación
class TeacherEvaluationsContent extends StatefulWidget {
  const TeacherEvaluationsContent({super.key});

  @override
  State<TeacherEvaluationsContent> createState() => _TeacherEvaluationsContentState();
}

class _TeacherEvaluationsContentState extends State<TeacherEvaluationsContent> {
  bool _isLoading = false;
  
  // 🔥 DATA QUEMADA - Simulación de evaluaciones del docente
  final List<TeacherEvaluationData> _evaluations = [
    TeacherEvaluationData(
      subjectName: 'Programación Orientada a Objetos',
      subjectCode: 'POO-301',
      careerName: 'Ingeniería de Sistemas',
      totalStudents: 35,
      completedEvaluations: 28,
      pendingEvaluations: 7,
      period: '2024-2',
      status: EvaluationStatus.active,
    ),
    TeacherEvaluationData(
      subjectName: 'Estructuras de Datos',
      subjectCode: 'ED-202',
      careerName: 'Ingeniería de Sistemas',
      totalStudents: 42,
      completedEvaluations: 42,
      pendingEvaluations: 0,
      period: '2024-2',
      status: EvaluationStatus.closed,
    ),
    TeacherEvaluationData(
      subjectName: 'Base de Datos I',
      subjectCode: 'BD-301',
      careerName: 'Ingeniería de Sistemas',
      totalStudents: 38,
      completedEvaluations: 15,
      pendingEvaluations: 23,
      period: '2024-2',
      status: EvaluationStatus.active,
    ),
    TeacherEvaluationData(
      subjectName: 'Cálculo Diferencial',
      subjectCode: 'CAL-101',
      careerName: 'Ingeniería Industrial',
      totalStudents: 45,
      completedEvaluations: 0,
      pendingEvaluations: 45,
      period: '2024-2',
      status: EvaluationStatus.upcoming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF8BC34A),
      child: _isLoading
          ? _buildLoadingState()
          : _buildEvaluationsList(),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8BC34A),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando evaluaciones...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationsList() {
    if (_evaluations.isEmpty) {
      return _buildEmptyState();
    }

    // Calcular estadísticas globales
    final totalStudents = _evaluations.fold<int>(
      0, 
      (sum, eval) => sum + eval.totalStudents,
    );
    final totalCompleted = _evaluations.fold<int>(
      0, 
      (sum, eval) => sum + eval.completedEvaluations,
    );
    final totalPending = _evaluations.fold<int>(
      0, 
      (sum, eval) => sum + eval.pendingEvaluations,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            _buildGlobalStatsHeader(
              totalSubjects: _evaluations.length,
              totalStudents: totalStudents,
              totalCompleted: totalCompleted,
              totalPending: totalPending,
            ),
            
            const SizedBox(height: 24),
            
            ...List.generate(
              _evaluations.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < _evaluations.length - 1 ? 16.0 : 0,
                ),
                child: _TeacherEvaluationCard(
                  evaluation: _evaluations[index],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes materias asignadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las materias que impartas aparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatsHeader({
    required int totalSubjects,
    required int totalStudents,
    required int totalCompleted,
    required int totalPending,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8BC34A),
            Color(0xFF689F38),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8BC34A).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Resumen General',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.book_rounded,
                  label: 'Materias',
                  value: '$totalSubjects',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  label: 'Estudiantes',
                  value: '$totalStudents',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completadas',
                  value: '$totalCompleted',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_rounded,
                  label: 'Pendientes',
                  value: '$totalPending',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CARD DE EVALUACIÓN ====================

class _TeacherEvaluationCard extends StatefulWidget {
  final TeacherEvaluationData evaluation;

  const _TeacherEvaluationCard({
    required this.evaluation,
  });

  @override
  State<_TeacherEvaluationCard> createState() => _TeacherEvaluationCardState();
}

class _TeacherEvaluationCardState extends State<_TeacherEvaluationCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = widget.evaluation.totalStudents > 0
        ? (widget.evaluation.completedEvaluations / widget.evaluation.totalStudents * 100)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8BC34A).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8BC34A).withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _toggleExpansion,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icono de materia
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8BC34A),
                                Color(0xFF7CB342),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF7CB342),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.book_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Info de materia
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.evaluation.subjectName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.evaluation.careerName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF1A1A1A).withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildChip(
                                    widget.evaluation.subjectCode,
                                    const Color(0xFF8BC34A),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildChip(
                                    widget.evaluation.period,
                                    const Color(0xFF1A1A1A),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(widget.evaluation.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Icono de expandir
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 350),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8BC34A).withOpacity(_isExpanded ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF1A1A1A),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Barra de progreso
                    _buildProgressBar(completionRate),
                    
                    const SizedBox(height: 12),
                    
                    // Estadísticas en línea
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInlineStats(
                          icon: Icons.people_rounded,
                          label: 'Total',
                          value: '${widget.evaluation.totalStudents}',
                          color: const Color(0xFF1A1A1A),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFF8BC34A).withOpacity(0.3),
                        ),
                        _buildInlineStats(
                          icon: Icons.check_circle_rounded,
                          label: 'Completadas',
                          value: '${widget.evaluation.completedEvaluations}',
                          color: Colors.green.shade700,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFF8BC34A).withOpacity(0.3),
                        ),
                        _buildInlineStats(
                          icon: Icons.pending_rounded,
                          label: 'Pendientes',
                          value: '${widget.evaluation.pendingEvaluations}',
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Contenido expandible
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8BC34A).withOpacity(0.08),
                          const Color(0xFF8BC34A).withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8BC34A).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Botón Ver Comentarios
                        _buildActionButton(
                          context: context,
                          icon: Icons.comment_rounded,
                          label: 'Ver Comentarios',
                          onTap: _showCommentsDialog,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(EvaluationStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case EvaluationStatus.active:
        color = Colors.green;
        text = 'Activa';
        break;
      case EvaluationStatus.closed:
        color = Colors.grey;
        text = 'Cerrada';
        break;
      case EvaluationStatus.upcoming:
        color = Colors.blue;
        text = 'Próxima';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de evaluación',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF1A1A1A).withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 75 
                  ? Colors.green.shade600
                  : percentage >= 50
                      ? Colors.orange.shade600
                      : Colors.red.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineStats({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF8BC34A),
            Color(0xFF7CB342),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8BC34A).withOpacity(0.3),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.info(
          title: 'Funcionalidad en desarrollo',
          message: 'El apartado de comentarios aún no está disponible. '
                   'Estamos trabajando para implementarlo pronto.',
          onContinue: () {
            Navigator.of(context).pop();
          },
          continueButtonText: 'Entendido',
        );
      },
    );
  }
}

// ==================== MODELOS DE DATOS ====================

enum EvaluationStatus {
  active,
  closed,
  upcoming,
}

class TeacherEvaluationData {
  final String subjectName;
  final String subjectCode;
  final String careerName;
  final int totalStudents;
  final int completedEvaluations;
  final int pendingEvaluations;
  final String period;
  final EvaluationStatus status;

  TeacherEvaluationData({
    required this.subjectName,
    required this.subjectCode,
    required this.careerName,
    required this.totalStudents,
    required this.completedEvaluations,
    required this.pendingEvaluations,
    required this.period,
    required this.status,
  });
}
