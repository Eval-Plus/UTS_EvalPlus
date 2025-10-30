import 'package:flutter/material.dart';

// Modelo de datos para una pregunta del formulario
class Question {
  final String categoria;
  final int nroPregunta;
  final String aspecto;
  final String enunciado;

  Question({
    required this.categoria,
    required this.nroPregunta,
    required this.aspecto,
    required this.enunciado,
  });

  // Factory constructor para crear desde JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      categoria: json['categoria'] as String,
      nroPregunta: json['nroPregunta'] as int,
      aspecto: json['aspecto'] as String,
      enunciado: json['enunciado'] as String,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'nroPregunta': nroPregunta,
      'aspecto': aspecto,
      'enunciado': enunciado,
    };
  }
}

// Servicio para obtener preguntas del formulario
class QuestionsDataService {
  // Data hardcodeada por ahora
  // TODO: Reemplazar con fetch a API
  static Future<List<Question>> getAllQuestions() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      // Pregunta 1
      Question(
        categoria: 'Respeto, buen trato, trabajo en equipo',
        nroPregunta: 1,
        aspecto: 'Ético - Social',
        enunciado: 'Inspira respeto y confiabilidad en su desempeño docente.',
      ),
      
      // Pregunta 2
      Question(
        categoria: 'Conocimiento y dominio de la materia',
        nroPregunta: 2,
        aspecto: 'Académico',
        enunciado: 'Demuestra dominio y actualización en los contenidos de la asignatura.',
      ),
      
      // Pregunta 3
      Question(
        categoria: 'Metodología y estrategias de enseñanza',
        nroPregunta: 3,
        aspecto: 'Pedagógico',
        enunciado: 'Utiliza métodos y recursos didácticos que facilitan el aprendizaje.',
      ),
      
      // Pregunta 4
      Question(
        categoria: 'Comunicación y relación con estudiantes',
        nroPregunta: 4,
        aspecto: 'Ético - Social',
        enunciado: 'Se comunica de manera clara y mantiene una actitud receptiva ante consultas.',
      ),
      
      // Pregunta 5
      Question(
        categoria: 'Evaluación y retroalimentación',
        nroPregunta: 5,
        aspecto: 'Académico',
        enunciado: 'Proporciona retroalimentación oportuna y constructiva sobre las evaluaciones.',
      ),
    ];
  }

  // Método para obtener preguntas por categoría
  static Future<List<Question>> getQuestionsByCategory(String categoria) async {
    final allQuestions = await getAllQuestions();
    return allQuestions
        .where((question) => question.categoria == categoria)
        .toList();
  }

  // Método para obtener preguntas por aspecto
  static Future<List<Question>> getQuestionsByAspect(String aspecto) async {
    final allQuestions = await getAllQuestions();
    return allQuestions
        .where((question) => question.aspecto == aspecto)
        .toList();
  }

  // Método preparado para el futuro fetch a API
  static Future<List<Question>> fetchQuestionsFromAPI() async {
    // TODO: Implementar fetch real
    /*
    try {
      final response = await http.get(
        Uri.parse('https://tu-api.com/questions')
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar preguntas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
    */
    
    // Por ahora, retorna data hardcodeada
    return getAllQuestions();
  }
}
