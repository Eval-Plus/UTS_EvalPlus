import 'package:flutter/material.dart';
import 'package:eval_plus/models/teacher/teacher_evaluation_model.dart';
import 'package:eval_plus/services/teacher_evaluation_service.dart';
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';
import 'package:eval_plus/widgets/evaluation/comments_modal.dart';

/// Contenido de evaluaciones para DOCENTES
/// Muestra las materias que imparte y estadísticas de evaluación
class TeacherEvaluationsContent extends StatefulWidget {
  const TeacherEvaluationsContent({super.key});

  @override
  State<TeacherEvaluationsContent> createState() => _TeacherEvaluationsContentState();
}

class _TeacherEvaluationsContentState extends State<TeacherEvaluationsContent> {
  late final TeacherEvaluationsService _evaluationsService;
  
  List<TeacherEvaluationModel> _evaluations = [];
  Map<String, int> _stats = {
    'totalSubjects': 0,
    'totalStudents': 0,
    'totalCompleted': 0,
    'totalPending': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _evaluationsService = TeacherEvaluationsService();
    
    debugPrint('🎯 [Teacher] Suscribiéndose al servicio...');
    
    _evaluationsService.addListener(_onEvaluationsChanged);
    
    _loadEvaluations();
  }

  @override
  void dispose() {
    debugPrint('🎯 [Teacher] Desuscribiéndose del servicio...');
    _evaluationsService.removeListener(_onEvaluationsChanged);
    super.dispose();
  }

  void _onEvaluationsChanged() {
    debugPrint('🔔 [Teacher] Notificación recibida: Recargando evaluaciones...');
    _loadEvaluations(forceRefresh: true);
  }

  Future<void> _loadEvaluations({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _evaluationsService.getMyEvaluations(
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          _evaluations = response['evaluations'] as List<TeacherEvaluationModel>;
          _stats = response['stats'] as Map<String, int>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar evaluaciones: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadEvaluations(forceRefresh: true),
      color: const Color(0xFF8BC34A),
      child: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildEvaluationsList(),
    );
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadEvaluations(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationsList() {
    if (_evaluations.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            _buildGlobalStatsHeader(
              totalSubjects: _stats['totalSubjects']!,
              totalStudents: _stats['totalStudents']!,
              totalCompleted: _stats['totalCompleted']!,
              totalPending: _stats['totalPending']!,
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
            // Icono representativo
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            
            // Título principal
            Text(
              'No hay evaluaciones disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Descripción más informativa
            Text(
              'Aún no tienes evaluaciones asignadas.\n'
              'Las evaluaciones aparecerán aquí cuando se complete el proceso de sincronización y asignación de materias.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Botón de actualizar con color del rol docente
            ElevatedButton.icon(
              onPressed: () => _loadEvaluations(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A), // Verde medio docente
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mensaje informativo con diseño coherente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A).withOpacity(0.1), // Fondo suave verde
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8BC34A).withOpacity(0.3), // Borde verde
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: const Color(0xFF689F38), // Verde oscuro
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si el problema persiste, contacta al coordinador académico',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
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
  final TeacherEvaluationModel evaluation;

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
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChip(
                                    widget.evaluation.subjectCode,
                                    const Color(0xFF8BC34A),
                                  ),
                                  _buildChip(
                                    widget.evaluation.period,
                                    const Color(0xFF1A1A1A),
                                  ),
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
                    _buildProgressBar(widget.evaluation.completionPercentage),
                    
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información adicional
                        _buildInfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Periodo',
                          value: widget.evaluation.period,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.assignment_rounded,
                          label: 'Plantilla',
                          value: widget.evaluation.templateName,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.event_available_rounded,
                          label: 'Días restantes',
                          value: '${widget.evaluation.daysRemaining} días',
                        ),
                        const SizedBox(height: 16),
                        
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
              widget.evaluation.progressColor,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF8BC34A),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
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
        return CommentsModal(
          evaluation: widget.evaluation,
        );
      },
    );
  }
}
