import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Hooks
import 'package:eval_plus/hooks/careers_data.dart';

// Contenido de carreras con FutureBuilder
class CarrerasContent extends StatelessWidget {
  const CarrerasContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Career>>(
      future: CareersDataService.getCareers(),
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
                  'Error al cargar carreras',
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
                  'No hay carreras disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Mostrar lista de carreras
        final carreras = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: carreras.length,
          itemBuilder: (context, index) {
            final carrera = carreras[index];
            return _CareerCard(career: carrera);
          },
        );
      },
    );
  }
}

// Widget separado para la tarjeta de carrera
class _CareerCard extends StatelessWidget {
  final Career career;

  const _CareerCard({required this.career});

  @override
  Widget build(BuildContext context) {
    // Extraer el color base sin opacidad
    final baseColor = career.color.withOpacity(1.0);
  
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: baseColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.2),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navegar a evaluación de docentes
            print('Seleccionada: ${career.nombre}');
          },
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
                    career.icon,
                    color: const Color(0xFF003C43),
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
                          color: Color(0xFF003C43),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
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
                                color: Color(0xFF003C43),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
