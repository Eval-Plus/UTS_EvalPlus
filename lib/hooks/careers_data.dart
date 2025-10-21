import 'package:flutter/material.dart';

// Modelo de datos para una carrera
class Career {
  final String nombre;
  final String codigo;
  final IconData icon;
  final Color color;

  Career({
    required this.nombre,
    required this.codigo,
    required this.icon,
    required this.color,
  });

  // Factory constructor para crear desde JSON (para futura API)
  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      icon: _getIconFromString(json['icon'] as String? ?? 'computer'),
      color: Color(int.parse(json['color'] as String? ?? '0xFF135D66')),
    );
  }

  // Método para convertir a JSON (por si necesitas enviar data)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'icon': _getIconString(icon),
      'color': '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
    };
  }

  // Helper para convertir string a IconData
  static IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'business_center':
        return Icons.business_center;
      case 'gavel':
        return Icons.gavel;
      default:
        return Icons.school;
    }
  }

  // Helper para convertir IconData a string
  static String _getIconString(IconData icon) {
    if (icon == Icons.computer) return 'computer';
    if (icon == Icons.business_center) return 'business_center';
    if (icon == Icons.gavel) return 'gavel';
    return 'school';
  }
}

// Hook/Servicio para obtener carreras
class CareersDataService {
  // Por ahora, data hardcodeada
  // TODO: Reemplazar con fetch a API
  static Future<List<Career>> getCareers() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Career(
        nombre: 'Ingeniería de Sistemas',
        codigo: 'ING-SIS',
        icon: Icons.computer,
        color: const Color(0xFF135D66),
      ),
      Career(
        nombre: 'Administración de Empresas',
        codigo: 'ADM-EMP',
        icon: Icons.business_center,
        color: const Color(0xFF77B0AA),
      ),
      Career(
        nombre: 'Derecho',
        codigo: 'DER',
        icon: Icons.gavel,
        color: const Color(0xFFE3FEF7),
      ),
    ];
  }

  // Método preparado para el futuro fetch a API
  static Future<List<Career>> fetchCareersFromAPI() async {
    // TODO: Implementar fetch real
    /*
    try {
      final response = await http.get(Uri.parse('https://tu-api.com/careers'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Career.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar carreras');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
    */
    
    // Por ahora, retorna data hardcodeada
    return getCareers();
  }
}
