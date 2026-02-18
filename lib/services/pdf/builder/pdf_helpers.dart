/// Widgets reutilizables para la construcción del PDF del informe docente.
/// Ubicación: lib/services/pdf/builder/pdf_helpers.dart
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_palette.dart';

// ══════════════════════════════════════════════════════════════
// TEXTO Y ETIQUETAS DE ESCALA LIKERT
// ══════════════════════════════════════════════════════════════

/// Etiqueta corta para un valor Likert (1–5).
String scaleLabel(int val) {
  switch (val) {
    case 5: return 'S';
    case 4: return 'CS';
    case 3: return 'AV';
    case 2: return 'CN';
    default: return 'N';
  }
}

/// Etiqueta de satisfacción según tasa (0–100).
String satisfactionLabel(double rate) {
  if (rate >= 80) return 'Excelente';
  if (rate >= 60) return 'Bueno';
  if (rate >= 40) return 'Regular';
  if (rate >= 20) return 'Bajo';
  return 'Muy bajo';
}

/// Etiqueta de completitud según tasa (0–100).
String completionLabel(double rate) {
  if (rate >= 90) return 'Completo';
  if (rate >= 70) return 'Avanzado';
  if (rate >= 50) return 'Parcial';
  if (rate >= 30) return 'Bajo';
  return 'Crítico';
}

/// Etiqueta legible para el sentimiento de un comentario.
String sentimentLabel(String sentiment) {
  switch (sentiment) {
    case 'positive': return 'Comentarios Positivos';
    case 'negative': return 'Comentarios Negativos';
    default:         return 'Comentarios Neutrales';
  }
}

/// Fecha formateada como dd/mm/yyyy.
String formattedDate() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/'
      '${now.year}';
}

/// Nombre de archivo seguro (sin caracteres especiales).
String sanitizeFilename(String name) {
  final sanitized = name
      .replaceAll(' ', '_')
      .replaceAll(RegExp(r'[^\w\-]'), '');
  return sanitized.substring(0, sanitized.length > 40 ? 40 : sanitized.length);
}

// ══════════════════════════════════════════════════════════════
// WIDGETS ATÓMICOS REUTILIZABLES
// ══════════════════════════════════════════════════════════════

/// Divisor vertical semitransparente (para filas de estadísticas).
pw.Widget verticalDivider({double height = 40}) {
  return pw.Container(
    width: 1,
    height: height,
    color: PdfPalette.whiteOp(0.3),
    margin: const pw.EdgeInsets.symmetric(horizontal: 8),
  );
}

/// Barra de progreso con esquinas redondeadas.
pw.Widget progressBar({
  required double value,
  required PdfColor color,
  double height = 6,
}) {
  return pw.ClipRRect(
    horizontalRadius: height / 2,
    verticalRadius: height / 2,
    child: pw.LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      backgroundColor: PdfPalette.border,
      valueColor: color,
      minHeight: height,
    ),
  );
}

/// Mini-estadística para filas de resumen (texto blanco sobre fondo coloreado).
pw.Widget miniStat({
  required String label,
  required String value,
  String suffix = '',
  required pw.Font boldFont,
  required pw.Font regularFont,
  PdfColor? color,
}) {
  final textColor = color ?? PdfPalette.white;
  final subColor = color != null
      ? PdfColor(color.red, color.green, color.blue, 0.7)
      : PdfPalette.whiteOp(0.6);
  final labelColor = color != null ? PdfPalette.textSecond : PdfPalette.whiteOp(0.75);

  return pw.Column(
    children: [
      pw.Text(
        value,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 20,
          color: textColor,
          height: 1,
        ),
      ),
      if (suffix.isNotEmpty)
        pw.Text(
          suffix,
          style: pw.TextStyle(font: regularFont, fontSize: 8, color: subColor),
        ),
      pw.SizedBox(height: 4),
      pw.Text(
        label,
        style: pw.TextStyle(font: regularFont, fontSize: 9, color: labelColor),
      ),
    ],
  );
}

/// Fila de tabla: cabecera con fondo primario.
pw.Widget tableHeader(String text, pw.Font boldFont) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfPalette.white),
    ),
  );
}

/// Fila de tabla: celda de datos.
pw.Widget tableCell(
  String text,
  pw.Font regularFont, {
  bool bold = false,
  pw.TextAlign align = pw.TextAlign.left,
  PdfColor? color,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        font: regularFont,
        fontSize: 9,
        color: color ?? PdfPalette.textPrimary,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

/// Celda de progreso con porcentaje y barra.
pw.Widget progressCell(
  double rate,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  final color = PdfPalette.forProgress(rate);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${rate.toStringAsFixed(0)}%',
          style: pw.TextStyle(font: boldFont, fontSize: 9, color: color),
        ),
        pw.SizedBox(height: 3),
        progressBar(value: rate / 100, color: color, height: 4),
      ],
    ),
  );
}

/// Tarjeta de ítem de tabla de contenidos (portada).
pw.Widget tocItem({
  required String number,
  required String title,
  required String subtitle,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 24,
          height: 24,
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
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: PdfPalette.textPrimary,
                ),
              ),
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: PdfPalette.textSecond,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Bloque de encabezado con barra de color lateral (para fortalezas/mejoras/recomendaciones).
pw.Widget insightHeader({
  required String title,
  required PdfColor color,
  required pw.Font boldFont,
}) {
  return pw.Row(
    children: [
      pw.Container(
        width: 4,
        height: 16,
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Text(
        title,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 12,
          color: PdfPalette.textPrimary,
        ),
      ),
    ],
  );
}

/// Bullet item con punto circular de color.
pw.Widget bulletItem({
  required String text,
  required PdfColor color,
  required pw.Font regularFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 6,
          height: 6,
          margin: const pw.EdgeInsets.only(top: 3, right: 8),
          decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
        ),
        pw.Expanded(
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
      ],
    ),
  );
}