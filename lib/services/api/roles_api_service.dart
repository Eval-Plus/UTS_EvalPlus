import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';

class RoleInfo {
  final int id;
  final String name;
  final String displayName;
  final String? description;
  final DateTime createdAt;

  RoleInfo({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.createdAt,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class RolesApiService {
  /// Obtiene los roles del usuario actual
  static Future<List<RoleInfo>?> fetchMyRoles(String token) async {
    try {
      debugPrint('🔍 Consultando roles del usuario...');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/roles/my'),
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
          final rolesList = (data['data'] as List)
              .map((role) => RoleInfo.fromJson(role))
              .toList();
          
          debugPrint('✅ Roles obtenidos: ${rolesList.map((r) => r.name).join(", ")}');
          return rolesList;
        } else {
          debugPrint('❌ Respuesta sin datos válidos');
          return null;
        }
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo roles: $e');
      return null;
    }
  }
}
