/// Construye la sección de materias asignadas del PDF.
/// Ubicación: lib/services/pdf/builder/pages/subjects_page_builder.dart
library;

import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_palette.dart';
import '../pdf_helpers.dart';

/// Retorna la lista de widgets que componen la sección de materias.
List<pw.Widget> buildSubjectsSection({
  required List<SubjectData> subjects,
  required String careerName,
  required pw.Font boldFont,
  required pw.Font semiBoldFont,
  required pw.Font regularFont,
}) {
  return [
    _buildSubjectsTable(subjects, boldFont, semiBoldFont, regularFont),
    pw.SizedBox(height: 24),
    _buildGlobalSummary(subjects, boldFont, semiBoldFont, regularFont),
  ];
}

// ══════════════════════════════════════════════════════════════
// TABLA DE MATERIAS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildSubjectsTable(
  List<SubjectData> subjects,
  pw.Font boldFont,
  pw.Font semiBoldFont,
  pw.Font regularFont,
) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfPalette.border, width: 0.75),
    columnWidths: {
      0: const pw.FlexColumnWidth(3.5), // Materia
      1: const pw.FlexColumnWidth(1.8), // Código
      2: const pw.FlexColumnWidth(1.0), // Total
      3: const pw.FlexColumnWidth(1.5), // Evaluados  — más ancho para no cortar
      4: const pw.FlexColumnWidth(1.5), // Pendientes — más ancho para no cortar
      5: const pw.FlexColumnWidth(1.8), // Progreso
    },
    children: [
      // ── Cabecera ──
      pw.TableRow(
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [PdfPalette.primary, PdfPalette.primaryDark],
          ),
        ),
        children: [
          _tableHeader('Materia', boldFont),
          _tableHeader('Código', boldFont),
          _tableHeader('Total', boldFont),
          _tableHeader('Evaluados', boldFont),
          _tableHeader('Pendientes', boldFont),
          _tableHeader('Progreso', boldFont),
        ],
      ),

      // ── Filas de datos ──
      ...subjects.asMap().entries.map((entry) {
        final index   = entry.key;
        final subject = entry.value;
        final rate    = subject.students > 0
            ? (subject.completed / subject.students) * 100
            : 0.0;
        final bg = index.isEven ? PdfPalette.white : PdfPalette.bgLight;

        return pw.TableRow(
          decoration: pw.BoxDecoration(color: bg),
          children: [
            _subjectNameCell(subject.name, boldFont),
            _codeCell(subject.code, regularFont),
            _numericCell('${subject.students}', regularFont, PdfPalette.blue),
            _numericCell('${subject.completed}', boldFont, PdfPalette.excellent),
            _pendingCell(subject.pending, boldFont, regularFont),
            _progressCell(rate, boldFont, regularFont),
          ],
        );
      }),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
// CELDAS DE LA TABLA
// ══════════════════════════════════════════════════════════════

/// Cabecera con texto blanco.
pw.Widget _tableHeader(String text, pw.Font boldFont) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfPalette.white),
    ),
  );
}

/// Nombre de la materia — permite múltiples líneas para evitar cortes.
pw.Widget _subjectNameCell(String name, pw.Font boldFont) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Text(
      name,
      softWrap: true,
      style: pw.TextStyle(
        font: boldFont,
        fontSize: 9,
        color: PdfPalette.textPrimary,
        lineSpacing: 1.5,
      ),
    ),
  );
}

/// Código de materia con chip de fondo azul suave.
/// Usa [withOpacity] para que el fondo sea visible correctamente en PDF.
pw.Widget _codeCell(String code, pw.Font regularFont) {
  final blue   = PdfPalette.blue;
  final bgBlue = withOpacity(blue, 0.12);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bgBlue,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        code,
        style: pw.TextStyle(font: regularFont, fontSize: 8, color: blue),
      ),
    ),
  );
}

/// Celda numérica genérica con color semántico.
pw.Widget _numericCell(String value, pw.Font font, PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Center(
      child: pw.Text(
        value,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 10, color: color),
      ),
    ),
  );
}

/// Celda de pendientes: resalta con chip naranja cuando hay pendientes,
/// gris tenue si no. Usa [withOpacity] para el fondo del chip.
pw.Widget _pendingCell(int pending, pw.Font boldFont, pw.Font regularFont) {
  final hasPending = pending > 0;
  final color      = hasPending ? PdfPalette.belowAvg : PdfPalette.textSecond;

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Center(
      child: hasPending
          ? pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: pw.BoxDecoration(
                color: withOpacity(PdfPalette.belowAvg, 0.15),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                '$pending',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: boldFont, fontSize: 10, color: color),
              ),
            )
          : pw.Text(
              '0',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 10,
                color: PdfPalette.textSecond,
              ),
            ),
    ),
  );
}

/// Celda de progreso con porcentaje + barra de progreso.
pw.Widget _progressCell(double rate, pw.Font boldFont, pw.Font regularFont) {
  final color = PdfPalette.forProgress(rate);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${rate.toStringAsFixed(0)}%',
          style: pw.TextStyle(font: boldFont, fontSize: 10, color: color),
        ),
        pw.SizedBox(height: 4),
        progressBar(value: rate / 100, color: color, height: 5),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// RESUMEN GLOBAL
// ══════════════════════════════════════════════════════════════

pw.Widget _buildGlobalSummary(
  List<SubjectData> subjects,
  pw.Font boldFont,
  pw.Font semiBoldFont,
  pw.Font regularFont,
) {
  final totalStudents  = subjects.fold(0, (s, sub) => s + sub.students);
  final totalCompleted = subjects.fold(0, (s, sub) => s + sub.completed);
  final totalPending   = subjects.fold(0, (s, sub) => s + sub.pending);
  final overallRate    = totalStudents > 0
      ? (totalCompleted / totalStudents) * 100
      : 0.0;

  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfPalette.bgLight,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── Título ──
        pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 16,
              decoration: pw.BoxDecoration(
                color: PdfPalette.primary,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'Resumen Global de Evaluación',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
                color: PdfPalette.textPrimary,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),

        // ── Tarjetas de estadísticas ──
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _summaryCard(
                label: 'Total Estudiantes',
                value: '$totalStudents',
                color: PdfPalette.blue,
                boldFont: boldFont,
                regularFont: regularFont,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _summaryCard(
                label: 'Completadas',
                value: '$totalCompleted',
                color: PdfPalette.excellent,
                boldFont: boldFont,
                regularFont: regularFont,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _summaryCard(
                label: 'Pendientes',
                value: '$totalPending',
                color: PdfPalette.belowAvg,
                boldFont: boldFont,
                regularFont: regularFont,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _summaryCard(
                label: 'Tasa Global',
                value: '${overallRate.toStringAsFixed(1)}%',
                color: PdfPalette.forProgress(overallRate),
                boldFont: boldFont,
                regularFont: regularFont,
                isRate: true,
                rate: overallRate,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Tarjeta individual del resumen global.
///
/// Usa [pw.ClipRRect] como envoltorio redondeado y apila una franja de color
/// superior (3 pt) sobre el cuerpo blanco con borde uniforme, evitando así
/// la restricción de la librería `pdf` que prohíbe combinar `borderRadius`
/// con un `Border` no uniforme.
pw.Widget _summaryCard({
  required String label,
  required String value,
  required PdfColor color,
  required pw.Font boldFont,
  required pw.Font regularFont,
  bool isRate = false,
  double rate = 0,
}) {
  return pw.ClipRRect(
    horizontalRadius: 8,
    verticalRadius: 8,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Franja de color superior
        pw.Container(height: 3, color: color),

        // Cuerpo — border uniforme, compatible con ClipRRect exterior
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: pw.BoxDecoration(
            color: PdfPalette.white,
            border: pw.Border.all(color: PdfPalette.border, width: 0.75),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: color,
                  height: 1,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                label,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: PdfPalette.textSecond,
                ),
              ),
              if (isRate) ...[
                pw.SizedBox(height: 8),
                progressBar(value: rate / 100, color: color, height: 4),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}