import 'package:flutter/material.dart';
import 'package:eval_plus/models/evaluation_model.dart';
import 'package:eval_plus/models/subject_model.dart';
import 'package:eval_plus/services/evaluations_service.dart';
import 'package:eval_plus/widgets/evaluation/evaluation_modal.dart';
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

/// Contenido de la lista de evaluaciones docentes (CON API REAL)
class EvaluationsList extends StatefulWidget {
  const EvaluationsList({super.key});

  @override
  State<EvaluationsList> createState() => _EvaluationsListState();
}

class _EvaluationsListState extends State<EvaluationsList> {
  late final EvaluationsService _evaluationsService;
  
  List<EvaluationModel> _evaluations = [];
  Map<String, int> _stats = {'total': 0, 'pending': 0, 'completed': 0};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _evaluationsService = EvaluationsService();
    
    debugPrint('🎯 EvaluationsList: Suscribiéndose al servicio...');
    
    _evaluationsService.addListener(_onEvaluationsChanged);
    
    _loadEvaluations();
  }

  @override
  void dispose() {
    debugPrint('🎯 EvaluationsList: Desuscribiéndose del servicio...');
    _evaluationsService.removeListener(_onEvaluationsChanged);
    super.dispose();
  }

  void _onEvaluationsChanged() {
    debugPrint('🔔 Notificación recibida: Recargando evaluaciones...');
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
          _evaluations = response['evaluations'] as List<EvaluationModel>;
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

  /// 🆕 NUEVA FUNCIÓN: Manejar tap en evaluación
  Future<void> _handleEvaluationTap(EvaluationModel evaluation) async {
    // Si ya está completada, mostrar mensaje
    if (evaluation.isCompleted) {
      _showCompletedMessage(evaluation);
      return;
    }

    // Si está cerrada, mostrar mensaje
    if (evaluation.isClosed) {
      _showClosedMessage(evaluation);
      return;
    }

    // Si aún no ha iniciado
    if (evaluation.isUpcoming) {
      _showUpcomingMessage(evaluation);
      return;
    }

    // Si está disponible, abrir el modal
    _openEvaluationModal(evaluation);
  }

  /// 🆕 Mostrar mensaje de evaluación completada
  void _showCompletedMessage(EvaluationModel evaluation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.info(
          title: 'Evaluación completada',
          message: 
              'Ya completaste la evaluación de ${evaluation.teacherName}.\n\n'
              '¡Gracias por tu participación!',
          onContinue: () {
            Navigator.of(context).pop();
          },
          continueButtonText: 'Entendido',
        );
      },
    );
  }

  /// 🆕 Mostrar mensaje de evaluación cerrada
  void _showClosedMessage(EvaluationModel evaluation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.warning(
          title: 'Evaluación cerrada',
          message: 
              'La evaluación de ${evaluation.teacherName} ya cerró.\n\n'
              'Ya no es posible responderla.',
          onAccept: () {
            Navigator.of(context).pop();
          },
          acceptButtonText: 'Entendido',
        );
      },
    );
  }

  /// 🆕 Mostrar mensaje de evaluación próxima
  void _showUpcomingMessage(EvaluationModel evaluation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.info(
          title: 'Evaluación próxima',
          message: 
              'La evaluación de ${evaluation.teacherName} aún no ha iniciado.\n\n'
              'Estará disponible próximamente.',
          onContinue: () {
            Navigator.of(context).pop();
          },
          continueButtonText: 'Entendido',
        );
      },
    );
  }

  /// 🆕 Abrir modal de evaluación
  void _openEvaluationModal(EvaluationModel evaluation) {
    debugPrint('📝 Abriendo modal para evaluación: ${evaluation.subject}');

    // Crear un SubjectModel a partir de los datos de la evaluación
    final subjectForModal = SubjectModel(
      id: 0, // No es crítico para el modal
      nombre: evaluation.subject,
      codigo: evaluation.subjectCode,
      careerCodigo: '', // No necesario
      professorName: evaluation.teacherName,
      semestre: 1,
      evaluationId: evaluation.evaluationId,
      hasActiveEvaluation: true,
      isEvaluationCompleted: false, // Ya verificamos que no está completada
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EvaluationModal(
          subject: subjectForModal,
          onEvaluationCompleted: () {
            debugPrint('✅ Evaluación completada desde evaluations_content');
            // Recargar evaluaciones
            _loadEvaluations(forceRefresh: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadEvaluations(forceRefresh: true),
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
            color: Color(0xFFCAD225),
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
                backgroundColor: const Color(0xFFCAD225),
                foregroundColor: const Color(0xFF1A1A1A),
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
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            ...List.generate(
              _evaluations.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < _evaluations.length - 1 ? 16.0 : 0,
                ),
                child: _buildEvaluationCard(context, _evaluations[index]),
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
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes evaluaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las evaluaciones aparecerán aquí cuando estén disponibles',
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCAD225).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA8B820).withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.assignment_rounded,
            label: 'Total',
            value: '${_stats['total']}',
            color: const Color(0xFF1A1A1A),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFA8B820).withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.check_circle_rounded,
            label: 'Completadas',
            value: '${_stats['completed']}',
            color: Colors.green.shade700,
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFA8B820).withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.pending_rounded,
            label: 'Pendientes',
            value: '${_stats['pending']}',
            color: Colors.orange.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF1A1A1A).withOpacity(0.6)
          ),
        ),
      ],
    );
  }

  /// 🔥 MODIFICADO: Ahora llama a _handleEvaluationTap
  Widget _buildEvaluationCard(BuildContext context, EvaluationModel evaluation) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleEvaluationTap(evaluation), // 🆕 CAMBIO AQUÍ
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFA8B820).withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA8B820).withOpacity(0.2),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildTeacherIcon(evaluation),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evaluation.teacherName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evaluation.subject,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF003C43).withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPeriodChip(evaluation.period),
                          const SizedBox(width: 8),
                          _buildStatusChip(evaluation),
                        ],
                      ),
                      if (evaluation.isCompleted && evaluation.completedDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Completada: ${_formatDate(evaluation.completedDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      if (!evaluation.isCompleted && evaluation.daysRemaining != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Cierra en ${evaluation.daysRemaining} día(s)',
                            style: TextStyle(
                              fontSize: 11,
                              color: evaluation.daysRemaining! <= 3 
                                  ? Colors.red.shade700 
                                  : Colors.blue.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Column(
                  children: [
                    _buildCheckbox(evaluation.isCompleted),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: const Color(0xFF1A1A1A).withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherIcon(EvaluationModel evaluation) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: evaluation.isCompleted
              ? [
                  Colors.green.shade600,
                  Colors.green.shade700,
                ]
              : [
                  const Color(0xFFCAD225),
                  const Color(0xFFA8B820),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: evaluation.isCompleted 
              ? Colors.green.shade700 
              : const Color(0xFFA8B820),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 28,
        color: evaluation.isCompleted 
            ? Colors.white 
            : const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFCAD225).withOpacity(0.15), 
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        period,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(EvaluationModel evaluation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: evaluation.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        evaluation.statusText,
        style: TextStyle(
          fontSize: 11,
          color: evaluation.statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isCompleted) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade600 : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted 
              ? Colors.green.shade700 
              : const Color(0xFFA8B820).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check_rounded,
              size: 18,
              color: Colors.white,
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
