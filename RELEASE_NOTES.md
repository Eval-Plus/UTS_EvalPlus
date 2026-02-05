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
