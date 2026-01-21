/// Tarjeta de docente para análisis (Con animaciones y modal de informe)
/// Ubicación: lib/widgets/admin/analysis/analysis_teacher_card.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/utils/admin/admin_analysis_constants.dart';
import 'package:eval_plus/animations/admin/animated_teacher_expansion.dart';
import 'package:eval_plus/widgets/common/message_dialog_widget.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/teacher_report_modal.dart';

class AnalysisTeacherCard extends StatefulWidget {
  final TeacherData teacher;
  final bool isExpanded;
  final RoleColorPalette palette;
  final VoidCallback onTap;
  final String initials;

  const AnalysisTeacherCard({
    super.key,
    required this.teacher,
    required this.isExpanded,
    required this.palette,
    required this.onTap,
    required this.initials,
  });

  @override
  State<AnalysisTeacherCard> createState() => _AnalysisTeacherCardState();
}

class _AnalysisTeacherCardState extends State<AnalysisTeacherCard> {
  
  // ==================== NAVEGACIÓN ====================
  
  /// Abre el modal de informe completo
  void _openFullReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeacherReportModal(teacher: widget.teacher),
        fullscreenDialog: true,
      ),
    );
  }

  /// Muestra un diálogo indicando que la funcionalidad está en desarrollo
  void _showFeatureInDevelopmentDialog(String feature, String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MessageDialogWidget.info(
        title: '🚧 En Desarrollo',
        message: description,
        onContinue: () => Navigator.of(context).pop(),
        continueButtonText: 'Entendido',
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final statusInfo = AdminAnalysisConstants.getTeacherStatus(widget.teacher.completionRate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AdminAnalysisConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius),
        border: Border.all(
          color: widget.isExpanded ? widget.palette.primary : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isExpanded
                ? widget.palette.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: widget.isExpanded ? 8 : 4,
            offset: Offset(0, widget.isExpanded ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(statusInfo),
          
          // ✨ Animación para el contenido expandido
          AnimatedTeacherExpansion(
            isExpanded: widget.isExpanded,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            expandedContent: Column(
              children: [
                const Divider(height: 1),
                _buildExpandedContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> statusInfo) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: widget.isExpanded
          ? const BorderRadius.only(
              topLeft: Radius.circular(AdminAnalysisConstants.cardBorderRadius),
              topRight: Radius.circular(AdminAnalysisConstants.cardBorderRadius),
            )
          : BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(AdminAnalysisConstants.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: AdminAnalysisConstants.statsCardPadding),
                Expanded(
                  child: _buildTeacherInfo(),
                ),
                
                // ✨ Ícono animado de expansión
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminAnalysisConstants.statsCardPadding),
            _buildProgressBar(),
            const SizedBox(height: AdminAnalysisConstants.paddingSmall),
            _buildStatusBadge(statusInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: AdminAnalysisConstants.avatarSize,
      height: AdminAnalysisConstants.avatarSize,
      decoration: BoxDecoration(
        gradient: widget.palette.avatarGradient,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.avatarBorderRadius),
      ),
      child: Center(
        child: Text(
          widget.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.teacher.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${widget.teacher.totalSubjects} materias • ${widget.teacher.activeEvaluations} activas',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completitud',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${widget.teacher.completionRate}%',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // ✨ Barra de progreso animada
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: widget.teacher.completionRate / 100),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AdminAnalysisConstants.chipBorderRadius),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AdminAnalysisConstants.getCompletionColor(widget.teacher.completionRate),
                ),
                minHeight: AdminAnalysisConstants.progressBarHeight,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusInfo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusInfo['color'],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: statusInfo['borderColor']),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusInfo['icon'], size: AdminAnalysisConstants.iconSizeSmall, color: statusInfo['textColor']),
            const SizedBox(width: 4),
            Text(
              statusInfo['text'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusInfo['textColor'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.all(AdminAnalysisConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactInfo(),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            _buildSubjectsList(),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            _buildQuickStats(),
            const SizedBox(height: AdminAnalysisConstants.paddingMedium),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Row(
      children: [
        const Icon(AdminAnalysisConstants.emailIcon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.teacher.email,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(AdminAnalysisConstants.bookIcon, size: 14),
            SizedBox(width: 6),
            Text('Materias', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AdminAnalysisConstants.paddingSmall),
        ...widget.teacher.subjects.asMap().entries.map((entry) {
          final index = entry.key;
          final subject = entry.value;
          
          // ✨ Animación escalonada para cada materia
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildSubjectItem(subject),
          );
        }),
      ],
    );
  }

  Widget _buildSubjectItem(SubjectData subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminAnalysisConstants.paddingSmall),
      padding: const EdgeInsets.all(AdminAnalysisConstants.statsCardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      subject.code,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AdminAnalysisConstants.chipBorderRadius),
                ),
                child: Text(
                  AdminAnalysisConstants.studentsMessage(subject.students),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminAnalysisConstants.paddingSmall),
          Row(
            children: [
              Text(
                '✓ ${subject.completed} completadas',
                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: AdminAnalysisConstants.paddingMedium),
              Text(
                '⏳ ${subject.pending} pendientes',
                style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(AdminAnalysisConstants.statsCardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(AdminAnalysisConstants.chartIcon, size: 14),
              SizedBox(width: 6),
              Text('Estadísticas rápidas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AdminAnalysisConstants.statsCardPadding),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Evaluaciones:',
                  AdminAnalysisConstants.evaluationsMessage(
                    widget.teacher.activeEvaluations,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Respuestas:',
                  AdminAnalysisConstants.responsesMessage(
                    widget.teacher.completedResponses,
                    widget.teacher.totalStudents,
                    widget.teacher.completionRate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminAnalysisConstants.paddingSmall),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Período actual:', widget.teacher.period),
              ),
              Expanded(
                child: _buildStatItem('Última actividad:', widget.teacher.lastActivity),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openFullReport, // 🔥 Ahora abre el modal
            icon: const Icon(AdminAnalysisConstants.chartIcon, size: 18),
            label: const Text('Ver Informe Completo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.palette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: AdminAnalysisConstants.paddingSmall),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFeatureInDevelopmentDialog(
                  'Enviar Email',
                  'La funcionalidad para enviar emails directamente al docente estará disponible próximamente. '
                  'Podrás contactar a los docentes sin salir de la aplicación.',
                ),
                icon: const Icon(AdminAnalysisConstants.emailIcon, size: AdminAnalysisConstants.iconSizeMedium),
                label: const Text('Email', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AdminAnalysisConstants.paddingSmall),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFeatureInDevelopmentDialog(
                  'Exportar a Excel',
                  'La funcionalidad para exportar datos a Excel estará disponible próximamente. '
                  'Podrás descargar informes detallados en formato XLSX con todas las estadísticas del docente.',
                ),
                icon: const Icon(AdminAnalysisConstants.downloadIcon, size: AdminAnalysisConstants.iconSizeMedium),
                label: const Text('Excel', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AdminAnalysisConstants.paddingSmall),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFeatureInDevelopmentDialog(
                  'Compartir Link',
                  'La funcionalidad para compartir enlaces estará disponible próximamente. '
                  'Podrás generar links para compartir informes con otros administradores de forma segura.',
                ),
                icon: const Icon(AdminAnalysisConstants.shareIcon, size: AdminAnalysisConstants.iconSizeMedium),
                label: const Text('Link', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminAnalysisConstants.buttonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
