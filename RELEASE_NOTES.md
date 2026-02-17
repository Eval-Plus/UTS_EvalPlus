## v0.5.5-rc (2026-02-17)
### Alcance de la versión
Esta versión se enfoca en **mejoras de experiencia de usuario en el modal de informe docente**, añadiendo funcionalidad real de actualización de datos y refinamiento de estados vacíos.

---

### Cambios principales

#### 🔄 Pull-to-refresh real en tabs del informe docente
- Se implementa **refresh funcional desde la API** en los tabs de Respuestas, Comentarios y Materias
- Anteriormente el gesto de deslizar hacia abajo solo mostraba el indicador visual sin re-consultar el servidor
- Ahora cada tab lanza una petición con `forceRefresh: true`, evitando el caché y obteniendo datos actualizados
- El indicador de carga usa los colores de la paleta admin (`palette.primary`) para consistencia visual

#### ⏳ Pantalla de splash durante el refresh
- Al iniciar el pull-to-refresh, cada tab muestra el componente `AIRegenerationLoading` como pantalla de transición
- Diferencia clara entre **carga inicial** (diálogo fullscreen `ReportLoadingDialog`) y **refresh posterior** (splash a nivel de tab)
- Callbacks separados por tab: `_refreshResponses`, `_refreshComments`, `_refreshSubjects` en `teacher_report_modal.dart`

#### 💬 Mejoras en estados vacíos del tab de Comentarios
- Los estados vacíos ya **no ocupan la pantalla completa**, evitando que oculten los filtros disponibles
- Dos escenarios diferenciados:
  - **Sin comentarios en absoluto**: empty state inline sin filtros
  - **Filtro activo sin resultados**: filtros visibles + empty state inline con hint *"Prueba seleccionando otro filtro"*
- Se añade `_buildInlineEmptyState()` y helper `_getFilterLabel()` para mensajes contextuales

---

### Archivos modificados
- `lib/widgets/admin/analysis/reports/tabs/responses_tab.dart`
- `lib/widgets/admin/analysis/reports/tabs/comments_tab.dart`
- `lib/widgets/admin/analysis/reports/tabs/subjects_tab.dart`
- `lib/widgets/admin/analysis/reports/teacher_report_modal.dart`

---

### Mejoras técnicas

#### UI/UX
- Consistencia visual del spinner de refresh con la paleta de color por rol
- Estados vacíos contextuales con hints accionables para el usuario
- Transición suave entre estado de carga y contenido en cada tab

#### Arquitectura
- Callbacks de refresh desacoplados por tab, facilitando migración futura a endpoints independientes
- `SubjectsTab` migrado de `StatelessWidget` a `StatefulWidget` para soportar estado de refresh
- `_refreshSubjects` preparado para conectarse a `getSubjectsReport()` cuando el endpoint esté disponible

---

### Próximos pasos (v0.6.0)
- Conexión completa del Informe Docente con endpoints productivos
- Métricas comparativas entre periodos
- Exportación de informes en PDF
- Optimización de rendimiento en carga de dashboards

---

**Tipo:** Release Candidate (RC)  
**Fecha de lanzamiento:** 17 de Febrero, 2026  
**Compilación:** `flutter build apk --release`  
**Tag:** v0.5.5-rc