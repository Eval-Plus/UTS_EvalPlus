import 'package:flutter/material.dart';

// Services
import 'package:eval_plus/services/careers_service.dart';

// Models
import 'package:eval_plus/models/career_model.dart';

// Content
import 'package:eval_plus/screen/content/student/subjects_content.dart';

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

  // ✅ CORRECCIÓN: RefreshIndicator usa forceRefresh
  Future<void> _onRefresh() async {
    await _loadCareers(forceRefresh: true);
  }

  // ✅ CORRECCIÓN: Nuevo método para el botón que fuerza refresh
  Future<void> _onManualRefresh() async {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFCAD225),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando carreras...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ],
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
          // ✅ CORRECCIÓN: Usa _onManualRefresh en lugar de _loadCareers
          ElevatedButton.icon(
            onPressed: _onManualRefresh,
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono más representativo
            Icon(
              Icons.pending_actions_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            
            // Título principal
            Text(
              'No hay carreras disponibles',
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
              'Aún no tienes carreras asignadas.\nPor favor, espera a que se complete el proceso de sincronización con el sistema académico.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // ✅ CORRECCIÓN: Usa _onManualRefresh en lugar de _loadCareers
            ElevatedButton.icon(
              onPressed: _onManualRefresh,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCAD225),
                foregroundColor: const Color(0xFF1A1A1A),
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
            
            // Mensaje adicional de ayuda
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCAD225).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCAD225).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: const Color(0xFFB8BE20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si el problema persiste, contacta al administrador',
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
