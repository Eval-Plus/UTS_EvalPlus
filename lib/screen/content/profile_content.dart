import 'package:flutter/material.dart';

/// Contenedor del perfil del usuario
/// Muestra información básica: avatar y correo institucional
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Tarjeta de perfil
            _buildProfileCard(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta principal del perfil
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF135D66).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF135D66).withOpacity(0.2),
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
            const Text(
              'Javier Socha',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003C43),
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
              color: const Color(0xFF003C43).withOpacity(0.1),
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            _buildInfoRow(
              icon: Icons.school_rounded,
              label: 'Estudiante',
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
            const Color(0xFF003C43),
            const Color(0xFF003C43).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF003C43),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003C43).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'JS',
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
        color: const Color(0xFF003C43).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.email_rounded,
            size: 16,
            color: const Color(0xFF003C43).withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          const Text(
            'jsocha@example.edu.co',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF003C43),
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
                const Color(0xFF003C43).withOpacity(0.1),
                const Color(0xFF003C43).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF003C43).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF003C43),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF003C43).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
