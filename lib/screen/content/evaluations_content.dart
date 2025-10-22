import 'package:flutter/material.dart';

/// Modelo temporal para evaluaciones (datos quemados)
class EvaluationModel {
  final String teacherName;
  final String subject;
  final String period;
  final bool isCompleted;
  final DateTime? completedDate;

  EvaluationModel({
    required this.teacherName,
    required this.subject,
    required this.period,
    required this.isCompleted,
    this.completedDate,
  });
}

/// Contenido de la lista de evaluaciones docentes
class EvaluationsList extends StatelessWidget {
  const EvaluationsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos quemados para pruebas
    final evaluations = [
      EvaluationModel(
        teacherName: 'Dr. Carlos Méndez',
        subject: 'Cálculo Diferencial',
        period: '2024-2',
        isCompleted: true,
        completedDate: DateTime(2024, 10, 15),
      ),
      EvaluationModel(
        teacherName: 'Ing. María González',
        subject: 'Programación I',
        period: '2024-2',
        isCompleted: false,
      ),
      EvaluationModel(
        teacherName: 'Dra. Ana Rodríguez',
        subject: 'Física Mecánica',
        period: '2024-2',
        isCompleted: true,
        completedDate: DateTime(2024, 10, 18),
      ),
      EvaluationModel(
        teacherName: 'Mg. Luis Fernández',
        subject: 'Álgebra Lineal',
        period: '2024-2',
        isCompleted: false,
      ),
      EvaluationModel(
        teacherName: 'Ing. Patricia Herrera',
        subject: 'Introducción a la Ingeniería',
        period: '2024-2',
        isCompleted: false,
      ),
      EvaluationModel(
        teacherName: 'Dr. Roberto Sánchez',
        subject: 'Química General',
        period: '2024-2',
        isCompleted: true,
        completedDate: DateTime(2024, 10, 12),
      ),
      EvaluationModel(
        teacherName: 'Lic. Sandra Morales',
        subject: 'Comunicación Escrita',
        period: '2024-2',
        isCompleted: false,
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Encabezado con información
            _buildHeader(evaluations),
            
            const SizedBox(height: 24),
            
            // Lista de evaluaciones
            ...evaluations.asMap().entries.map((entry) {
              final index = entry.key;
              final evaluation = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < evaluations.length - 1 ? 16.0 : 0,
                ),
                child: _buildEvaluationCard(context, evaluation),
              );
            }).toList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye el encabezado con estadísticas
  Widget _buildHeader(List<EvaluationModel> evaluations) {
    final completed = evaluations.where((e) => e.isCompleted).length;
    final total = evaluations.length;
    final pending = total - completed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003C43).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.assignment_rounded,
            label: 'Total',
            value: '$total',
            color: const Color(0xFF003C43),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF003C43).withOpacity(0.2),
          ),
          _buildStatItem(
            icon: Icons.check_circle_rounded,
            label: 'Completadas',
            value: '$completed',
            color: Colors.green.shade700,
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF003C43).withOpacity(0.2),
          ),
          _buildStatItem(
            icon: Icons.pending_rounded,
            label: 'Pendientes',
            value: '$pending',
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
            color: const Color(0xFF003C43).withOpacity(0.6),
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
          // Acción al presionar la tarjeta
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
              color: const Color(0xFF135D66).withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF135D66).withOpacity(0.2),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Ícono del docente con estado
                _buildTeacherIcon(evaluation.isCompleted),
                
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
                          color: Color(0xFF003C43),
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
                          _buildStatusChip(evaluation.isCompleted),
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
                      color: const Color(0xFF003C43).withOpacity(0.3),
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
  Widget _buildTeacherIcon(bool isCompleted) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [
                  Colors.green.shade600,
                  Colors.green.shade700,
                ]
              : [
                  const Color(0xFF003C43),
                  const Color(0xFF003C43).withOpacity(0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.shade700 : const Color(0xFF003C43),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 28,
        color: Colors.white,
      ),
    );
  }

  /// Construye el chip del período
  Widget _buildPeriodChip(String period) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF003C43).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        period,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF003C43),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Construye el chip de estado
  Widget _buildStatusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isCompleted ? 'Completada' : 'Pendiente',
        style: TextStyle(
          fontSize: 11,
          color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
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
          color: isCompleted ? Colors.green.shade700 : const Color(0xFF003C43).withOpacity(0.3),
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
