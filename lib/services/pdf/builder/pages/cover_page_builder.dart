/// Construye la página de portada del PDF del informe docente.
/// Ubicación: lib/services/pdf/builder/pages/cover_page_builder.dart
library;

import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';
import '../components/stat_cards_builder.dart';

/// Genera el widget completo de la portada del PDF.
Future<pw.Widget> buildCoverPage({
  required TeacherData teacher,
  required TeacherResponsesReport? responsesReport,
  required List<CommentReport> comments,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) async {
  final positive = comments.where((c) => c.sentiment == 'positive').length;
  final neutral  = comments.where((c) => c.sentiment == 'neutral').length;
  final negative = comments.where((c) => c.sentiment == 'negative').length;
  final satisfactionRate = comments.isEmpty
      ? 0.0
      : ((positive + (neutral * 0.5)) / comments.length) * 100;

  // Cargar logo institucional UTS
  pw.ImageProvider? logoImage;
  try {
    final logoBytes = await rootBundle.load(
      'assets/illustrations/LogoUnidades.png',
    );
    logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
  } catch (_) {}

  return pw.Stack(
    children: [
      _buildBackgroundBanner(),
      pw.Padding(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(
              teacher,
              boldFont,
              regularFont,
              semiBoldFont,
              logoImage,
            ),
            pw.SizedBox(height: 28),
            _buildTitleBlock(teacher, boldFont, regularFont),
            pw.SizedBox(height: 40),
            _buildStatRow(
              teacher: teacher,
              responsesReport: responsesReport,
              comments: comments,
              satisfactionRate: satisfactionRate,
              boldFont: boldFont,
              regularFont: regularFont,
            ),
            pw.SizedBox(height: 24),
            _buildTableOfContents(
              teacher: teacher,
              responsesReport: responsesReport,
              comments: comments,
              positive: positive,
              neutral: neutral,
              negative: negative,
              boldFont: boldFont,
              semiBoldFont: semiBoldFont,
              regularFont: regularFont,
            ),
            pw.Spacer(),
            _buildCoverFooter(boldFont, regularFont),
          ],
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
// SECCIONES INTERNAS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildBackgroundBanner() {
  return pw.Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: pw.Container(
      height: 260,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [PdfPalette.primary, PdfPalette.primaryDark],
        ),
      ),
    ),
  );
}

pw.Widget _buildHeaderRow(
  TeacherData teacher,
  pw.Font boldFont,
  pw.Font regularFont,
  pw.Font semiBoldFont,
  pw.ImageProvider? logoImage,
) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      // Lado izquierdo: nombre del sistema y subtítulo
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EVAL+',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 28,
              color: PdfPalette.white,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Sistema de Evaluación Docente UTS',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 12,
              color: PdfPalette.whiteOp(0.90),
            ),
          ),
          pw.Text(
            'Universidad Tecnológica de Santander',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              color: PdfPalette.whiteOp(0.80),
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildTitleBlock(
  TeacherData teacher,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'INFORME COMPLETO DE EVALUACIÓN',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
          color: PdfPalette.whiteOp(0.70),
          letterSpacing: 2.5,
        ),
      ),
      pw.SizedBox(height: 6),
      // Prefijo "Docente" antes del nombre
      pw.Text(
        'Docente:',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 12,
          color: PdfPalette.whiteOp(0.75),
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        teacher.name,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 22,
          color: PdfPalette.white,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Período: ${teacher.period}',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 10,
          color: PdfPalette.white,
        ),
      ),
      // ❌ Se eliminó teacher.careerName aquí intencionalmente,
      // ya que el docente puede dictar materias en múltiples carreras.
    ],
  );
}

pw.Widget _buildStatRow({
  required TeacherData teacher,
  required TeacherResponsesReport? responsesReport,
  required List<CommentReport> comments,
  required double satisfactionRate,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: buildCoverStatCard(
          label: 'Promedio General',
          value: responsesReport != null
              ? responsesReport.averageScore.toStringAsFixed(2)
              : 'N/D',
          suffix: '/ 5.0',
          color: PdfPalette.excellent,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: buildCoverStatCard(
          label: 'Evaluaciones',
          value: responsesReport != null
              ? '${responsesReport.completedEvaluations}'
              : 'N/D',
          suffix: 'completadas',
          color: PdfPalette.blue,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: buildCoverStatCard(
          label: 'Satisfacción',
          value: comments.isNotEmpty
              ? '${satisfactionRate.toStringAsFixed(1)}%'
              : 'N/D',
          suffix: comments.isNotEmpty ? satisfactionLabel(satisfactionRate) : '',
          color: PdfPalette.purple,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: buildCoverStatCard(
          label: 'Materias',
          value: '${teacher.subjects.length}',
          suffix: 'asignadas',
          color: PdfPalette.accent,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
    ],
  );
}

pw.Widget _buildTableOfContents({
  required TeacherData teacher,
  required TeacherResponsesReport? responsesReport,
  required List<CommentReport> comments,
  required int positive,
  required int neutral,
  required int negative,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final questionCount = responsesReport?.questions.length ?? 0;
  final completionRate = responsesReport?.completionRate ?? 0.0;

  return pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: PdfPalette.bgLight,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título de la sección
        pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 18,
              decoration: pw.BoxDecoration(
                color: PdfPalette.primary,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'Contenido del Informe',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 13,
                color: PdfPalette.textPrimary,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),

        // ── 01 Análisis de Respuestas ──
        _tocItemDetailed(
          number: '01',
          title: 'Análisis de Respuestas',
          subtitle:
              '$questionCount preguntas evaluadas  •  ${completionRate.toStringAsFixed(0)}% completitud',
          description:
              'Detalle de cada pregunta del formulario de evaluación docente. '
              'Muestra el total de respuestas recibidas por pregunta, '
              'el promedio calculado en escala 1–5, la distribución de '
              'opciones (Nunca → Siempre) y el porcentaje de evaluaciones '
              'completadas frente a las pendientes.',
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
          regularFont: regularFont,
        ),

        // ── 02 Materias Asignadas ──
        _tocItemDetailed(
          number: '02',
          title: 'Materias Asignadas',
          subtitle: '${teacher.subjects.length} materias',
          description:
              'Listado de todas las asignaturas a cargo del docente '
              'durante el período. Incluye el nombre de la materia, '
              'el programa al que pertenece, el número de estudiantes '
              'matriculados y el progreso de evaluación de cada grupo.',
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
          regularFont: regularFont,
        ),

        // ── 03 Análisis de IA ──
        _tocItemDetailed(
          number: '03',
          title: 'Análisis de Inteligencia Artificial',
          subtitle: 'Perfil docente · Fortalezas · Mejoras · Recomendaciones',
          description:
              'Análisis generado automáticamente a partir de los datos '
              'cuantitativos y cualitativos de la evaluación. Presenta un '
              'perfil general del desempeño, las principales fortalezas '
              'identificadas, las oportunidades de mejora y un conjunto de '
              'recomendaciones concretas para potenciar la práctica docente.',
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
          regularFont: regularFont,
        ),

        // ── 04 Comentarios Anónimos ──
        _tocItemDetailed(
          number: '04',
          title: 'Comentarios Anónimos de Estudiantes',
          subtitle:
              '${comments.length} comentarios  •  $positive positivos  •  $neutral neutrales  •  $negative negativos',
          description:
              'Recopilación de los comentarios libres que los estudiantes '
              'dejaron al finalizar la evaluación. Cada comentario incluye '
              'el análisis de sentimiento aplicado (positivo, neutral o '
              'negativo) para facilitar una lectura rápida del estado '
              'general de la percepción estudiantil sobre el docente.',
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
          regularFont: regularFont,
          isLast: true,
        ),
      ],
    ),
  );
}

/// Ítem de tabla de contenidos con número, título, subtítulo y descripción expandida.
pw.Widget _tocItemDetailed({
  required String number,
  required String title,
  required String subtitle,
  required String description,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
  bool isLast = false,
}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 12),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Número del ítem
        pw.Container(
          width: 26,
          height: 26,
          decoration: pw.BoxDecoration(
            color: PdfPalette.primary,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Center(
            child: pw.Text(
              number,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 9,
                color: PdfPalette.white,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 12),

        // Contenido textual
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Título
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: PdfPalette.textPrimary,
                ),
              ),
              pw.SizedBox(height: 2),
              // Subtítulo con datos clave
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  font: semiBoldFont,
                  fontSize: 8,
                  color: PdfPalette.primary,
                ),
              ),
              pw.SizedBox(height: 4),
              // Descripción explicativa
              pw.Text(
                description,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8.5,
                  color: PdfPalette.textSecond,
                  lineSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildCoverFooter(pw.Font boldFont, pw.Font regularFont) {
  return pw.Column(
    children: [
      pw.Divider(color: PdfPalette.border),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado por Eval+ • ${formattedDate()}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: PdfPalette.textSecond,
            ),
          ),
          pw.Text(
            'Documento Confidencial UTS',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: PdfPalette.textSecond,
            ),
          ),
        ],
      ),
    ],
  );
}