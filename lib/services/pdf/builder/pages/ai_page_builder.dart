/// Construye la sección de Análisis de IA del PDF.
///
/// Secciones renderizadas (en orden):
///   1. Perfil Docente            → banner morado (ancho completo)
///   2. Fortalezas | Oportunidades → dos columnas con altura igualada
///   3. Recomendaciones           → ítems numerados (ancho completo)
///   4. Análisis de Respuestas y Comentarios → dos columnas compactas
///
/// Las secciones 4 y 5 se renderizan juntas en una fila de dos columnas
/// solo si sus listas no están vacías; si solo hay una, ocupa todo el ancho.
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
  final hasFeedback = insights.evaluationFeedback.isNotEmpty;
  final hasSentiment = insights.sentimentFeedback.isNotEmpty;

  return [
    // 1. Perfil Docente
    _buildProfileCard(
      profile: insights.profile,
      boldFont: boldFont,
      regularFont: regularFont,
    ),

    pw.SizedBox(height: 14),

    // 2. Fortalezas | Oportunidades de Mejora
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
            fillHeight: true,
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
            fillHeight: true,
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

    // 4 + 5. Análisis de Respuestas y Comentarios en una fila compacta
    if (hasFeedback || hasSentiment) ...[
      pw.SizedBox(height: 14),
      _buildFeedbackRow(
        insights: insights,
        hasFeedback: hasFeedback,
        hasSentiment: hasSentiment,
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
            // Blanco puro para el título
            color: PdfPalette.white,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          profile,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
            // Blanco con opacidad para diferenciar del título sin desaparecer
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
  bool fillHeight = false,
}) {
  // Altura estimada por ítem: header (~30) + padding (~24) + por ítem (~26 cada uno)
  // Usamos una altura mínima fija generosa para que ambas tarjetas luzcan parejas
  // cuando una tiene menos ítems que la otra.
  final double minHeight = fillHeight ? 30 + 24 + (3 * 26.0) : 0;

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
    constraints: fillHeight
        ? pw.BoxConstraints(minHeight: minHeight)
        : const pw.BoxConstraints(),
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
// SECCIONES 4 + 5 — FILA COMPACTA DE FEEDBACK
// ══════════════════════════════════════════════════════════════

/// Coloca Análisis de Respuestas y Análisis de Comentarios en una fila de
/// dos columnas para que todo el contenido de IA quepa en una sola página.
/// Si solo existe uno de los dos, ocupa el ancho completo.
pw.Widget _buildFeedbackRow({
  required AIInsights insights,
  required bool hasFeedback,
  required bool hasSentiment,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  // Ambas columnas presentes
  if (hasFeedback && hasSentiment) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildEvaluationFeedbackCard(
            items: insights.evaluationFeedback,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: _buildSentimentFeedbackCard(
            items: insights.sentimentFeedback,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
      ],
    );
  }

  // Solo análisis de respuestas
  if (hasFeedback) {
    return _buildEvaluationFeedbackCard(
      items: insights.evaluationFeedback,
      boldFont: boldFont,
      regularFont: regularFont,
    );
  }

  // Solo análisis de comentarios
  return _buildSentimentFeedbackCard(
    items: insights.sentimentFeedback,
    boldFont: boldFont,
    regularFont: regularFont,
  );
}

// ══════════════════════════════════════════════════════════════
// SECCIÓN 4 — ANÁLISIS DE RESPUESTAS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildEvaluationFeedbackCard({
  required List<EvaluationFeedback> items,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        insightHeader(
          title: 'Análisis de Respuestas',
          color: PdfPalette.blue,
          boldFont: boldFont,
        ),
        pw.SizedBox(height: 10),
        ...items.asMap().entries.map(
          (entry) => _buildEvaluationItem(
            item: entry.value,
            isLast: entry.key == items.length - 1,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildEvaluationItem({
  required EvaluationFeedback item,
  required bool isLast,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  final scoreColor = PdfPalette.forScore(item.score);

  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 4,
          height: 48,
          decoration: pw.BoxDecoration(
            color: scoreColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      item.category,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 9,
                        color: PdfPalette.textPrimary,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  _buildScoreBadge(
                    label: item.score.toStringAsFixed(1),
                    color: scoreColor,
                    boldFont: boldFont,
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                item.feedback,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8,
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

// ══════════════════════════════════════════════════════════════
// SECCIÓN 5 — ANÁLISIS DE COMENTARIOS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildSentimentFeedbackCard({
  required List<SentimentFeedback> items,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfPalette.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        insightHeader(
          title: 'Análisis de Comentarios',
          color: PdfPalette.purple,
          boldFont: boldFont,
        ),
        pw.SizedBox(height: 10),
        ...items.asMap().entries.map(
          (entry) => _buildSentimentItem(
            item: entry.value,
            isLast: entry.key == items.length - 1,
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildSentimentItem({
  required SentimentFeedback item,
  required bool isLast,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  final sentimentColor = PdfPalette.forSentiment(item.sentiment);

  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 4,
          height: 48,
          decoration: pw.BoxDecoration(
            color: sentimentColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _sentimentLabel(item.sentiment),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 9,
                      color: sentimentColor,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  _buildScoreBadge(
                    label: '${item.percentage}%',
                    color: sentimentColor,
                    boldFont: boldFont,
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                item.feedback,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8,
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

// ══════════════════════════════════════════════════════════════
// HELPERS PRIVADOS
// ══════════════════════════════════════════════════════════════

/// Badge con borde de color para puntajes y porcentajes.
pw.Widget _buildScoreBadge({
  required String label,
  required PdfColor color,
  required pw.Font boldFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: pw.BoxDecoration(
      color: withOpacity(color, 0.15),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(
        color: withOpacity(color, 0.3),
        width: 1,
      ),
    ),
    child: pw.Text(
      label,
      style: pw.TextStyle(font: boldFont, fontSize: 9, color: color),
    ),
  );
}

/// Etiqueta legible para cada tipo de sentimiento.
String _sentimentLabel(String sentiment) {
  switch (sentiment) {
    case 'positive':
      return 'Positivos';
    case 'negative':
      return 'Negativos';
    default:
      return 'Neutrales';
  }
}