import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/services/api/careers_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

// Modelo de datos para una carrera
class Career {
  final int id;
  final String nombre;
  final String codigo;
  final IconData icon;
  final Color color;
  final String? descripcion;
  final bool activo;

  Career({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.icon,
    required this.color,
    this.descripcion,
    this.activo = true,
  });

  // Factory constructor para crear desde la respuesta del API
  factory Career.fromApiResponse(CareerApiResponse apiResponse) {
    return Career(
      id: apiResponse.id,
      nombre: apiResponse.nombre,
      codigo: apiResponse.codigo,
      icon: _getIconFromString(apiResponse.icon),
      color: AppColors.parseColorString(apiResponse.color),
      descripcion: apiResponse.descripcion,
      activo: apiResponse.activo,
    );
  }

  // Factory constructor para crear desde JSON (legacy)
  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      icon: _getIconFromString(json['icon'] as String? ?? 'computer'),
      color: AppColors.parseColorString(json['color'] as String? ?? '0xFFA8B820'),
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'icon': _getIconString(icon),
      'color': '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      'descripcion': descripcion,
      'activo': activo,
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
      case 'school':
        return Icons.school;
      case 'engineering':
        return Icons.engineering;
      case 'science':
        return Icons.science;
      case 'business':
        return Icons.business;
      default:
        return Icons.school;
    }
  }

  // Helper para convertir IconData a string
  static String _getIconString(IconData icon) {
    if (icon == Icons.computer) return 'computer';
    if (icon == Icons.business_center) return 'business_center';
    if (icon == Icons.gavel) return 'gavel';
    if (icon == Icons.engineering) return 'engineering';
    if (icon == Icons.science) return 'science';
    if (icon == Icons.business) return 'business';
    return 'school';
  }
}

// Servicio para obtener carreras
class CareersDataService {
  /// Obtiene las carreras del usuario desde el API
  static Future<List<Career>> getCareers() async {
    try {
      // Obtener token
      final token = await AuthStorageService.getToken();
      
      if (token == null) {
        debugPrint('❌ No hay token disponible');
        return _getFallbackCareers();
      }

      // Fetch desde API
      final apiResponse = await CareersApiService.fetchMyCareers(token);

      if (apiResponse != null && apiResponse.isNotEmpty) {
        // Convertir respuesta del API a modelo Career
        return apiResponse
            .where((career) => career.activo)
            .map((apiCareer) => Career.fromApiResponse(apiCareer))
            .toList();
      }

      // Si no hay carreras o hubo error, retornar fallback
      debugPrint('⚠️ No se obtuvieron carreras del API, usando fallback');
      return _getFallbackCareers();
      
    } catch (e) {
      debugPrint('💥 Error en getCareers: $e');
      return _getFallbackCareers();
    }
  }

  /// Carreras de respaldo (fallback) por si falla el API
  static Future<List<Career>> _getFallbackCareers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Career(
        id: 1,
        nombre: 'Ingeniería de Sistemas',
        codigo: 'ING-SIS',
        icon: Icons.computer,
        color: AppColors.getCareerColor('ING-SIS'),
        descripcion: 'Carrera enfocada en el desarrollo de software',
      ),
      Career(
        id: 2,
        nombre: 'Administración de Empresas',
        codigo: 'ADM-EMP',
        icon: Icons.business_center,
        color: AppColors.getCareerColor('ADM-EMP'),
        descripcion: 'Formación integral en gestión empresarial',
      ),
      Career(
        id: 3,
        nombre: 'Derecho',
        codigo: 'DER',
        icon: Icons.gavel,
        color: AppColors.getCareerColor('DER'),
        descripcion: 'Carrera enfocada en ciencias jurídicas',
      ),
    ];
  }

  /// Método para obtener una carrera específica por código
  static Future<Career?> getCareerByCode(String codigo) async {
    final careers = await getCareers();
    try {
      return careers.firstWhere(
        (career) => career.codigo.toUpperCase() == codigo.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Método para obtener una carrera específica por ID
  static Future<Career?> getCareerById(int id) async {
    final careers = await getCareers();
    try {
      return careers.firstWhere((career) => career.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresca las carreras (útil después de cambios)
  static Future<List<Career>> refreshCareers() async {
    return await getCareers();
  }
}
