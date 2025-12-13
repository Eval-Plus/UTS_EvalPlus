# Release Notes - Eval+

## v0.3.0-alpha (2024-12-13)

### 🎯 Alcance de la versión
Esta versión Alpha incluye **3 paneles principales**:
- **Panel Estudiante** ✅ (Funcional)
- **Panel Docente** 🚧 (Próximamente)
- **Panel Administrador** 🚧 (Próximamente)

### ✨ Funcionalidades Estudiante (Completadas)

#### Autenticación
- ✅ Inicio de sesión con Microsoft OAuth
- ✅ Perfil de usuario con información personal
- ✅ Detección automática de rol según correo institucional

#### Carreras y Materias
- ✅ Visualización de todas las carreras asignadas
- ✅ Listado de materias por carrera
- ✅ Inscripción automática en todas las carreras disponibles
- ✅ Asignación aleatoria de hasta 2 materias por carrera
- ✅ Semestre aleatorio por carrera

#### Evaluaciones
- ✅ Listado de evaluaciones disponibles
- ✅ Responder evaluaciones con formulario interactivo
- ✅ Progreso en tiempo real durante evaluación
- ✅ Comentarios anónimos opcionales
- ✅ Estadísticas personales:
  - Total de evaluaciones
  - Evaluaciones completadas
  - Evaluaciones pendientes

#### Perfil
- ✅ Visualización de datos personales
- ✅ Foto de perfil de Microsoft
- ✅ Información de carreras y materias inscritas

### 🚧 Próximas funcionalidades (v0.4.0-alpha)

#### Panel Docente
- 📊 Visualización de comentarios anónimos de estudiantes
- 📈 Estadísticas por materia
- 📋 Listado de evaluaciones asignadas
- 👥 Cantidad de estudiantes que han respondido

#### Panel Administrador
- 📊 Dashboard de monitoreo general
- 📈 Estadísticas globales de evaluaciones
- 👥 Gestión de usuarios (estudiantes y docentes)
- 📝 Gestión de plantillas de evaluación
- 🏫 Administración de carreras y materias

### 🔧 Mejoras técnicas
- Refactorización del servicio de inscripciones
- Optimización de logs con emojis y mejor legibilidad
- Mejora en el manejo de errores por carrera
- Sistema de configuración centralizado para estudiantes

### 🐛 Correcciones
- Fix: Inscripción de estudiantes ahora incluye todas las carreras
- Fix: Máximo 2 materias por carrera en lugar de 3
- Fix: Semestre aleatorio independiente por carrera

### 📱 Plataformas soportadas
- Android (APK)
- Web (Próximamente)

---

## v0.2.0-alpha (2024-12-XX)
[Contenido anterior...]
