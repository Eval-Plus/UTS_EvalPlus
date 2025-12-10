import 'package:flutter/material.dart';

// Data
import 'package:eval_plus/data/subjects_data.dart';
import 'package:eval_plus/models/career_model.dart'; // ← CAMBIADO: usar CareerModel

// Widgets
import 'package:eval_plus/widgets/evaluation/evaluation_modal.dart';
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';

class SubjectsContent extends StatefulWidget {
  final CareerModel career; // ← CAMBIADO: de Career a CareerModel
  final VoidCallback onBack;

  const SubjectsContent({
    super.key,
    required this.career,
    required this.onBack,
  });

  @override
  State<SubjectsContent> createState() => _SubjectsContentState();
}

class _SubjectsContentState extends State<SubjectsContent> {
  List<Subject>? _subjects;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  /// Carga las materias de la carrera seleccionada
  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📚 Cargando materias para: ${widget.career.nombre}');
      debugPrint('   - Código: ${widget.career.codigo}');
      debugPrint('   - ID: ${widget.career.id}');

      final subjects = await SubjectsDataService.getSubjectsByCareer(
        careerCodigo: widget.career.codigo,
        careerId: widget.career.id,
      );

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
        
        debugPrint('✅ ${subjects.length} materias cargadas');
      }
    } catch (e) {
      debugPrint('💥 Error cargando materias: $e');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar materias: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Refresca las materias
  Future<void> _onRefresh() async {
    await _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón para volver
        _BackButton(
          careerName: widget.career.nombre,
          careerColor: widget.career.colorValue, // ← CAMBIADO: .color a .colorValue
          onBack: widget.onBack,
        ),
        
        // Lista de materias
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Mientras carga
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFCAD225),
        ),
      );
    }

    // Si hay error
    if (_errorMessage != null) {
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
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Si no hay materias
    if (_subjects == null || _subjects!.isEmpty) {
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
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No tienes materias en esta carrera',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar lista de materias con RefreshIndicator
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFFCAD225),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _subjects!.length,
        itemBuilder: (context, index) {
          final subject = _subjects![index];
          return _SubjectCard(
            subject: subject,
            color: widget.career.colorValue, // ← CAMBIADO: .color a .colorValue
          );
        },
      ),
    );
  }
}

// Botón de regreso personalizado
class _BackButton extends StatelessWidget {
  final String careerName;
  final Color careerColor;
  final VoidCallback onBack;
  
  const _BackButton({
    required this.careerName,
    required this.careerColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = careerColor.withOpacity(1.0);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withOpacity(0.15),
                  baseColor.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: baseColor.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Icono con fondo circular
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 14),
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Volver a carreras',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        careerName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
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
    final baseColor = widget.color.withOpacity(1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: baseColor.withOpacity(0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.18),
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
              // Header de la materia
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono de libro
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            baseColor.withOpacity(0.25),
                            baseColor.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: baseColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF1A1A1A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: baseColor.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: baseColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.subject.codigo,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: baseColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 12,
                                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Sem ${widget.subject.semestre}',
                                      style: TextStyle(
                                        color: const Color(0xFF1A1A1A).withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                          color: baseColor.withOpacity(_isExpanded ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF1A1A1A),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido expandible - Info del profesor
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
                          baseColor.withOpacity(0.08),
                          baseColor.withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: baseColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Información del profesor con avatar
                        Row(
                          children: [
                            // Avatar del profesor
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    baseColor.withOpacity(0.3),
                                    baseColor.withOpacity(0.15),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: baseColor.withOpacity(0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF1A1A1A),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info del profesor
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Docente',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subject.hasTeacher 
                                      ? widget.subject.professorName 
                                      : 'Sin docente',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Botón de evaluar
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: widget.subject.hasTeacher
                                ? LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      baseColor.withOpacity(0.9),
                                      baseColor.withOpacity(0.7),
                                    ],
                                  )
                                : null,
                            color: widget.subject.hasTeacher 
                                ? null 
                                : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: widget.subject.hasTeacher
                                ? [
                                    BoxShadow(
                                      color: baseColor.withOpacity(0.3),
                                      offset: const Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: widget.subject.canBeEvaluated
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return EvaluationModal(subject: widget.subject);
                                      },
                                    );
                                  }
                                : () {
                                    String message = !widget.subject.hasTeacher
                                        ? 'No hay docente registrado en esta materia.'
                                        : 'No hay evaluación activa disponible en este momento.';
                                        
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return MessageDialogWidget.info(
                                          title: 'Evaluación no disponible',
                                          message: message,
                                          onContinue: () {
                                            Navigator.of(context).pop();
                                          },
                                          continueButtonText: 'Entendido',
                                        );
                                      },
                                    );
                                  },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.rate_review_rounded,
                                      color: widget.subject.hasTeacher 
                                          ? Colors.white 
                                          : Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Evaluar Docente',
                                      style: TextStyle(
                                        color: widget.subject.hasTeacher 
                                            ? Colors.white 
                                            : Colors.grey.shade400,
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
