## v1.1.0-stable (2026-02-25)
### 🤖 Análisis de datos del docente con IA — Ahora funcional

Esta versión activa completamente el módulo de **Análisis de datos del docente con IA**, que estaba planteado arquitectónicamente desde v1.0.0-stable pero pendiente de integración. El módulo ya es funcional de extremo a extremo: desde la generación del análisis en la API hasta su visualización en la aplicación Flutter.

---

### Cambios respecto a v1.0.0-stable

#### 🤖 Módulo de Análisis con IA (nuevo — funcional)
- Integración completa del endpoint de generación y consulta de análisis IA en la aplicación Flutter
- El informe completo del docente ahora incluye el panel de análisis generado por IA con los siguientes campos:
  - **Perfil docente**: valoración global de hasta 30 palabras basada en respuestas y comentarios
  - **Fortalezas**: hasta 2 fortalezas identificadas con evidencia en los datos reales
  - **Oportunidades de mejora**: hasta 2 áreas con evidencia real de bajo desempeño
  - **Recomendaciones**: hasta 2 acciones concretas derivadas de las oportunidades de mejora
  - **Análisis de respuestas**: conclusión interpretativa de las puntuaciones cuantitativas (máx. 40 palabras)
  - **Análisis de comentarios**: conclusión sobre la percepción estudiantil con tasa de satisfacción en porcentaje (máx. 40 palabras)

#### 🛠️ Mejoras en la API (backend)
- Parseo robusto de la respuesta del modelo LLaMA con tres estrategias de extracción en cascada (marcadores explícitos → bloque markdown → búsqueda de llaves)
- Prompt del sistema rediseñado para generar **conclusiones interpretativas**, no un reflejo literal de los datos
- Se prohíbe explícitamente la alucinación: el modelo solo puede basarse en los datos proporcionados
- Normalización y truncado server-side de todos los campos como segunda línea de defensa
- `MAX_TOKENS` ajustado a 2000 para garantizar generación completa sin desperdiciar tokens
- Nuevos campos `responses_comment` y `comments_comment` añadidos a la tabla `ai_analysis` (migración incluida)

---

### Estado del proyecto

| Módulo | Estado |
|---|---|
| Autenticación y roles | ✅ Completo |
| Dashboard administrador | ✅ Completo |
| Gestión de evaluaciones | ✅ Completo |
| Informes docentes | ✅ Completo |
| Generación de PDF | ✅ Completo |
| Pull-to-refresh & empty states | ✅ Completo |
| **Análisis de datos del docente con IA** | ✅ Completo |

---

**Tipo:** Stable Release  
**Fecha de lanzamiento:** 25 de Febrero, 2026  
**Compilación:** `flutter build apk --split-per-abi --release`  
**Tag:** v1.1.0-stable