import 'package:flutter/material.dart';
import 'package:eval_plus/hooks/subjects_data.dart';
import 'package:eval_plus/hooks/careers_data.dart';

class SubjectsContent extends StatelessWidget {
  final Career career;
  final VoidCallback onBack;

  const SubjectsContent({
    super.key,
    required this.career,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón para volver
        _BackButton(
          careerName: career.nombre,
          onBack: onBack,
        ),
        // Lista de materias
        Expanded(
          child: FutureBuilder<List<Subject>>(
            future: SubjectsDataService.getSubjectsByCareer(career.codigo),
            builder: (context, snapshot) {
              // Mientras carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF003C43),
                  ),
                );
              }

              // Si hay error
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar materias',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Si no hay data
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay materias matriculadas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Mostrar lista de materias
              final subjects = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _SubjectCard(
                    subject: subject,
                    color: career.color,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Botón de regreso personalizado
class _BackButton extends StatelessWidget {
  final String careerName;
  final VoidCallback onBack;

  const _BackButton({
    required this.careerName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF003C43).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF003C43).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: const Color(0xFF003C43),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Volver a carreras',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF003C43),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        careerName,
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF003C43).withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tarjeta de materia (diseño tipo desplegable)
class _SubjectCard extends StatefulWidget {
  final Subject subject;
  final Color color;

  const _SubjectCard({
    required this.subject,
    required this.color,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
    final baseColor = widget.color.withOpacity(1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: baseColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _toggleExpansion,
          child: Column(
            children: [
              // Header de la materia
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Icono de libro
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            baseColor.withOpacity(0.2),
                            baseColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: const Color(0xFF003C43),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF003C43),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: baseColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.subject.codigo,
                              style: const TextStyle(
                                color: Color(0xFF003C43),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icono de expandir
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: baseColor.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido expandible (para futuro - info del profesor)
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: const Color(0xFF003C43).withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Profesor: ${widget.subject.professorName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF003C43).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 16,
                              color: const Color(0xFF003C43).withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Semestre: ${widget.subject.semestre}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF003C43).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Text(
                          'TODO: Información del profesor y evaluación',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
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
}
