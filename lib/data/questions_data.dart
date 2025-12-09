import 'package:flutter/material.dart';
import 'package:eval_plus/services/api/questions_api_service.dart';

// Modelo de datos para una pregunta del formulario
class Question {
  final int id;
  final String categoria;
  final int nroPregunta;
  final String aspecto;
  final String enunciado;
  final bool esObligatoria;
  final int orden;

  Question({
    required this.id,
    required this.categoria,
    required this.nroPregunta,
    required this.aspecto,
    required this.enunciado,
    required this.esObligatoria,
    required this.orden,
  });

  // Factory constructor para crear desde la respuesta del API
  factory Question.fromApiResponse(QuestionApiResponse apiResponse) {
    return Question(
      id: apiResponse.id,
      categoria: apiResponse.categoria,
      nroPregunta: apiResponse.nroPregunta,
      aspecto: apiResponse.aspecto,
      enunciado: apiResponse.enunciado,
      esObligatoria: apiResponse.esObligatoria,
      orden: apiResponse.orden,
    );
  }

  // Factory constructor para crear desde JSON (legacy/fallback)
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int? ?? 0,
      categoria: json['categoria'] as String,
      nroPregunta: json['nroPregunta'] as int,
      aspecto: json['aspecto'] as String,
      enunciado: json['enunciado'] as String,
      esObligatoria: json['esObligatoria'] as bool? ?? true,
      orden: json['orden'] as int? ?? 0,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'nroPregunta': nroPregunta,
      'aspecto': aspecto,
      'enunciado': enunciado,
      'esObligatoria': esObligatoria,
      'orden': orden,
    };
  }
}

// Servicio para obtener preguntas del formulario
class QuestionsDataService {
  /// Obtiene todas las preguntas desde el API
  static Future<List<Question>> getAllQuestions() async {
    try {
      debugPrint('🔍 Cargando preguntas del formulario...');

      // Fetch desde API
      final apiResponse = await QuestionsApiService.fetchQuestions();

      if (apiResponse != null && apiResponse.isNotEmpty) {
        // Convertir respuesta del API a modelo Question
        final questions = apiResponse
            .where((question) => question.activo)
            .map((apiQuestion) => Question.fromApiResponse(apiQuestion))
            .toList();

        // Ordenar por el campo 'orden'
        questions.sort((a, b) => a.orden.compareTo(b.orden));

        debugPrint('✅ ${questions.length} preguntas cargadas');
        return questions;
      }

      // Si no hay preguntas o hubo error, retornar fallback
      debugPrint('⚠️ No se obtuvieron preguntas del API, usando fallback');
      return _getFallbackQuestions();
      
    } catch (e) {
      debugPrint('💥 Error en getAllQuestions: $e');
      return _getFallbackQuestions();
    }
  }

  /// Preguntas de respaldo (fallback) por si falla el API
  static Future<List<Question>> _getFallbackQuestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      // Pregunta 1
      Question(
        id: 1,
        categoria: 'Competencia Disciplinaria',
        nroPregunta: 1,
        aspecto: 'Formativo',
        enunciado: 'Demuestra dominio y actualización en la presentación de los temas del curso.',
        esObligatoria: true,
        orden: 1,
      ),
      
      // Pregunta 2
      Question(
        id: 2,
        categoria: 'Conocimiento y dominio de la materia',
        nroPregunta: 2,
        aspecto: 'Formativo',
        enunciado: 'Orienta de manera clara los conceptos y teorias del curso.',
        esObligatoria: true,
        orden: 2,
      ),
      
      // Pregunta 3
      Question(
        id: 3,
        categoria: 'Dominio de una segunda lengua',
        nroPregunta: 3,
        aspecto: 'Formativo',
        enunciado: 'Promueve el uso de textos u otros materiales en idioma extranjero.',
        esObligatoria: true,
        orden: 3,
      ),
      
      // Pregunta 4
      Question(
        id: 4,
        categoria: 'Planeación y organización del trabajo pedagógico',
        nroPregunta: 4,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Presenta el plan de curso y explica su importancia para la formación profesional de los estudiantes.',
        esObligatoria: true,
        orden: 4,
      ),
      
      // Pregunta 5
      Question(
        id: 5,
        categoria: 'Manejo de estrategias didácticas para el aprendizaje',
        nroPregunta: 5,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Explica con claridad las actividades y los aprendizajes que se pretenden alcanzar.',
        esObligatoria: true,
        orden: 5,
      ),
      
      // Pregunta 6
      Question(
        id: 6,
        categoria: 'Gestión de TIC y Recursos para el aprendizaje',
        nroPregunta: 6,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Utiliza el aula virtual institucional para compartir recursos y materiales que complementan los procesos de enseñanza y aprendizaje.',
        esObligatoria: true,
        orden: 6,
      ),
      
      // Pregunta 7
      Question(
        id: 7,
        categoria: 'Evaluación del aprendizaje',
        nroPregunta: 7,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Realiza evaluaciones coherentes con los contenidos desarrollados en clase y con los aprendizajes esperados.',
        esObligatoria: true,
        orden: 7,
      ),
      
      // Pregunta 8
      Question(
        id: 8,
        categoria: 'Evaluación del aprendizaje',
        nroPregunta: 8,
        aspecto: 'Comunicación',
        enunciado: 'Escribe recomendaciones públicas y privadas en el aula virtual del curso a partir de los resultados de las evaluaciones para mejorar el proceso de aprendizaje.',
        esObligatoria: true,
        orden: 8,
      ),
      
      // Pregunta 9
      Question(
        id: 9,
        categoria: 'Gestión del aprendizaje autónomo y autoregulado',
        nroPregunta: 9,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Propone actividades de aprendizaje fuera del aula orientadas a preparar o complementar los contenidos del curso.',
        esObligatoria: true,
        orden: 9,
      ),
      
      // Pregunta 10
      Question(
        id: 10,
        categoria: 'Gestión de un clima favorable para el desarrollo del aprendizaje',
        nroPregunta: 10,
        aspecto: 'Comunicación',
        enunciado: 'Establece normas y acuerdos para que exista un clima de respeto mutuo.',
        esObligatoria: true,
        orden: 10,
      ),
      
      // Pregunta 11
      Question(
        id: 11,
        categoria: 'Comunicación asertiva',
        nroPregunta: 11,
        aspecto: 'Comunicación',
        enunciado: 'Se expresa con claridad, coherencia y precisión.',
        esObligatoria: true,
        orden: 11,
      ),
      
      // Pregunta 12
      Question(
        id: 12,
        categoria: 'Observancia de los principios institucionales',
        nroPregunta: 12,
        aspecto: 'Ético - Social',
        enunciado: 'Comienza y termina las clases a la hora prevista.',
        esObligatoria: true,
        orden: 12,
      ),
      
      // Pregunta 13
      Question(
        id: 13,
        categoria: 'Respeto, buen trato, trabajo en Equipo',
        nroPregunta: 13,
        aspecto: 'Ético - Social',
        enunciado: 'Inspira respeto y confiabilidad en su desempeño docente.',
        esObligatoria: true,
        orden: 13,
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
}
