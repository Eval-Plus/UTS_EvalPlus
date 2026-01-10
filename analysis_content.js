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

export class AdminService {
  // ==========================================
  // SINCRONIZACIÓN DE ESTUDIANTES
  // ==========================================

  /**
   * Sincroniza estudiantes: inscribe en carreras y materias
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
      resultado.total = estudiantes.length;

      logger.info(`📊 ${resultado.total} estudiantes encontrados`);

      // 2. Procesar cada estudiante
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

          // Inscribir estudiante
          const inscripcion = await EnrollmentService.setupStudentEnrollment(estudiante.id);

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

      // 3. Guardar log de sincronización
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
   * Sincroniza profesores: asigna materias
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
      resultado.total = profesores.length;

      logger.info(`📊 ${resultado.total} profesores encontrados`);

      // 2. Procesar cada profesor
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

          // Asignar materias al profesor
          const asignacion = await EnrollmentService.setupTeacherAssignment(profesor.id);

          resultado.exitosos++;
          resultado.detalles.push({
            userId: profesor.id,
            email: profesor.email,
            materias: asignacion.assignedSubjects,
            evaluaciones: asignacion.createdEvaluations,
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

      // 3. Guardar log
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
      // 1. Obtener plantilla
      const template = templateId 
        ? await EvaluationTemplateModel.findById(templateId)
        : await EvaluationTemplateModel.findDefault();

      if (!template) {
        throw new Error('Plantilla de evaluación no encontrada');
      }

      // 2. Obtener todas las materias con profesor asignado
      const materias = await prisma.subject.findMany({
        where: {
          teacherId: { not: null },
          activo: true
        },
        include: {
          teacher: { select: { id: true, email: true } },
          career: { select: { nombre: true } }
        }
      });

      resultado.total = materias.length;
      logger.info(`📊 ${resultado.total} materias con profesor encontradas`);

      // 3. Crear evaluación para cada materia
      for (const materia of materias) {
        try {
          // Verificar si ya existe
          const existe = await EvaluationModel.exists(
            materia.id,
            materia.teacherId,
            periodo
          );

          if (existe) {
            resultado.omitidas++;
            logger.debug(`Evaluación ya existe: ${materia.nombre} - ${periodo}`);
            continue;
          }

          // Crear evaluación
          const evaluation = await EvaluationModel.create({
            templateId: template.id,
            subjectId: materia.id,
            teacherId: materia.teacherId,
            periodo,
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
            success: true
          });

          logger.success(`✅ Evaluación creada: ${materia.nombre}`);
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

      // 4. Guardar log
      const duracion = Date.now() - startTime;
      await this.saveSyncLog(adminId, 'evaluations', periodo, {
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
}

export default AdminService;
