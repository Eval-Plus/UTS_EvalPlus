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
    _buildCareerBadge(careerName, boldFont, regularFont),
    pw.SizedBox(height: 16),
    _buildSubjectsTable(subjects, boldFont, regularFont),
    pw.SizedBox(height: 20),
    _buildGlobalSummary(subjects, boldFont, regularFont),
  ];
}

// ══════════════════════════════════════════════════════════════
// SECCIONES INTERNAS
// ══════════════════════════════════════════════════════════════

pw.Widget _buildCareerBadge(
  String careerName,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  final blue = PdfPalette.blue;
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: pw.BoxDecoration(
      color: PdfColor(blue.red, blue.green, blue.blue, 0.08),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(
        color: PdfColor(blue.red, blue.green, blue.blue, 0.25),
        width: 1,
      ),
    ),
    child: pw.Row(
      children: [
        pw.Text(
          'Carrera: ',
          style: pw.TextStyle(font: boldFont, fontSize: 11, color: blue),
        ),
        pw.Text(
          careerName,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
            color: PdfPalette.textPrimary,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildSubjectsTable(
  List<SubjectData> subjects,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfPalette.border, width: 1),
    columnWidths: {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1),
      5: const pw.FlexColumnWidth(1.5),
    },
    children: [
      // ── Cabecera ──
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfPalette.primary),
        children: [
          tableHeader('Materia', boldFont),
          tableHeader('Código', boldFont),
          tableHeader('Total', boldFont),
          tableHeader('Evaluados', boldFont),
          tableHeader('Pendientes', boldFont),
          tableHeader('Progreso', boldFont),
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
            tableCell(subject.name, regularFont, bold: true),
            tableCell(subject.code, regularFont),
            tableCell(
              '${subject.students}',
              regularFont,
              align: pw.TextAlign.center,
            ),
            tableCell(
              '${subject.completed}',
              regularFont,
              align: pw.TextAlign.center,
              color: PdfPalette.excellent,
            ),
            tableCell(
              '${subject.pending}',
              regularFont,
              align: pw.TextAlign.center,
              color: subject.pending > 0 ? PdfPalette.belowAvg : PdfPalette.textSecond,
            ),
            progressCell(rate, boldFont, regularFont),
          ],
        );
      }),
    ],
  );
}

pw.Widget _buildGlobalSummary(
  List<SubjectData> subjects,
  pw.Font boldFont,
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
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      border: pw.Border.all(color: PdfPalette.border, width: 1),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen Global de Evaluación',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            color: PdfPalette.textPrimary,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: miniStat(
                label: 'Total Estudiantes',
                value: '$totalStudents',
                boldFont: boldFont,
                regularFont: regularFont,
                color: PdfPalette.blue,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: miniStat(
                label: 'Evaluaciones Completadas',
                value: '$totalCompleted',
                boldFont: boldFont,
                regularFont: regularFont,
                color: PdfPalette.excellent,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: miniStat(
                label: 'Evaluaciones Pendientes',
                value: '$totalPending',
                boldFont: boldFont,
                regularFont: regularFont,
                color: PdfPalette.belowAvg,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: miniStat(
                label: 'Tasa Global',
                value: '${overallRate.toStringAsFixed(1)}%',
                boldFont: boldFont,
                regularFont: regularFont,
                color: PdfPalette.forScore(overallRate / 20),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}