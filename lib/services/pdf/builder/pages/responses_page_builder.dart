/// Construye la sección de respuestas por pregunta del PDF.
/// Rediseñado para mejor legibilidad, paletas diferenciadas y layout compacto.
/// Ubicación: lib/services/pdf/builder/pages/responses_page_builder.dart
library;

import 'dart:ui';

import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';

// ══════════════════════════════════════════════════════════════
// COLORES DIFERENCIADOS PARA LAS TARJETAS DE RESUMEN
// Inspirado en responses_tab.dart (verde / azul / dinámico)
// ══════════════════════════════════════════════════════════════

// Promedio → verde de marca
final _avgGradientA = PdfPalette.primary;
final _avgGradientB = PdfPalette.primaryDark;

// Respuestas → azul
final _respGradientA = toPdfColor(const Color(0xFF2196F3));
final _respGradientB = toPdfColor(const Color(0xFF1976D2));

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
    // ── Banner de 3 tarjetas diferenciadas ──
    _buildSummaryBanner(
      report: report,
      completionRate: completionRate,
      boldFont: boldFont,
      regularFont: regularFont,
    ),

    pw.SizedBox(height: 16),

    // ── Título de la tabla ──
    _buildSectionTitle(
      questionCount: report.questions.length,
      boldFont: boldFont,
      regularFont: regularFont,
    ),

    pw.SizedBox(height: 10),

    // ── Tabla compacta de preguntas ──
    _buildQuestionsTable(
      questions: report.questions,
      boldFont: boldFont,
      semiBoldFont: semiBoldFont,
      regularFont: regularFont,
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// BANNER DE RESUMEN (3 tarjetas con colores distintos)
// ══════════════════════════════════════════════════════════════

pw.Widget _buildSummaryBanner({
  required TeacherResponsesReport report,
  required double completionRate,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Row(
    children: [
      // Tarjeta 1: Promedio (verde)
      pw.Expanded(
        child: _buildGradientCard(
          icon: '★',
          label: 'Promedio General',
          value: report.averageScore.toStringAsFixed(2),
          sub: '/ 5.0',
          gradA: _avgGradientA,
          gradB: _avgGradientB,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
      pw.SizedBox(width: 10),

      // Tarjeta 2: Evaluaciones completadas (azul)
      pw.Expanded(
        child: _buildGradientCard(
          icon: '✓',
          label: 'Evaluaciones',
          value: '${report.completedEvaluations}',
          sub: 'de ${report.totalEvaluations} completadas',
          gradA: _respGradientA,
          gradB: _respGradientB,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
      pw.SizedBox(width: 10),

      // Tarjeta 3: Completitud (color dinámico según tasa)
      pw.Expanded(
        child: _buildCompletionCard(
          icon: '◆',
          completionRate: completionRate,
          pending: report.pendingEvaluations,
          boldFont: boldFont,
          regularFont: regularFont,
        ),
      ),
    ],
  );
}

/// Tarjeta con degradado de color fijo.
pw.Widget _buildGradientCard({
  required String icon,
  required String label,
  required String value,
  required String sub,
  required PdfColor gradA,
  required PdfColor gradB,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        begin: pw.Alignment.topLeft,
        end: pw.Alignment.bottomRight,
        colors: [gradA, gradB],
      ),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          icon,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 14,
            color: PdfPalette.whiteOp(0.7),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: PdfPalette.whiteOp(0.75),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 26,
            color: PdfPalette.white,
            height: 1,
          ),
        ),
        pw.Text(
          sub,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: PdfPalette.whiteOp(0.7),
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

/// Tarjeta de completitud con color dinámico según la tasa.
pw.Widget _buildCompletionCard({
  required String icon,
  required double completionRate,
  required int pending,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  final colors = _completionGradient(completionRate);
  final statusLabel = completionLabel(completionRate);

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        begin: pw.Alignment.topLeft,
        end: pw.Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          icon,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 14,
            color: PdfPalette.whiteOp(0.7),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Completitud',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: PdfPalette.whiteOp(0.75),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${completionRate.toStringAsFixed(0)}%',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 26,
            color: PdfPalette.white,
            height: 1,
          ),
        ),
        pw.Text(
          pending == 0 ? statusLabel : '$pending pendientes',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: PdfPalette.whiteOp(0.7),
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

/// Degradados para la tarjeta de completitud según porcentaje.
List<PdfColor> _completionGradient(double rate) {
  if (rate >= 90) {
    return [toPdfColor(const Color(0xFF10B981)), toPdfColor(const Color(0xFF059669))];
  }
  if (rate >= 70) {
    return [toPdfColor(const Color(0xFF8BC34A)), toPdfColor(const Color(0xFF689F38))];
  }
  if (rate >= 50) {
    return [toPdfColor(const Color(0xFFFCD34D)), toPdfColor(const Color(0xFFF59E0B))];
  }
  if (rate >= 30) {
    return [toPdfColor(const Color(0xFFF59E0B)), toPdfColor(const Color(0xFFD97706))];
  }
  return [toPdfColor(const Color(0xFFEF4444)), toPdfColor(const Color(0xFFDC2626))];
}

// ══════════════════════════════════════════════════════════════
// TÍTULO DE SECCIÓN
// ══════════════════════════════════════════════════════════════

pw.Widget _buildSectionTitle({
  required int questionCount,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Row(
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          color: PdfPalette.bgLight,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfPalette.border, width: 1),
        ),
        child: pw.Text(
          '?',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 10,
            color: PdfPalette.textSecond,
          ),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.Text(
          'Distribución de Respuestas por Pregunta',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 13,
            color: PdfPalette.textPrimary,
          ),
        ),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: pw.BoxDecoration(
          color: toPdfColor(const Color(0xFFEFF6FF)),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(
            color: toPdfColor(const Color(0xFFBFDBFE)),
            width: 1,
          ),
        ),
        child: pw.Text(
          '$questionCount preguntas',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 9,
            color: toPdfColor(const Color(0xFF3B82F6)),
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
// TABLA COMPACTA DE PREGUNTAS
// Una fila por pregunta: número | enunciado | barra Likert | promedio
// ══════════════════════════════════════════════════════════════

pw.Widget _buildQuestionsTable({
  required List<QuestionResponseData> questions,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      children: [
        // Cabecera de tabla
        _buildTableHeader(boldFont),

        // Filas de preguntas con divisor
        ...questions.asMap().entries.map((entry) {
          return pw.Column(
            children: [
              if (entry.key > 0)
                pw.Divider(height: 1, color: PdfPalette.border),
              _buildQuestionRow(
                question: entry.value,
                index: entry.key,
                boldFont: boldFont,
                semiBoldFont: semiBoldFont,
                regularFont: regularFont,
              ),
            ],
          );
        }),
      ],
    ),
  );
}

/// Cabecera de la tabla de preguntas.
pw.Widget _buildTableHeader(pw.Font boldFont) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [PdfPalette.primary, PdfPalette.primaryDark],
      ),
      borderRadius: const pw.BorderRadius.only(
        topLeft: pw.Radius.circular(10),
        topRight: pw.Radius.circular(10),
      ),
    ),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 28), // espacio para el badge #N
        pw.SizedBox(width: 8),
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            'Enunciado',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8,
              color: PdfPalette.whiteOp(0.85),
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.SizedBox(
          width: 130,
          child: pw.Text(
            'Distribución (N → S)',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8,
              color: PdfPalette.whiteOp(0.85),
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.SizedBox(
          width: 36,
          child: pw.Text(
            'Prom.',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8,
              color: PdfPalette.whiteOp(0.85),
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

/// Fila compacta de una pregunta.
pw.Widget _buildQuestionRow({
  required QuestionResponseData question,
  required int index,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final scoreColor = PdfPalette.forScore(question.average);
  // Colores de categoría rotativos (igual que responses_tab.dart)
  final categoryColors = [
    toPdfColor(const Color(0xFF3B82F6)),
    toPdfColor(const Color(0xFF8B5CF6)),
    toPdfColor(const Color(0xFF10B981)),
    toPdfColor(const Color(0xFFF59E0B)),
    toPdfColor(const Color(0xFFEC4899)),
  ];
  final categoryColor = categoryColors[index % categoryColors.length];
  final total = question.responses.values.fold(0, (a, b) => a + b);

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    color: index.isEven
        ? PdfPalette.white
        : toPdfColor(const Color(0xFFFAFAFA)),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Badge de número con color de categoría
        pw.Container(
          width: 28,
          height: 22,
          decoration: pw.BoxDecoration(
            color: categoryColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Center(
            child: pw.Text(
              '#${question.number}',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 8,
                color: PdfPalette.white,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 8),

        // Categoría + Enunciado
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                question.category,
                style: pw.TextStyle(
                  font: semiBoldFont,
                  fontSize: 7,
                  color: categoryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                question.text,
                style: pw.TextStyle(
                  font: semiBoldFont,
                  fontSize: 9,
                  color: PdfPalette.textPrimary,
                  lineSpacing: 1,
                ),
                maxLines: 2,
                overflow: pw.TextOverflow.clip,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 8),

        // Mini barras Likert (5 → 1) de manera horizontal compacta
        pw.SizedBox(
          width: 130,
          child: _buildMiniLikertBars(
            question: question,
            total: total,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
        pw.SizedBox(width: 8),

        // Badge de promedio
        pw.Container(
          width: 36,
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            color: withOpacity(scoreColor, 0.15),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(
              color: withOpacity(scoreColor, 0.35),
              width: 1,
            ),
          ),
          child: pw.Text(
            question.average.toStringAsFixed(1),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 13,
              color: scoreColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

/// Cinco mini-barras Likert apiladas horizontalmente dentro de la fila.
pw.Widget _buildMiniLikertBars({
  required QuestionResponseData question,
  required int total,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  // Escala 1→5 con colores fijos de escala Likert
  final scaleValues = [5, 4, 3, 2, 1];
  final scaleLabels = ['S', 'CS', 'AV', 'CN', 'N'];

  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: List.generate(scaleValues.length, (i) {
      final val = scaleValues[i];
      final lbl = scaleLabels[i];
      final count = question.responses[val] ?? 0;
      final pct = total > 0 ? count / total : 0.0;
      final color = PdfPalette.forScale(val);

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 14,
              child: pw.Text(
                lbl,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 6,
                  color: color,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(width: 3),
            pw.Expanded(
              child: pw.ClipRRect(
                horizontalRadius: 2,
                verticalRadius: 2,
                child: pw.LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  backgroundColor: PdfPalette.border,
                  valueColor: color,
                  minHeight: 5,
                ),
              ),
            ),
            pw.SizedBox(width: 3),
            pw.SizedBox(
              width: 18,
              child: pw.Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 6,
                  color: PdfPalette.textSecond,
                ),
                textAlign: pw.TextAlign.left,
              ),
            ),
          ],
        ),
      );
    }),
  );
}