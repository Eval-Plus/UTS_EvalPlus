import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Widgets
import 'package:eval_plus/widgets/custom_bottom_nav_bar.dart';
import 'package:eval_plus/widgets/custom_header_wave.dart';
import 'package:eval_plus/widgets/custom_top_bar.dart';

// Layouts
import 'package:eval_plus/layouts/base_screen_layout.dart';

class ProfileScreen extends StatelessWidget {
  static const String routename = 'ProfileScreen';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      topBarTitle: 'Hola, Estudiante',
      topBarSubtitle: 'Aqui puedes cambiar tu avatar',
      currentNavIndex: 2,
      centerContent: false,
      paddingTop: 120.0,
      paddingBottom: 20.0,
      onLogoutPressed: () {
        // Cierre de sesión
        Navigator.pop(context);
      },
      child: const _ProfileContent(),
    );
  }
}

// Cotenido de perfil
class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    // Lista de evaluaciones
    return Container(
      child: const Center(
        child: Text('Contenido del perfil'),
      ),
    );
  }
}
