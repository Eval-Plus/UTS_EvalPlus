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

