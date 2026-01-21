/// Tab de comentarios del reporte
/// Ubicación: lib/widgets/admin/analysis/reports/tabs/comments_tab.dart

import 'package:flutter/material.dart';
import 'package:eval_plus/models/teacher_analysis_model.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_models.dart';
import 'package:eval_plus/widgets/admin/analysis/reports/models/report_constants.dart';

class CommentsTab extends StatefulWidget {
  final List<CommentReport> comments;
  final List<SubjectData> subjects;

  const CommentsTab({
    super.key,
    required this.comments,
    required this.subjects,
  });

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  String _commentFilter = 'all';
  String _subjectFilter = 'all';

  List<CommentReport> get _filteredComments {
    return widget.comments.where((comment) {
      final sentimentMatch = _commentFilter == 'all' || comment.sentiment == _commentFilter;
      final subjectMatch = _subjectFilter == 'all' || comment.subject == _subjectFilter;
      return sentimentMatch && subjectMatch;
    }).toList();
  }

  Map<String, int> get _sentimentCounts {
    return {
      'positive': widget.comments.where((c) => c.sentiment == 'positive').length,
      'neutral': widget.comments.where((c) => c.sentiment == 'neutral').length,
      'negative': widget.comments.where((c) => c.sentiment == 'negative').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        _buildSentimentDistribution(),
        Expanded(
          child: _filteredComments.isEmpty
              ? _buildEmptyState()
              : _buildCommentsList(),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(ReportConstants.filterIcon, size: 16, color: Colors.grey),
              SizedBox(width: ReportConstants.paddingMedium),
              Text(
                ReportConstants.filtersTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: ReportConstants.paddingLarge),
          _buildSentimentFilter(),
          const SizedBox(height: ReportConstants.paddingMedium),
          _buildSubjectFilter(),
        ],
      ),
    );
  }

  Widget _buildSentimentFilter() {
    return DropdownButtonFormField<String>(
      value: _commentFilter,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReportConstants.paddingLarge,
          vertical: ReportConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        ),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text('${ReportConstants.allCommentsLabel} (${widget.comments.length})'),
        ),
        DropdownMenuItem(
          value: 'positive',
          child: Text(
            '${ReportConstants.positiveCommentsLabel} (${_sentimentCounts['positive']})',
          ),
        ),
        DropdownMenuItem(
          value: 'neutral',
          child: Text(
            '${ReportConstants.neutralCommentsLabel} (${_sentimentCounts['neutral']})',
          ),
        ),
        DropdownMenuItem(
          value: 'negative',
          child: Text(
            '${ReportConstants.negativeCommentsLabel} (${_sentimentCounts['negative']})',
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _commentFilter = value!;
        });
      },
    );
  }

  Widget _buildSubjectFilter() {
    return DropdownButtonFormField<String>(
      value: _subjectFilter,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReportConstants.paddingLarge,
          vertical: ReportConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        ),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(
          value: 'all',
          child: Text(ReportConstants.allSubjectsLabel),
        ),
        ...widget.subjects.map((subject) => DropdownMenuItem(
          value: subject.code,
          child: Text(subject.name),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _subjectFilter = value!;
        });
      },
    );
  }

  Widget _buildSentimentDistribution() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReportConstants.paddingXLarge,
        vertical: ReportConstants.paddingLarge,
      ),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildSentimentCard(
              ReportConstants.positiveCommentsLabel,
              _sentimentCounts['positive']!,
              const Color(0xFF4CAF50),
              ReportConstants.positiveIcon,
            ),
          ),
          const SizedBox(width: ReportConstants.paddingMedium),
          Expanded(
            child: _buildSentimentCard(
              ReportConstants.neutralCommentsLabel,
              _sentimentCounts['neutral']!,
              Colors.grey,
              ReportConstants.neutralIcon,
            ),
          ),
          const SizedBox(width: ReportConstants.paddingMedium),
          Expanded(
            child: _buildSentimentCard(
              ReportConstants.negativeCommentsLabel,
              _sentimentCounts['negative']!,
              const Color(0xFFEF4444),
              ReportConstants.negativeIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(ReportConstants.paddingLarge),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: ReportConstants.paddingSmall),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView(
      padding: const EdgeInsets.all(ReportConstants.paddingXLarge),
      children: _filteredComments.map((comment) => _buildCommentCard(comment)).toList(),
    );
  }

  Widget _buildCommentCard(CommentReport comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: ReportConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReportConstants.cardBorderRadius),
        side: BorderSide(color: comment.borderColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReportConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReportConstants.paddingMedium,
                    vertical: ReportConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: comment.chipColor,
                    borderRadius: BorderRadius.circular(ReportConstants.chipBorderRadius),
                  ),
                  child: Text(
                    comment.chipLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: comment.borderColor,
                    ),
                  ),
                ),
                Text(
                  comment.subject,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ReportConstants.paddingMedium),
            Text(
              comment.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ReportConstants.emptyCommentIcon,
              size: ReportConstants.emptyIconSize,
              color: Colors.grey[300],
            ),
            const SizedBox(height: ReportConstants.paddingXLarge),
            Text(
              ReportConstants.emptyCommentsMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
