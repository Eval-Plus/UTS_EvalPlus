/// Construye la sección de Análisis de IA del PDF.
///
/// Secciones renderizadas (en orden):
///   1. Perfil Docente            → banner morado (ancho completo)
///   2. Fortalezas | Oportunidades → dos columnas con altura igualada
///   3. Recomendaciones           → ítems numerados (ancho completo)
///   4. Análisis de Respuestas    → comentario general (ancho completo)
///   5. Análisis de Comentarios   → comentario general (ancho completo)
///
/// Las secciones 4 y 5 solo se renderizan si su texto no está vacío.
///
/// Ubicación: lib/services/pdf/builder/pages/ai_page_builder.dart
library;

import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';

// ══════════════════════════════════════════════════════════════
// ENTRY POINT
// ══════════════════════════════════════════════════════════════

/// Retorna la lista de widgets que componen la sección de IA.
List<pw.Widget> buildAISection({
  required AIInsights insights,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  final hasResponsesComment = insights.responsesComment.isNotEmpty;
  final hasCommentsComment  = insights.commentsComment.isNotEmpty;

  // Altura compartida para las columnas de Fortalezas / Oportunidades.
  // Header (38) + padding vertical (28) + por ítem (~28 c/u).
  final int maxItems = insights.strengths.length > insights.improvements.length
      ? insights.strengths.length
      : insights.improvements.length;
  final double sharedHeight = 38 + 28 + (maxItems * 28.0);

  return [
    // 1. Perfil Docente
    _buildProfileCard(
      profile: insights.profile,
      boldFont: boldFont,
      regularFont: regularFont,
    ),

    pw.SizedBox(height: 14),

    // 2. Fortalezas | Oportunidades de Mejora (altura igualada)
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildInsightCard(
            title: 'Fortalezas',
            items: insights.strengths,
            accentColor: PdfPalette.excellent,
            boldFont: boldFont,
            regularFont: regularFont,
            fixedHeight: sharedHeight,
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: _buildInsightCard(
            title: 'Oportunidades de Mejora',
            items: insights.improvements,
            accentColor: PdfPalette.belowAvg,
            boldFont: boldFont,
            regularFont: regularFont,
            fixedHeight: sharedHeight,
          ),
        ),
      ],
    ),

    pw.SizedBox(height: 14),

    // 3. Recomendaciones
    _buildRecommendationsCard(
      recommendations: insights.recommendations,
      boldFont: boldFont,
      regularFont: regularFont,
    ),

    // 4. Análisis de Respuestas (comentario general)
    if (hasResponsesComment) ...[
      pw.SizedBox(height: 14),
      _buildCommentCard(
        title: 'Análisis de Respuestas',
        comment: insights.responsesComment,
        accentColor: PdfPalette.blue,
        boldFont: boldFont,
        regularFont: regularFont,
      ),
    ],

    // 5. Análisis de Comentarios (comentario general)
    if (hasCommentsComment) ...[
      pw.SizedBox(height: 14),
      _buildCommentCard(
        title: 'Análisis de Comentarios',
        comment: insights.commentsComment,
        accentColor: PdfPalette.purple,
        boldFont: boldFont,
        regularFont: regularFont,
      ),
    ],
  ];
}

// ══════════════════════════════════════════════════════════════
// SECCIÓN 1 — PERFIL DOCENTE
// ══════════════════════════════════════════════════════════════

pw.Widget _buildProfileCard({
  required String profile,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
            color: withOpacity(PdfPalette.white, 0.88),
            lineSpacing: 3,
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// SECCIÓN 2 — FORTALEZAS / OPORTUNIDADES DE MEJORA
// ══════════════════════════════════════════════════════════════

pw.Widget _buildInsightCard({
  required String title,
  required List<String> items,
  required PdfColor accentColor,
  required pw.Font boldFont,
  required pw.Font regularFont,
  double? fixedHeight,
}) {
  final content = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      insightHeader(title: title, color: accentColor, boldFont: boldFont),
      pw.SizedBox(height: 10),
      ...items.map(
        (item) => bulletItem(
          text: item,
          color: accentColor,
          regularFont: regularFont,
        ),
      ),
    ],
  );

  return pw.Container(
    height: fixedHeight,
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: content,
  );
}

// ══════════════════════════════════════════════════════════════
// SECCIÓN 3 — RECOMENDACIONES
// ══════════════════════════════════════════════════════════════

pw.Widget _buildRecommendationsCard({
  required List<String> recommendations,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    width: double.infinity,
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
          (entry) => _buildNumberedItem(
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

pw.Widget _buildNumberedItem({
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

// ══════════════════════════════════════════════════════════════
// SECCIONES 4 + 5 — COMENTARIO GENERAL (reutilizable)
// ══════════════════════════════════════════════════════════════

/// Tarjeta genérica de comentario general para Respuestas y Comentarios.
/// Muestra una línea lateral de color y el texto del comentario.
pw.Widget _buildCommentCard({
  required String title,
  required String comment,
  required PdfColor accentColor,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    width: double.infinity,
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
          title: title,
          color: accentColor,
          boldFont: boldFont,
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Línea lateral de color
            pw.Container(
              width: 3,
              height: 60,
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Text(
                comment,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 10,
                  color: PdfPalette.textPrimary,
                  lineSpacing: 2.5,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}