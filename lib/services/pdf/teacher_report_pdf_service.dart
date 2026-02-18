/// Servicio para generar el PDF del informe completo del docente
/// Ubicación: lib/services/pdf/teacher_report_pdf_service.dart
library;

import 'dart:typed_data';

import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Convierte un Color de Flutter a PdfColor
PdfColor _pdfColor(Color c) =>
    PdfColor(c.red / 255, c.green / 255, c.blue / 255);

/// Paleta de colores admin (verde) como PdfColor
class _PdfPalette {
  static final primary = _pdfColor(const Color(0xFF4CAF50));
  static final primaryDark = _pdfColor(const Color(0xFF388E3C));
  static final accent = _pdfColor(const Color(0xFF43A047));

  static final positive = _pdfColor(const Color(0xFF10B981));
  static final neutral = _pdfColor(const Color(0xFF6B7280));
  static final negative = _pdfColor(const Color(0xFFEF4444));

  static final excellent = _pdfColor(const Color(0xFF4CAF50));
  static final good = _pdfColor(const Color(0xFF8BC34A));
  static final average = _pdfColor(const Color(0xFFFCD34D));
  static final belowAverage = _pdfColor(const Color(0xFFF59E0B));
  static final poor = _pdfColor(const Color(0xFFEF4444));

  static final bgLight = _pdfColor(const Color(0xFFF9FAFB));
  static final border = _pdfColor(const Color(0xFFE5E7EB));
  static final textPrimary = _pdfColor(const Color(0xFF1F2937));
  static final textSecondary = _pdfColor(const Color(0xFF6B7280));
  static final white = PdfColors.white;
}

class TeacherReportPdfService {
  // ==================== PUNTO DE ENTRADA ====================

  /// Genera y descarga/comparte el PDF del informe del docente.
  /// Usa los datos ya cargados en memoria (sin nueva consulta a la API).
  static Future<void> generateAndDownload({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required AIInsights aiInsights,
  }) async {
    final pdfBytes = await _buildPdf(
      teacher: teacher,
      responsesReport: responsesReport,
      comments: comments,
      aiInsights: aiInsights,
    );

    // Usar el plugin printing para compartir/guardar el PDF nativo
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'Informe_${_sanitizeFilename(teacher.name)}_${teacher.period}.pdf',
    );
  }

  /// Genera los bytes del PDF sin descargarlo (útil para preview).
  static Future<Uint8List> generateBytes({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required AIInsights aiInsights,
  }) async {
    return _buildPdf(
      teacher: teacher,
      responsesReport: responsesReport,
      comments: comments,
      aiInsights: aiInsights,
    );
  }

  // ==================== CONSTRUCCIÓN DEL PDF ====================

  static Future<Uint8List> _buildPdf({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required AIInsights aiInsights,
  }) async {
    final doc = pw.Document(
      title: 'Informe Docente - ${teacher.name}',
      author: 'Eval+',
      creator: 'Eval+ App',
      subject: 'Informe completo de evaluación docente - Período ${teacher.period}',
    );

    // Fuentes
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
    final semiBoldFont = await PdfGoogleFonts.interMedium();

    final baseTheme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    // ── Página 1: Portada + Resumen ==──
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: baseTheme,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _buildCoverPage(
          teacher: teacher,
          responsesReport: responsesReport,
          comments: comments,
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
          regularFont: regularFont,
        ),
      ),
    );

    // ── Página 2: Respuestas por pregunta ──
    if (responsesReport != null && responsesReport.questions.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: baseTheme,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => _buildPageHeader(
            'Análisis de Respuestas',
            teacher.name,
            boldFont,
            semiBoldFont,
          ),
          footer: (ctx) => _buildPageFooter(ctx, regularFont),
          build: (ctx) => _buildResponsesSection(
            responsesReport,
            boldFont,
            semiBoldFont,
            regularFont,
          ),
        ),
      );
    }

    // ── Página 3: Materias ──
    if (teacher.subjects.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: baseTheme,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => _buildPageHeader(
            'Materias Asignadas',
            teacher.name,
            boldFont,
            semiBoldFont,
          ),
          footer: (ctx) => _buildPageFooter(ctx, regularFont),
          build: (ctx) => _buildSubjectsSection(
            teacher.subjects,
            teacher.careerName,
            boldFont,
            semiBoldFont,
            regularFont,
          ),
        ),
      );
    }

    // ── Página 4: Análisis IA ──
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: baseTheme,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildPageHeader(
          'Análisis de Inteligencia Artificial',
          teacher.name,
          boldFont,
          semiBoldFont,
        ),
        footer: (ctx) => _buildPageFooter(ctx, regularFont),
        build: (ctx) => _buildAISection(
          aiInsights,
          boldFont,
          semiBoldFont,
          regularFont,
        ),
      ),
    );

    // ── Página 5: Comentarios ──
    if (comments.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: baseTheme,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => _buildPageHeader(
            'Comentarios Anónimos',
            teacher.name,
            boldFont,
            semiBoldFont,
          ),
          footer: (ctx) => _buildPageFooter(ctx, regularFont),
          build: (ctx) => _buildCommentsSection(
            comments,
            boldFont,
            semiBoldFont,
            regularFont,
          ),
        ),
      );
    }

    return doc.save();
  }

  // ==================== PORTADA ──====================

  static pw.Widget _buildCoverPage({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required pw.Font boldFont,
    required pw.Font semiBoldFont,
    required pw.Font regularFont,
  }) {
    final positive = comments.where((c) => c.sentiment == 'positive').length;
    final neutral = comments.where((c) => c.sentiment == 'neutral').length;
    final negative = comments.where((c) => c.sentiment == 'negative').length;
    final satisfactionRate = comments.isEmpty
        ? 0.0
        : ((positive + (neutral * 0.5)) / comments.length) * 100;

    return pw.Stack(
      children: [
        // Fondo con gradiente superior (simulado con rectángulo)
        pw.Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: pw.Container(
            height: 260,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_PdfPalette.primary, _PdfPalette.primaryDark],
              ),
            ),
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'EVAL+',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 28,
                          color: _PdfPalette.white,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Sistema de Evaluación Docente',
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 11,
                          color: PdfColor(1, 1, 1, 0.75),
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: pw.BoxDecoration(
                      color: PdfColor(1, 1, 1, 0.2),
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(20)),
                      border: pw.Border.all(
                          color: PdfColor(1, 1, 1, 0.4), width: 1),
                    ),
                    child: pw.Text(
                      'Período ${teacher.period}',
                      style: pw.TextStyle(
                        font: semiBoldFont,
                        fontSize: 11,
                        color: _PdfPalette.white,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 32),

              // ── Título ──
              pw.Text(
                'INFORME COMPLETO',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 13,
                  color: PdfColor(1, 1, 1, 0.7),
                  letterSpacing: 3,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                teacher.name,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 22,
                  color: _PdfPalette.white,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                teacher.careerName,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 13,
                  color: PdfColor(1, 1, 1, 0.8),
                ),
              ),

              pw.SizedBox(height: 48),

              // ── Tarjetas de resumen ──
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildCoverStatCard(
                      label: 'Promedio General',
                      value: responsesReport != null
                          ? responsesReport.averageScore.toStringAsFixed(2)
                          : 'N/D',
                      suffix: '/ 5.0',
                      color: _PdfPalette.excellent,
                      boldFont: boldFont,
                      regularFont: regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildCoverStatCard(
                      label: 'Evaluaciones',
                      value: responsesReport != null
                          ? '${responsesReport.completedEvaluations}'
                          : 'N/D',
                      suffix: 'completadas',
                      color: _pdfColor(const Color(0xFF3B82F6)),
                      boldFont: boldFont,
                      regularFont: regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildCoverStatCard(
                      label: 'Satisfacción',
                      value: comments.isNotEmpty
                          ? '${satisfactionRate.toStringAsFixed(1)}%'
                          : 'N/D',
                      suffix: comments.isNotEmpty
                          ? _getSatisfactionLabel(satisfactionRate)
                          : '',
                      color: _pdfColor(const Color(0xFF8B5CF6)),
                      boldFont: boldFont,
                      regularFont: regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildCoverStatCard(
                      label: 'Materias',
                      value: '${teacher.subjects.length}',
                      suffix: 'asignadas',
                      color: _PdfPalette.accent,
                      boldFont: boldFont,
                      regularFont: regularFont,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 28),

              // ── Índice de contenido ──
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: _PdfPalette.bgLight,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(10)),
                  border: pw.Border.all(color: _PdfPalette.border, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Contenido del Informe',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 13,
                        color: _PdfPalette.textPrimary,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildTocItem('01', 'Análisis de Respuestas',
                        '${responsesReport?.questions.length ?? 0} preguntas evaluadas',
                        boldFont, regularFont),
                    _buildTocItem('02', 'Materias Asignadas',
                        '${teacher.subjects.length} materias',
                        boldFont, regularFont),
                    _buildTocItem(
                        '03',
                        'Análisis de Inteligencia Artificial',
                        'Fortalezas, mejoras y recomendaciones',
                        boldFont,
                        regularFont),
                    _buildTocItem('04', 'Comentarios Anónimos',
                        '${comments.length} comentarios (${positive} positivos, $neutral neutrales, $negative negativos)',
                        boldFont, regularFont),
                  ],
                ),
              ),

              pw.Spacer(),

              // ── Footer de portada ──
              pw.Divider(color: _PdfPalette.border),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generado por Eval+ • ${_formattedDate()}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 9,
                      color: _PdfPalette.textSecondary,
                    ),
                  ),
                  pw.Text(
                    'Documento confidencial',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 9,
                      color: _PdfPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCoverStatCard({
    required String label,
    required String value,
    required String suffix,
    required PdfColor color,
    required pw.Font boldFont,
    required pw.Font regularFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _PdfPalette.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _PdfPalette.border, width: 1),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColor(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const PdfPoint(0, 2),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 28,
            height: 4,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),
          pw.SizedBox(height: 10),
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
          pw.Text(
            suffix,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
              color: _PdfPalette.textSecondary,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
              color: _PdfPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTocItem(
    String number,
    String title,
    String subtitle,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 24,
            height: 24,
            decoration: pw.BoxDecoration(
              color: _PdfPalette.primary,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Center(
              child: pw.Text(
                number,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 9,
                  color: _PdfPalette.white,
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
                    color: _PdfPalette.textPrimary,
                  ),
                ),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 9,
                    color: _PdfPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECCIÓN RESPUESTAS ====================

  static List<pw.Widget> _buildResponsesSection(
    TeacherResponsesReport report,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    final completionRate = report.totalEvaluations > 0
        ? (report.completedEvaluations / report.totalEvaluations) * 100
        : 0.0;

    return [
      // ── Resumen estadístico ──
      pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            begin: pw.Alignment.topLeft,
            end: pw.Alignment.bottomRight,
            colors: [_PdfPalette.primary, _PdfPalette.primaryDark],
          ),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: _buildMiniStat(
                'Promedio',
                report.averageScore.toStringAsFixed(2),
                '/ 5.0',
                boldFont,
                regularFont,
              ),
            ),
            _verticalDivider(),
            pw.Expanded(
              child: _buildMiniStat(
                'Completadas',
                '${report.completedEvaluations}',
                'de ${report.totalEvaluations}',
                boldFont,
                regularFont,
              ),
            ),
            _verticalDivider(),
            pw.Expanded(
              child: _buildMiniStat(
                'Pendientes',
                '${report.pendingEvaluations}',
                'evaluaciones',
                boldFont,
                regularFont,
              ),
            ),
            _verticalDivider(),
            pw.Expanded(
              child: _buildMiniStat(
                'Completitud',
                '${completionRate.toStringAsFixed(0)}%',
                _getCompletionLabel(completionRate),
                boldFont,
                regularFont,
              ),
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 20),

      // ── Tabla de preguntas ──
      pw.Text(
        'Distribución de Respuestas por Pregunta',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 13,
          color: _PdfPalette.textPrimary,
        ),
      ),
      pw.SizedBox(height: 12),

      ...report.questions.map((q) => _buildQuestionBlock(
            q,
            boldFont,
            semiBoldFont,
            regularFont,
          )),
    ];
  }

  static pw.Widget _buildQuestionBlock(
    QuestionResponseData q,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    final scoreColor = _getScorePdfColor(q.average);
    final totalResponses = q.responses.values.fold(0, (a, b) => a + b);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        color: _PdfPalette.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _PdfPalette.border, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header pregunta
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: PdfColor(
                  scoreColor.red, scoreColor.green, scoreColor.blue, 0.08),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: scoreColor,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    '#${q.number}',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 9,
                      color: _PdfPalette.white,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        q.category,
                        style: pw.TextStyle(
                          font: semiBoldFont,
                          fontSize: 9,
                          color: scoreColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        q.text,
                        style: pw.TextStyle(
                          font: semiBoldFont,
                          fontSize: 10,
                          color: _PdfPalette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColor(scoreColor.red, scoreColor.green,
                        scoreColor.blue, 0.15),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(
                        color: PdfColor(scoreColor.red, scoreColor.green,
                            scoreColor.blue, 0.4),
                        width: 1),
                  ),
                  child: pw.Text(
                    q.average.toStringAsFixed(1),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barras de respuesta
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              children: [
                // Barra de progreso global
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.ClipRRect(
                        horizontalRadius: 3,
                        verticalRadius: 3,
                        child: pw.LinearProgressIndicator(
                          value: q.average / 5,
                          backgroundColor: _PdfPalette.border,
                          valueColor: scoreColor,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      '$totalResponses resp.',
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                        color: _PdfPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),

                // Distribución compacta (5 valores)
                pw.Row(
                  children: [5, 4, 3, 2, 1].map((val) {
                    final count = q.responses[val] ?? 0;
                    final pct = totalResponses > 0
                        ? (count / totalResponses)
                        : 0.0;
                    final scaleColor = _getScalePdfColor(val);
                    final label = _getScaleLabel(val);
                    return pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 6),
                        child: pw.Column(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  label,
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 8,
                                    color: scaleColor,
                                  ),
                                ),
                                pw.Text(
                                  '${(pct * 100).toStringAsFixed(0)}%',
                                  style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 7,
                                    color: _PdfPalette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 3),
                            pw.ClipRRect(
                              horizontalRadius: 2,
                              verticalRadius: 2,
                              child: pw.LinearProgressIndicator(
                                value: pct,
                                backgroundColor: _PdfPalette.border,
                                valueColor: scaleColor,
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECCIÓN MATERIAS ====================

  static List<pw.Widget> _buildSubjectsSection(
    List<SubjectData> subjects,
    String careerName,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    return [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          color: _pdfColor(const Color(0xFFEFF6FF)),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(
              color: _pdfColor(const Color(0xFFBFDBFE)), width: 1),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              'Carrera: ',
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: _pdfColor(const Color(0xFF3B82F6))),
            ),
            pw.Text(
              careerName,
              style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 11,
                  color: _PdfPalette.textPrimary),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),

      // Tabla de materias
      pw.Table(
        border: pw.TableBorder.all(color: _PdfPalette.border, width: 1),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(1.5),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1),
          4: const pw.FlexColumnWidth(1),
          5: const pw.FlexColumnWidth(1.5),
        },
        children: [
          // Header
          pw.TableRow(
            decoration: pw.BoxDecoration(color: _PdfPalette.primary),
            children: [
              _tableHeader('Materia', boldFont),
              _tableHeader('Código', boldFont),
              _tableHeader('Total', boldFont),
              _tableHeader('Evaluados', boldFont),
              _tableHeader('Pendientes', boldFont),
              _tableHeader('Progreso', boldFont),
            ],
          ),
          // Filas
          ...subjects.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final completionRate =
                s.students > 0 ? (s.completed / s.students) * 100 : 0.0;
            final bg =
                i.isEven ? _PdfPalette.white : _PdfPalette.bgLight;
            return pw.TableRow(
              decoration: pw.BoxDecoration(color: bg),
              children: [
                _tableCell(s.name, regularFont, bold: true),
                _tableCell(s.code, regularFont),
                _tableCell('${s.students}', regularFont,
                    align: pw.TextAlign.center),
                _tableCell('${s.completed}', regularFont,
                    align: pw.TextAlign.center,
                    color: _PdfPalette.excellent),
                _tableCell('${s.pending}', regularFont,
                    align: pw.TextAlign.center,
                    color: s.pending > 0
                        ? _pdfColor(const Color(0xFFF59E0B))
                        : _PdfPalette.textSecondary),
                _buildProgressCell(completionRate, boldFont, regularFont),
              ],
            );
          }),
        ],
      ),

      pw.SizedBox(height: 20),

      // Resumen de materias
      _buildSubjectsSummary(subjects, boldFont, semiBoldFont, regularFont),
    ];
  }

  static pw.Widget _buildSubjectsSummary(
    List<SubjectData> subjects,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    final totalStudents = subjects.fold(0, (s, sub) => s + sub.students);
    final totalCompleted = subjects.fold(0, (s, sub) => s + sub.completed);
    final totalPending = subjects.fold(0, (s, sub) => s + sub.pending);
    final overallRate =
        totalStudents > 0 ? (totalCompleted / totalStudents) * 100 : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _PdfPalette.bgLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _PdfPalette.border, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumen Global de Evaluación',
            style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
                color: _PdfPalette.textPrimary),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                  child: _buildMiniStat('Total Estudiantes',
                      '$totalStudents', '', boldFont, regularFont,
                      color: _pdfColor(const Color(0xFF3B82F6)))),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: _buildMiniStat('Evaluaciones Completadas',
                      '$totalCompleted', '', boldFont, regularFont,
                      color: _PdfPalette.excellent)),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: _buildMiniStat('Evaluaciones Pendientes',
                      '$totalPending', '', boldFont, regularFont,
                      color: _pdfColor(const Color(0xFFF59E0B)))),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: _buildMiniStat('Tasa Global',
                      '${overallRate.toStringAsFixed(1)}%', '', boldFont,
                      regularFont,
                      color: _getScorePdfColor(overallRate / 20))),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SECCIÓN IA ====================

  static List<pw.Widget> _buildAISection(
    AIInsights insights,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    return [
      // Perfil
      pw.Container(
        padding: const pw.EdgeInsets.all(18),
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [
              _pdfColor(const Color(0xFF9C27B0)),
              _pdfColor(const Color(0xFF7B1FA2)),
            ],
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
                color: _PdfPalette.white,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              insights.profile,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 11,
                color: PdfColor(1, 1, 1, 0.9),
                lineSpacing: 3,
              ),
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 16),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Fortalezas
          pw.Expanded(
            child: _buildInsightCard(
              'Fortalezas',
              insights.strengths,
              _PdfPalette.excellent,
              boldFont,
              regularFont,
            ),
          ),
          pw.SizedBox(width: 12),
          // Oportunidades de mejora
          pw.Expanded(
            child: _buildInsightCard(
              'Oportunidades de Mejora',
              insights.improvements,
              _pdfColor(const Color(0xFFF59E0B)),
              boldFont,
              regularFont,
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 16),

      // Recomendaciones
      _buildRecommendationsCard(
          insights.recommendations, boldFont, semiBoldFont, regularFont),
    ];
  }

  static pw.Widget _buildInsightCard(
    String title,
    List<String> items,
    PdfColor color,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _PdfPalette.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _PdfPalette.border, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 16,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                  color: _PdfPalette.textPrimary,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 6,
                    height: 6,
                    margin: const pw.EdgeInsets.only(top: 3, right: 8),
                    decoration: pw.BoxDecoration(
                      color: color,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 10,
                        color: _PdfPalette.textPrimary,
                        lineSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRecommendationsCard(
    List<String> recommendations,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    final color = _pdfColor(const Color(0xFF2196F3));
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _PdfPalette.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _PdfPalette.border, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 16,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Recomendaciones',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                  color: _PdfPalette.textPrimary,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          ...recommendations.asMap().entries.map(
            (entry) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 22,
                    height: 22,
                    decoration: pw.BoxDecoration(
                      color: color,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${entry.key + 1}',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 9,
                          color: _PdfPalette.white,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        entry.value,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 10,
                          color: _PdfPalette.textPrimary,
                          lineSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECCIÓN COMENTARIOS ====================

  static List<pw.Widget> _buildCommentsSection(
    List<CommentReport> comments,
    pw.Font boldFont,
    pw.Font semiBoldFont,
    pw.Font regularFont,
  ) {
    final positive = comments.where((c) => c.sentiment == 'positive').length;
    final neutral = comments.where((c) => c.sentiment == 'neutral').length;
    final negative = comments.where((c) => c.sentiment == 'negative').length;
    final satisfactionRate = comments.isEmpty
        ? 0.0
        : ((positive + (neutral * 0.5)) / comments.length) * 100;

    return [
      // Resumen de sentimientos
      pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: _PdfPalette.bgLight,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: _PdfPalette.border, width: 1),
        ),
        child: pw.Row(
          children: [
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
                        color: _PdfPalette.textPrimary),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '${satisfactionRate.toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 28,
                        color: _getScorePdfColor(satisfactionRate / 20),
                        height: 1),
                  ),
                  pw.Text(
                    _getSatisfactionLabel(satisfactionRate),
                    style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 10,
                        color: _PdfPalette.textSecondary),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              flex: 3,
              child: pw.Row(
                children: [
                  pw.Expanded(
                      child: _buildSentimentStat(
                          'Positivos', positive, _PdfPalette.positive,
                          boldFont, regularFont)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                      child: _buildSentimentStat(
                          'Neutrales', neutral, _PdfPalette.neutral,
                          boldFont, regularFont)),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                      child: _buildSentimentStat(
                          'Negativos', negative, _PdfPalette.negative,
                          boldFont, regularFont)),
                ],
              ),
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 16),

      // Comentarios agrupados por sentimiento
      ...['positive', 'neutral', 'negative'].expand((sentiment) {
        final filtered =
            comments.where((c) => c.sentiment == sentiment).toList();
        if (filtered.isEmpty) return <pw.Widget>[];
        return [
          _buildCommentGroupHeader(sentiment, filtered.length, boldFont),
          pw.SizedBox(height: 8),
          ...filtered.map((c) =>
              _buildCommentCard(c, boldFont, regularFont)),
          pw.SizedBox(height: 12),
        ];
      }),
    ];
  }

  static pw.Widget _buildSentimentStat(
    String label,
    int count,
    PdfColor color,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color:
            PdfColor(color.red, color.green, color.blue, 0.1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(
            color: PdfColor(color.red, color.green, color.blue, 0.25),
            width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '$count',
            style: pw.TextStyle(
                font: boldFont, fontSize: 20, color: color, height: 1),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            label,
            style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: PdfColor(
                    color.red, color.green, color.blue, 0.8)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCommentGroupHeader(
    String sentiment,
    int count,
    pw.Font boldFont,
  ) {
    final config = _getSentimentPdfConfig(sentiment);
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColor((config['color'] as PdfColor).red,
            (config['color'] as PdfColor).green,
            (config['color'] as PdfColor).blue, 0.1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(
            color: PdfColor((config['color'] as PdfColor).red,
                (config['color'] as PdfColor).green,
                (config['color'] as PdfColor).blue, 0.3),
            width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            config['label'] as String,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 11,
              color: config['color'] as PdfColor,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            '$count comentarios',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 9,
              color: config['color'] as PdfColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCommentCard(
    CommentReport comment,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    final config = _getSentimentPdfConfig(comment.sentiment);
    final color = config['color'] as PdfColor;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _PdfPalette.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
        border: pw.Border.all(color: _PdfPalette.border, width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 3,
            height: 40,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              comment.text,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 10,
                color: _PdfPalette.textPrimary,
                lineSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER / FOOTER DE PÁGINA ====================

  static pw.Widget _buildPageHeader(
    String sectionTitle,
    String teacherName,
    pw.Font boldFont,
    pw.Font semiBoldFont,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_PdfPalette.primary, _PdfPalette.primaryDark],
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
                    color: _PdfPalette.white,
                  ),
                ),
                pw.Text(
                  teacherName,
                  style: pw.TextStyle(
                    font: semiBoldFont,
                    fontSize: 10,
                    color: PdfColor(1, 1, 1, 0.75),
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
              color: PdfColor(1, 1, 1, 0.5),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageFooter(
    pw.Context ctx,
    pw.Font regularFont,
  ) {
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
              color: _PdfPalette.textSecondary,
            ),
          ),
          pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: _PdfPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  static pw.Widget _buildMiniStat(
    String label,
    String value,
    String suffix,
    pw.Font boldFont,
    pw.Font regularFont, {
    PdfColor? color,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 20,
            color: color ?? _PdfPalette.white,
            height: 1,
          ),
        ),
        if (suffix.isNotEmpty)
          pw.Text(
            suffix,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: color != null
                  ? PdfColor(color.red, color.green, color.blue, 0.7)
                  : PdfColor(1, 1, 1, 0.6),
            ),
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 9,
            color: color != null
                ? _PdfPalette.textSecondary
                : PdfColor(1, 1, 1, 0.75),
          ),
        ),
      ],
    );
  }

  static pw.Widget _verticalDivider() {
    return pw.Container(
      width: 1,
      height: 40,
      color: PdfColor(1, 1, 1, 0.3),
      margin: const pw.EdgeInsets.symmetric(horizontal: 8),
    );
  }

  static pw.Widget _tableHeader(String text, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 9,
          color: _PdfPalette.white,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
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
          color: color ?? _PdfPalette.textPrimary,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildProgressCell(
    double rate,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    final color = _getProgressPdfColor(rate);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${rate.toStringAsFixed(0)}%',
            style:
                pw.TextStyle(font: boldFont, fontSize: 9, color: color),
          ),
          pw.SizedBox(height: 3),
          pw.ClipRRect(
            horizontalRadius: 2,
            verticalRadius: 2,
            child: pw.LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: _PdfPalette.border,
              valueColor: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Colores helpers ──

  static PdfColor _getScorePdfColor(double score) {
    if (score >= 4.5) return _PdfPalette.excellent;
    if (score >= 4.0) return _PdfPalette.good;
    if (score >= 3.5) return _PdfPalette.average;
    if (score >= 3.0) return _PdfPalette.belowAverage;
    return _PdfPalette.poor;
  }

  static PdfColor _getProgressPdfColor(double rate) {
    if (rate >= 80) return _PdfPalette.excellent;
    if (rate >= 60) return _PdfPalette.good;
    if (rate >= 40) return _PdfPalette.average;
    if (rate >= 20) return _PdfPalette.belowAverage;
    return _PdfPalette.poor;
  }

  static PdfColor _getScalePdfColor(int val) {
    switch (val) {
      case 5: return _PdfPalette.excellent;
      case 4: return _PdfPalette.good;
      case 3: return _PdfPalette.average;
      case 2: return _PdfPalette.belowAverage;
      default: return _PdfPalette.poor;
    }
  }

  static String _getScaleLabel(int val) {
    switch (val) {
      case 5: return 'S';
      case 4: return 'CS';
      case 3: return 'AV';
      case 2: return 'CN';
      default: return 'N';
    }
  }

  static Map<String, dynamic> _getSentimentPdfConfig(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return {'label': 'Comentarios Positivos', 'color': _PdfPalette.positive};
      case 'negative':
        return {'label': 'Comentarios Negativos', 'color': _PdfPalette.negative};
      default:
        return {'label': 'Comentarios Neutrales', 'color': _PdfPalette.neutral};
    }
  }

  static String _getSatisfactionLabel(double rate) {
    if (rate >= 80) return 'Excelente';
    if (rate >= 60) return 'Bueno';
    if (rate >= 40) return 'Regular';
    if (rate >= 20) return 'Bajo';
    return 'Muy bajo';
  }

  static String _getCompletionLabel(double rate) {
    if (rate >= 90) return 'Completo';
    if (rate >= 70) return 'Avanzado';
    if (rate >= 50) return 'Parcial';
    if (rate >= 30) return 'Bajo';
    return 'Crítico';
  }

  static String _sanitizeFilename(String name) {
    return name
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\-]'), '')
        .substring(0, name.length > 40 ? 40 : name.length);
  }

  static String _formattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}