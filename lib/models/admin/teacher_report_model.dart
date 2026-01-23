/// Modelos para el reporte completo del docente
/// Ubicación: lib/models/teacher_report_model.dart

// ==============================================
// RESPUESTA DE ANÁLISIS DE RESPUESTAS
// ==============================================

class TeacherResponsesReport {
  final int teacherId;
  final String periodo;
  final int totalEvaluations;
  final int completedEvaluations;
  final int pendingEvaluations;
  final double completionRate;
  final double averageScore;
  final List<QuestionResponseData> questions;

  TeacherResponsesReport({
    required this.teacherId,
    required this.periodo,
    required this.totalEvaluations,
    required this.completedEvaluations,
    required this.pendingEvaluations,
    required this.completionRate,
    required this.averageScore,
    required this.questions,
  });

  factory TeacherResponsesReport.fromJson(Map<String, dynamic> json) {
    return TeacherResponsesReport(
      teacherId: json['teacherId'] as int,
      periodo: json['periodo'] as String,
      totalEvaluations: json['totalEvaluations'] as int,
      completedEvaluations: json['completedEvaluations'] as int,
      pendingEvaluations: json['pendingEvaluations'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      averageScore: (json['averageScore'] as num).toDouble(),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuestionResponseData.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'periodo': periodo,
      'totalEvaluations': totalEvaluations,
      'completedEvaluations': completedEvaluations,
      'pendingEvaluations': pendingEvaluations,
      'completionRate': completionRate,
      'averageScore': averageScore,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

// ==============================================
// DATOS DE PREGUNTA CON RESPUESTAS
// ==============================================

class QuestionResponseData {
  final int id;
  final int number;
  final String text;
  final String category;
  final String aspect;
  final int order;
  final Map<int, int> responses;
  final int totalResponses;
  final double average;

  QuestionResponseData({
    required this.id,
    required this.number,
    required this.text,
    required this.category,
    required this.aspect,
    required this.order,
    required this.responses,
    required this.totalResponses,
    required this.average,
  });

  factory QuestionResponseData.fromJson(Map<String, dynamic> json) {
    // Convertir el mapa de respuestas de String keys a int keys
    final responsesMap = <int, int>{};
    final responsesJson = json['responses'] as Map<String, dynamic>;
    
    responsesJson.forEach((key, value) {
      responsesMap[int.parse(key)] = value as int;
    });

    return QuestionResponseData(
      id: json['id'] as int,
      number: json['number'] as int,
      text: json['text'] as String,
      category: json['category'] as String,
      aspect: json['aspect'] as String,
      order: json['order'] as int,
      responses: responsesMap,
      totalResponses: json['totalResponses'] as int,
      average: (json['average'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir el mapa de respuestas de int keys a String keys para JSON
    final responsesJson = <String, int>{};
    responses.forEach((key, value) {
      responsesJson[key.toString()] = value;
    });

    return {
      'id': id,
      'number': number,
      'text': text,
      'category': category,
      'aspect': aspect,
      'order': order,
      'responses': responsesJson,
      'totalResponses': totalResponses,
      'average': average,
    };
  }

  /// Obtiene el porcentaje para un valor específico
  double getPercentage(int value) {
    if (totalResponses == 0) return 0;
    final count = responses[value] ?? 0;
    return (count / totalResponses) * 100;
  }
}
