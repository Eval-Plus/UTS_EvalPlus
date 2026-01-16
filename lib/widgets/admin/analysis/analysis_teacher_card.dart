/// Tarjeta de docente para análisis
/// Ubicación: lib/widgets/admin/analysis_teacher_card.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/config/app_colors.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/utils/admin/admin_analysis_constants.dart';

class AnalysisTeacherCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final statusInfo = AdminAnalysisConstants.getTeacherStatus(teacher.completionRate);

    return Container(
      margin: const EdgeInsets.only(bottom: AdminAnalysisConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.cardBorderRadius),
        border: Border.all(
          color: isExpanded ? palette.primary : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(statusInfo),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> statusInfo) {
    return InkWell(
      onTap: onTap,
      borderRadius: isExpanded
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
                Icon(
                  isExpanded
                      ? AdminAnalysisConstants.expandLessIcon
                      : AdminAnalysisConstants.expandMoreIcon,
                  color: Colors.grey[600],
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
        gradient: palette.avatarGradient,
        borderRadius: BorderRadius.circular(AdminAnalysisConstants.avatarBorderRadius),
      ),
      child: Center(
        child: Text(
          initials,
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
          teacher.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (teacher.career.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.getCareerColor(teacher.career).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AdminAnalysisConstants.chipBorderRadius),
                  border: Border.all(
                    color: AppColors.getCareerColor(teacher.career).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  teacher.career,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(width: AdminAnalysisConstants.paddingSmall),
            Text(
              '${teacher.totalSubjects} materias • ${teacher.activeEvaluations} activas',
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
              '${teacher.completionRate}%',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AdminAnalysisConstants.chipBorderRadius),
          child: LinearProgressIndicator(
            value: teacher.completionRate / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              AdminAnalysisConstants.getCompletionColor(teacher.completionRate),
            ),
            minHeight: AdminAnalysisConstants.progressBarHeight,
          ),
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
            teacher.email,
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
        ...teacher.subjects.map((subject) => _buildSubjectItem(subject)),
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
                    teacher.activeEvaluations,
                    teacher.closedEvaluations,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Respuestas:',
                  AdminAnalysisConstants.responsesMessage(
                    teacher.completedResponses,
                    teacher.totalStudents,
                    teacher.completionRate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminAnalysisConstants.paddingSmall),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Período actual:', teacher.period),
              ),
              Expanded(
                child: _buildStatItem('Última actividad:', teacher.lastActivity),
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
            onPressed: () {
              // TODO: Navegar a informe detallado
            },
            icon: const Icon(AdminAnalysisConstants.chartIcon, size: 18),
            label: const Text('Ver Informe Completo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primary,
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
                onPressed: () {},
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
                onPressed: () {},
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
                onPressed: () {},
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
