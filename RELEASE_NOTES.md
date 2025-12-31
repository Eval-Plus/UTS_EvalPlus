# 📋 Release Notes - Eval+

## v0.3.2-alpha (2024-12-31)

### 🎯 Alcance de la versión
Actualización mayor de la versión Alpha con **integración completa del Panel Docente** conectado al backend, permitiendo visualización en tiempo real de evaluaciones, estadísticas y comentarios anónimos.

### ✨ Nuevas funcionalidades

#### 🧑‍🏫 Panel Docente - Integración Completa
- ✅ **Conexión total con la API backend**
- ✅ Visualización dinámica de evaluaciones asignadas
- ✅ Estadísticas en tiempo real por evaluación:
  - Total de estudiantes por materia
  - Respuestas completadas vs pendientes
  - Porcentaje de participación
  - Días restantes hasta cierre
  - Progreso visual con indicadores de color
- ✅ **Modal de comentarios anónimos** por evaluación:
  - Listado de comentarios de estudiantes
  - Análisis de sentimiento (Positivo/Neutral/Negativo)
  - Filtros por tipo de sentimiento
  - Búsqueda en comentarios
  - Estadísticas agregadas de comentarios
  - Indicador de anonimato y privacidad
- ✅ Sistema de caché inteligente para optimizar consultas
- ✅ Pull-to-refresh en evaluaciones
- ✅ Animaciones suaves en expansión de cards

#### 🎨 Mejoras de UI/UX
- ✅ Cards de evaluación con diseño mejorado
- ✅ Gradientes dinámicos basados en rol de usuario
- ✅ Chips informativos con códigos y períodos
- ✅ Indicadores visuales de estado (Activa/Cerrada/Próxima)
- ✅ Barra de progreso con colores según porcentaje
- ✅ Modal full-screen para comentarios con header personalizado
- ✅ Estados de carga y error informativos

#### 🔐 Sistema de Roles Mejorado
- ✅ Carga de roles desde API al iniciar sesión
- ✅ Paleta de colores dinámica según rol:
  - 🟢 Estudiantes: Amarillo-verde (#CAD225)
  - 🟢 Docentes: Verde medio (#8BC34A)
  - 🟢 Administradores: Verde oscuro (#4CAF50)
- ✅ Navegación adaptativa según permisos
- ✅ UserSessionController con gestión centralizada

### 🔧 Mejoras técnicas

#### Backend
- ✅ Endpoint `/api/student-evaluations/evaluation/:id/comments` funcional
- ✅ Modelo `CommentModel` con análisis de sentimiento
- ✅ Estructura de respuesta optimizada para frontend
- ✅ Soporte de metadata y paginación en comentarios

#### Frontend
- ✅ `TeacherEvaluationsService` con caché y listeners
- ✅ Separación de modelos: `TeacherEvaluationModel` y `CommentModel`
- ✅ Widgets reutilizables: `CommentsModal`, `_TeacherEvaluationCard`
- ✅ Manejo robusto de errores y estados de carga
- ✅ Logging detallado para debugging

#### Arquitectura
- ✅ Patrón Service + Controller + Model consistente
- ✅ Caché en memoria con invalidación inteligente
- ✅ Sistema de notificaciones entre servicios
- ✅ Separación clara entre contenido de estudiantes y docentes

### 🐛 Correcciones de bugs
- ✅ Estructura de respuesta de API de comentarios corregida
- ✅ Mapeo correcto de datos anidados en JSON
- ✅ Validación de tipos en deserialización
- ✅ Manejo de evaluaciones sin comentarios
- ✅ Prevención de múltiples cargas simultáneas

### 🚧 Limitaciones actuales
- ⚠️ Panel de administrador aún no implementado
- ⚠️ Análisis de sentimiento básico (próxima versión con IA)
- ⚠️ Sin soporte de exportación de datos
- ⚠️ Sin notificaciones push

### 📂 Estructura del proyecto actualizada
```
lib/
├── config/
│   ├── app_colors.dart          # ✨ Paletas por rol
│   ├── navigation_config.dart   # ✨ Navegación dinámica
│   └── ...
├── controllers/
│   └── user_session_controller.dart  # ✨ Gestión de sesión
├── models/
│   └── teacher_evaluation_model.dart # ✨ Con CommentModel
├── services/
│   ├── api/
│   │   └── student_evaluation_api_service.dart
│   └── teacher_evaluation_service.dart  # ✨ Con caché
├── screen/content/teacher/
│   └── teacher_evaluations_content.dart  # ✨ Integrado
└── widgets/evaluation/
    └── comments_modal.dart  # ✨ Nuevo modal
```

### 🔄 Cambios desde v0.3.1-alpha
| Componente | v0.3.1-alpha | v0.3.2-alpha |
|------------|--------------|--------------|
| Panel Docente | Datos estáticos | ✅ API integrada |
| Comentarios | ❌ No disponible | ✅ Modal completo |
| Roles | Básico | ✅ Sistema dinámico |
| Caché | ❌ Sin caché | ✅ Inteligente |
| UI | Simple | ✅ Mejorada |

### 📱 Plataformas soportadas
- ✅ Android (APK incluido)
- 🔄 Web (En desarrollo)
- 🔄 iOS (Próximamente)

### 🚀 Próximos pasos (v0.4.0-alpha)
- [ ] Panel de administrador completo
- [ ] Análisis de sentimiento con IA
- [ ] Exportación de reportes (PDF/Excel)
- [ ] Notificaciones push
- [ ] Gráficos interactivos de estadísticas
- [ ] Filtros avanzados en evaluaciones

### 📦 Instalación
1. Descarga el APK desde la sección de Releases
2. Habilita "Instalar desde fuentes desconocidas" en Android
3. Instala la aplicación
4. Inicia sesión con tus credenciales de Microsoft

### 🐛 Reporte de bugs
Si encuentras algún problema, por favor reporta en:
- GitHub Issues: [URL_DEL_REPO]/issues
- Email: [TU_EMAIL]

### 👥 Contribuidores
- [Tu Nombre] - Desarrollo principal

---

**Notas importantes:**
- Esta es una versión **Alpha** para pruebas internas
- No usar en producción
- Los datos son de prueba y pueden ser eliminados en cualquier momento
- Se requiere conexión a internet constante

**Fecha de lanzamiento:** 31 de Diciembre, 2024  
**Compilación:** `flutter build apk --release`  
**Versión mínima Android:** 5.0 (API 21)  
**Tamaño APK:** ~XX MB

---

## Versiones anteriores

## v0.3.1-alpha (2024-12-18)
### 🎯 Alcance de la versión
Actualización incremental de la versión Alpha enfocada en el **Panel Docente**, con funcionalidades iniciales de visualización.

### ✨ Nuevas funcionalidades
#### Panel Docente
- ✅ Visualización de evaluaciones asignadas al docente
- ✅ Estadísticas generales por evaluación
- ✅ Vista de resultados por evaluación
- ⚠️ Datos cargados de forma **estática** (no consume API aún)

### 🚧 Limitaciones actuales
- El panel docente **no está conectado a la API**
- La información mostrada es de prueba (mock / estática)

### 📱 Plataformas soportadas
- Android (APK)
