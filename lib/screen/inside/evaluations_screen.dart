import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Widgets
import 'package:eval_plus/widgets/custom_bottom_nav_bar.dart';
import 'package:eval_plus/widgets/custom_header_wave.dart';
import 'package:eval_plus/widgets/custom_top_bar.dart';

// Layouts
import 'package:eval_plus/layouts/base_screen_layout.dart';

class EvaluationsScreen extends StatelessWidget {
  static const String routename = 'EvaluationsScreen';

  const EvaluationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      topBarTitle: '¡Hola, Estudiante',
      topBarSubtitle: 'Aqui estan tus evaluaciones',
      currentNavIndex: 1,
      centerContent: false,
      paddingTop: 120.0,
      paddingBottom: 20.0,
      onLogoutPressed: () {
        // Implementar cierre de sesión posteriormente
        Navigator.pop(context);
      },
      onNavTap: (index) {
        // Manejar logica de navegación
        print('Tap en indice: $index');
      },
      child: const _EvaluationsList(),
    );
  }
}

// Cotenido de evaluaciones
class _EvaluationsList extends StatelessWidget {
  const _EvaluationsList();

  @override
  Widget build(BuildContext context) {
    // Lista de evaluaciones
    return Container(
      child: const Center(
        child: Text('Contenido de evaluaciones'),
      ),
    );
  }
}
