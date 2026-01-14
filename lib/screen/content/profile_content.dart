import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'package:eval_plus/models/user_model.dart';

// Controllers
import 'package:eval_plus/controllers/user_session_controller.dart';

/// Contenedor del perfil del usuario
/// Muestra información básica: avatar y correo institucional
/// 🔥 ACTUALIZADO: Colores dinámicos según rol del usuario
class ProfileContent extends StatelessWidget {
  final UserModel? user;

  const ProfileContent({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener la sesión completa (rol y paleta de colores)
    final session = context.watch<UserSessionController>();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(
              session.roleDisplayName,
              session.palette, // 🔥 Pasar la paleta completa
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta principal del perfil
  Widget _buildProfileCard(String roleDisplay, palette) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.borderColor(0.4), // 🔥 Color dinámico
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadowLight, // 🔥 Sombra dinámica
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar con colores dinámicos
            _buildAvatar(palette),
            
            const SizedBox(height: 20),
            
            // Nombre del usuario
            Text(
              user?.nombreCompleto ?? 'Usuario',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Chip con correo institucional (colores dinámicos)
            _buildEmailChip(palette),
            
            const SizedBox(height: 24),
            
            // Divider sutil con color dinámico
            Container(
              height: 1,
              color: palette.borderColor(0.2), // 🔥 Color dinámico
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional con colores dinámicos
            _buildInfoRow(
              icon: Icons.school_rounded,
              label: roleDisplay,
              palette: palette,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el avatar del usuario con colores dinámicos
  Widget _buildAvatar(palette) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: palette.avatarGradient, // 🔥 Gradiente dinámico
        border: Border.all(
          color: palette.accent, // 🔥 Border dinámico
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadowLight, // 🔥 Sombra dinámica
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          user?.initials ?? 'US',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Construye el chip con el correo institucional
  Widget _buildEmailChip(palette) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: palette.chipBackground, // 🔥 Fondo dinámico
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.email_rounded,
            size: 12,
            color: const Color(0xFF1A1A1A).withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            user?.email ?? 'correo@uts.edu.co',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una fila de información con ícono y texto
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required palette,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palette.chipBackground, // 🔥 Color dinámico
                palette.primary.withOpacity(0.08), // 🔥 Color dinámico
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: palette.borderColor(0.3), // 🔥 Border dinámico
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
