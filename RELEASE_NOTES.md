## v0.4.3-alpha (2026-01-12)

### Alcance de la versión
Esta pre-release se enfoca en mejoras de experiencia de usuario, estabilidad del flujo de autenticación y refinamiento visual, corrigiendo comportamientos que afectaban el uso continuo de la aplicación durante pruebas prolongadas.

---

### Cambios principales

#### Gestión de datos y refresco
- Se implementa `forceRefresh` en acciones de actualización dentro de `careers_content.dart`
- Las acciones manuales de actualización ahora ignoran caché y consultan directamente la API
- Se reduce la posibilidad de mostrar información desactualizada

#### Flujo de arranque y autenticación
- `splash_screen.dart` ahora espera correctamente:
  - La finalización de la animación
  - La validación completa de sesión y datos
- Se evita quedar atrapado en la pantalla de inicio en escenarios de latencia o error
- Se introduce el estado `_isAuthenticated` en `home_screen.dart` para:
  - Prevenir múltiples aperturas del WebView de inicio de sesión
  - Eliminar el comportamiento de spam del WebView

#### Sistema y modo inmersivo
- Se gestiona correctamente el modo inmersivo usando `immersiveSticky`
- Comportamiento más consistente del sistema UI en navegación prolongada

#### WebView de autenticación
- Actualización visual del WebView de inicio de sesión
- Ajustes en diseño y paleta de colores para mayor coherencia con la aplicación

---

### Mejoras técnicas

#### Frontend
- Mejor control de estados en flujos críticos (splash, login, navegación)
- Reducción de efectos colaterales por reconstrucciones innecesarias
- Código más predecible en escenarios de reconexión o relanzamiento

---

### Correcciones
- Corrección de múltiples ejecuciones del flujo de autenticación
- Corrección de estados inconsistentes al volver desde segundo plano
- Ajustes de diseño menores en pantallas de autenticación

---

### Limitaciones actuales
- El contenido de análisis (`analysis_content.dart`) aún no consume información real
- Las sincronizaciones administrativas aún no cuentan con confirmación previa

---

### Próximos pasos (v0.4.4-alpha)
- Mapeo de información real en `analysis_content.dart`
- Validaciones y confirmaciones antes de ejecutar sincronizaciones
- Estados visuales de ejecución y error en procesos administrativos

---

**Tipo:** Alpha (Pre-release)  
**Fecha de lanzamiento:** 12 de Enero, 2026  
**Compilación:** flutter build apk --release  
**Versión mínima Android:** 5.0 (API 21)

---
