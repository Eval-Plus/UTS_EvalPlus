import 'package:flutter/material.dart';
import 'dart:convert';

// Config
import 'package:eval_plus/config/constants.dart';

// Models
import 'package:eval_plus/data/questions_data.dart';
import 'package:eval_plus/data/subjects_data.dart';

// Services
import 'package:eval_plus/services/storage/auth_storage_service.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';
import 'package:eval_plus/widgets/evaluation/question_card.dart';

class EvaluationModal extends StatefulWidget {
  final Subject subject;

  const EvaluationModal({
    super.key,
    required this.subject,
  });

  @override
  State<EvaluationModal> createState() => _EvaluationModalState();
}

class _EvaluationModalState extends State<EvaluationModal> {
  final Map<int, String> _answers = {};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  late Future<List<Question>> _questionsFuture;

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
    // Cachear el Future para que solo se ejecute una vez
    _questionsFuture = QuestionsDataService.getAllQuestions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onAnswerChanged(int questionNumber, String answer) {
    setState(() {
      _answers[questionNumber] = answer;
    });
  }

  bool _areAllQuestionsAnswered(int totalQuestions) {
    return _answers.length == totalQuestions;
  }

  Future<void> _submitEvaluation(List<Question> questions) async {
    // Validación: verificar si todas las preguntas están respondidas
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

    // Confirmación: preguntar al usuario si está seguro de enviar
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.warning(
          title: '¿Enviar evaluación?',
          message: 'Una vez enviada, no podrás modificar tus respuestas. ¿Estás seguro de que deseas continuar?',
          onAccept: () {
            Navigator.of(context).pop(true); // Usuario confirma
          },
          onCancel: () {
            Navigator.of(context).pop(false); // Usuario cancela
          },
          acceptButtonText: 'Sí, enviar',
          cancelButtonText: 'Cancelar',
        );
      },
    );

    // Si el usuario canceló, no hacer nada
    if (shouldSubmit != true) {
      return;
    }

    // Mostrar indicador de carga
    setState(() {
      _isSubmitting = true;
    });

    try {
      // CONVERTIR RESPUESTAS AL FORMATO DEL BACKEND
      final List<Map<String, dynamic>> responses = _answers.entries.map((entry) {
        final questionId = entry.key;
        final answerCode = entry.value; // "S", "CS", "AV", etc.
        final numericValue = _responseValueMap[answerCode] ?? 3; // Default a 3 si no encuentra

        return {
          'questionId': questionId,
          'valorNumerico': numericValue,
        };
      }).toList();

      // Obtener token
      final token = await AuthStorageService.getToken();
      
      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      // Preparar datos para enviar
      final evaluationData = {
        'responses': responses,
        'comentario': _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
      };

      debugPrint('📤 Enviando evaluación...');
      debugPrint('Datos: ${jsonEncode(evaluationData)}');

      // TODO: Implementar envío real a API
      // Endpoint: POST /api/student-evaluations/:id/submit
      /*
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/student-evaluations/${widget.subject.id}/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(evaluationData),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Error desconocido');
      }
      */

      // Simular envío exitoso (remover cuando implementes el API real)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Cerrar el modal de evaluación
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito con el MessageDialog
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
      // Manejar errores
      debugPrint('💥 Error enviando evaluación: $e');
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MessageDialogWidget.error(
              title: 'Error al enviar',
              message: 'Ocurrió un error al enviar tu evaluación. Por favor, intenta nuevamente.',
              onAccept: () {
                Navigator.of(context).pop();
              },
              acceptButtonText: 'Entendido',
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            // Header personalizado
            _buildHeader(context),
            // Contenido con scroll
            Expanded(
              child: FutureBuilder<List<Question>>(
                future: _questionsFuture, // Usar el Future cacheado
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

                  return _buildContent(questions);
                },
              ),
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
                onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildContent(List<Question> questions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título y descripción
          _buildIntroCard(),
          const SizedBox(height: 24),
          
          // Preguntas
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
          
          // Sección de comentario
          _buildCommentSection(),
          const SizedBox(height: 24),
          
          // Botón de envío
          _buildSubmitButton(questions),
          const SizedBox(height: 40),
        ],
      ),
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
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: const Color(0xFF1A1A1A),
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

  Widget _buildSubmitButton(List<Question> questions) {
    final allAnswered = _areAllQuestionsAnswered(questions.length);

    return ElevatedButton(
      onPressed: _isSubmitting
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
