import 'package:flutter/material.dart';

// Services
import 'package:eval_plus/services/careers_service.dart';

// Models
import 'package:eval_plus/models/career_model.dart';

// Content
import 'package:eval_plus/screen/content/subjects_content.dart';

// NOTA: SubjectsContent necesita CareerModel, no Career
// Asegúrate de actualizar subjects_content.dart para usar career.colorValue

class CarrerasContent extends StatefulWidget {
  const CarrerasContent({super.key});

  @override
  State<CarrerasContent> createState() => _CarrerasContentState();
}

class _CarrerasContentState extends State<CarrerasContent> {
  final _careersService = CareersService();
  
  CareerModel? _selectedCareer;
  List<CareerModel>? _careers;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  Future<void> _loadCareers({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final careers = await _careersService.getMyCareers(
        forceRefresh: forceRefresh,
      );
      
      if (mounted) {
        setState(() {
          _careers = careers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar carreras: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onCareerSelected(CareerModel career) {
    setState(() {
      _selectedCareer = career;
    });
  }

  void _onBackToCareersList() {
    setState(() {
      _selectedCareer = null;
    });
  }

  Future<void> _onRefresh() async {
    await _loadCareers(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Si hay una carrera seleccionada, mostrar materias
    if (_selectedCareer != null) {
      return SubjectsContent(
        career: _selectedCareer!,
        onBack: _onBackToCareersList,
      );
    }

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
      return _buildErrorState();
    }

    // Si no hay carreras
    if (_careers == null || _careers!.isEmpty) {
      return _buildEmptyState();
    }

    // Mostrar lista de carreras con RefreshIndicator
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFFCAD225),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _careers!.length,
        itemBuilder: (context, index) {
          final carrera = _careers![index];
          return _CareerCard(
            career: carrera,
            onTap: () => _onCareerSelected(carrera),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar carreras',
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
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCareers,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay carreras disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes carreras asignadas',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCareers,
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
}

// Widget separado para la tarjeta de carrera
class _CareerCard extends StatelessWidget {
  final CareerModel career;
  final VoidCallback onTap;

  const _CareerCard({
    required this.career,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = career.colorValue.withOpacity(1.0);
  
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono con diseño mejorado
                Container(
                  padding: const EdgeInsets.all(14),
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
                      color: baseColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    career.iconData,
                    color: const Color(0xFF1A1A1A),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          career.codigo,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: baseColor.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
