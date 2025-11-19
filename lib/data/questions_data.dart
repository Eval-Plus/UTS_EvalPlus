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
        categoria: 'Competencia Disciplinaria',
        nroPregunta: 1,
        aspecto: 'Formativo',
        enunciado: 'Demuestra dominio y actualización en la presentación de los temas del curso.',
      ),
      
      // Pregunta 2
      Question(
        categoria: 'Conocimiento y dominio de la materia',
        nroPregunta: 2,
        aspecto: 'Formativo',
        enunciado: 'Orienta de manera clara los conceptos y teorias del curso.',
      ),
      
      // Pregunta 3
      Question(
        categoria: 'Dominio de una segunda lengua',
        nroPregunta: 3,
        aspecto: 'Formativo',
        enunciado: 'Promueve el uso de textos u otros materiales en idioma extranjero.',
      ),
      
      // Pregunta 4
      Question(
        categoria: 'Planeación y organización del trabajo pedagógico',
        nroPregunta: 4,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Presenta el plan de curso y explica su importancia para la formación profesional de los estudiantes.',
      ),
      
      // Pregunta 5
      Question(
        categoria: 'Manejo de estrategias didácticas para el aprendizaje',
        nroPregunta: 5,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Explica con claridad las actividades y los aprendizajes que se pretenden alcanzar.',
      ),
      
      // Pregunta 6
      Question(
        categoria: 'Gestión de TIC y Recursos para el aprendizaje',
        nroPregunta: 6,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Utiliza el aula virtual institucional para compartir recursos y materiales que complementan los procesos de enseñanza y aprendizaje.',
      ),
      
      // Pregunta 7
      Question(
        categoria: 'Evaluación del aprendizaje',
        nroPregunta: 7,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Realiza evaluaciones coherentes con los contenidos desarrollados en clase y con los aprendizajes esperados.',
      ),
      
      // Pregunta 8
      Question(
        categoria: 'Evaluación del aprendizaje',
        nroPregunta: 8,
        aspecto: 'Comunicación',
        enunciado: 'Escribe recomendaciones públicas y privadas en el aula virtual del curso a partir de los resultados de las evaluaciones para mejorar el proceso de aprendizaje.',
      ),
      
      // Pregunta 9
      Question(
        categoria: 'Gestión del aprendizaje autónomo y autoregulado',
        nroPregunta: 9,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Propone actividades de aprendizaje fuera del aula orientadas a preparar o complementar los contenidos del curso.',
      ),
      
      // Pregunta 10
      Question(
        categoria: 'Gestión de un clima favorable para el desarrollo del aprendizaje',
        nroPregunta: 10,
        aspecto: 'Comunicación',
        enunciado: 'Establece normas y acuerdos para que exista un clima de respeto mutuo.',
      ),
      
      // Pregunta 11
      Question(
        categoria: 'Comunicación asertiva',
        nroPregunta: 11,
        aspecto: 'Comunicación',
        enunciado: 'Se expresa con claridad, coherencia y precisión.',
      ),
      
      // Pregunta 12
      Question(
        categoria: 'Observancia de los principios institucionales',
        nroPregunta: 12,
        aspecto: 'Ético - Social',
        enunciado: 'Comienza y termina las clases a la hora prevista.',
      ),
      
      // Pregunta 13
      Question(
        categoria: 'Respeto, buen trato, trabajo en Equipo',
        nroPregunta: 13,
        aspecto: 'Ético - Social',
        enunciado: 'Inspira respeto y confiabilidad en su desempeño docente.',
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
