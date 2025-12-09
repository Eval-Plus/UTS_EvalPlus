import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';

/// Respuesta del API para una pregunta
class QuestionApiResponse {
  final int id;
  final int templateId;
  final String categoria;
  final String aspecto;
  final int nroPregunta;
  final String enunciado;
  final String tipoRespuesta;
  final int valorMinimo;
  final int valorMaximo;
  final bool esObligatoria;
  final int orden;
  final bool activo;
  final String createdAt;

  QuestionApiResponse({
    required this.id,
    required this.templateId,
    required this.categoria,
    required this.aspecto,
    required this.nroPregunta,
    required this.enunciado,
    required this.tipoRespuesta,
    required this.valorMinimo,
    required this.valorMaximo,
    required this.esObligatoria,
    required this.orden,
    required this.activo,
    required this.createdAt,
  });

  factory QuestionApiResponse.fromJson(Map<String, dynamic> json) {
    return QuestionApiResponse(
      id: json['id'] as int,
      templateId: json['templateId'] as int,
      categoria: json['categoria'] as String,
      aspecto: json['aspecto'] as String,
      nroPregunta: json['nroPregunta'] as int,
      enunciado: json['enunciado'] as String,
      tipoRespuesta: json['tipoRespuesta'] as String,
      valorMinimo: json['valorMinimo'] as int,
      valorMaximo: json['valorMaximo'] as int,
      esObligatoria: json['esObligatoria'] as bool,
      orden: json['orden'] as int,
      activo: json['activo'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }
}

/// Servicio para manejar el endpoint de preguntas
class QuestionsApiService {
  /// Obtiene todas las preguntas del formulario
  static Future<List<QuestionApiResponse>?> fetchQuestions() async {
    try {
      debugPrint('🔍 Consultando preguntas del formulario...');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/questions'),
        headers: {
          'Content-Type': 'application/json',
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
          final questionsList = (data['data'] as List)
              .map((question) => QuestionApiResponse.fromJson(question))
              .toList();
          
          debugPrint('✅ Preguntas obtenidas: ${questionsList.length}');
          return questionsList;
        } else {
          debugPrint('❌ Respuesta sin datos válidos');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron preguntas');
        return [];
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Error obteniendo preguntas: $e');
      return null;
    }
  }
}
