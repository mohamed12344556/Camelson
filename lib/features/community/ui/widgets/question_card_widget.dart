import 'package:flutter/material.dart';
import '../../../../core/themes/font_weight_helper.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/question.dart';

class QuestionCardWidget extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const QuestionCardWidget({
    super.key,
    required this.question,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),

                const SizedBox(height: 16),

                // Title
                Text(
                  question.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeightHelper.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  question.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Tags
                if (question.tags.isNotEmpty) ...[
                  _buildTags(context),
                  const SizedBox(height: 16),
                ],

                const Divider(height: 1),
                const SizedBox(height: 12),

                // Footer Stats
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // User Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.secondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              question.creatorName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.creatorName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
              Text(
                _formatTime(question.createdAt),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Pin Badge
        if (question.isPinned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.push_pin_rounded,
                  size: 14,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'مثبت',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.primary,
                    fontWeight: FontWeightHelper.bold,
                  ),
                ),
              ],
            ),
          ),

        // Actions Menu (if any callback provided)
        if (onEdit != null || onDelete != null || onClose != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.colors.onSurfaceVariant,
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              if (onEdit != null)
                _buildPopupMenuItem(
                  context: context,
                  icon: Icons.edit_rounded,
                  title: 'تعديل',
                  value: 'edit',
                ),
              if (onClose != null)
                _buildPopupMenuItem(
                  context: context,
                  icon: Icons.close_rounded,
                  title: 'إغلاق',
                  value: 'close',
                  isDestructive: true,
                ),
              if (onDelete != null)
                _buildPopupMenuItem(
                  context: context,
                  icon: Icons.delete_rounded,
                  title: 'حذف',
                  value: 'delete',
                  isDestructive: true,
                ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'close':
                  onClose?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
          ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : context.colors.onSurface,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? Colors.red : context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: question.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.colors.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: context.colors.secondary,
              fontWeight: FontWeightHelper.medium,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          context,
          icon: Icons.visibility_rounded,
          value: '${question.viewCount}',
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          context,
          icon: Icons.message_rounded,
          value: '${question.messageCount}',
          color: context.colors.primary,
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          context,
          icon: Icons.people_rounded,
          value: '${question.memberCount}',
          color: context.colors.secondary,
        ),
        const Spacer(),

        // Subject Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
          ),
          child: Text(
            question.subjectName,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    }
  }
}
