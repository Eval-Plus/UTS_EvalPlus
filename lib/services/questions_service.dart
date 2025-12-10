import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:eval_plus/config/constants.dart';
import 'package:eval_plus/models/question_model.dart';

/// Servicio UNIFICADO para manejar preguntas
/// Combina lógica de API + fallback + caching
class QuestionsService {
  // ==================== SINGLETON ====================
  
  static final QuestionsService _instance = QuestionsService._internal();
  factory QuestionsService() => _instance;
  QuestionsService._internal();

  // Cache en memoria
  List<QuestionModel>? _cachedQuestions;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 10);

  // ==================== PUBLIC API ====================
  
  /// Obtiene todas las preguntas del formulario
  /// Usa cache si está disponible, sino consulta API
  Future<List<QuestionModel>> getAllQuestions({
    bool forceRefresh = false,
  }) async {
    // Usar cache si es válido
    if (!forceRefresh && _isCacheValid()) {
      debugPrint('⚡ Usando cache de preguntas');
      return _cachedQuestions!;
    }

    try {
      debugPrint('🌐 Consultando API de preguntas...');
      final questions = await _fetchFromApi();

      if (questions != null && questions.isNotEmpty) {
        // Actualizar cache
        _cachedQuestions = questions;
        _lastFetchTime = DateTime.now();
        debugPrint('✅ ${questions.length} preguntas obtenidas');
        return questions;
      }

      // Fallback si API falla
      debugPrint('⚠️ API sin datos, usando fallback');
      return _getFallbackQuestions();
      
    } catch (e) {
      debugPrint('💥 Error obteniendo preguntas: $e');
      
      // Retornar cache si existe, sino fallback
      if (_cachedQuestions != null) {
        debugPrint('📦 Usando cache como fallback');
        return _cachedQuestions!;
      }
      
      return _getFallbackQuestions();
    }
  }

  /// Obtiene preguntas filtradas por categoría
  Future<List<QuestionModel>> getQuestionsByCategory(String categoria) async {
    final allQuestions = await getAllQuestions();
    return allQuestions
        .where((question) => question.categoria == categoria)
        .toList();
  }

  /// Obtiene preguntas filtradas por aspecto
  Future<List<QuestionModel>> getQuestionsByAspect(String aspecto) async {
    final allQuestions = await getAllQuestions();
    return allQuestions
        .where((question) => question.aspecto == aspecto)
        .toList();
  }

  /// Limpia el cache
  void clearCache() {
    _cachedQuestions = null;
    _lastFetchTime = null;
    debugPrint('🗑️ Cache de preguntas limpiado');
  }

  // ==================== PRIVATE METHODS ====================
  
  /// Verifica si el cache es válido
  bool _isCacheValid() {
    if (_cachedQuestions == null || _lastFetchTime == null) {
      return false;
    }
    
    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  /// Consulta real a la API
  Future<List<QuestionModel>?> _fetchFromApi() async {
    try {
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
              .map((json) => QuestionModel.fromJson(json))
              .where((question) => question.activo)
              .toList();
          
          // Ordenar por el campo 'orden'
          questionsList.sort((a, b) => a.orden.compareTo(b.orden));
          
          return questionsList;
        }
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️ No se encontraron preguntas');
        return [];
      }

      return null;
    } catch (e) {
      debugPrint('💥 Error en _fetchFromApi: $e');
      return null;
    }
  }

  /// Datos de respaldo estáticos
  Future<List<QuestionModel>> _getFallbackQuestions() async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      QuestionModel(
        id: 1,
        templateId: 1,
        categoria: 'Competencia Disciplinaria',
        nroPregunta: 1,
        aspecto: 'Formativo',
        enunciado: 'Demuestra dominio y actualización en la presentación de los temas del curso.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 1,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 2,
        templateId: 1,
        categoria: 'Conocimiento y dominio de la materia',
        nroPregunta: 2,
        aspecto: 'Formativo',
        enunciado: 'Orienta de manera clara los conceptos y teorias del curso.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 2,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 3,
        templateId: 1,
        categoria: 'Dominio de una segunda lengua',
        nroPregunta: 3,
        aspecto: 'Formativo',
        enunciado: 'Promueve el uso de textos u otros materiales en idioma extranjero.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 3,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 4,
        templateId: 1,
        categoria: 'Planeación y organización del trabajo pedagógico',
        nroPregunta: 4,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Presenta el plan de curso y explica su importancia para la formación profesional de los estudiantes.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 4,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 5,
        templateId: 1,
        categoria: 'Manejo de estrategias didácticas para el aprendizaje',
        nroPregunta: 5,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Explica con claridad las actividades y los aprendizajes que se pretenden alcanzar.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 5,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 6,
        templateId: 1,
        categoria: 'Gestión de TIC y Recursos para el aprendizaje',
        nroPregunta: 6,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Utiliza el aula virtual institucional para compartir recursos y materiales que complementan los procesos de enseñanza y aprendizaje.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 6,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 7,
        templateId: 1,
        categoria: 'Evaluación del aprendizaje',
        nroPregunta: 7,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Realiza evaluaciones coherentes con los contenidos desarrollados en clase y con los aprendizajes esperados.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 7,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 8,
        templateId: 1,
        categoria: 'Evaluación del aprendizaje',
        nroPregunta: 8,
        aspecto: 'Comunicación',
        enunciado: 'Escribe recomendaciones públicas y privadas en el aula virtual del curso a partir de los resultados de las evaluaciones para mejorar el proceso de aprendizaje.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 8,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 9,
        templateId: 1,
        categoria: 'Gestión del aprendizaje autónomo y autoregulado',
        nroPregunta: 9,
        aspecto: 'Destrezas para desarrollar el proceso de enseñanza y aprendizaje',
        enunciado: 'Propone actividades de aprendizaje fuera del aula orientadas a preparar o complementar los contenidos del curso.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 9,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 10,
        templateId: 1,
        categoria: 'Gestión de un clima favorable para el desarrollo del aprendizaje',
        nroPregunta: 10,
        aspecto: 'Comunicación',
        enunciado: 'Establece normas y acuerdos para que exista un clima de respeto mutuo.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 10,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 11,
        templateId: 1,
        categoria: 'Comunicación asertiva',
        nroPregunta: 11,
        aspecto: 'Comunicación',
        enunciado: 'Se expresa con claridad, coherencia y precisión.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 11,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 12,
        templateId: 1,
        categoria: 'Observancia de los principios institucionales',
        nroPregunta: 12,
        aspecto: 'Ético - Social',
        enunciado: 'Comienza y termina las clases a la hora prevista.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 12,
        activo: true,
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 13,
        templateId: 1,
        categoria: 'Respeto, buen trato, trabajo en Equipo',
        nroPregunta: 13,
        aspecto: 'Ético - Social',
        enunciado: 'Inspira respeto y confiabilidad en su desempeño docente.',
        tipoRespuesta: 'escala',
        valorMinimo: 1,
        valorMaximo: 5,
        esObligatoria: true,
        orden: 13,
        activo: true,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
