import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'package:eval_plus/models/user_model.dart';

// Controllers
import 'package:eval_plus/controllers/user_session_controller.dart';
import 'package:eval_plus/controllers/inside_screen_controller.dart';

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
    
    // 🆕 Obtener el controller para acceder a los datos del usuario
    final controller = context.watch<InsideScreenController>();
    
    // 🆕 Usar el usuario del controller si está disponible, sino el que viene por parámetro
    final currentUser = controller.currentUser ?? user;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // 🆕 Mostrar loading si los datos se están cargando
            if (controller.isLoadingUserData)
              _buildLoadingState(session.palette)
            else
              _buildProfileCard(
                currentUser,
                session.roleDisplayName,
                session.palette,
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🆕 Widget de loading mientras se cargan los datos
  Widget _buildLoadingState(palette) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.borderColor(0.4),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: CircularProgressIndicator(
            color: palette.primary,
          ),
        ),
      ),
    );
  }

  /// Construye la tarjeta principal del perfil
  Widget _buildProfileCard(UserModel? userData, String roleDisplay, palette) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.borderColor(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar con colores dinámicos
            _buildAvatar(userData, palette),
            
            const SizedBox(height: 20),
            
            // Nombre del usuario
            Text(
              userData?.nombreCompleto ?? 'Usuario',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Chip con correo institucional (colores dinámicos)
            _buildEmailChip(userData, palette),
            
            const SizedBox(height: 24),
            
            // Divider sutil con color dinámico
            Container(
              height: 1,
              color: palette.borderColor(0.2),
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
  Widget _buildAvatar(UserModel? userData, palette) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: palette.avatarGradient,
        border: Border.all(
          color: palette.accent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          userData?.initials ?? 'US',
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
  Widget _buildEmailChip(UserModel? userData, palette) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: palette.chipBackground,
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
          Flexible(
            child: Text(
              userData?.email ?? 'correo@uts.edu.co',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
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
                palette.chipBackground,
                palette.primary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: palette.borderColor(0.3),
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