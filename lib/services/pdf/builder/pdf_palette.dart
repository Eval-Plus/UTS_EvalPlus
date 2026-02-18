/// Paleta de colores centralizada para el PDF del informe docente.
/// Ubicación: lib/services/pdf/builder/pdf_palette.dart
library;

import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';

/// Convierte un [Color] de Flutter a [PdfColor].
PdfColor toPdfColor(Color c) =>
    PdfColor(c.red / 255, c.green / 255, c.blue / 255);

/// Colores admin (verde) y funcionales usados en todo el PDF.
class PdfPalette {
  PdfPalette._();

  // ── Verdes de marca ──
  static final primary     = toPdfColor(const Color(0xFF4CAF50));
  static final primaryDark = toPdfColor(const Color(0xFF388E3C));
  static final accent      = toPdfColor(const Color(0xFF43A047));

  // ── Semánticos ──
  static final positive    = toPdfColor(const Color(0xFF10B981));
  static final neutral     = toPdfColor(const Color(0xFF6B7280));
  static final negative    = toPdfColor(const Color(0xFFEF4444));

  // ── Escala de calidad ──
  static final excellent   = toPdfColor(const Color(0xFF4CAF50));
  static final good        = toPdfColor(const Color(0xFF8BC34A));
  static final average     = toPdfColor(const Color(0xFFFCD34D));
  static final belowAvg    = toPdfColor(const Color(0xFFF59E0B));
  static final poor        = toPdfColor(const Color(0xFFEF4444));

  // ── Colores extra de UI ──
  static final blue        = toPdfColor(const Color(0xFF3B82F6));
  static final purple      = toPdfColor(const Color(0xFF9C27B0));
  static final purpleDark  = toPdfColor(const Color(0xFF7B1FA2));

  // ── Neutros ──
  static final bgLight     = toPdfColor(const Color(0xFFF9FAFB));
  static final border      = toPdfColor(const Color(0xFFE5E7EB));
  static final textPrimary = toPdfColor(const Color(0xFF1F2937));
  static final textSecond  = toPdfColor(const Color(0xFF6B7280));
  static const white       = PdfColors.white;

  // ── Colores con opacidad ──
  static PdfColor whiteOp(double opacity) => PdfColor(1, 1, 1, opacity);

  // ──────────────────────────────────────────────────
  // Helpers de semántica
  // ──────────────────────────────────────────────────

  /// Elige color según puntuación (escala 0–5).
  static PdfColor forScore(double score) {
    if (score >= 4.5) return excellent;
    if (score >= 4.0) return good;
    if (score >= 3.5) return average;
    if (score >= 3.0) return belowAvg;
    return poor;
  }

  /// Elige color según tasa de progreso (0–100).
  static PdfColor forProgress(double rate) {
    if (rate >= 80) return excellent;
    if (rate >= 60) return good;
    if (rate >= 40) return average;
    if (rate >= 20) return belowAvg;
    return poor;
  }

  /// Elige color según valor de escala Likert (1–5).
  static PdfColor forScale(int val) {
    switch (val) {
      case 5: return excellent;
      case 4: return good;
      case 3: return average;
      case 2: return belowAvg;
      default: return poor;
    }
  }

  /// Elige color según sentimiento textual.
  static PdfColor forSentiment(String sentiment) {
    switch (sentiment) {
      case 'positive': return positive;
      case 'negative': return negative;
      default:         return neutral;
    }
  }
}