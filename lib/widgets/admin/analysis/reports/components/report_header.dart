/// Header del modal de reporte (con botón de descarga PDF)
/// Ubicación: lib/widgets/admin/analysis/reports/components/report_header.dart
library;

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class ReportHeader extends StatelessWidget {
  final String teacherName;
  final VoidCallback onClose;

  /// Callback invocado al pulsar el botón de descarga PDF.
  /// Si es null, el botón no se muestra.
  final VoidCallback? onDownloadPdf;

  /// Si true, muestra un spinner en lugar del ícono de descarga
  /// (útil mientras se genera el PDF).
  final bool isGeneratingPdf;

  const ReportHeader({
    super.key,
    required this.teacherName,
    required this.onClose,
    this.onDownloadPdf,
    this.isGeneratingPdf = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPaletteForRole(UserRole.admin);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
        child: Row(
          children: [
            // ── Ícono del reporte ──
            Container(
              width: ReportConstants.headerIconSize,
              height: ReportConstants.headerIconSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  ReportConstants.headerIconContainerSize,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                ReportConstants.reportIcon,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: ReportConstants.paddingLarge),

            // ── Títulos ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ReportConstants.modalTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    teacherName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Botón de descarga PDF ──
            if (onDownloadPdf != null) ...[
              _DownloadPdfButton(
                onTap: isGeneratingPdf ? null : onDownloadPdf,
                isGenerating: isGeneratingPdf,
              ),
              const SizedBox(width: 4),
            ],

            // ── Botón cerrar ──
            IconButton(
              onPressed: onClose,
              tooltip: 'Cerrar',
              icon: const Icon(
                ReportConstants.closeIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón de descarga con estado de carga integrado.
class _DownloadPdfButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isGenerating;

  const _DownloadPdfButton({
    required this.onTap,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isGenerating ? 'Generando PDF...' : 'Descargar informe en PDF',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isGenerating ? 0.1 : 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono / spinner
                SizedBox(
                  width: 18,
                  height: 18,
                  child: isGenerating
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
                const SizedBox(width: 6),
                Text(
                  isGenerating ? 'Generando...' : 'PDF',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}