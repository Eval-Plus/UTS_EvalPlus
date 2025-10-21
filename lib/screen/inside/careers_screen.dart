import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Widgets
import 'package:eval_plus/widgets/custom_bottom_nav_bar.dart';
import 'package:eval_plus/widgets/custom_header_wave.dart';
import 'package:eval_plus/widgets/custom_top_bar.dart';

// Hooks
import 'package:eval_plus/hooks/careers_data.dart';

class CareersScreen extends StatelessWidget {
  static const String routename = 'CareersScreen';

  // Configuración
  static const double verticalPadding = 80.0; // Margenes arriba/abajo
  static const bool centerContent = true;    // true = centrado, false = distribuido
  
  const CareersScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true, // Contenido detras de la navBar
      body: Stack(
        children: [
          // Fondo blanco
          Container(color: Colors.grey[50]),
          
          // Header con onda
          const CustomHeaderWave(),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Barra superior con info del usuario
                CustomTopBar(
                  title: '¡Hola, Estudiante!',
                  subtitle: 'Selecciona tu programa',
                  onLogoutPressed: () {
                    // Implementar cierre de sesión posteriormente
                    Navigator.pop(context);
                  },
                ),
                
                // Opción 1: Padding fijo
                if (!centerContent)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: verticalPadding,
                      ),
                      child: const _CarrerasContent(),
                    ),
                  ),

                // Opción 2: Centrado con spacer
                if (centerContent) ...[
                  const Spacer(flex: 1),
                  const Flexible(
                    flex: 3,
                    child: _CarrerasContent(),
                  ),
                  const Spacer(flex: 1),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Manejar logica de navegación
          print('Tap en indice: $index');
        },
      ),
    );
  }
}

// Contenido de carreras con FutureBuilder
class _CarrerasContent extends StatelessWidget {
  const _CarrerasContent();

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: career.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            career.icon,
            color: const Color(0xFF003C43),
            size: 28,
          ),
        ),
        title: Text(
          career.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          career.codigo,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navegar a evaluación de docentes
          print('Seleccionada: ${career.nombre}');
        },
      ),
    );
  }
}
