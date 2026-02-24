## v1.0.0-stable (2026-02-21)
### 🎉 Primera versión estable — Salida a producción
Esta versión marca el **lanzamiento oficial a producción de EvalPlus**. La aplicación se considera funcional y completa en su núcleo. Los cambios futuros esperados se limitan a mejoras de diseño y la integración pendiente del módulo *Análisis de datos del docente con IA*, cuya arquitectura ya está preparada en cliente y API.

---

### Cambios respecto a v0.5.5-rc

#### 🎨 Mejoras de UI/Diseño
- En `careers_content.dart` se añadió una nueva función en el modelo para mostrar **iconos diferenciados por carrera**, mejorando la identificación visual de cada una

#### 📄 Mejoras en generación de PDF
- Mejoras visuales para facilitar la lectura del contenido generado
- Uso de helpers como `withOpacity` para evitar textos con contraste insuficiente o invisibles sobre fondos de color

#### 🧹 Limpieza de funciones no utilizadas
- Se comentó parte de `_actionButtons` para **desactivar botones de acciones no planificadas** en el corto plazo: exportar a Excel, descargar y compartir
- Esto simplifica la interfaz y evita exponer funcionalidades incompletas en producción

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
| **Análisis de datos del docente con IA** | 🔜 Pendiente (API + App listos para integrar) |

---

### Funcionalidad pendiente — Análisis con IA
El módulo de **Análisis de datos del docente con IA** está completamente planteado a nivel de arquitectura. Su activación únicamente requiere:
1. Actualizar el endpoint correspondiente en la API
2. Conectar la llamada desde la aplicación Flutter

No implica cambios estructurales; es una integración puntual.

---

**Tipo:** Stable Release  
**Fecha de lanzamiento:** 21 de Febrero, 2026  
**Compilación:** `flutter build apk --split-per-abi --release`  
**Tag:** v1.0.0-stable