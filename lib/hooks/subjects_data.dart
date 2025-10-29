import 'package:flutter/material.dart';

// Modelo de datos para una materia
class Subject {
  final String nombre;
  final String codigo;
  final String careerCodigo; // Para asociarla con una carrera
  final String professorName;
  final int semestre;

  Subject({
    required this.nombre,
    required this.codigo,
    required this.careerCodigo,
    required this.professorName,
    this.semestre = 1,
  });

  // Factory constructor para crear desde JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
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
  // Data hardcodeada por ahora
  // TODO: Reemplazar con fetch a API
  static Future<List<Subject>> getSubjectsByCareer(String careerCodigo) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Todas las materias
    final allSubjects = [
      // Materias de Ingeniería de Sistemas
      Subject(
        nombre: 'Programación Orientada a Objetos',
        codigo: 'B191',
        careerCodigo: 'ING-SIS',
        professorName: 'Dr. Juan Pérez',
        semestre: 3,
      ),
      Subject(
        nombre: 'Bases de Datos',
        codigo: 'B192',
        careerCodigo: 'ING-SIS',
        professorName: 'Dra. María García',
        semestre: 4,
      ),
      Subject(
        nombre: 'Estructuras de Datos',
        codigo: 'B193',
        careerCodigo: 'ING-SIS',
        professorName: 'Ing. Carlos Rodríguez',
        semestre: 2,
      ),
      Subject(
        nombre: 'Desarrollo Web',
        codigo: 'B194',
        careerCodigo: 'ING-SIS',
        professorName: 'Ing. Ana Martínez',
        semestre: 5,
      ),
      
      // Materias de Administración de Empresas
      Subject(
        nombre: 'Contabilidad General',
        codigo: 'A101',
        careerCodigo: 'ADM-EMP',
        professorName: 'Lic. Pedro Sánchez',
        semestre: 1,
      ),
      Subject(
        nombre: 'Gestión Empresarial',
        codigo: 'A102',
        careerCodigo: 'ADM-EMP',
        professorName: 'MBA. Laura Torres',
        semestre: 3,
      ),
      Subject(
        nombre: 'Marketing Digital',
        codigo: 'A103',
        careerCodigo: 'ADM-EMP',
        professorName: 'Lic. Roberto Díaz',
        semestre: 4,
      ),
      
      // Materias de Derecho
      Subject(
        nombre: 'Derecho Constitucional',
        codigo: 'D201',
        careerCodigo: 'DER',
        professorName: 'Abg. Sofía Ramírez',
        semestre: 2,
      ),
      Subject(
        nombre: 'Derecho Civil',
        codigo: 'D202',
        careerCodigo: 'DER',
        professorName: 'Dr. Luis Herrera',
        semestre: 3,
      ),
      Subject(
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

  // Método preparado para el futuro fetch a API
  static Future<List<Subject>> fetchSubjectsFromAPI(String careerCodigo) async {
    // TODO: Implementar fetch real
    /*
    try {
      final response = await http.get(
        Uri.parse('https://tu-api.com/subjects?career=$careerCodigo')
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Subject.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar materias');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
    */
    
    // Por ahora, retorna data hardcodeada
    return getSubjectsByCareer(careerCodigo);
  }
}
