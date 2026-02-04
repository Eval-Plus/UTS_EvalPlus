/// Modelo para el dashboard de administración
/// Ubicación: lib/models/admin_dashboard_model.dart
class AdminDashboardModel {
  final String periodo;
  final DashboardStats stats;
  final LastSyncs lastSyncs;
  final DateTime generatedAt;

  AdminDashboardModel({
    required this.periodo,
    required this.stats,
    required this.lastSyncs,
    required this.generatedAt,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      periodo: json['periodo'] as String,
      stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
      lastSyncs: LastSyncs.fromJson(json['lastSyncs'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodo': periodo,
      'stats': stats.toJson(),
      'lastSyncs': lastSyncs.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Estadísticas principales del dashboard
class DashboardStats {
  // Estudiantes
  final int totalStudents;
  final int syncedStudents;
  final int pendingStudents;
  final double studentsSyncRate;

  // Profesores
  final int totalTeachers;
  final int enrolledTeachers;
  final int pendingTeachers;
  final double teachersEnrollRate;

  // Evaluaciones
  final int totalEvaluations;
  final int activeEvaluations;
  final int completedEvaluations;
  final int closedEvaluations;
  final double evaluationsCompletionRate;

  // Usuarios pendientes
  final int pendingFirstLogin;

  DashboardStats({
    required this.totalStudents,
    required this.syncedStudents,
    required this.pendingStudents,
    required this.studentsSyncRate,
    required this.totalTeachers,
    required this.enrolledTeachers,
    required this.pendingTeachers,
    required this.teachersEnrollRate,
    required this.totalEvaluations,
    required this.activeEvaluations,
    required this.completedEvaluations,
    required this.closedEvaluations,
    required this.evaluationsCompletionRate,
    required this.pendingFirstLogin,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // 🔥 HELPER: Parsea int de forma segura
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // 🔥 HELPER: Parsea double de forma segura
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DashboardStats(
      totalStudents: parseInt(json['totalStudents']),
      syncedStudents: parseInt(json['syncedStudents']),
      pendingStudents: parseInt(json['pendingStudents']),
      studentsSyncRate: parseDouble(json['studentsSyncRate']),
      totalTeachers: parseInt(json['totalTeachers']),
      enrolledTeachers: parseInt(json['enrolledTeachers']),
      pendingTeachers: parseInt(json['pendingTeachers']),
      teachersEnrollRate: parseDouble(json['teachersEnrollRate']),
      totalEvaluations: parseInt(json['totalEvaluations']),
      activeEvaluations: parseInt(json['activeEvaluations']),
      completedEvaluations: parseInt(json['completedEvaluations']),
      closedEvaluations: parseInt(json['closedEvaluations']),
      evaluationsCompletionRate: parseDouble(json['evaluationsCompletionRate']),
      pendingFirstLogin: parseInt(json['pendingFirstLogin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'syncedStudents': syncedStudents,
      'pendingStudents': pendingStudents,
      'studentsSyncRate': studentsSyncRate,
      'totalTeachers': totalTeachers,
      'enrolledTeachers': enrolledTeachers,
      'pendingTeachers': pendingTeachers,
      'teachersEnrollRate': teachersEnrollRate,
      'totalEvaluations': totalEvaluations,
      'activeEvaluations': activeEvaluations,
      'completedEvaluations': completedEvaluations,
      'closedEvaluations': closedEvaluations,
      'evaluationsCompletionRate': evaluationsCompletionRate,
      'pendingFirstLogin': pendingFirstLogin,
    };
  }

  /// Genera un mapa compatible con el widget para facilitar transición
  Map<String, int> toWidgetMap() {
    return {
      'totalStudents': totalStudents,
      'syncedStudents': syncedStudents,
      'totalTeachers': totalTeachers,
      'enrolledTeachers': enrolledTeachers,
      'totalEvaluations': totalEvaluations,
      'activeEvaluations': activeEvaluations,
      'completedEvaluations': completedEvaluations,
    };
  }
}

/// Información de las últimas sincronizaciones
class LastSyncs {
  final SyncLogInfo? students;
  final SyncLogInfo? teachers;
  final SyncLogInfo? evaluations;

  LastSyncs({
    this.students,
    this.teachers,
    this.evaluations,
  });

  factory LastSyncs.fromJson(Map<String, dynamic> json) {
    return LastSyncs(
      students: json['students'] != null 
          ? SyncLogInfo.fromJson(json['students'] as Map<String, dynamic>)
          : null,
      teachers: json['teachers'] != null
          ? SyncLogInfo.fromJson(json['teachers'] as Map<String, dynamic>)
          : null,
      evaluations: json['evaluations'] != null
          ? SyncLogInfo.fromJson(json['evaluations'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'students': students?.toJson(),
      'teachers': teachers?.toJson(),
      'evaluations': evaluations?.toJson(),
    };
  }
}

/// Información de un log de sincronización
class SyncLogInfo {
  final int id;
  final DateTime createdAt;
  final AdminInfo admin;
  final SyncResult resultado;

  SyncLogInfo({
    required this.id,
    required this.createdAt,
    required this.admin,
    required this.resultado,
  });

  factory SyncLogInfo.fromJson(Map<String, dynamic> json) {
    return SyncLogInfo(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      admin: AdminInfo.fromJson(json['admin'] as Map<String, dynamic>),
      resultado: SyncResult.fromJson(json['resultado'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'admin': admin.toJson(),
      'resultado': resultado.toJson(),
    };
  }

  /// Formatea la fecha de sincronización
  String get formattedDate {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  /// Calcula hace cuánto tiempo fue la sincronización
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }
}

/// Información del administrador que ejecutó la sincronización
class AdminInfo {
  final int? id; // 🔥 Ahora es nullable
  final String nombreCompleto;
  final String email;

  AdminInfo({
    this.id, // 🔥 Ya no es required
    required this.nombreCompleto,
    required this.email,
  });

  factory AdminInfo.fromJson(Map<String, dynamic> json) {
    return AdminInfo(
      id: json['id'] as int?, // 🔥 Cast nullable
      nombreCompleto: json['nombreCompleto'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // 🔥 Solo incluir si no es null
      'nombreCompleto': nombreCompleto,
      'email': email,
    };
  }
}

/// Resultado de una sincronización
class SyncResult {
  final int total;
  final int procesados;
  final int exitosos;
  final int errores;
  final int? yaInscritos; // Solo para students/teachers
  final int? yaAsignados; // Solo para teachers
  final int? creadas; // Solo para evaluations
  final int? omitidas; // Solo para evaluations
  final String duracion;
  final String timestamp;

  SyncResult({
    required this.total,
    required this.procesados,
    required this.exitosos,
    required this.errores,
    this.yaInscritos,
    this.yaAsignados,
    this.creadas,
    this.omitidas,
    required this.duracion,
    required this.timestamp,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    // 🔥 HELPER: Parsea int de forma segura (puede ser null)
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return SyncResult(
      total: parseInt(json['total']),
      procesados: parseInt(json['procesados']),
      exitosos: parseInt(json['exitosos']),
      errores: parseInt(json['errores']),
      yaInscritos: parseIntNullable(json['yaInscritos']),
      yaAsignados: parseIntNullable(json['yaAsignados']),
      creadas: parseIntNullable(json['creadas']),
      omitidas: parseIntNullable(json['omitidas']),
      duracion: json['duracion'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'procesados': procesados,
      'exitosos': exitosos,
      'errores': errores,
      if (yaInscritos != null) 'yaInscritos': yaInscritos,
      if (yaAsignados != null) 'yaAsignados': yaAsignados,
      if (creadas != null) 'creadas': creadas,
      if (omitidas != null) 'omitidas': omitidas,
      'duracion': duracion,
      'timestamp': timestamp,
    };
  }

  /// Calcula la tasa de éxito
  double get successRate {
    if (total == 0) return 0.0;
    return (exitosos / total) * 100;
  }

  /// Verifica si hubo errores
  bool get hasErrors => errores > 0;
}
