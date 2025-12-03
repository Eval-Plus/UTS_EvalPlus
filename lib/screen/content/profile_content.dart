import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'package:eval_plus/models/user_model.dart';

// Controllers
import 'package:eval_plus/controllers/user_session_controller.dart';

/// Contenedor del perfil del usuario
/// Muestra información básica: avatar y correo institucional
class ProfileContent extends StatelessWidget {
  final UserModel? user;

  const ProfileContent({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el displayName del rol desde la sesión
    final session = context.watch<UserSessionController>();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(session.roleDisplayName), // Pasar displayName
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta principal del perfil
  Widget _buildProfileCard(String roleDisplay) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA8B820).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8B820).withOpacity(0.2),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            _buildAvatar(),
            
            const SizedBox(height: 20),
            
            // Nombre del usuario
            Text(
              user?.nombreCompleto ?? 'Estudiante',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Chip con correo institucional
            _buildEmailChip(),
            
            const SizedBox(height: 24),
            
            // Divider sutil
            Container(
              height: 1,
              color: const Color(0xFFA8B820).withOpacity(0.2),
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            _buildInfoRow(
              icon: Icons.school_rounded,
              label: roleDisplay,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el avatar del usuario
  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFFCAD225),
            const Color(0xFFA8B820),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFA8B820),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8B820).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          user?.initials ?? 'US',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Construye el chip con el correo institucional
  Widget _buildEmailChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFCAD225).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.email_rounded,
            size: 16,
            color: const Color(0xFF1A1A1A).withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            user?.email ?? 'correo@uts.edu.co',
            style: TextStyle(
              fontSize: 13,
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
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFCAD225).withOpacity(0.15),
                const Color(0xFFCAD225).withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFA8B820).withOpacity(0.3),
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
