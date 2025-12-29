import 'package:flutter/material.dart';
import 'package:eval_plus/models/teacher_evaluation_model.dart';

/// Modal para mostrar comentarios anónimos de una evaluación
class CommentsModal extends StatefulWidget {
  final TeacherEvaluationModel evaluation;

  const CommentsModal({
    super.key,
    required this.evaluation,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  // 📊 Datos quemados para diseño
  final List<Map<String, dynamic>> _allComments = [
    {
      'id': 1,
      'text': 'Excelente profesor, explica muy bien los conceptos y siempre está dispuesto a resolver dudas. Las clases son dinámicas y se nota su preparación.',
      'date': '2024-12-15',
      'sentiment': 'positive',
    },
    {
      'id': 2,
      'text': 'Sería bueno que dejara más ejercicios prácticos para reforzar lo visto en clase. En general, buen profesor.',
      'date': '2024-12-16',
      'sentiment': 'neutral',
    },
    {
      'id': 3,
      'text': 'Me gusta su metodología, pero a veces va muy rápido con los temas. Sugiero dedicar más tiempo a los conceptos difíciles.',
      'date': '2024-12-17',
      'sentiment': 'neutral',
    },
    {
      'id': 4,
      'text': 'Uno de los mejores profesores que he tenido. Muy claro en sus explicaciones y siempre disponible para ayudar.',
      'date': '2024-12-18',
      'sentiment': 'positive',
    },
    {
      'id': 5,
      'text': 'Las evaluaciones son justas y los temas están bien organizados. Se nota que le apasiona enseñar.',
      'date': '2024-12-19',
      'sentiment': 'positive',
    },
    {
      'id': 6,
      'text': 'Las clases son interesantes pero a veces falta material de apoyo para estudiar en casa.',
      'date': '2024-12-20',
      'sentiment': 'neutral',
    },
    {
      'id': 7,
      'text': 'Excelente dominio del tema. Sus ejemplos prácticos ayudan mucho a entender la teoría.',
      'date': '2024-12-21',
      'sentiment': 'positive',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra comentarios según búsqueda y filtro
  List<Map<String, dynamic>> get _filteredComments {
    return _allComments.where((comment) {
      final matchesFilter = _selectedFilter == 'all' || 
                           comment['sentiment'] == _selectedFilter;
      final matchesSearch = (comment['text'] as String)
          .toLowerCase()
          .contains(_searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  /// Calcula estadísticas
  Map<String, int> get _stats {
    return {
      'total': _allComments.length,
      'positive': _allComments.where((c) => c['sentiment'] == 'positive').length,
      'neutral': _allComments.where((c) => c['sentiment'] == 'neutral').length,
      'negative': _allComments.where((c) => c['sentiment'] == 'negative').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildStatsCard(),
                      const SizedBox(height: 20),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 16),
                      _buildAnonymityNotice(),
                      const SizedBox(height: 20),
                      _buildCommentsList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8BC34A),
            Color(0xFF689F38),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8BC34A).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.comment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comentarios Anónimos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.evaluation.subjectName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8BC34A), Color(0xFF7CB342)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.evaluation.subjectCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8BC34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.evaluation.subjectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.evaluation.careerName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Color(0xFF8BC34A),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total',
                  value: '${_stats['total']}',
                  color: Colors.grey.shade600,
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Positivos',
                  value: '${_stats['positive']}',
                  color: Colors.green.shade700,
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade50,
                      Colors.green.shade100,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Neutrales',
                  value: '${_stats['neutral']}',
                  color: Colors.blue.shade700,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Negativos',
                  value: '${_stats['negative']}',
                  color: Colors.red.shade700,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade50,
                      Colors.red.shade100,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar en comentarios...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8BC34A)),
              filled: true,
              fillColor: Colors.white,
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
                  color: Color(0xFF8BC34A),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.filter_list, color: Color(0xFF8BC34A)),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('Todos'),
                ),
                DropdownMenuItem(
                  value: 'positive',
                  child: Text('Positivos'),
                ),
                DropdownMenuItem(
                  value: 'neutral',
                  child: Text('Neutrales'),
                ),
                DropdownMenuItem(
                  value: 'negative',
                  child: Text('Negativos'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymityNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_rounded,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los comentarios son completamente anónimos para proteger la privacidad de los estudiantes.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    final comments = _filteredComments;

    if (comments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...comments.map((comment) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _CommentCard(comment: comment),
        )),
        
        if (comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Mostrando ${comments.length} de ${_allComments.length} comentarios',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron comentarios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchTerm.isNotEmpty
                ? 'Intenta con otros términos de búsqueda'
                : 'Los comentarios aparecerán aquí cuando los estudiantes completen sus evaluaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card individual de comentario
class _CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;

  const _CommentCard({required this.comment});

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green.shade700;
      case 'neutral':
        return Colors.blue.shade700;
      case 'negative':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getSentimentBgColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green.shade100;
      case 'neutral':
        return Colors.blue.shade100;
      case 'negative':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getSentimentBorderColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green.shade300;
      case 'neutral':
        return Colors.blue.shade300;
      case 'negative':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  String _getSentimentLabel(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return '😊 Positivo';
      case 'neutral':
        return '😐 Neutral';
      case 'negative':
        return '😕 Negativo';
      default:
        return '😐 Neutral';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentiment = comment['sentiment'] as String;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8BC34A), Color(0xFF7CB342)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8BC34A).withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#${comment['id']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSentimentBgColor(sentiment),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getSentimentBorderColor(sentiment),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getSentimentLabel(sentiment),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getSentimentColor(sentiment),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(comment['date'] as String),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment['text'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
