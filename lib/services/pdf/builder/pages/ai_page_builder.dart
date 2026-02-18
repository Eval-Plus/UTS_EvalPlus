/// Construye la sección de Análisis de IA del PDF.
/// Ubicación: lib/services/pdf/builder/pages/ai_page_builder.dart
library;

import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';

/// Retorna la lista de widgets que componen la sección de IA.
List<pw.Widget> buildAISection({
  required AIInsights insights,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  return [
    _buildProfileCard(insights.profile, boldFont, regularFont),
    pw.SizedBox(height: 16),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildInsightCard(
            title: 'Fortalezas',
            items: insights.strengths,
            color: PdfPalette.excellent,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: _buildInsightCard(
            title: 'Oportunidades de Mejora',
            items: insights.improvements,
            color: PdfPalette.belowAvg,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 16),
    _buildRecommendationsCard(
      recommendations: insights.recommendations,
      boldFont: boldFont,
      semiBoldFont: semiBoldFont,
      regularFont: regularFont,
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// SECCIONES INTERNAS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildProfileCard(
  String profile,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(18),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [PdfPalette.purple, PdfPalette.purpleDark],
      ),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Perfil Docente',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 13,
            color: PdfPalette.white,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          profile,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
            color: PdfPalette.whiteOp(0.9),
            lineSpacing: 3,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildInsightCard({
  required String title,
  required List<String> items,
  required PdfColor color,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        insightHeader(title: title, color: color, boldFont: boldFont),
        pw.SizedBox(height: 10),
        ...items.map(
          (item) => bulletItem(
            text: item,
            color: color,
            regularFont: regularFont,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildRecommendationsCard({
  required List<String> recommendations,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        insightHeader(
          title: 'Recomendaciones',
          color: PdfPalette.blue,
          boldFont: boldFont,
        ),
        pw.SizedBox(height: 10),
        ...recommendations.asMap().entries.map(
          (entry) => _buildRecommendationItem(
            index: entry.key,
            text: entry.value,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildRecommendationItem({
  required int index,
  required String text,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 22,
          height: 22,
          decoration: pw.BoxDecoration(
            color: PdfPalette.blue,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              '${index + 1}',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 9,
                color: PdfPalette.white,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              text,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 10,
                color: PdfPalette.textPrimary,
                lineSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}