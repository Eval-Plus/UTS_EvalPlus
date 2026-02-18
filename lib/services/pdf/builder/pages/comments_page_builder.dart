/// Construye la sección de Comentarios Anónimos del PDF.
/// Ubicación: lib/services/pdf/builder/pages/comments_page_builder.dart
library;

import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';
import '../components/stat_cards_builder.dart';

/// Retorna la lista de widgets que componen la sección de comentarios.
List<pw.Widget> buildCommentsSection({
  required List<CommentReport> comments,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final positive = comments.where((c) => c.sentiment == 'positive').length;
  final neutral  = comments.where((c) => c.sentiment == 'neutral').length;
  final negative = comments.where((c) => c.sentiment == 'negative').length;
  final satisfRate = comments.isEmpty
      ? 0.0
      : ((positive + (neutral * 0.5)) / comments.length) * 100;

  return [
    _buildSentimentSummary(
      comments: comments,
      positive: positive,
      neutral: neutral,
      negative: negative,
      satisfRate: satisfRate,
      boldFont: boldFont,
      regularFont: regularFont,
    ),
    pw.SizedBox(height: 16),

    // ── Grupos por sentimiento ──
    ..._buildGroupedComments(comments, boldFont, regularFont),
  ];
}

// ══════════════════════════════════════════════════════════════
// RESUMEN DE SENTIMIENTOS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildSentimentSummary({
  required List<CommentReport> comments,
  required int positive,
  required int neutral,
  required int negative,
  required double satisfRate,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfPalette.bgLight,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Row(
      children: [
        // ── Satisfacción general ──
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Satisfacción General',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: PdfPalette.textPrimary,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '${satisfRate.toStringAsFixed(1)}%',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 28,
                  color: PdfPalette.forScore(satisfRate / 20),
                  height: 1,
                ),
              ),
              pw.Text(
                satisfactionLabel(satisfRate),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 10,
                  color: PdfPalette.textSecond,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 16),

        // ── Contadores por sentimiento ──
        pw.Expanded(
          flex: 3,
          child: pw.Row(
            children: [
              pw.Expanded(
                child: buildSentimentStatCard(
                  label: 'Positivos',
                  count: positive,
                  color: PdfPalette.positive,
                  boldFont: boldFont,
                  regularFont: regularFont,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: buildSentimentStatCard(
                  label: 'Neutrales',
                  count: neutral,
                  color: PdfPalette.neutral,
                  boldFont: boldFont,
                  regularFont: regularFont,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: buildSentimentStatCard(
                  label: 'Negativos',
                  count: negative,
                  color: PdfPalette.negative,
                  boldFont: boldFont,
                  regularFont: regularFont,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// GRUPOS DE COMENTARIOS
// ══════════════════════════════════════════════════════════════

List<pw.Widget> _buildGroupedComments(
  List<CommentReport> comments,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  final groups = ['positive', 'neutral', 'negative'];
  final result = <pw.Widget>[];

  for (final sentiment in groups) {
    final filtered = comments.where((c) => c.sentiment == sentiment).toList();
    if (filtered.isEmpty) continue;

    result
      ..add(_buildGroupHeader(sentiment, filtered.length, boldFont))
      ..add(pw.SizedBox(height: 8))
      ..addAll(filtered.map((c) => _buildCommentCard(c, boldFont, regularFont)))
      ..add(pw.SizedBox(height: 12));
  }

  return result;
}

pw.Widget _buildGroupHeader(String sentiment, int count, pw.Font boldFont) {
  final color = PdfPalette.forSentiment(sentiment);
  final label = sentimentLabel(sentiment);

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: pw.BoxDecoration(
      color: PdfColor(color.red, color.green, color.blue, 0.1),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(
        color: PdfColor(color.red, color.green, color.blue, 0.3),
        width: 1,
      ),
    ),
    child: pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: boldFont, fontSize: 11, color: color),
        ),
        pw.Spacer(),
        pw.Text(
          '$count comentarios',
          style: pw.TextStyle(font: boldFont, fontSize: 9, color: color),
        ),
      ],
    ),
  );
}

pw.Widget _buildCommentCard(
  CommentReport comment,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  final color = PdfPalette.forSentiment(comment.sentiment);

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Barra lateral de color
        pw.Container(
          width: 3,
          height: 40,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            comment.text,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 10,
              color: PdfPalette.textPrimary,
              lineSpacing: 2,
            ),
          ),
        ),
      ],
    ),
  );
}