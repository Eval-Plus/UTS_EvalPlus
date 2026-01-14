// lib/models/teacher_analysis_models.dart

/// Modelo genérico de respuesta de la API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : null,
      timestamp: json['timestamp'] as String,
    );
  }
}

/// Respuesta completa del análisis de docentes
class TeachersAnalysisResponse {
  final List<TeacherData> teachers;
  final AnalysisStats stats;
  final String periodo;
  final String generatedAt;

  TeachersAnalysisResponse({
    required this.teachers,
    required this.stats,
    required this.periodo,
    required this.generatedAt,
  });

  factory TeachersAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return TeachersAnalysisResponse(
      teachers: (json['teachers'] as List<dynamic>)
          .map((t) => TeacherData.fromJson(t as Map<String, dynamic>))
          .toList(),
      stats: AnalysisStats.fromJson(json['stats'] as Map<String, dynamic>),
      periodo: json['periodo'] as String,
      generatedAt: json['generatedAt'] as String,
    );
  }
}

/// Estadísticas globales del análisis
class AnalysisStats {
  final int totalTeachers;
  final int totalEvaluations;
  final String avgCompletion;
  final int totalStudents;

  AnalysisStats({
    required this.totalTeachers,
    required this.totalEvaluations,
    required this.avgCompletion,
    required this.totalStudents,
  });

  factory AnalysisStats.fromJson(Map<String, dynamic> json) {
    return AnalysisStats(
      totalTeachers: json['totalTeachers'] as int,
      totalEvaluations: json['totalEvaluations'] as int,
      avgCompletion: json['avgCompletion'].toString(),
      totalStudents: json['totalStudents'] as int,
    );
  }

  // Método helper para obtener el mapa para _buildGlobalStats
  Map<String, dynamic> toStatsMap() {
    return {
      'totalTeachers': totalTeachers,
      'totalEvaluations': totalEvaluations,
      'avgCompletion': avgCompletion,
      'totalStudents': totalStudents,
    };
  }
}

/// Modelo de datos del docente
class TeacherData {
  final int id;
  final String name;
  final String email;
  final String career;
  final String careerName;
  final int totalSubjects;
  final int activeEvaluations;
  final int closedEvaluations;
  final int completionRate;
  final int totalStudents;
  final int completedResponses;
  final int pendingResponses;
  final String lastActivity;
  final List<SubjectData> subjects;
  final double avgRating;
  final String period;

  TeacherData({
    required this.id,
    required this.name,
    required this.email,
    required this.career,
    required this.careerName,
    required this.totalSubjects,
    required this.activeEvaluations,
    required this.closedEvaluations,
    required this.completionRate,
    required this.totalStudents,
    required this.completedResponses,
    required this.pendingResponses,
    required this.lastActivity,
    required this.subjects,
    required this.avgRating,
    required this.period,
  });

  factory TeacherData.fromJson(Map<String, dynamic> json) {
    return TeacherData(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      career: json['career'] as String,
      careerName: json['careerName'] as String,
      totalSubjects: json['totalSubjects'] as int,
      activeEvaluations: json['activeEvaluations'] as int,
      closedEvaluations: json['closedEvaluations'] as int,
      completionRate: json['completionRate'] as int,
      totalStudents: json['totalStudents'] as int,
      completedResponses: json['completedResponses'] as int,
      pendingResponses: json['pendingResponses'] as int,
      lastActivity: json['lastActivity'] as String,
      subjects: (json['subjects'] as List<dynamic>)
          .map((s) => SubjectData.fromJson(s as Map<String, dynamic>))
          .toList(),
      avgRating: ((json['avgRating'] ?? 0) as num).toDouble(),
      period: json['period'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'career': career,
      'careerName': careerName,
      'totalSubjects': totalSubjects,
      'activeEvaluations': activeEvaluations,
      'closedEvaluations': closedEvaluations,
      'completionRate': completionRate,
      'totalStudents': totalStudents,
      'completedResponses': completedResponses,
      'pendingResponses': pendingResponses,
      'lastActivity': lastActivity,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'avgRating': avgRating,
      'period': period,
    };
  }
}

/// Modelo de datos de materia
class SubjectData {
  final String name;
  final String code;
  final int students;
  final int completed;
  final int pending;

  SubjectData({
    required this.name,
    required this.code,
    required this.students,
    required this.completed,
    required this.pending,
  });

  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      name: json['name'] as String,
      code: json['code'] as String,
      students: json['students'] as int,
      completed: json['completed'] as int,
      pending: json['pending'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'students': students,
      'completed': completed,
      'pending': pending,
    };
  }
}

/// Respuesta detallada de un docente específico
class TeacherDetailResponse {
  final TeacherInfo teacher;
  final TeacherSummary summary;
  final List<EvaluationDetail> evaluations;
  final List<SubjectInfo> subjects;
  final String periodo;
  final String generatedAt;

  TeacherDetailResponse({
    required this.teacher,
    required this.summary,
    required this.evaluations,
    required this.subjects,
    required this.periodo,
    required this.generatedAt,
  });

  factory TeacherDetailResponse.fromJson(Map<String, dynamic> json) {
    return TeacherDetailResponse(
      teacher: TeacherInfo.fromJson(json['teacher'] as Map<String, dynamic>),
      summary: TeacherSummary.fromJson(json['summary'] as Map<String, dynamic>),
      evaluations: (json['evaluations'] as List<dynamic>)
          .map((e) => EvaluationDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjects: (json['subjects'] as List<dynamic>)
          .map((s) => SubjectInfo.fromJson(s as Map<String, dynamic>))
          .toList(),
      periodo: json['periodo'] as String,
      generatedAt: json['generatedAt'] as String,
    );
  }
}

class TeacherInfo {
  final int id;
  final String name;
  final String email;
  final String? profilePicture;

  TeacherInfo({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }
}

class TeacherSummary {
  final int totalSubjects;
  final int totalEvaluations;
  final int activeEvaluations;
  final int closedEvaluations;
  final int totalStudents;
  final int completedResponses;
  final int pendingResponses;
  final int overallCompletionRate;

  TeacherSummary({
    required this.totalSubjects,
    required this.totalEvaluations,
    required this.activeEvaluations,
    required this.closedEvaluations,
    required this.totalStudents,
    required this.completedResponses,
    required this.pendingResponses,
    required this.overallCompletionRate,
  });

  factory TeacherSummary.fromJson(Map<String, dynamic> json) {
    return TeacherSummary(
      totalSubjects: json['totalSubjects'] as int,
      totalEvaluations: json['totalEvaluations'] as int,
      activeEvaluations: json['activeEvaluations'] as int,
      closedEvaluations: json['closedEvaluations'] as int,
      totalStudents: json['totalStudents'] as int,
      completedResponses: json['completedResponses'] as int,
      pendingResponses: json['pendingResponses'] as int,
      overallCompletionRate: json['overallCompletionRate'] as int,
    );
  }
}

class EvaluationDetail {
  final int id;
  final String subjectName;
  final String subjectCode;
  final String careerName;
  final String templateName;
  final String periodo;
  final DateTime fechaInicio;
  final DateTime fechaCierre;
  final bool isActive;
  final int totalStudents;
  final int completedResponses;
  final int pendingResponses;
  final int completionRate;

  EvaluationDetail({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.careerName,
    required this.templateName,
    required this.periodo,
    required this.fechaInicio,
    required this.fechaCierre,
    required this.isActive,
    required this.totalStudents,
    required this.completedResponses,
    required this.pendingResponses,
    required this.completionRate,
  });

  factory EvaluationDetail.fromJson(Map<String, dynamic> json) {
    return EvaluationDetail(
      id: json['id'] as int,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,
      careerName: json['careerName'] as String,
      templateName: json['templateName'] as String,
      periodo: json['periodo'] as String,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaCierre: DateTime.parse(json['fechaCierre'] as String),
      isActive: json['isActive'] as bool,
      totalStudents: json['totalStudents'] as int,
      completedResponses: json['completedResponses'] as int,
      pendingResponses: json['pendingResponses'] as int,
      completionRate: json['completionRate'] as int,
    );
  }
}

class SubjectInfo {
  final int id;
  final String name;
  final String code;
  final String career;
  final int studentsCount;

  SubjectInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.career,
    required this.studentsCount,
  });

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      career: json['career'] as String,
      studentsCount: json['studentsCount'] as int,
    );
  }
}
