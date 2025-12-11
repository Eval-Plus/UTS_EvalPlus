import 'package:flutter/material.dart';
import 'package:eval_plus/models/evaluation_model.dart';
import 'package:eval_plus/services/evaluations_service.dart';

/// Contenido de la lista de evaluaciones docentes (CON API REAL)
class EvaluationsList extends StatefulWidget {
  const EvaluationsList({super.key});

  @override
  State<EvaluationsList> createState() => _EvaluationsListState();
}

class _EvaluationsListState extends State<EvaluationsList> {
  final _evaluationsService = EvaluationsService();
  
  List<EvaluationModel> _evaluations = [];
  Map<String, int> _stats = {'total': 0, 'pending': 0, 'completed': 0};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  /// Carga las evaluaciones desde el servicio
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

  /// Estado de carga
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

  /// Estado de error
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

  /// Lista de evaluaciones
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
            
            // Encabezado con estadísticas
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Lista de evaluaciones
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

  /// Estado vacío
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

  /// Construye el encabezado con estadísticas
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

  /// Construye un item de estadística
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

  /// Construye una tarjeta de evaluación
  Widget _buildEvaluationCard(BuildContext context, EvaluationModel evaluation) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navegar a pantalla de evaluación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                evaluation.isCompleted
                    ? 'Ver evaluación de ${evaluation.teacherName}'
                    : 'Iniciar evaluación de ${evaluation.teacherName}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
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
                // Ícono del docente con estado
                _buildTeacherIcon(evaluation),
                
                const SizedBox(width: 16),
                
                // Información del docente y materia
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
                
                // Checkbox de estado y flecha
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

  /// Construye el ícono del docente con gradiente
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

  /// Construye el chip del período
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

  /// Construye el chip de estado
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

  /// Construye el checkbox de estado
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

  /// Formatea la fecha
  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
