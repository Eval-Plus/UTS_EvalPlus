/// Tarjetas de estadísticas reutilizables para distintas páginas del PDF.
/// Ubicación: lib/services/pdf/builder/components/stat_cards_builder.dart
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';

// ══════════════════════════════════════════════════════════════
// TARJETA DE ESTADÍSTICA (PORTADA)
// ══════════════════════════════════════════════════════════════

/// Tarjeta de métrica usada en la portada.
/// Fondo tintado con el color de la métrica (usando withOpacity para mezcla
/// real con blanco) y borde coloreado para mayor presencia visual.
pw.Widget buildCoverStatCard({
  required String label,
  required String value,
  required String suffix,
  required PdfColor color,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  // Fondo pastel: mezcla del color con blanco al 12% de opacidad
  final bgColor     = withOpacity(color, 0.12);
  // Borde coloreado suave al 35%
  final borderColor = withOpacity(color, 0.35);
  // Color del sufijo ligeramente más oscuro que el fondo pero más claro que el valor
  final suffixColor = withOpacity(color, 0.70);

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: pw.BoxDecoration(
      color: bgColor,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      border: pw.Border.all(color: borderColor, width: 1.2),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Barra de color decorativa (más saturada para anclar el color)
        pw.Container(
          width: 32,
          height: 4,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(height: 10),
        // Valor principal — usa el color puro para máximo contraste
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 22,
            color: color,
            height: 1,
          ),
        ),
        pw.SizedBox(height: 3),
        // Sufijo con color intermedio legible
        pw.Text(
          suffix,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 9,
            color: suffixColor,
          ),
        ),
        pw.SizedBox(height: 6),
        // Etiqueta inferior en gris oscuro para máxima legibilidad
        pw.Text(
          label,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 10,
            color: PdfPalette.textPrimary,
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// RESUMEN DE ESTADÍSTICAS (BANNER DEGRADADO)
// ══════════════════════════════════════════════════════════════

/// Fila de mini-estadísticas sobre fondo degradado verde.
/// Usada en la sección de respuestas.
pw.Widget buildStatsBanner({
  required String average,
  required int completed,
  required int total,
  required int pending,
  required double completionRate,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        begin: pw.Alignment.topLeft,
        end: pw.Alignment.bottomRight,
        colors: [PdfPalette.primary, PdfPalette.primaryDark],
      ),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: miniStat(
            label: 'Promedio',
            value: average,
            suffix: '/ 5.0',
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
        verticalDivider(),
        pw.Expanded(
          child: miniStat(
            label: 'Completadas',
            value: '$completed',
            suffix: 'de $total',
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
        verticalDivider(),
        pw.Expanded(
          child: miniStat(
            label: 'Pendientes',
            value: '$pending',
            suffix: 'evaluaciones',
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
        verticalDivider(),
        pw.Expanded(
          child: miniStat(
            label: 'Completitud',
            value: '${completionRate.toStringAsFixed(0)}%',
            suffix: _completionLabel(completionRate),
            boldFont: boldFont,
            regularFont: regularFont,
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// TARJETA DE SENTIMIENTO (COMENTARIOS)
// ══════════════════════════════════════════════════════════════

/// Tarjeta con contador de un sentimiento (positivo/neutral/negativo).
/// ✅ Usa withOpacity() en lugar del canal alpha de PdfColor para
///    garantizar visibilidad real del fondo y borde en el PDF renderizado.
pw.Widget buildSentimentStatCard({
  required String label,
  required int count,
  required PdfColor color,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: withOpacity(color, 0.15),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(
        color: withOpacity(color, 0.35),
        width: 1,
      ),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          '$count',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 20,
            color: color,
            height: 1,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: withOpacity(color, 0.85),
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// HELPERS PRIVADOS
// ══════════════════════════════════════════════════════════════

String _completionLabel(double rate) {
  if (rate >= 90) return 'Completo';
  if (rate >= 70) return 'Avanzado';
  if (rate >= 50) return 'Parcial';
  if (rate >= 30) return 'Bajo';
  return 'Crítico';
}