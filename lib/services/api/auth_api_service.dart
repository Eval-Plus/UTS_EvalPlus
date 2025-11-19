import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = 'https://evalplus-api.emprenet.work/api';
  
  /// Valida un token JWT con el backend
  static Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      print('🔍 Validando token con backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/validate-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Token válido');
        return {
          'valid': true,
          'user': data['data']['user'], // Acceso correcto
          'message': data['message'],
        };
      } else {
        print('❌ Token inválido: ${data['message']}');
        return {
          'valid': false,
          'message': data['message'] ?? 'Token inválido',
        };
      }
    } catch (e) {
      print('💥 Error validando token: $e');
      return {
        'valid': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene la información del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }
}
