/**
 * Servicio de Administración
 * Maneja sincronizaciones controladas de estudiantes, profesores y evaluaciones
 */

import { UserModel } from '../models/user.model.js';
import { CareerModel } from '../models/career.model.js';
import { SubjectModel } from '../models/subject.model.js';
import { EvaluationModel } from '../models/evaluation.model.js';
import { EvaluationTemplateModel } from '../models/evaluation-template.model.js';
import { EnrollmentService } from './enrollment.service.js';
import { RoleService } from './role.service.js';
import { createLogger } from '../utils/logger.js';
import prisma from '../config/prisma.js';

const logger = createLogger('AdminService');

// Periodo actual
const CURRENT_PERIOD = '2025-1';

// 🆕 Límites de sincronización
const SYNC_LIMITS = {
  MAX_SUBJECTS_PER_STUDENT: 7,  // 1 materia por cada una de las 7 carreras
  MAX_SUBJECTS_PER_TEACHER: 7   // Máximo 7 materias por docente
};

export class AdminService {
  // ==========================================
  // SINCRONIZACIÓN DE ESTUDIANTES
  // ==========================================

  /**
   * Sincroniza estudiantes: inscribe en carreras y materias
   * Límite: 7 materias (1 por cada una de las 7 carreras)
   * @param {number} adminId - ID del administrador que ejecuta
   * @param {Object} options - Opciones de sincronización
   * @returns {Object} Resultado de la sincronización
   */
  static async syncStudents(adminId, options = {}) {
    logger.info(`🎓 Iniciando sincronización de estudiantes (Admin: ${adminId})`);

    const startTime = Date.now();
    const resultado = {
      total: 0,
      procesados: 0,
      exitosos: 0,
      errores: 0,
      yaInscritos: 0,
      detalles: [],
      erroresDetalle: []
    };

    try {
      // 1. Obtener todos los estudiantes
      const estudiantes = await this.getStudentsToSync();
      
      if (estudiantes.length === 0) {
        logger.warn('⚠️ No hay estudiantes registrados para sincronizar');
        throw new Error('No hay estudiantes registrados en el sistema');
      }

      resultado.total = estudiantes.length;
      logger.info(`📊 ${resultado.total} estudiantes encontrados`);

      // 2. Verificar que existan carreras
      const carreras = await CareerModel.findAll();
      if (carreras.length === 0) {
        logger.warn('⚠️ No hay carreras disponibles');
        throw new Error('No hay carreras disponibles en el sistema');
      }

      // 3. Procesar cada estudiante
      for (const estudiante of estudiantes) {
        try {
          resultado.procesados++;

          // Verificar si ya tiene inscripciones
          const tieneInscripciones = await this.studentHasEnrollments(estudiante.id);
          
          if (tieneInscripciones && !options.force) {
            resultado.yaInscritos++;
            logger.debug(`Estudiante ${estudiante.email} ya tiene inscripciones`);
            continue;
          }

          // Inscribir estudiante (7 carreras, 1 materia por carrera)
          const inscripcion = await EnrollmentService.setupStudentEnrollment(estudiante.id);

          if (!inscripcion.success) {
            resultado.errores++;
            resultado.erroresDetalle.push({
              userId: estudiante.id,
              email: estudiante.email,
              error: inscripcion.message
            });
            continue;
          }

          resultado.exitosos++;
          resultado.detalles.push({
            userId: estudiante.id,
            email: estudiante.email,
            carreras: inscripcion.careers,
            materias: inscripcion.subjects,
            success: true
          });

          logger.success(
            `✅ ${estudiante.email}: ${inscripcion.careers} carreras, ${inscripcion.subjects} materias`
          );
        } catch (error) {
          resultado.errores++;
          resultado.erroresDetalle.push({
            userId: estudiante.id,
            email: estudiante.email,
            error: error.message
          });
          logger.error(`Error procesando estudiante ${estudiante.email}`, error);
        }
      }

      // 4. Guardar log de sincronización
      const duracion = Date.now() - startTime;
      await this.saveSyncLog(adminId, 'students', CURRENT_PERIOD, {
        ...resultado,
        duracion: `${(duracion / 1000).toFixed(2)}s`,
        timestamp: new Date().toISOString()
      });

      logger.success(
        `✅ Sincronización completada:\n` +
        `   - Total: ${resultado.total}\n` +
        `   - Exitosos: ${resultado.exitosos}\n` +
        `   - Ya inscritos: ${resultado.yaInscritos}\n` +
        `   - Errores: ${resultado.errores}\n` +
        `   - Duración: ${(duracion / 1000).toFixed(2)}s`
      );

      return resultado;
    } catch (error) {
      logger.error('Error en sincronización de estudiantes', error);
      throw error;
    }
  }

  /**
   * Obtiene estudiantes que necesitan sincronización
   */
  static async getStudentsToSync() {
    const students = await prisma.user.findMany({
      where: {
        roles: {
          some: {
            role: { name: 'STUDENT' }
          }
        }
      },
      select: {
        id: true,
        email: true,
        nombreCompleto: true,
        isProfileComplete: true,
        firstLoginAt: true,
        lastLoginAt: true,
        careers: { select: { id: true } },
        subjects: { select: { id: true } }
      }
    });

    return students;
  }

  /**
   * Verifica si un estudiante ya tiene inscripciones
   */
  static async studentHasEnrollments(userId) {
    const careers = await prisma.userCareer.count({
      where: { userId, periodo: CURRENT_PERIOD }
    });

    const subjects = await prisma.userSubject.count({
      where: { userId, periodo: CURRENT_PERIOD }
    });

    return careers > 0 || subjects > 0;
  }

  // ==========================================
  // SINCRONIZACIÓN DE PROFESORES
  // ==========================================

  /**
   * Sincroniza profesores: asigna materias (SIN crear evaluaciones)
   * Límite: 7 materias por docente
   * @param {number} adminId - ID del administrador
   * @param {Object} options - Opciones de sincronización
   * @returns {Object} Resultado de la sincronización
   */
  static async syncTeachers(adminId, options = {}) {
    logger.info(`🧑‍🏫 Iniciando sincronización de profesores (Admin: ${adminId})`);

    const startTime = Date.now();
    const resultado = {
      total: 0,
      procesados: 0,
      exitosos: 0,
      errores: 0,
      yaAsignados: 0,
      detalles: [],
      erroresDetalle: []
    };

    try {
      // 1. Obtener todos los profesores
      const profesores = await this.getTeachersToSync();
      
      if (profesores.length === 0) {
        logger.warn('⚠️ No hay profesores registrados para sincronizar');
        throw new Error('No hay profesores registrados en el sistema');
      }

      resultado.total = profesores.length;
      logger.info(`📊 ${resultado.total} profesores encontrados`);

      // 2. Verificar que existan materias sin profesor
      const materiasSinProfesor = await SubjectModel.findSubjectsWithoutTeacher();
      if (materiasSinProfesor.length === 0) {
        logger.warn('⚠️ No hay materias disponibles sin profesor asignado');
        throw new Error('No hay materias disponibles sin profesor. Todas las materias ya tienen docente asignado.');
      }

      logger.info(`📚 ${materiasSinProfesor.length} materias disponibles sin profesor`);

      // 3. Procesar cada profesor
      for (const profesor of profesores) {
        try {
          resultado.procesados++;

          // Verificar si ya tiene materias asignadas
          const tieneAsignaciones = await this.teacherHasAssignments(profesor.id);
          
          if (tieneAsignaciones && !options.force) {
            resultado.yaAsignados++;
            logger.debug(`Profesor ${profesor.email} ya tiene asignaciones`);
            continue;
          }

          // Asignar materias al profesor (SIN crear evaluaciones)
          const asignacion = await EnrollmentService.setupTeacherAssignment(profesor.id);

          if (!asignacion.success) {
            resultado.errores++;
            resultado.erroresDetalle.push({
              userId: profesor.id,
              email: profesor.email,
              error: asignacion.message
            });
            continue;
          }

          resultado.exitosos++;
          resultado.detalles.push({
            userId: profesor.id,
            email: profesor.email,
            materias: asignacion.assignedSubjects,
            success: true
          });

          logger.success(
            `✅ ${profesor.email}: ${asignacion.assignedSubjects} materias asignadas`
          );
        } catch (error) {
          resultado.errores++;
          resultado.erroresDetalle.push({
            userId: profesor.id,
            email: profesor.email,
            error: error.message
          });
          logger.error(`Error procesando profesor ${profesor.email}`, error);
        }
      }

      // 4. Guardar log
      const duracion = Date.now() - startTime;
      await this.saveSyncLog(adminId, 'teachers', CURRENT_PERIOD, {
        ...resultado,
        duracion: `${(duracion / 1000).toFixed(2)}s`,
        timestamp: new Date().toISOString()
      });

      logger.success(
        `✅ Sincronización de profesores completada:\n` +
        `   - Total: ${resultado.total}\n` +
        `   - Exitosos: ${resultado.exitosos}\n` +
        `   - Ya asignados: ${resultado.yaAsignados}\n` +
        `   - Errores: ${resultado.errores}\n` +
        `   - Duración: ${(duracion / 1000).toFixed(2)}s`
      );

      return resultado;
    } catch (error) {
      logger.error('Error en sincronización de profesores', error);
      throw error;
    }
  }

  /**
   * Obtiene profesores que necesitan sincronización
   */
  static async getTeachersToSync() {
    const teachers = await prisma.user.findMany({
      where: {
        roles: {
          some: {
            role: { name: 'TEACHER' }
          }
        }
      },
      select: {
        id: true,
        email: true,
        nombreCompleto: true,
        firstLoginAt: true,
        lastLoginAt: true,
        taughtSubjects: { select: { id: true } }
      }
    });

    return teachers;
  }

  /**
   * Verifica si un profesor ya tiene asignaciones
   */
  static async teacherHasAssignments(userId) {
    const subjects = await prisma.subject.count({
      where: { teacherId: userId }
    });

    return subjects > 0;
  }

  // ==========================================
  // GENERACIÓN DE EVALUACIONES
  // ==========================================

  /**
   * Genera evaluaciones masivas para un periodo
   * @param {number} adminId - ID del administrador
   * @param {Object} data - Datos de evaluación
   * @returns {Object} Resultado de la generación
   */
  static async generateEvaluations(adminId, data) {
    logger.info(`📝 Generando evaluaciones masivas (Admin: ${adminId})`);

    const { periodo, fechaInicio, fechaCierre, templateId } = data;
    const startTime = Date.now();

    const resultado = {
      total: 0,
      creadas: 0,
      omitidas: 0,
      errores: 0,
      detalles: [],
      erroresDetalle: []
    };

    try {
      // 1. Validar que existan estudiantes
      const totalEstudiantes = await prisma.user.count({
        where: {
          roles: {
            some: {
              role: { name: 'STUDENT' }
            }
          }
        }
      });

      if (totalEstudiantes === 0) {
        throw new Error('No hay estudiantes registrados. Primero debe sincronizar estudiantes.');
      }

      // 2. Validar que existan profesores
      const totalProfesores = await prisma.user.count({
        where: {
          roles: {
            some: {
              role: { name: 'TEACHER' }
            }
          }
        }
      });

      if (totalProfesores === 0) {
        throw new Error('No hay profesores registrados. Primero debe sincronizar profesores.');
      }

      // 3. Obtener plantilla
      const template = templateId 
        ? await EvaluationTemplateModel.findById(templateId)
        : await EvaluationTemplateModel.findDefault();

      if (!template) {
        throw new Error('Plantilla de evaluación no encontrada');
      }

      // 4. Obtener todas las materias con profesor asignado Y con estudiantes
      const materias = await prisma.subject.findMany({
        where: {
          teacherId: { not: null },
          activo: true,
          students: {
            some: {
              periodo: periodo || CURRENT_PERIOD
            }
          }
        },
        include: {
          teacher: { select: { id: true, email: true } },
          career: { select: { nombre: true } },
          students: {
            where: {
              periodo: periodo || CURRENT_PERIOD
            }
          }
        }
      });

      if (materias.length === 0) {
        throw new Error(
          'No hay materias con profesor asignado y estudiantes inscritos. ' +
          'Primero debe sincronizar estudiantes y profesores.'
        );
      }

      resultado.total = materias.length;
      logger.info(`📊 ${resultado.total} materias con profesor y estudiantes encontradas`);

      // 5. Crear evaluación para cada materia
      for (const materia of materias) {
        try {
          // Verificar si ya existe
          const existe = await EvaluationModel.exists(
            materia.id,
            materia.teacherId,
            periodo || CURRENT_PERIOD
          );

          if (existe) {
            resultado.omitidas++;
            logger.debug(`Evaluación ya existe: ${materia.nombre} - ${periodo || CURRENT_PERIOD}`);
            continue;
          }

          // Crear evaluación
          const evaluation = await EvaluationModel.create({
            templateId: template.id,
            subjectId: materia.id,
            teacherId: materia.teacherId,
            periodo: periodo || CURRENT_PERIOD,
            fechaInicio: new Date(fechaInicio),
            fechaCierre: new Date(fechaCierre),
            esObligatoria: true,
            activo: true
          });

          resultado.creadas++;
          resultado.detalles.push({
            evaluationId: evaluation.id,
            materia: materia.nombre,
            profesor: materia.teacher.email,
            carrera: materia.career.nombre,
            estudiantesInscritos: materia.students.length,
            success: true
          });

          logger.success(
            `✅ Evaluación creada: ${materia.nombre} (${materia.students.length} estudiantes)`
          );
        } catch (error) {
          resultado.errores++;
          resultado.erroresDetalle.push({
            materia: materia.nombre,
            profesor: materia.teacher.email,
            error: error.message
          });
          logger.error(`Error creando evaluación para ${materia.nombre}`, error);
        }
      }

      // 6. Guardar log
      const duracion = Date.now() - startTime;
      await this.saveSyncLog(adminId, 'evaluations', periodo || CURRENT_PERIOD, {
        ...resultado,
        templateId: template.id,
        templateNombre: template.nombre,
        fechaInicio,
        fechaCierre,
        duracion: `${(duracion / 1000).toFixed(2)}s`,
        timestamp: new Date().toISOString()
      });

      logger.success(
        `✅ Generación de evaluaciones completada:\n` +
        `   - Total: ${resultado.total}\n` +
        `   - Creadas: ${resultado.creadas}\n` +
        `   - Omitidas: ${resultado.omitidas}\n` +
        `   - Errores: ${resultado.errores}\n` +
        `   - Duración: ${(duracion / 1000).toFixed(2)}s`
      );

      return resultado;
    } catch (error) {
      logger.error('Error generando evaluaciones', error);
      throw error;
    }
  }

  // ==========================================
  // GESTIÓN DE LOGS
  // ==========================================

  /**
   * Guarda log de sincronización
   */
  static async saveSyncLog(adminId, tipo, periodo, resultado) {
    try {
      await prisma.syncLog.create({
        data: {
          adminId,
          tipo,
          periodo,
          resultado: resultado
        }
      });
      logger.debug(`Log de sincronización guardado: ${tipo} - ${periodo}`);
    } catch (error) {
      logger.error('Error guardando log de sincronización', error);
    }
  }

  /**
   * Obtiene historial de sincronizaciones
   */
  static async getSyncLogs(filters = {}) {
    const { tipo, periodo, adminId, limit = 50 } = filters;

    const where = {};
    if (tipo) where.tipo = tipo;
    if (periodo) where.periodo = periodo;
    if (adminId) where.adminId = parseInt(adminId);

    const logs = await prisma.syncLog.findMany({
      where,
      include: {
        admin: {
          select: {
            id: true,
            nombreCompleto: true,
            email: true
          }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: limit
    });

    return logs;
  }

  /**
   * Obtiene el último log de sincronización por tipo
   */
  static async getLastSyncLog(tipo, periodo = CURRENT_PERIOD) {
    return await prisma.syncLog.findFirst({
      where: { tipo, periodo },
      include: {
        admin: {
          select: {
            id: true,
            nombreCompleto: true,
            email: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  // ==========================================
  // REPORTES Y ESTADÍSTICAS
  // ==========================================

  /**
   * Obtiene dashboard con estadísticas globales
   */
  static async getDashboard(periodo = CURRENT_PERIOD) {
    try {
      const [
        // Totales generales
        totalEstudiantes,
        totalProfesores,
        totalEvaluaciones,

        // Sincronizados en el periodo actual
        estudiantesSincronizados,
        profesoresInscritos,

        // Evaluaciones del periodo
        evaluacionesActivas,
        evaluacionesCompletadas,

        // Extra
        usuariosSinLogin
      ] = await Promise.all([
        // 1. Total de estudiantes registrados
        prisma.user.count({
          where: { roles: { some: { role: { name: 'STUDENT' } } } }
        }),

        // 2. Total de profesores registrados
        prisma.user.count({
          where: { roles: { some: { role: { name: 'TEACHER' } } } }
        }),

        // 3. Total de evaluaciones del periodo
        prisma.evaluation.count({
          where: { periodo, activo: true }
        }),

        // 4. Estudiantes con inscripciones en este periodo (sincronizados)
        prisma.userCareer.groupBy({
          by: ['userId'],
          where: { periodo },
          _count: true
        }).then(result => result.length),

        // 5. Profesores con materias asignadas (inscritos)
        prisma.subject.groupBy({
          by: ['teacherId'],
          where: { 
            teacherId: { not: null },
            activo: true
          },
          _count: true
        }).then(result => result.length),

        // 6. Evaluaciones activas (aún abiertas)
        prisma.evaluation.count({
          where: {
            periodo,
            activo: true,
            fechaCierre: { gte: new Date() }
          }
        }),

        // 7. Evaluaciones completadas (respuestas completadas)
        prisma.studentEvaluation.count({
          where: {
            completada: true,
            evaluation: { periodo }
          }
        }),

        // 8. Usuarios sin primer login
        prisma.user.count({
          where: { firstLoginAt: null }
        })
      ]);

      // Calcular estadísticas adicionales
      const tasaCompletitudEstudiantes = totalEstudiantes > 0 
        ? ((estudiantesSincronizados / totalEstudiantes) * 100).toFixed(2)
        : 0;

      const tasaCompletitudProfesores = totalProfesores > 0 
        ? ((profesoresInscritos / totalProfesores) * 100).toFixed(2)
        : 0;

      const tasaCompletitudEvaluaciones = totalEvaluaciones > 0
        ? ((evaluacionesCompletadas / totalEvaluaciones) * 100).toFixed(2)
        : 0;

      // Obtener últimas sincronizaciones
      const [lastSyncStudents, lastSyncTeachers, lastSyncEvaluations] = await Promise.all([
        this.getLastSyncLog('students', periodo),
        this.getLastSyncLog('teachers', periodo),
        this.getLastSyncLog('evaluations', periodo)
      ]);

      return {
        periodo,
        
        // Estadísticas principales (formato compatible con Flutter)
        stats: {
          // Estudiantes
          totalStudents: totalEstudiantes,
          syncedStudents: estudiantesSincronizados,
          pendingStudents: totalEstudiantes - estudiantesSincronizados,
          studentsSyncRate: parseFloat(tasaCompletitudEstudiantes),

          // Profesores
          totalTeachers: totalProfesores,
          enrolledTeachers: profesoresInscritos,
          pendingTeachers: totalProfesores - profesoresInscritos,
          teachersEnrollRate: parseFloat(tasaCompletitudProfesores),

          // Evaluaciones
          totalEvaluations: totalEvaluaciones,
          activeEvaluations: evaluacionesActivas,
          completedEvaluations: evaluacionesCompletadas,
          closedEvaluations: totalEvaluaciones - evaluacionesActivas,
          evaluationsCompletionRate: parseFloat(tasaCompletitudEvaluaciones),

          // Usuarios pendientes
          pendingFirstLogin: usuariosSinLogin
        },

        // Últimas sincronizaciones
        lastSyncs: {
          students: lastSyncStudents ? {
            id: lastSyncStudents.id,
            createdAt: lastSyncStudents.createdAt,
            admin: lastSyncStudents.admin,
            resultado: lastSyncStudents.resultado
          } : null,
          
          teachers: lastSyncTeachers ? {
            id: lastSyncTeachers.id,
            createdAt: lastSyncTeachers.createdAt,
            admin: lastSyncTeachers.admin,
            resultado: lastSyncTeachers.resultado
          } : null,
          
          evaluations: lastSyncEvaluations ? {
            id: lastSyncEvaluations.id,
            createdAt: lastSyncEvaluations.createdAt,
            admin: lastSyncEvaluations.admin,
            resultado: lastSyncEvaluations.resultado
          } : null
        },

        // Timestamp de generación
        generatedAt: new Date().toISOString()
      };
    } catch (error) {
      logger.error('Error obteniendo dashboard', error);
      throw error;
    }
  }

  /**
   * Obtiene estadísticas de evaluaciones
   */
  static async getEvaluationStats(periodo = CURRENT_PERIOD) {
    const evaluaciones = await prisma.evaluation.findMany({
      where: { periodo, activo: true },
      include: {
        subject: {
          include: {
            students: true
          }
        },
        studentResponses: {
          where: { completada: true }
        }
      }
    });

    let totalPosibles = 0;
    let totalCompletadas = 0;

    evaluaciones.forEach(ev => {
      totalPosibles += ev.subject.students.length;
      totalCompletadas += ev.studentResponses.length;
    });

    const tasaCompletitud = totalPosibles > 0 
      ? ((totalCompletadas / totalPosibles) * 100).toFixed(2)
      : 0;

    return {
      totalEvaluaciones: evaluaciones.length,
      totalPosibles,
      totalCompletadas,
      tasaCompletitud: parseFloat(tasaCompletitud),
      promedioGeneral: 0 // TODO: Calcular promedio de respuestas
    };
  }

  /**
   * Obtiene usuarios pendientes de primer login
   */
  static async getPendingFirstLogin() {
    return await prisma.user.findMany({
      where: { firstLoginAt: null },
      include: {
        roles: {
          include: { role: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  // ==========================================
  // 🆕 ANÁLISIS DE DOCENTES
  // ==========================================

  /**
  * Obtener análisis completo de todos los docentes
  */
  static async getTeachersAnalysis(filters = {}) {
    try {
      const { periodo = CURRENT_PERIOD, career, sortBy = 'name' } = filters;

      // Construir filtros para profesores
      const whereTeacher = {
        roles: {
          some: {
            role: { name: 'TEACHER' }
          }
        }
      };

      // Obtener todos los profesores
      const teachers = await prisma.user.findMany({
        where: whereTeacher,
        include: {
          taughtSubjects: {
            where: {
              activo: true,
              ...(career && {
                career: {
                  codigo: career
                }
              })
            },
            include: {
              career: {
                select: {
                  id: true,
                  nombre: true,
                  codigo: true
                }
              },
              students: {
                where: {
                  periodo
                },
                select: {
                  userId: true
                }
              },
              evaluations: {
                where: {
                  periodo,
                  activo: true
                },
                include: {
                  studentResponses: {
                    select: {
                      id: true,
                      completada: true,
                      fechaCompleta: true
                    }
                  }
                }
              }
            }
          },
          roles: {
            include: {
              role: true
            }
          }
        }
      });

      // Procesar datos de cada profesor
      const teachersData = teachers.map(teacher => {
        const subjects = teacher.taughtSubjects;

        // Calcular totales
        let totalStudents = 0;
        let completedResponses = 0;
        let pendingResponses = 0;
        let activeEvaluations = 0;
        let closedEvaluations = 0;

        const now = new Date();
        const subjectsData = [];

        subjects.forEach(subject => {
          const studentsCount = subject.students.length;
          totalStudents += studentsCount;

          subject.evaluations.forEach(evaluation => {
            const isActive = evaluation.fechaCierre >= now;
            
            if (isActive) {
              activeEvaluations++;
            } else {
              closedEvaluations++;
            }

            const completed = evaluation.studentResponses.filter(r => r.completada).length;
            const pending = studentsCount - completed;

            completedResponses += completed;
            pendingResponses += pending;

            subjectsData.push({
              name: subject.nombre,
              code: subject.codigo,
              students: studentsCount,
              completed: completed,
              pending: pending,
              evaluationId: evaluation.id,
              isActive: isActive
            });
          });
        });

        const completionRate = totalStudents > 0
          ? Math.round((completedResponses / totalStudents) * 100)
          : 0;

        // Determinar carrera principal (la que tiene más materias)
        const careerCounts = {};
        subjects.forEach(subject => {
          const careerCode = subject.career.codigo;
          careerCounts[careerCode] = (careerCounts[careerCode] || 0) + 1;
        });

        const mainCareerCode = Object.keys(careerCounts).sort(
          (a, b) => careerCounts[b] - careerCounts[a]
        )[0] || '';

        const mainCareer = subjects.find(s => s.career.codigo === mainCareerCode)?.career;

        // Última actividad (última evaluación completada)
        const allResponses = subjects.flatMap(s =>
          s.evaluations.flatMap(e =>
            e.studentResponses.filter(r => r.completada && r.fechaCompleta)
          )
        );

        const lastActivity = allResponses.length > 0
          ? allResponses.sort((a, b) =>
              new Date(b.fechaCompleta) - new Date(a.fechaCompleta)
            )[0].fechaCompleta
          : teacher.lastLoginAt || teacher.createdAt;

        return {
          id: teacher.id,
          name: teacher.nombreCompleto,
          email: teacher.email,
          career: mainCareer?.codigo || '',
          careerName: mainCareer?.nombre || '',
          totalSubjects: subjects.length,
          activeEvaluations,
          closedEvaluations,
          completionRate,
          totalStudents,
          completedResponses,
          pendingResponses,
          lastActivity: lastActivity?.toISOString().split('T')[0] || '',
          subjects: subjectsData,
          avgRating: 0, // TODO: Implementar cuando tengamos ratings
          period: periodo
        };
      });

      // Filtrar profesores sin materias si se especificó una carrera
      const filteredTeachers = career
        ? teachersData.filter(t => t.totalSubjects > 0)
        : teachersData;

      // Ordenar según el criterio
      const sortedTeachers = this._sortTeachers(filteredTeachers, sortBy);

      // Calcular estadísticas globales
      const globalStats = {
        totalTeachers: filteredTeachers.length,
        totalEvaluations: filteredTeachers.reduce((sum, t) => sum + t.activeEvaluations, 0),
        avgCompletion: filteredTeachers.length > 0
          ? (filteredTeachers.reduce((sum, t) => sum + t.completionRate, 0) / filteredTeachers.length).toFixed(1)
          : '0.0',
        totalStudents: filteredTeachers.reduce((sum, t) => sum + t.totalStudents, 0)
      };

      return {
        teachers: sortedTeachers,
        stats: globalStats,
        periodo,
        generatedAt: new Date().toISOString()
      };
    } catch (error) {
      logger.error('Error obteniendo análisis de docentes', error);
      throw error;
    }
  }

  /**
  * Obtener análisis detallado de un docente específico
  */
  static async getTeacherAnalysis(teacherId, periodo = CURRENT_PERIOD) {
    try {
      const teacher = await prisma.user.findUnique({
        where: { id: teacherId },
        include: {
          taughtSubjects: {
            where: { activo: true },
            include: {
              career: {
                select: {
                  id: true,
                  nombre: true,
                  codigo: true
                }
              },
              students: {
                where: { periodo },
                select: { userId: true }
              },
              evaluations: {
                where: {
                  periodo,
                  activo: true
                },
                include: {
                  template: {
                    select: {
                      id: true,
                      nombre: true
                    }
                  },
                  studentResponses: {
                    include: {
                      responses: {
                        include: {
                          question: true
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          roles: {
            include: {
              role: true
            }
          }
        }
      });

      if (!teacher) {
        return null;
      }

      // Verificar que sea profesor
      const isTeacher = teacher.roles.some(ur => ur.role.name === 'TEACHER');
      if (!isTeacher) {
        return null;
      }

      const subjects = teacher.taughtSubjects;
      const now = new Date();

      // Procesar evaluaciones detalladas
      const evaluationsDetail = [];
      let totalCompletedResponses = 0;
      let totalPossibleResponses = 0;

      subjects.forEach(subject => {
        subject.evaluations.forEach(evaluation => {
          const studentsCount = subject.students.length;
          const completedCount = evaluation.studentResponses.filter(r => r.completada).length;
          
          totalCompletedResponses += completedCount;
          totalPossibleResponses += studentsCount;

          evaluationsDetail.push({
            id: evaluation.id,
            subjectName: subject.nombre,
            subjectCode: subject.codigo,
            careerName: subject.career.nombre,
            templateName: evaluation.template.nombre,
            periodo: evaluation.periodo,
            fechaInicio: evaluation.fechaInicio,
            fechaCierre: evaluation.fechaCierre,
            isActive: evaluation.fechaCierre >= now,
            totalStudents: studentsCount,
            completedResponses: completedCount,
            pendingResponses: studentsCount - completedCount,
            completionRate: studentsCount > 0
              ? Math.round((completedCount / studentsCount) * 100)
              : 0
          });
        });
      });

      const overallCompletionRate = totalPossibleResponses > 0
        ? Math.round((totalCompletedResponses / totalPossibleResponses) * 100)
        : 0;

      return {
        teacher: {
          id: teacher.id,
          name: teacher.nombreCompleto,
          email: teacher.email,
          profilePicture: teacher.profilePicture
        },
        summary: {
          totalSubjects: subjects.length,
          totalEvaluations: evaluationsDetail.length,
          activeEvaluations: evaluationsDetail.filter(e => e.isActive).length,
          closedEvaluations: evaluationsDetail.filter(e => !e.isActive).length,
          totalStudents: totalPossibleResponses,
          completedResponses: totalCompletedResponses,
          pendingResponses: totalPossibleResponses - totalCompletedResponses,
          overallCompletionRate
        },
        evaluations: evaluationsDetail,
        subjects: subjects.map(s => ({
          id: s.id,
          name: s.nombre,
          code: s.codigo,
          career: s.career.nombre,
          studentsCount: s.students.length
        })),
        periodo,
        generatedAt: new Date().toISOString()
      };
    } catch (error) {
      logger.error(`Error obteniendo análisis del docente ${teacherId}`, error);
      throw error;
    }
  }

  /**
  * Obtener estadísticas globales para análisis
  */
  static async getAnalysisStats(filters = {}) {
    try {
      const { periodo = CURRENT_PERIOD, career } = filters;

      const whereSubject = {
        activo: true,
        teacherId: { not: null }
      };

      if (career) {
        whereSubject.career = { codigo: career };
      }

      const whereEvaluation = {
        periodo,
        activo: true
      };

      if (career) {
        whereEvaluation.subject = {
          career: { codigo: career }
        };
      }

      const [
        totalTeachers,
        totalEvaluations,
        totalStudents,
        completedResponses
      ] = await Promise.all([
        // Total de profesores con materias
        prisma.subject.groupBy({
          by: ['teacherId'],
          where: whereSubject,
          _count: true
        }).then(result => result.length),

        // Total de evaluaciones
        prisma.evaluation.count({
          where: whereEvaluation
        }),

        // Total de estudiantes en materias con evaluaciones
        prisma.userSubject.count({
          where: {
            periodo,
            subject: whereSubject
          }
        }),

        // Total de respuestas completadas
        prisma.studentEvaluation.count({
          where: {
            completada: true,
            evaluation: whereEvaluation
          }
        })
      ]);

      const avgCompletion = totalStudents > 0
        ? ((completedResponses / totalStudents) * 100).toFixed(1)
        : '0.0';

      return {
        totalTeachers,
        totalEvaluations,
        totalStudents,
        completedResponses,
        pendingResponses: totalStudents - completedResponses,
        avgCompletion: parseFloat(avgCompletion),
        periodo,
        career: career || 'all'
      };
    } catch (error) {
      logger.error('Error obteniendo estadísticas de análisis', error);
      throw error;
    }
  }

  /**
  * Método auxiliar para ordenar profesores
  */
  static _sortTeachers(teachers, sortBy) {
    const sortFunctions = {
      name: (a, b) => a.name.localeCompare(b.name),
      evaluations: (a, b) => b.activeEvaluations - a.activeEvaluations,
      completion: (a, b) => a.completionRate - b.completionRate, // Ascendente para mostrar urgentes primero
      activity: (a, b) => b.lastActivity.localeCompare(a.lastActivity)
    };

    const sortFn = sortFunctions[sortBy] || sortFunctions.name;
    return [...teachers].sort(sortFn);
  }
  
}

export default AdminService;
