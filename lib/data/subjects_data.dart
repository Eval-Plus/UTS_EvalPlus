import 'package:flutter/material.dart';
import 'package:eval_plus/services/api/subjects_api_service.dart';
import 'package:eval_plus/services/storage/auth_storage_service.dart';

// Modelo de datos para una materia
class Subject {
  final int id;
  final String nombre;
  final String codigo;
  final String careerCodigo; // Para asociarla con una carrera
  final String professorName;
  final int semestre;

  Subject({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.careerCodigo,
    required this.professorName,
    this.semestre = 1,
  });

  bool get hasTeacher =>
    professorName.trim().isNotEmpty &&
    professorName.toLowerCase() != 'sin profesor';

  // Factory constructor para crear desde la respuesta del API
  factory Subject.fromApiResponse(
    SubjectApiResponse apiResponse,
    String careerCodigo,
  ) {
    return Subject(
      id: apiResponse.id,
      nombre: apiResponse.nombre,
      codigo: apiResponse.codigo,
      careerCodigo: careerCodigo,
      professorName: apiResponse.teacher,
      semestre: apiResponse.semestre,
    );
  }

  // Factory constructor para crear desde JSON (legacy/fallback)
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      careerCodigo: json['careerCodigo'] as String,
      professorName: json['professorName'] as String,
      semestre: json['semestre'] as int? ?? 1,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'careerCodigo': careerCodigo,
      'professorName': professorName,
      'semestre': semestre,
    };
  }
}

// Servicio para obtener materias
class SubjectsDataService {
  /// Obtiene las materias del usuario por carrera desde el API
  static Future<List<Subject>> getSubjectsByCareer({
    required String careerCodigo,
    required int careerId,
  }) async {
    try {
      debugPrint('🔍 Cargando materias para carrera: $careerCodigo (ID: $careerId)');
      
      // Obtener token
      final token = await AuthStorageService.getToken();
      
      if (token == null) {
        debugPrint('❌ No hay token disponible');
        return _getFallbackSubjects(careerCodigo);
      }

      // Fetch desde API
      final apiResponse = await SubjectsApiService.fetchSubjectsByCareer(
        token: token,
        careerId: careerId,
      );

      if (apiResponse != null && apiResponse.subjects.isNotEmpty) {
        // Convertir respuesta del API a modelo Subject
        return apiResponse.subjects
            .where((subject) => subject.activo)
            .map((apiSubject) => Subject.fromApiResponse(
                  apiSubject,
                  careerCodigo,
                ))
            .toList();
      }

      // Si no hay materias o hubo error, retornar fallback
      debugPrint('⚠️ No se obtuvieron materias del API, usando fallback');
      return _getFallbackSubjects(careerCodigo);
      
    } catch (e) {
      debugPrint('💥 Error en getSubjectsByCareer: $e');
      return _getFallbackSubjects(careerCodigo);
    }
  }

  /// Materias de respaldo (fallback) por si falla el API
  static Future<List<Subject>> _getFallbackSubjects(String careerCodigo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Todas las materias hardcodeadas
    final allSubjects = [
      // Materias de Ingeniería de Sistemas
      Subject(
        id: 1,
        nombre: 'Programación Orientada a Objetos',
        codigo: 'B191',
        careerCodigo: 'ING-SIS',
        professorName: 'Dr. Juan Pérez',
        semestre: 3,
      ),
      Subject(
        id: 2,
        nombre: 'Bases de Datos',
        codigo: 'B192',
        careerCodigo: 'ING-SIS',
        professorName: 'Dra. María García',
        semestre: 4,
      ),
      Subject(
        id: 3,
        nombre: 'Estructuras de Datos',
        codigo: 'B193',
        careerCodigo: 'ING-SIS',
        professorName: 'Ing. Carlos Rodríguez',
        semestre: 2,
      ),
      Subject(
        id: 4,
        nombre: 'Desarrollo Web',
        codigo: 'B194',
        careerCodigo: 'ING-SIS',
        professorName: 'Ing. Ana Martínez',
        semestre: 5,
      ),
      
      // Materias de Administración de Empresas
      Subject(
        id: 5,
        nombre: 'Contabilidad General',
        codigo: 'A101',
        careerCodigo: 'ADM-EMP',
        professorName: 'Lic. Pedro Sánchez',
        semestre: 1,
      ),
      Subject(
        id: 6,
        nombre: 'Gestión Empresarial',
        codigo: 'A102',
        careerCodigo: 'ADM-EMP',
        professorName: 'MBA. Laura Torres',
        semestre: 3,
      ),
      Subject(
        id: 7,
        nombre: 'Marketing Digital',
        codigo: 'A103',
        careerCodigo: 'ADM-EMP',
        professorName: 'Lic. Roberto Díaz',
        semestre: 4,
      ),
      
      // Materias de Derecho
      Subject(
        id: 8,
        nombre: 'Derecho Constitucional',
        codigo: 'D201',
        careerCodigo: 'DER',
        professorName: 'Abg. Sofía Ramírez',
        semestre: 2,
      ),
      Subject(
        id: 9,
        nombre: 'Derecho Civil',
        codigo: 'D202',
        careerCodigo: 'DER',
        professorName: 'Dr. Luis Herrera',
        semestre: 3,
      ),
      Subject(
        id: 10,
        nombre: 'Derecho Penal',
        codigo: 'D203',
        careerCodigo: 'DER',
        professorName: 'Abg. Carmen López',
        semestre: 4,
      ),
    ];

    // Filtrar por código de carrera
    return allSubjects
        .where((subject) => subject.careerCodigo == careerCodigo)
        .toList();
  }

  /// Método para obtener una materia específica por código
  static Future<Subject?> getSubjectByCode({
    required String codigo,
    required String careerCodigo,
    required int careerId,
  }) async {
    final subjects = await getSubjectsByCareer(
      careerCodigo: careerCodigo,
      careerId: careerId,
    );
    
    try {
      return subjects.firstWhere(
        (subject) => subject.codigo.toUpperCase() == codigo.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Método para obtener una materia específica por ID
  static Future<Subject?> getSubjectById({
    required int id,
    required String careerCodigo,
    required int careerId,
  }) async {
    final subjects = await getSubjectsByCareer(
      careerCodigo: careerCodigo,
      careerId: careerId,
    );
    
    try {
      return subjects.firstWhere((subject) => subject.id == id);
    } catch (e) {
      return null;
    }
  }
}
