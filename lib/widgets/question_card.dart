import 'package:flutter/material.dart';
import 'package:eval_plus/hooks/questions_data.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final Function(String) onAnswerChanged;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerChanged,
  });

  static const List<Map<String, String>> _options = [
    {'value': 'N', 'label': 'Nunca'},
    {'value': 'CN', 'label': 'Casi Nunca'},
    {'value': 'AV', 'label': 'Algunas Veces'},
    {'value': 'CS', 'label': 'Casi Siempre'},
    {'value': 'S', 'label': 'Siempre'},
  ];

  Color _getAspectColor(String aspecto) {
    switch (aspecto.toLowerCase()) {
      case 'ético - social':
      case 'etico - social':
        return const Color(0xFF4CAF50); // Verde
      case 'académico':
      case 'academico':
        return const Color(0xFF2196F3); // Azul
      case 'pedagógico':
      case 'pedagogico':
        return const Color(0xFFFF9800); // Naranja
      default:
        return const Color(0xFF003C43); // Color por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspectColor = _getAspectColor(question.aspecto);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedAnswer != null
              ? aspectColor.withOpacity(0.3)
              : Colors.grey[200]!,
          width: selectedAnswer != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con número y aspecto
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: aspectColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pregunta ${question.nroPregunta}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: aspectColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      question.aspecto,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (selectedAnswer != null)
                  Icon(
                    Icons.check_circle,
                    color: aspectColor,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Categoría
            Text(
              question.categoria,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            
            // Enunciado
            Text(
              question.enunciado,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF003C43),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Divider
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 16),
            
            // Opciones de respuesta
            ..._options.map((option) => _buildOptionTile(
                  option['value']!,
                  option['label']!,
                  aspectColor,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String value, String label, Color accentColor) {
    final isSelected = selectedAnswer == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onAnswerChanged(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button personalizado
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? accentColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Valor corto
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? accentColor : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // Label completo
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? const Color(0xFF003C43)
                        : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
