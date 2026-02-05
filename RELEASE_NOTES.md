## v0.5.3-rc (2026-02-05)
### Alcance de la versión
Esta versión se enfoca en **mejoras de experiencia de usuario** mediante el bloqueo de orientación horizontal y optimizaciones en el sistema de autenticación de Microsoft.

---

### Cambios principales

#### 📱 Bloqueo de orientación horizontal
- La aplicación ahora **solo permite orientación vertical** (portrait)
- Mejora la consistencia visual y evita problemas de diseño en modo landscape
- Implementación a nivel de sistema usando `SystemChrome.setPreferredOrientations`

#### 🔐 Mejoras en WebView de autenticación Microsoft
- **Inyección de JavaScript** para optimizar el comportamiento de campos de texto
- Mejora significativa en la respuesta al escribir y borrar texto
- Deshabilitación de autocompletado, autocorrección y autocapitalización para evitar conflictos
- Mejor manejo del evento `Backspace` para borrado fluido

---

### Mejoras técnicas

#### UX/UI
- Experiencia más consistente al forzar modo portrait
- Input más responsivo en flujo de autenticación

#### WebView
- Script de inyección ejecutado después de cada carga de página
- Compatibilidad mejorada con diferentes dispositivos Android

---

### Próximos pasos (v0.6.0)
- Conexión real del Informe Completo con la API
- Métricas dinámicas y comparativas por periodo
- Exportación del informe (PDF)
- Mejoras visuales y animaciones internas

---

**Tipo:** Release Candidate (RC)  
**Fecha de lanzamiento:** 05 de Febrero, 2026  
**Compilación:** `flutter build apk --release`  
**Tag:** v0.5.3-rc

---

## v0.5.2-rc (2026-01-22)
### Alcance de la versión
Esta versión introduce el **Informe Completo del Docente**, una vista integral que centraliza toda la información relevante de un docente en un solo lugar. Se agregan módulos visuales hardcodeados para análisis global y se corrigen inconsistencias en los filtros académicos mediante consumo real de datos desde la API.

---

### Cambios principales

#### 📊 Informe Completo del Docente (hardcodeado)
- Nueva vista unificada para observación global del docente
- Implementación inicial **hardcodeada** de los módulos:
  - 📝 **Respuestas**: visualización consolidada de respuestas obtenidas
  - 📚 **Materias**: listado y asociación de materias evaluadas
  - 🤖 **Análisis con IA**: sección dedicada a interpretación automática
  - 💬 **Comentarios anónimos**: observación cualitativa del feedback recibido
- Estructura preparada para futura conexión dinámica con API

#### 🎛️ Correcciones en filtros académicos
- Eliminación de carreras genéricas o inconsistentes
- Integración de un **endpoint adicional de la API** para:
  - Obtener todas las carreras reales del sistema
  - Garantizar coherencia entre frontend y backend
- Filtros ahora reflejan fielmente la estructura académica institucional

#### 🎨 Mejoras de experiencia de usuario
- Navegación más clara dentro del perfil del docente
- Jerarquía visual mejorada en el informe completo
- Preparación visual para futuras mejoras dinámicas

---

### Mejoras técnicas

#### Consumo de API
- Nuevo flujo para obtención de carreras desde backend
- Reducción de supuestos hardcodeados en filtros
- Base sólida para futuras extensiones dinámicas

#### Arquitectura
- Componentes del informe organizados por módulos
- Código preparado para desacoplar hardcode → API
- Mejor mantenibilidad del panel docente

---

### Limitaciones actuales
- El Informe Completo utiliza datos hardcodeados (fase inicial)
- No todos los módulos tienen interacción dinámica aún
- El análisis con IA es únicamente demostrativo

---

### Próximos pasos (v0.5.3-rc / v0.6.0)
- Conexión real del Informe Completo con la API
- Métricas dinámicas y comparativas por periodo
- Exportación del informe (PDF)
- Mejoras visuales y animaciones internas
- Permisos y visibilidad por rol

---

**Tipo:** Release Candidate (RC)  
**Fecha de lanzamiento:** 22 de Enero, 2026  
**Compilación:** `flutter build apk --release`  
**Tag:** v0.5.2-rc

