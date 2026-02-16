import 'package:flutter/material.dart';

// Config

// Models
import 'package:eval_plus/models/question_model.dart';
import 'package:eval_plus/models/subject_model.dart';

// Services
import 'package:eval_plus/services/questions_service.dart';
import 'package:eval_plus/services/evaluations_service.dart';
import 'package:eval_plus/services/subjects_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';
import 'package:eval_plus/services/api/student_evaluation_api_service.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';
import 'package:eval_plus/widgets/evaluation/question_card.dart';

class EvaluationModal extends StatefulWidget {
  final SubjectModel subject;
  final VoidCallback? onEvaluationCompleted; // 🆕 Callback opcional

  const EvaluationModal({
    super.key,
    required this.subject,
    this.onEvaluationCompleted, // 🆕
  });

  @override
  State<EvaluationModal> createState() => _EvaluationModalState();
}

class _EvaluationModalState extends State<EvaluationModal> {
  final Map<int, String> _answers = {};
  final TextEditingController _commentController = TextEditingController();
  final _questionsService = QuestionsService();
  
  // 🔧 Servicios singleton
  late final EvaluationsService _evaluationsService;
  late final SubjectsService _subjectsService;
  
  bool _isSubmitting = false;
  bool _isInitializing = true;
  bool _hasError = false;
  String? _errorMessage;
  
  late Future<List<QuestionModel>> _questionsFuture;
  
  int? _studentEvaluationId;

  static const Map<String, int> _responseValueMap = {
    'N': 1,  // Nunca
    'CN': 2, // Casi nunca
    'AV': 3, // Algunas veces
    'CS': 4, // Casi siempre
    'S': 5,  // Siempre
  };

  @override
  void initState() {
    super.initState();
    
    // 🔧 Obtener instancias singleton
    _evaluationsService = EvaluationsService();
    _subjectsService = SubjectsService();
    
    _questionsFuture = _questionsService.getAllQuestions();
    _initializeEvaluation();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Inicializa la evaluación llamando al endpoint /start
  Future<void> _initializeEvaluation() async {
    try {
      debugPrint('🎬 Inicializando evaluación...');
      
      if (widget.subject.evaluationId == null) {
        throw Exception('Esta materia no tiene una evaluación activa');
      }

      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      final response = await StudentEvaluationApiService.startEvaluation(
        token: token,
        evaluationId: widget.subject.evaluationId!,
      );

      if (response == null) {
        throw Exception('No se pudo iniciar la evaluación');
      }

      setState(() {
        _studentEvaluationId = response.id;
        _isInitializing = false;
        _hasError = false;
      });

      final isExisting = response.evaluation == null;
      
      debugPrint('✅ Evaluación inicializada correctamente');
      debugPrint('   ${isExisting ? '🔄 Continuando' : '🆕 Nueva'} evaluación');
      debugPrint('   Student Evaluation ID: $_studentEvaluationId');
      
    } catch (e) {
      debugPrint('💥 Error inicializando evaluación: $e');
      
      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorAndClose(_errorMessage!);
        });
      }
    }
  }

  void _showErrorAndClose(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MessageDialogWidget.error(
          title: 'No se puede iniciar la evaluación',
          message: message,
          onAccept: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
          acceptButtonText: 'Entendido',
        );
      },
    );
  }

  void _onAnswerChanged(int questionNumber, String answer) {
    setState(() {
      _answers[questionNumber] = answer;
    });
  }

  bool _areAllQuestionsAnswered(int totalQuestions) {
    return _answers.length == totalQuestions;
  }

  Future<void> _submitEvaluation(List<QuestionModel> questions) async {
    if (!_areAllQuestionsAnswered(questions.length)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return MessageDialogWidget.info(
            title: 'Formulario incompleto',
            message: 'Por favor, responde todas las preguntas obligatorias antes de enviar la evaluación.',
            onContinue: () {
              Navigator.of(context).pop();
            },
            continueButtonText: 'Entendido',
          );
        },
      );
      return;
    }

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.warning(
          title: '¿Enviar evaluación?',
          message: 'Una vez enviada, no podrás modificar tus respuestas. ¿Estás seguro de que deseas continuar?',
          onAccept: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          acceptButtonText: 'Sí, enviar',
          cancelButtonText: 'Cancelar',
        );
      },
    );

    if (shouldSubmit != true) {
      return;
    }

    if (_studentEvaluationId == null) {
      _showErrorDialog('Error interno: No se encontró el ID de la evaluación');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final List<Map<String, dynamic>> responses = _answers.entries.map((entry) {
        final questionId = entry.key;
        final answerCode = entry.value;
        final numericValue = _responseValueMap[answerCode] ?? 3;

        return {
          'questionId': questionId,
          'valorNumerico': numericValue,
        };
      }).toList();

      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      final comentario = _commentController.text.trim().isEmpty 
          ? null 
          : _commentController.text.trim();

      debugPrint('📤 Enviando evaluación...');
      debugPrint('   Student Evaluation ID: $_studentEvaluationId');
      debugPrint('   Total respuestas: ${responses.length}');

      final success = await StudentEvaluationApiService.submitEvaluation(
        token: token,
        studentEvaluationId: _studentEvaluationId!,
        responses: responses,
        comentario: comentario,
      );

      if (!success) {
        throw Exception('No se pudo enviar la evaluación');
      }

      // 🆕 INVALIDAR CACHES después de enviar exitosamente
      debugPrint('🔄 Invalidando caches...');
      _evaluationsService.invalidateCache();
      _subjectsService.invalidateCache();

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Cerrar el modal
        Navigator.of(context).pop();

        // 🆕 Ejecutar callback si existe
        widget.onEvaluationCompleted?.call();

        // Mostrar mensaje de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MessageDialogWidget.success(
              title: '¡Evaluación enviada!',
              message: 'Tu evaluación ha sido registrada exitosamente. Gracias por tu participación.',
              onContinue: () {
                Navigator.of(context).pop();
              },
              continueButtonText: 'Aceptar',
            );
          },
        );
      }
    } catch (e) {
      debugPrint('💥 Error enviando evaluación: $e');
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        _showErrorDialog(
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.error(
          title: 'Error al enviar',
          message: message,
          onAccept: () {
            Navigator.of(context).pop();
          },
          acceptButtonText: 'Entendido',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isInitializing
                  ? _buildLoadingState()
                  : _hasError
                      ? _buildErrorState()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subject.professorName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFCAD225),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Iniciando evaluación...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor espera un momento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'No se pudo iniciar la evaluación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<List<QuestionModel>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFCAD225),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar preguntas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final questions = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntroCard(),
              const SizedBox(height: 24),
              
              ...questions.map((question) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: QuestionCard(
                      question: question,
                      selectedAnswer: _answers[question.nroPregunta],
                      onAnswerChanged: (answer) =>
                          _onAnswerChanged(question.nroPregunta, answer),
                    ),
                  )),
              
              const SizedBox(height: 8),
              _buildCommentSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(questions),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCAD225).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFF1A1A1A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Evaluación Docente',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tu opinión es importante para mejorar la calidad educativa. Por favor, responde todas las preguntas con sinceridad.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFCAD225).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFA8B820).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Todas las preguntas son obligatorias',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.comment_outlined,
                color: Color(0xFF1A1A1A),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Comentarios adicionales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(Opcional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Comparte tus comentarios o sugerencias...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFCAD225),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(List<QuestionModel> questions) {
    final allAnswered = _areAllQuestionsAnswered(questions.length);

    return ElevatedButton(
      onPressed: (_isSubmitting || !allAnswered)
          ? null
          : () => _submitEvaluation(questions),
      style: ElevatedButton.styleFrom(
        backgroundColor: allAnswered
            ? const Color(0xFFCAD225)
            : Colors.grey[400],
        foregroundColor: allAnswered
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: allAnswered ? 4 : 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send, size: 20),
                const SizedBox(width: 8),
                Text(
                  allAnswered
                      ? 'Enviar Evaluación'
                      : 'Completa todas las preguntas',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
