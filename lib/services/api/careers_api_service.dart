import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';

class CareerApiResponse {
  final int id;
  final String nombre;
  final String codigo;
  final String icon;
  final String color;
  final String? descripcion;
  final bool activo;

  CareerApiResponse({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.icon,
    required this.color,
    this.descripcion,
    required this.activo,
  });

  factory CareerApiResponse.fromJson(Map<String, dynamic> json) {
    return CareerApiResponse(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'icon': icon,
      'color': color,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}

class CareersApiService {
  /// Obtiene las carreras del usuario desde el backend
  static Future<List<CareerApiResponse>?> fetchMyCareers(String token) async {
    try {
      debugPrint('🔍 Consultando carreras del usuario...');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/careers/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        AppConstants.apiTimeout,
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      debugPrint('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final careersList = (data['data'] as List)
              .map((career) => CareerApiResponse.fromJson(career))
              .toList();
          
          debugPrint('✅ Carreras obtenidas: ${careersList.length}');
          return careersList;
        } else {
          debugPrint('❌ Respuesta sin datos válidos');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron carreras para este usuario');
        return [];
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo carreras: $e');
      return null;
    }
  }

  /// Obtiene todas las carreras disponibles (para futuro)
  static Future<List<CareerApiResponse>?> fetchAllCareers(String token) async {
    try {
      debugPrint('🔍 Consultando todas las carreras...');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/careers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final careersList = (data['data'] as List)
              .map((career) => CareerApiResponse.fromJson(career))
              .toList();
          
          debugPrint('✅ Todas las carreras obtenidas: ${careersList.length}');
          return careersList;
        }
      }

      debugPrint('❌ Error obteniendo todas las carreras');
      return null;
    } catch (e) {
      debugPrint('💥 Error: $e');
      return null;
    }
  }
}
