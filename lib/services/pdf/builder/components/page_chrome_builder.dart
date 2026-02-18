/// Header y footer reutilizables para las páginas internas del PDF.
/// Ubicación: lib/services/pdf/builder/components/page_chrome_builder.dart
library;
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';

/// Genera el header superior de cada página interna (sección + nombre docente).
pw.Widget buildPageHeader({
  required String sectionTitle,
  required String teacherName,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
}) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [PdfPalette.primary, PdfPalette.primaryDark],
      ),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                sectionTitle,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfPalette.white,
                ),
              ),
              pw.Text(
                teacherName,
                style: pw.TextStyle(
                  font: semiBoldFont,
                  fontSize: 10,
                  color: PdfPalette.whiteOp(0.75),
                ),
              ),
            ],
          ),
        ),
        pw.Text(
          'EVAL+',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
            color: PdfPalette.whiteOp(0.5),
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );
}

/// Genera el footer inferior de cada página interna (marca + número de página).
pw.Widget buildPageFooter(pw.Context ctx, pw.Font regularFont) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 12),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Eval+ • Documento confidencial',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: PdfPalette.textSecond,
          ),
        ),
        pw.Text(
          'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
            color: PdfPalette.textSecond,
          ),
        ),
      ],
    ),
  );
}