/// Construye la sección de respuestas por pregunta del PDF.
/// Ubicación: lib/services/pdf/builder/pages/responses_page_builder.dart
library;

import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';
import '../components/stat_cards_builder.dart';

/// Retorna la lista de widgets que componen la sección de respuestas.
List<pw.Widget> buildResponsesSection({
  required TeacherResponsesReport report,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final completionRate = report.totalEvaluations > 0
      ? (report.completedEvaluations / report.totalEvaluations) * 100
      : 0.0;

  return [
    // ── Banner de resumen ──
    buildStatsBanner(
      average: report.averageScore.toStringAsFixed(2),
      completed: report.completedEvaluations,
      total: report.totalEvaluations,
      pending: report.pendingEvaluations,
      completionRate: completionRate,
      boldFont: boldFont,
      regularFont: regularFont,
    ),

    pw.SizedBox(height: 20),

    // ── Encabezado de tabla de preguntas ──
    pw.Text(
      'Distribución de Respuestas por Pregunta',
      style: pw.TextStyle(
        font: boldFont,
        fontSize: 13,
        color: PdfPalette.textPrimary,
      ),
    ),
    pw.SizedBox(height: 12),

    // ── Una tarjeta por pregunta ──
    ...report.questions.map(
      (q) => buildQuestionCard(
        question: q,
        boldFont: boldFont,
        semiBoldFont: semiBoldFont,
        regularFont: regularFont,
      ),
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// TARJETA DE PREGUNTA
// ══════════════════════════════════════════════════════════════

/// Genera la tarjeta completa de una pregunta con sus barras de respuesta.
pw.Widget buildQuestionCard({
  required QuestionResponseData question,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final scoreColor = PdfPalette.forScore(question.average);
  final total = question.responses.values.fold(0, (a, b) => a + b);

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(
          question: question,
          scoreColor: scoreColor,
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
        ),
        _buildResponseBars(
          question: question,
          total: total,
          scoreColor: scoreColor,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ],
    ),
  );
}

pw.Widget _buildQuestionHeader({
  required QuestionResponseData question,
  required PdfColor scoreColor,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: pw.BoxDecoration(
      color: PdfColor(scoreColor.red, scoreColor.green, scoreColor.blue, 0.08),
      borderRadius: const pw.BorderRadius.only(
        topLeft: pw.Radius.circular(8),
        topRight: pw.Radius.circular(8),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Badge de número de pregunta
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: pw.BoxDecoration(
            color: scoreColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            '#${question.number}',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 9,
              color: PdfPalette.white,
            ),
          ),
        ),
        pw.SizedBox(width: 8),

        // Categoría y texto
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                question.category,
                style: pw.TextStyle(
                  font: semiBoldFont,
                  fontSize: 9,
                  color: scoreColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                question.text,
                style: pw.TextStyle(
                  font: semiBoldFont,
                  fontSize: 10,
                  color: PdfPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 8),

        // Badge de promedio
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColor(scoreColor.red, scoreColor.green, scoreColor.blue, 0.15),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(
              color: PdfColor(scoreColor.red, scoreColor.green, scoreColor.blue, 0.4),
              width: 1,
            ),
          ),
          child: pw.Text(
            question.average.toStringAsFixed(1),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              color: scoreColor,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildResponseBars({
  required QuestionResponseData question,
  required int total,
  required PdfColor scoreColor,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(12),
    child: pw.Column(
      children: [
        // Barra global de progreso
        pw.Row(
          children: [
            pw.Expanded(
              child: progressBar(
                value: question.average / 5,
                color: scoreColor,
                height: 6,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              '$total resp.',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: PdfPalette.textSecond,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),

        // Barras por valor Likert (5 → 1)
        pw.Row(
          children: [5, 4, 3, 2, 1].map((val) {
            return _buildScaleBar(
              value: val,
              count: question.responses[val] ?? 0,
              total: total,
              boldFont: boldFont,
              regularFont: regularFont,
            );
          }).toList(),
        ),
      ],
    ),
  );
}

pw.Widget _buildScaleBar({
  required int value,
  required int count,
  required int total,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  final pct = total > 0 ? count / total : 0.0;
  final color = PdfPalette.forScale(value);
  final label = scaleLabel(value);

  return pw.Expanded(
    child: pw.Padding(
      padding: const pw.EdgeInsets.only(right: 6),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(font: boldFont, fontSize: 8, color: color),
              ),
              pw.Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 7,
                  color: PdfPalette.textSecond,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          progressBar(value: pct, color: color, height: 5),
        ],
      ),
    ),
  );
}