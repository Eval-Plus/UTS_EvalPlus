/// Servicio principal de generación del PDF del informe completo del docente.
///
/// Este archivo solo orquesta la composición del documento PDF delegando
/// cada sección a su builder dedicado. No contiene lógica de layout propia.
///
/// Estructura de builders:
///   lib/services/pdf/builder/
///   ├── pdf_palette.dart               ← Colores centralizados
///   ├── pdf_helpers.dart               ← Widgets atómicos reutilizables
///   ├── components/
///   │   ├── page_chrome_builder.dart   ← Header / footer de página
///   │   └── stat_cards_builder.dart    ← Tarjetas de estadísticas
///   └── pages/
///       ├── cover_page_builder.dart    ← Portada
///       ├── responses_page_builder.dart← Respuestas por pregunta
///       ├── subjects_page_builder.dart ← Materias asignadas
///       ├── ai_page_builder.dart       ← Análisis de IA
///       └── comments_page_builder.dart ← Comentarios anónimos
///
/// Ubicación: lib/services/pdf/teacher_report_pdf_service.dart
library;

import 'dart:typed_data';

import 'package:eval_plus/models/admin/teacher_analysis_model.dart';
import 'package:eval_plus/models/admin/teacher_report_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'builder/pdf_helpers.dart';
import 'builder/components/page_chrome_builder.dart';
import 'builder/pages/cover_page_builder.dart';
import 'builder/pages/responses_page_builder.dart';
import 'builder/pages/subjects_page_builder.dart';
import 'builder/pages/ai_page_builder.dart';
import 'builder/pages/comments_page_builder.dart';

class TeacherReportPdfService {
  // ══════════════════════════════════════════════════════════════
  // API PÚBLICA
  // ══════════════════════════════════════════════════════════════

  /// Genera el PDF y lo comparte / guarda mediante el plugin [printing].
  ///
  /// Utiliza los datos ya cargados en memoria: no realiza nuevas llamadas
  /// a la API, por lo que es seguro llamarlo desde la UI.
  static Future<void> generateAndDownload({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required AIInsights aiInsights,
  }) async {
    final bytes = await generateBytes(
      teacher: teacher,
      responsesReport: responsesReport,
      comments: comments,
      aiInsights: aiInsights,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'Informe_${sanitizeFilename(teacher.name)}_${teacher.period}.pdf',
    );
  }

  /// Genera y retorna los bytes del PDF sin descargarlo.
  /// Útil para preview o para tests.
  static Future<Uint8List> generateBytes({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required AIInsights aiInsights,
  }) async {
    return _buildDocument(
      teacher: teacher,
      responsesReport: responsesReport,
      comments: comments,
      aiInsights: aiInsights,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CONSTRUCCIÓN DEL DOCUMENTO
  // ══════════════════════════════════════════════════════════════

  static Future<Uint8List> _buildDocument({
    required TeacherData teacher,
    required TeacherResponsesReport? responsesReport,
    required List<CommentReport> comments,
    required AIInsights aiInsights,
  }) async {
    final doc = pw.Document(
      title: 'Informe Docente - ${teacher.name}',
      author: 'Eval+',
      creator: 'Eval+ App',
      subject:
          'Informe completo de evaluación docente - Período ${teacher.period}',
    );

    // ── Fuentes ──
    final regularFont  = await PdfGoogleFonts.interRegular();
    final boldFont     = await PdfGoogleFonts.interBold();
    final semiBoldFont = await PdfGoogleFonts.interMedium();

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    // ── Portada: construir widget ANTES de addPage (es async) ──
    final coverWidget = await buildCoverPage(
      teacher: teacher,
      responsesReport: responsesReport,
      comments: comments,
      boldFont: boldFont,
      semiBoldFont: semiBoldFont,
      regularFont: regularFont,
    );

    // ── Página 1: Portada ──
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => coverWidget,
      ),
    );

    // ── Página 2: Respuestas por pregunta ──
    if (responsesReport != null && responsesReport.questions.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => buildPageHeader(
            sectionTitle: 'Análisis de Respuestas',
            teacherName: teacher.name,
            boldFont: boldFont,
            semiBoldFont: semiBoldFont,
          ),
          footer: (ctx) => buildPageFooter(ctx, regularFont),
          build: (ctx) => buildResponsesSection(
            report: responsesReport,
            boldFont: boldFont,
            semiBoldFont: semiBoldFont,
            regularFont: regularFont,
          ),
        ),
      );
    }

    // ── Página 3: Materias ──
    if (teacher.subjects.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => buildPageHeader(
            sectionTitle: 'Materias Asignadas',
            teacherName: teacher.name,
            boldFont: boldFont,
            semiBoldFont: semiBoldFont,
          ),
          footer: (ctx) => buildPageFooter(ctx, regularFont),
          build: (ctx) => buildSubjectsSection(
            subjects: teacher.subjects,
            careerName: teacher.careerName,
            boldFont: boldFont,
            semiBoldFont: semiBoldFont,
            regularFont: regularFont,
          ),
        ),
      );
    }

    // ── Página 4: Análisis IA ──
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => buildPageHeader(
          sectionTitle: 'Análisis de Inteligencia Artificial',
          teacherName: teacher.name,
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
        ),
        footer: (ctx) => buildPageFooter(ctx, regularFont),
        build: (ctx) => buildAISection(
          insights: aiInsights,
          boldFont: boldFont,
          semiBoldFont: semiBoldFont,
          regularFont: regularFont,
        ),
      ),
    );

    // ── Página 5: Comentarios ──
    if (comments.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => buildPageHeader(
            sectionTitle: 'Comentarios Anónimos',
            teacherName: teacher.name,
            boldFont: boldFont,
            semiBoldFont: semiBoldFont,
          ),
          footer: (ctx) => buildPageFooter(ctx, regularFont),
          build: (ctx) => buildCommentsSection(
            comments: comments,
            boldFont: boldFont,
            semiBoldFont: semiBoldFont,
            regularFont: regularFont,
          ),
        ),
      );
    }

    return doc.save();
  }
}