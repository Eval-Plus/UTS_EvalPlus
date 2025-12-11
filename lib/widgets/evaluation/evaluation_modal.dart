import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Config
import 'package:eval_plus/config/constants.dart';

// Models
import 'package:eval_plus/models/question_model.dart';
import 'package:eval_plus/models/subject_model.dart';

// Services
import 'package:eval_plus/services/questions_service.dart';

// Controllers
import 'package:eval_plus/controllers/evaluation_state_controller.dart';

// Widgets
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';
import 'package:eval_plus/widgets/evaluation/question_card.dart';

class EvaluationModal extends StatefulWidget {
  final SubjectModel subject;

  const EvaluationModal({
    super.key,
    required this.subject,
  });

  @override
  State<EvaluationModal> createState() => _EvaluationModalState();
}

class _EvaluationModalState extends State<EvaluationModal> {
  final TextEditingController _commentController = TextEditingController();
  final _questionsService = QuestionsService();
  
  late Future<List<QuestionModel>> _questionsFuture;
  late EvaluationStateController _evalController;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _questionsService.getAllQuestions();
    
    // Crear el controller y vincularlo al widget
    _evalController = EvaluationStateController();
    
    // Inicializar la evaluación
    _initializeEvaluation();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _evalController.dispose();
    super.dispose();
  }

  Future<void> _initializeEvaluation() async {
    if (widget.subject.evaluationId == null) {
      _showErrorAndClose('Esta materia no tiene una evaluación activa');
      return;
    }

    final success = await _evalController.initialize(widget.subject.evaluationId!);
    
    if (!success && mounted) {
      _showErrorAndClose(_evalController.errorMessage ?? 'Error al inicializar la evaluación');
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

  Future<void> _handleSubmit(List<QuestionModel> questions) async {
    // Validación: todas las preguntas respondidas
    if (!_evalController.areAllQuestionsAnswered(questions.length)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return MessageDialogWidget.info(
            title: 'Formulario incompleto',
            message: 'Por favor, responde todas las preguntas obligatorias antes de enviar la evaluación.',
            onContinue: () => Navigator.of(context).pop(),
            continueButtonText: 'Entendido',
          );
        },
      );
      return;
    }

    // Confirmación
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.warning(
          title: '¿Enviar evaluación?',
          message: 'Una vez enviada, no podrás modificar tus respuestas. ¿Estás seguro de que deseas continuar?',
          onAccept: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
          acceptButtonText: 'Sí, enviar',
          cancelButtonText: 'Cancelar',
        );
      },
    );

    if (shouldSubmit != true) return;

    // Actualizar comentario en el controller
    _evalController.updateComment(_commentController.text);

    // Enviar evaluación
    final success = await _evalController.submitEvaluation();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return MessageDialogWidget.success(
            title: '¡Evaluación enviada!',
            message: 'Tu evaluación ha sido registrada exitosamente. Gracias por tu participación.',
            onContinue: () => Navigator.of(context).pop(),
            continueButtonText: 'Aceptar',
          );
        },
      );
    } else {
      _showErrorDialog(_evalController.errorMessage ?? 'Error al enviar la evaluación');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MessageDialogWidget.error(
          title: 'Error al enviar',
          message: message,
          onAccept: () => Navigator.of(context).pop(),
          acceptButtonText: 'Entendido',
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Si hay cambios sin guardar, preguntar antes de cerrar
    if (_evalController.hasUnsavedChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => MessageDialogWidget.warning(
          title: 'Tienes cambios sin guardar',
          message: '¿Deseas guardar tu progreso antes de salir?',
          onAccept: () async {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          acceptButtonText: 'Guardar y salir',
          cancelButtonText: 'Salir sin guardar',
        ),
      );

      if (shouldSave == true) {
        await _evalController.saveProgress();
      }
    }
    
    _evalController.clear();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _evalController,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Dialog.fullscreen(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<EvaluationStateController>(
      builder: (context, controller, _) {
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                        onPressed: controller.isSubmitting ? null : () => Navigator.of(context).pop(),
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
                      // Indicador de guardado
                      if (controller.isSaving)
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Guardando...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      else if (controller.lastSavedAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Guardado',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Barra de progreso
                _buildProgressBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return FutureBuilder<List<QuestionModel>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final totalQuestions = snapshot.data!.length;
        
        return Consumer<EvaluationStateController>(
          builder: (context, controller, _) {
            final progress = controller.getProgress(totalQuestions);
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.answeredCount} de $totalQuestions preguntas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFCAD225),
                  ),
                  minHeight: 4,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<EvaluationStateController>(
      builder: (context, controller, _) {
        if (controller.isInitializing) {
          return _buildLoadingState();
        }

        if (controller.hasError) {
          return _buildErrorState(controller.errorMessage ?? 'Error desconocido');
        }

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
                          selectedAnswer: controller.answers[question.nroPregunta],
                          onAnswerChanged: (answer) {
                            controller.updateAnswer(question.nroPregunta, answer);
                          },
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
      },
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

  Widget _buildErrorState(String errorMessage) {
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
              errorMessage,
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
                  Icons.cloud_done,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tus respuestas se guardan automáticamente cada 30 segundos',
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
                color: Color(0xFF1
