import 'package:flutter/material.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/themes/font_weight_helper.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/modern_loading_indicator.dart';
import '../../data/models/question.dart';
import '../../data/services/question_service.dart';

class QuestionMembersBottomSheet extends StatefulWidget {
  final String questionId;

  const QuestionMembersBottomSheet({
    super.key,
    required this.questionId,
  });

  @override
  State<QuestionMembersBottomSheet> createState() =>
      _QuestionMembersBottomSheetState();
}

class _QuestionMembersBottomSheetState
    extends State<QuestionMembersBottomSheet> {
  final _questionService = sl<QuestionService>();
  List<QuestionMember>? _members;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await _questionService.getQuestionMembers(widget.questionId);
      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'أعضاء السؤال ${_members != null ? '(${_members!.length})' : ''}',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeightHelper.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: ModernLoadingIndicator(
          message: 'جاري تحميل الأعضاء...',
          type: LoadingType.pulse,
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'فشل في تحميل الأعضاء',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadMembers();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_members == null || _members!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد أعضاء',
              style: context.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _members!.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final member = _members![index];
        return _buildMemberItem(member);
      },
    );
  }

  Widget _buildMemberItem(QuestionMember member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.colors.primaryContainer,
            child: Text(
              member.userName.isNotEmpty
                  ? member.userName[0].toUpperCase()
                  : 'U',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ),
          // Online indicator
          if (member.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              member.userName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeightHelper.semiBold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildRoleBadge(member),
          if (member.isTeacher) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.school,
              size: 16,
              color: context.colors.primary,
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${member.messagesCount} رسالة',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: member.isOnline
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'متصل',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeightHelper.medium,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRoleBadge(QuestionMember member) {
    final String roleText;
    final Color roleColor;

    if (member.isCreator) {
      roleText = 'منشئ';
      roleColor = context.colors.primary;
    } else if (member.isAdmin) {
      roleText = 'مشرف';
      roleColor = Colors.orange;
    } else {
      roleText = 'عضو';
      roleColor = context.colors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: roleColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        roleText,
        style: context.textTheme.bodySmall?.copyWith(
          color: roleColor,
          fontWeight: FontWeightHelper.medium,
          fontSize: 11,
        ),
      ),
    );
  }
}
