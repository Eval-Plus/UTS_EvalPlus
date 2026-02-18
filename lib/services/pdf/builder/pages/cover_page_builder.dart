/// Construye la página de portada del PDF del informe docente.
/// Ubicación: lib/services/pdf/builder/pages/cover_page_builder.dart
library;

import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';
import '../components/stat_cards_builder.dart';

/// Genera el widget completo de la portada del PDF.
pw.Widget buildCoverPage({
  required TeacherData teacher,
  required TeacherResponsesReport? responsesReport,
  required List<CommentReport> comments,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final positive = comments.where((c) => c.sentiment == 'positive').length;
  final neutral  = comments.where((c) => c.sentiment == 'neutral').length;
  final negative = comments.where((c) => c.sentiment == 'negative').length;
  final satisfactionRate = comments.isEmpty
      ? 0.0
      : ((positive + (neutral * 0.5)) / comments.length) * 100;

  return pw.Stack(
    children: [
      _buildBackgroundBanner(),
      pw.Padding(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(teacher, boldFont, regularFont, semiBoldFont),
            pw.SizedBox(height: 32),
            _buildTitleBlock(teacher, boldFont, regularFont),
            pw.SizedBox(height: 48),
            _buildStatRow(
              teacher: teacher,
              responsesReport: responsesReport,
              comments: comments,
              satisfactionRate: satisfactionRate,
              boldFont: boldFont,
              regularFont: regularFont,
            ),
            pw.SizedBox(height: 28),
            _buildTableOfContents(
              teacher: teacher,
              responsesReport: responsesReport,
              comments: comments,
              positive: positive,
              neutral: neutral,
              negative: negative,
              boldFont: boldFont,
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
) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
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
            'Sistema de Evaluación Docente',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 11,
              color: PdfPalette.whiteOp(0.75),
            ),
          ),
        ],
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: pw.BoxDecoration(
          color: PdfPalette.whiteOp(0.2),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
          border: pw.Border.all(color: PdfPalette.whiteOp(0.4), width: 1),
        ),
        child: pw.Text(
          'Período ${teacher.period}',
          style: pw.TextStyle(
            font: semiBoldFont,
            fontSize: 11,
            color: PdfPalette.white,
          ),
        ),
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
        'INFORME COMPLETO',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 13,
          color: PdfPalette.whiteOp(0.7),
          letterSpacing: 3,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        teacher.name,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 22,
          color: PdfPalette.white,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        teacher.careerName,
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 13,
          color: PdfPalette.whiteOp(0.8),
        ),
      ),
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
          suffix: comments.isNotEmpty
              ? satisfactionLabel(satisfactionRate)
              : '',
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
  required pw.Font regularFont,
}) {
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
        pw.Text(
          'Contenido del Informe',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 13,
            color: PdfPalette.textPrimary,
          ),
        ),
        pw.SizedBox(height: 12),
        tocItem(
          number: '01',
          title: 'Análisis de Respuestas',
          subtitle:
              '${responsesReport?.questions.length ?? 0} preguntas evaluadas',
          boldFont: boldFont,
          regularFont: regularFont,
        ),
        tocItem(
          number: '02',
          title: 'Materias Asignadas',
          subtitle: '${teacher.subjects.length} materias',
          boldFont: boldFont,
          regularFont: regularFont,
        ),
        tocItem(
          number: '03',
          title: 'Análisis de Inteligencia Artificial',
          subtitle: 'Fortalezas, mejoras y recomendaciones',
          boldFont: boldFont,
          regularFont: regularFont,
        ),
        tocItem(
          number: '04',
          title: 'Comentarios Anónimos',
          subtitle:
              '${comments.length} comentarios ($positive positivos, $neutral neutrales, $negative negativos)',
          boldFont: boldFont,
          regularFont: regularFont,
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
            'Documento confidencial',
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