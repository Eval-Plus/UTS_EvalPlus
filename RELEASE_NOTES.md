## v0.5.0-rc (2026-01-15)
### Alcance de la versión
Esta versión marca la transición de Alpha a Release Candidate (RC), consolidando mejoras críticas en la experiencia de usuario del frontend y refactorización estructural del backend. Se enfoca en corregir bugs importantes, mejorar la navegación y fortalecer la lógica de sincronización administrativa con validaciones robustas.

---

### Cambios principales

#### 🐛 Correcciones críticas
- **Bug de mensaje de bienvenida corregido**: El mensaje de bienvenida ahora redirige correctamente al panel de usuario en lugar de la pestaña de inicio, mejorando el flujo de primera experiencia

#### 🎨 Experiencia de usuario mejorada
- **Navegación por deslizamiento (swipe)**: Se implementa navegación horizontal por gestos en la barra de navegación inferior, permitiendo cambiar entre pestañas con swipe izquierda/derecha
- Mayor fluidez y naturalidad en la navegación entre secciones
- Interacción más intuitiva alineada con estándares modernos de aplicaciones móviles

#### ⚙️ Backend - Refactorización de sincronización administrativa
- **Límites de sincronización implementados**:
  - Estudiantes: Máximo 7 materias (1 por cada una de las 7 carreras)
  - Docentes: Máximo 7 materias por profesor
  
- **Separación de responsabilidades**:
  - Sincronización de estudiantes: Solo inscribe en carreras y materias
  - Sincronización de docentes: Solo asigna materias (ya NO genera evaluaciones)
  - Generación de evaluaciones: Proceso separado e independiente

- **Validaciones agregadas**:
  - ✅ Verificación de existencia de estudiantes antes de sincronizar
  - ✅ Verificación de existencia de profesores antes de sincronizar
  - ✅ Verificación de carreras disponibles
  - ✅ Verificación de materias sin profesor con estudiantes inscritos
  - ✅ Validación de fechas en generación de evaluaciones
  - ✅ Mensajes de error descriptivos y accionables

---

### Mejoras técnicas

#### Frontend
- Implementación de `PageController` para navegación por swipe
- Sincronización bidireccional entre swipe y tap en barra de navegación
- Mejoras en la gestión de estado de navegación

#### Backend
- **Archivos refactorizados**:
  - `admin.service.js`: Lógica de sincronización con validaciones
  - `enrollment.service.js`: Límites e inscripción optimizada
  - `admin.controller.js`: Manejo robusto de errores
  
- Flujo de sincronización claramente definido:
  ```
  1. Sincronizar Estudiantes → 7 materias (1 por carrera)
  2. Sincronizar Docentes → Máximo 7 materias
  3. Generar Evaluaciones → Para materias con docente
  ```

---

### Correcciones
- Flujo de redirección post-bienvenida corregido
- Lógica de sincronización de docentes separada de generación de evaluaciones
- Prevención de inscripciones duplicadas
- Mejor manejo de casos donde no existen datos para sincronizar

---

### Limitaciones actuales
- La paleta de colores del panel de análisis aún requiere ajustes finales
- No existen diálogos de confirmación antes de ejecutar sincronizaciones masivas
- La aplicación permite rotación de pantalla sin diseño optimizado para horizontal
- Los límites de sincronización (7 materias) están hardcodeados en constantes

---

### Próximos pasos (v0.5.1-rc / v0.6.0-rc)
- Diálogos de confirmación para procesos administrativos críticos
- Indicadores de progreso durante sincronizaciones largas
- Adaptación completa del panel de análisis a paleta institucional
- Bloqueo de orientación horizontal
- Configuración dinámica de límites de sincronización
- Logs detallados de sincronización accesibles desde UI

---

### Notas de migración
**Para administradores que actualicen desde v0.4.x:**
- La sincronización de docentes ya NO genera evaluaciones automáticamente
- Debe ejecutarse el endpoint de generación de evaluaciones por separado
- Se recomienda seguir el flujo: Estudiantes → Docentes → Evaluaciones
- Los estudiantes ahora tendrán exactamente 7 materias (1 por carrera)
- Los docentes tendrán máximo 7 materias asignadas

**Flujo recomendado:**
```bash
1. POST /api/admin/sync/students
2. POST /api/admin/sync/teachers
3. POST /api/admin/evaluations/generate
```

---

**Tipo:** Release Candidate (RC)  
**Fecha de lanzamiento:** 15 de Enero, 2026  
**Compilación:** `flutter build apk --release`  
**Versión mínima Android:** 5.0 (API 21)  
**Versión mínima iOS:** 11.0

---

## v0.4.4-alpha (2026-01-13)
### Alcance de la versión
Esta versión cierra el ciclo de la serie v0.4.x incorporando mejoras visuales, ajustes de experiencia de usuario y la integración de información real en el panel de análisis administrativo, consolidando el sistema como funcional y evaluable en escenarios reales de prueba.

---

### Cambios principales

#### Experiencia de usuario
- Se incorpora un mensaje de bienvenida al ingreso a la aplicación
- Mejora en el flujo y comportamiento del sistema de cierre de sesión
- Navegación más clara y consistente durante el uso continuo de la aplicación

#### Panel de Administración – Configuración
- Adaptación completa de `config_content.dart` a la paleta de colores institucional
- Uso de distintos tonos de verde para mejorar jerarquía visual y legibilidad
- Mejor coherencia visual con el resto de la aplicación

#### Panel de Administración – Análisis
- Integración de información real en `analysis_content.dart`
- El panel de análisis deja de ser estático y refleja datos reales del sistema
- Base preparada para futuras mejoras visuales y analíticas

---

### Mejoras técnicas

#### Frontend
- Ajustes visuales generales en componentes administrativos
- Mejor alineación entre diseño, paleta de colores y estructura de contenido
- Código preparado para futuras restricciones de orientación de pantalla

---

### Correcciones
- Correcciones menores de presentación visual
- Ajustes en flujos de sesión y salida del usuario
- Mejor consistencia en estados de navegación

---

### Limitaciones actuales
- La paleta de colores del panel de análisis aún no está completamente alineada con los colores institucionales
- No existen validaciones previas ni confirmaciones antes de ejecutar procesos administrativos críticos
- La aplicación permite rotación de pantalla, aunque el diseño no está optimizado para orientación horizontal

---

### Próximos pasos (v0.5.0-alpha)
- Adaptación completa del panel de análisis a la paleta institucional
- Mejoras visuales adicionales y refinamiento de UI
- Validaciones y confirmaciones para procesos administrativos
- Bloqueo de orientación horizontal para evitar inconsistencias de diseño
- Endurecimiento general del flujo administrativo

---

**Tipo:** Alpha (Pre-release)  
**Fecha de lanzamiento:** 13 de Enero, 2026  
**Compilación:** flutter build apk --release  
**Versión mínima Android:** 5.0 (API 21)

---
