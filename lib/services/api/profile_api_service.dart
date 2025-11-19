import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/user_model.dart';

class ProfileApiService {
  /// Obtiene el perfil completo del usuario desde el backend
  static Future<UserModel?> fetchUserProfile(String token) async {
    try {
      debugPrint('🔍 Consultando perfil del usuario...');

      final response = await http.get(
        Uri.parse('${AppConstants.authUrl}/profile'),
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
          debugPrint('✅ Perfil obtenido exitosamente');
          return UserModel.fromJson(data['data']);
        } else {
          debugPrint('❌ Respuesta sin datos válidos');
          return null;
        }
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo perfil: $e');
      return null;
    }
  }

  /// Actualiza el perfil del usuario (para futuro)
  static Future<UserModel?> updateUserProfile({
    required String token,
    required Map<String, dynamic> updates,
  }) async {
    try {
      debugPrint('📝 Actualizando perfil...');

      final response = await http.put(
        Uri.parse('${AppConstants.authUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ Perfil actualizado');
          return UserModel.fromJson(data['data']);
        }
      }

      debugPrint('❌ Error actualizando perfil');
      return null;
    } catch (e) {
      debugPrint('💥 Error actualizando perfil: $e');
      return null;
    }
  }
}
