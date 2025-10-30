import 'package:flutter/material.dart';
import 'package:eval_plus/hooks/questions_data.dart';
import 'package:eval_plus/hooks/subjects_data.dart';
import 'package:eval_plus/widgets/question_card.dart';

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
    if (!_areAllQuestionsAnswered(questions.length)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor responde todas las preguntas'),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simular envío a API
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implementar envío real a API
    /*
    final evaluationData = {
      'subjectCode': widget.subject.codigo,
      'professorName': widget.subject.professorName,
      'answers': _answers,
      'comment': _commentController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };
    */

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Evaluación enviada exitosamente!'),
          backgroundColor: const Color(0xFF003C43),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
                        color: Color(0xFF003C43),
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
                icon: const Icon(Icons.close, color: Color(0xFF003C43)),
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
                        color: Color(0xFF003C43),
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
                  color: const Color(0xFF003C43).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFF003C43),
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
                    color: Color(0xFF003C43),
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
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Todas las preguntas son obligatorias',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
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
                color: Color(0xFF003C43),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Comentarios adicionales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003C43),
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
                  color: Color(0xFF003C43),
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
            ? const Color(0xFF003C43)
            : Colors.grey[400],
        foregroundColor: Colors.white,
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
